//! `xtask patch` — Replace a firmware entry in a SPI image.
//!
//! This is the key operation for USB4 enablement:
//! replacing engineering ABL2 with production ABL2 (+ adding ABL_POST).

use anyhow::{Context, Result, bail};
use colored::Colorize;
use spi_image::psp::PspFwHeader;
use spi_image::SpiImage;
use std::fs;

pub fn run(image_path: &str, fw_type_name: &str, blob_path: &str, output_path: &str) -> Result<()> {
    let mut data = fs::read(image_path).with_context(|| format!("reading {image_path}"))?;
    let blob = fs::read(blob_path).with_context(|| format!("reading {blob_path}"))?;
    let img = SpiImage::parse(&data)?;

    let fw_type = super::extract::match_fw_type(fw_type_name)?;

    // Find the primary $PL2 directory
    let pl2 = img.primary_psp_l2()
        .ok_or_else(|| anyhow::anyhow!("no $PL2 directory found"))?;

    let entry = pl2.find_entry(fw_type)
        .ok_or_else(|| anyhow::anyhow!("{} not found in primary $PL2", fw_type_name))?;

    let old_size = entry.size as usize;
    let new_size = blob.len();
    let spi_off = entry.spi_offset as usize;

    println!("{}", "═══ Patch Operation ═══".bright_cyan());
    println!("  Target:    {} @ 0x{:06X}", fw_type_name, spi_off);
    println!("  Old size:  0x{:X} ({} bytes)", old_size, old_size);
    println!("  New size:  0x{:X} ({} bytes)", new_size, new_size);

    if new_size > old_size {
        let overflow = new_size - old_size;
        println!("  {} New blob is {} bytes larger!", "WARNING:".red(), overflow);
        println!("  Checking if space after entry is available (0xFF)...");

        // Check if the overflow region is free (all 0xFF)
        let check_start = spi_off + old_size;
        let check_end = spi_off + new_size;
        if check_end > data.len() {
            bail!("new blob extends beyond image boundary");
        }
        let overflow_data = &data[check_start..check_end];
        let free = overflow_data.iter().all(|&b| b == 0xFF);
        if !free {
            let first_nonff = overflow_data.iter().position(|&b| b != 0xFF)
                .unwrap_or(0);
            bail!(
                "overflow region 0x{:06X}-0x{:06X} is NOT free \
                 (first non-FF at +0x{:X}). Cannot safely expand entry.",
                check_start, check_end, first_nonff
            );
        }
        println!("  {} Overflow region is free (all 0xFF), safe to expand.", "OK:".green());
    }

    // Verify $PS1 header of new blob (if applicable)
    if let Some(hdr) = PspFwHeader::parse(&blob) {
        if hdr.is_valid {
            println!("  New blob has valid $PS1 header (body_size=0x{:X})", hdr.body_size);
        } else {
            println!("  {} New blob header magic: 0x{:08X} (not $PS1)", "NOTE:".yellow(), hdr.magic);
        }
    }

    // Write the new blob
    let write_size = new_size.min(data.len() - spi_off);
    data[spi_off..spi_off + write_size].copy_from_slice(&blob[..write_size]);

    // Update the size field in the $PL2 directory entry
    // Entry is at directory_offset + 16 + entry_index * 16, size is at +4
    let entry_offset = pl2.spi_offset as usize + 16 + entry.index * 16;
    let size_offset = entry_offset + 4;
    if size_offset + 4 <= data.len() {
        let new_size_bytes = (new_size as u32).to_le_bytes();
        data[size_offset..size_offset + 4].copy_from_slice(&new_size_bytes);
        println!("  Updated $PL2 entry size: 0x{:X} → 0x{:X}", old_size, new_size);
    }

    // Also update the backup $PL2 if it exists
    let backup_pl2: Vec<_> = img.directories.iter()
        .filter(|d| d.cookie == "$PL2" && d.spi_offset != pl2.spi_offset)
        .collect();
    for bdir in &backup_pl2 {
        if let Some(bentry) = bdir.find_entry(fw_type) {
            // Write blob to backup too
            let boff = bentry.spi_offset as usize;
            if boff + write_size <= data.len() {
                data[boff..boff + write_size].copy_from_slice(&blob[..write_size]);
            }
            // Update size
            let be_off = bdir.spi_offset as usize + 16 + bentry.index * 16 + 4;
            if be_off + 4 <= data.len() {
                data[be_off..be_off + 4].copy_from_slice(&(new_size as u32).to_le_bytes());
                println!("  Updated backup $PL2 @ 0x{:06X} entry", bdir.spi_offset);
            }
        }
    }

    // Write output
    fs::write(output_path, &data)
        .with_context(|| format!("writing to {output_path}"))?;

    println!("\n  {} Patched image written to {}", "✓".green(), output_path);
    println!("  Total image size: {} bytes", data.len());

    Ok(())
}
