//! `xtask transplant` — Transplant ABL2 + ABL_POST from production BIOS to engineering SPI.
//!
//! This is the main operation for USB4 enablement:
//! 1. Relocate prod ABL2 to free space (since it's 12KB larger)
//! 2. Inject prod ABL_POST (entirely new module, 393KB)
//! 3. Update both primary and backup $PL2 directories
//!
//! ## Address layout
//! DirRelative offsets are relative to $PL2 base.
//! Using the SAME relative offset for both primary/backup $PL2 works because
//! free space at matching relative offsets exists in both directory regions.

use anyhow::{Context, Result, bail};
use colored::Colorize;
use spi_image::psp::{AddrMode, Directory, FwType, PspFwHeader};
use spi_image::SpiImage;
use std::fs;

/// Alignment for placed firmware blobs (4KB boundary).
const BLOB_ALIGN: u32 = 0x1000;

pub fn run(eng_path: &str, prod_path: &str, prod_skip: usize, output_path: &str) -> Result<()> {
    let mut eng_data = fs::read(eng_path).with_context(|| format!("reading {eng_path}"))?;
    let prod_raw = fs::read(prod_path).with_context(|| format!("reading {prod_path}"))?;
    let prod_data = &prod_raw[prod_skip..];

    let eng_img = SpiImage::parse(&eng_data).context("parsing engineering image")?;
    let prod_img = SpiImage::parse(prod_data).context("parsing production image")?;

    println!("{}", "═══ ABL Transplant Operation ═══".bright_cyan());

    // ── Step 1: Verify root public key match ──
    let eng_pl2 = eng_img.primary_psp_l2()
        .ok_or_else(|| anyhow::anyhow!("no $PL2 in engineering image"))?;
    let prod_pl2 = prod_img.primary_psp_l2()
        .ok_or_else(|| anyhow::anyhow!("no $PL2 in production image"))?;

    let eng_pk = eng_pl2.find_entry(FwType::PubKey)
        .ok_or_else(|| anyhow::anyhow!("no PUB_KEY in engineering $PL2"))?;
    let prod_pk = prod_pl2.find_entry(FwType::PubKey)
        .ok_or_else(|| anyhow::anyhow!("no PUB_KEY in production $PL2"))?;

    let eng_pk_blob = eng_pk.extract(&eng_data)
        .ok_or_else(|| anyhow::anyhow!("cannot read engineering PUB_KEY"))?;
    let prod_pk_blob = prod_pk.extract(prod_data)
        .ok_or_else(|| anyhow::anyhow!("cannot read production PUB_KEY"))?;

    if eng_pk_blob != prod_pk_blob {
        bail!("Root public keys DO NOT MATCH — cannot transplant ABL modules safely!");
    }
    println!("  {} Root public key match verified", "✓".green());

    // ── Step 2: Get source blobs from production ──
    let prod_abl2 = prod_pl2.find_entry(FwType::Abl2)
        .ok_or_else(|| anyhow::anyhow!("no ABL2 in production image"))?;
    let prod_abl_post = prod_pl2.find_entry(FwType::AblPost)
        .ok_or_else(|| anyhow::anyhow!("no ABL_POST in production image"))?;

    let abl2_blob = prod_abl2.extract(prod_data)
        .ok_or_else(|| anyhow::anyhow!("cannot read production ABL2"))?
        .to_vec();
    let abl_post_blob = prod_abl_post.extract(prod_data)
        .ok_or_else(|| anyhow::anyhow!("cannot read production ABL_POST"))?
        .to_vec();

    println!("  Source ABL2:     {} bytes (from production)", abl2_blob.len());
    println!("  Source ABL_POST: {} bytes (from production)", abl_post_blob.len());

    // Verify $PS1 header on ABL2
    if let Some(hdr) = PspFwHeader::parse(&abl2_blob) {
        if hdr.is_valid {
            println!("  ABL2 $PS1 header: {} (body_size=0x{:X})", "valid".green(), hdr.body_size);
        } else {
            println!("  {} ABL2 header magic: 0x{:08X} (not $PS1)", "WARN:".yellow(), hdr.magic);
        }
    }

    // ── Step 3: Find all $PL2 directories (primary + backup) ──
    let pl2_dirs: Vec<&Directory> = eng_img.directories.iter()
        .filter(|d| d.cookie == "$PL2")
        .collect();

    if pl2_dirs.is_empty() {
        bail!("no $PL2 directories found in engineering image");
    }

    println!("\n  Found {} $PL2 directories:", pl2_dirs.len());
    for d in &pl2_dirs {
        println!("    $PL2 @ 0x{:06X} ({} entries)", d.spi_offset, d.entry_count);
    }

    // ── Step 4: Calculate placement ──
    // Use DirRelative addressing: relative offset from $PL2 base.
    // We need to find a free region large enough for both ABL2+ABL_POST
    // that exists at the same relative offset from ALL $PL2 directories.
    let total_needed = align_up(abl2_blob.len() as u32, BLOB_ALIGN)
        + align_up(abl_post_blob.len() as u32, BLOB_ALIGN);

    println!("\n{}", "── Placement Planning ──".bright_yellow());
    println!("  Total space needed: 0x{:X} ({} KB)", total_needed, total_needed / 1024);

    // Scan for a free region that works for ALL $PL2 directories
    let (abl2_rel_offset, abl_post_rel_offset) = find_common_free_region(
        &eng_data, &pl2_dirs, abl2_blob.len(), abl_post_blob.len()
    )?;

    let primary_base = pl2_dirs[0].spi_offset;
    let abl2_spi_primary = primary_base + abl2_rel_offset;
    let abl_post_spi_primary = primary_base + abl_post_rel_offset;

    // Show old ABL2 info
    if let Some(eng_abl2) = pl2_dirs[0].find_entry(FwType::Abl2) {
        println!("  Old ABL2 relative offset: 0x{:06X} (size 0x{:X})",
            eng_abl2.spi_offset - primary_base, eng_abl2.size);
    }
    println!("  New ABL2 relative offset: 0x{:06X} (SPI: 0x{:06X})", abl2_rel_offset, abl2_spi_primary);
    println!("  New ABL_POST relative offset: 0x{:06X} (SPI: 0x{:06X})", abl_post_rel_offset, abl_post_spi_primary);

    // ── Step 5: Verify free space for ALL $PL2 directories ──
    println!("\n{}", "── Free Space Verification ──".bright_yellow());
    for dir in &pl2_dirs {
        let base = dir.spi_offset;

        // Check ABL2 placement
        let abl2_spi = base + abl2_rel_offset;
        let abl2_end = abl2_spi + abl2_blob.len() as u32;
        verify_free_region(&eng_data, abl2_spi as usize, abl2_blob.len(),
            &format!("ABL2 for $PL2@0x{:06X}", base))?;

        // Check ABL_POST placement
        let abl_post_spi = base + abl_post_rel_offset;
        verify_free_region(&eng_data, abl_post_spi as usize, abl_post_blob.len(),
            &format!("ABL_POST for $PL2@0x{:06X}", base))?;

        println!("  {} $PL2@0x{:06X}: ABL2@0x{:06X}-0x{:06X}, ABL_POST@0x{:06X}-0x{:06X}",
            "✓".green(), base,
            abl2_spi, abl2_end,
            abl_post_spi, abl_post_spi + abl_post_blob.len() as u32);
    }

    // ── Step 6: Write blobs to all locations ──
    println!("\n{}", "── Writing Firmware Blobs ──".bright_yellow());
    for dir in &pl2_dirs {
        let base = dir.spi_offset;

        // Write ABL2
        let abl2_spi = (base + abl2_rel_offset) as usize;
        eng_data[abl2_spi..abl2_spi + abl2_blob.len()].copy_from_slice(&abl2_blob);
        println!("  Wrote ABL2 ({} bytes) @ 0x{:06X} for $PL2@0x{:06X}",
            abl2_blob.len(), abl2_spi, base);

        // Write ABL_POST
        let abl_post_spi = (base + abl_post_rel_offset) as usize;
        eng_data[abl_post_spi..abl_post_spi + abl_post_blob.len()].copy_from_slice(&abl_post_blob);
        println!("  Wrote ABL_POST ({} bytes) @ 0x{:06X} for $PL2@0x{:06X}",
            abl_post_blob.len(), abl_post_spi, base);
    }

    // ── Step 7: Update $PL2 directory entries ──
    println!("\n{}", "── Updating Directory Entries ──".bright_yellow());

    // Encode the DirRelative location (bit 63 set + relative offset)
    let abl2_location: u64 = 0x8000_0000_0000_0000 | (abl2_rel_offset as u64);
    let abl_post_location: u64 = 0x8000_0000_0000_0000 | (abl_post_rel_offset as u64);
    let abl2_new_size = abl2_blob.len() as u32;
    let abl_post_size = abl_post_blob.len() as u32;

    for dir in &pl2_dirs {
        let base = dir.spi_offset as usize;

        // Update ABL2 entry: modify existing entry's size and location
        if let Some(abl2_entry) = dir.find_entry(FwType::Abl2) {
            let entry_offset = base + 16 + abl2_entry.index * 16;
            // size at +4, location at +8
            write_u32_le(&mut eng_data, entry_offset + 4, abl2_new_size);
            write_u64_le(&mut eng_data, entry_offset + 8, abl2_location);
            println!("  $PL2@0x{:06X} ABL2[{}]: size=0x{:X} loc=0x{:016X}",
                base, abl2_entry.index, abl2_new_size, abl2_location);
        }

        // Add ABL_POST entry: append new entry at end of directory
        let old_count = dir.entry_count;
        let new_entry_offset = base + 16 + (old_count as usize) * 16;

        // Verify the slot is free
        if new_entry_offset + 16 > eng_data.len() {
            bail!("directory entry slot extends beyond image");
        }
        let slot = &eng_data[new_entry_offset..new_entry_offset + 16];
        if !slot.iter().all(|&b| b == 0xFF || b == 0x00) {
            bail!("new entry slot at 0x{:06X} is not free (contains data)", new_entry_offset);
        }

        // Write new ABL_POST entry: type(4) + size(4) + location(8)
        let abl_post_raw_type: u32 = FwType::AblPost as u32;  // 0x5F
        write_u32_le(&mut eng_data, new_entry_offset, abl_post_raw_type);
        write_u32_le(&mut eng_data, new_entry_offset + 4, abl_post_size);
        write_u64_le(&mut eng_data, new_entry_offset + 8, abl_post_location);

        // Increment entry count (at base + 8)
        let new_count = old_count + 1;
        write_u32_le(&mut eng_data, base + 8, new_count);

        println!("  $PL2@0x{:06X}: added ABL_POST entry[{}], count {} → {}",
            base, old_count, old_count, new_count);
    }

    // ── Step 8: Zero out old ABL2 data (optional cleanup) ──
    println!("\n{}", "── Cleanup ──".bright_yellow());
    for dir in &pl2_dirs {
        if let Some(abl2_entry) = dir.find_entry(FwType::Abl2) {
            let old_off = abl2_entry.spi_offset as usize;
            let old_size = abl2_entry.size as usize;
            let old_end = old_off + old_size;
            if old_end <= eng_data.len() {
                // Fill old location with 0xFF
                eng_data[old_off..old_end].fill(0xFF);
                println!("  Zeroed old ABL2 @ 0x{:06X} ({} bytes) for $PL2@0x{:06X}",
                    old_off, old_size, dir.spi_offset);
            }
        }
    }

    // ── Step 9: Verify the patched image ──
    println!("\n{}", "── Verification ──".bright_yellow());
    let verify_img = SpiImage::parse(&eng_data).context("re-parsing patched image")?;
    if let Some(vpl2) = verify_img.primary_psp_l2() {
        let has_abl2 = vpl2.find_entry(FwType::Abl2).is_some();
        let has_abl_post = vpl2.find_entry(FwType::AblPost).is_some();
        let abl2_entry = vpl2.find_entry(FwType::Abl2);
        let abl_post_entry = vpl2.find_entry(FwType::AblPost);

        println!("  $PL2 entry count: {}", vpl2.entry_count);
        println!("  ABL2:     {} (size=0x{:X})",
            if has_abl2 { "present".green().to_string() } else { "MISSING".red().to_string() },
            abl2_entry.map(|e| e.size).unwrap_or(0));
        println!("  ABL_POST: {} (size=0x{:X})",
            if has_abl_post { "present".green().to_string() } else { "MISSING".red().to_string() },
            abl_post_entry.map(|e| e.size).unwrap_or(0));

        // Verify data at new ABL2 location
        if let Some(e) = abl2_entry {
            if e.has_data(&eng_data) {
                println!("  ABL2 data @ 0x{:06X}: {}", e.spi_offset, "populated ✓".green());
                // Verify $PS1 header
                if let Some(blob) = e.extract(&eng_data) {
                    if let Some(hdr) = PspFwHeader::parse(blob) {
                        if hdr.is_valid {
                            println!("  ABL2 $PS1 header: {} (body_size=0x{:X})", "valid ✓".green(), hdr.body_size);
                        }
                    }
                }
            } else {
                println!("  ABL2 data: {}", "EMPTY (all 0xFF) ✗".red());
            }
        }

        if let Some(e) = abl_post_entry {
            if e.has_data(&eng_data) {
                println!("  ABL_POST data @ 0x{:06X}: {}", e.spi_offset, "populated ✓".green());
            } else {
                println!("  ABL_POST data: {}", "EMPTY (all 0xFF) ✗".red());
            }
        }
    }

    // ── Step 10: Write output ──
    fs::write(output_path, &eng_data)
        .with_context(|| format!("writing to {output_path}"))?;

    println!("\n  {} Transplanted image written to {}", "✓".green(), output_path);
    println!("  Total image size: {} bytes", eng_data.len());

    Ok(())
}

fn align_up(value: u32, alignment: u32) -> u32 {
    (value + alignment - 1) & !(alignment - 1)
}

/// Find a free region at a common relative offset from all $PL2 directories.
/// Returns (abl2_rel_offset, abl_post_rel_offset).
fn find_common_free_region(
    data: &[u8],
    pl2_dirs: &[&Directory],
    abl2_size: usize,
    abl_post_size: usize,
) -> Result<(u32, u32)> {
    let abl2_aligned = align_up(abl2_size as u32, BLOB_ALIGN);
    let abl_post_aligned = align_up(abl_post_size as u32, BLOB_ALIGN);
    let total_needed = abl2_aligned + abl_post_aligned;

    // Scan relative offsets (4KB aligned) looking for a range that's free
    // across ALL $PL2 directories.
    // Start from 0x1000 (skip the directory header area) up to ~4MB relative.
    let max_rel = 0x400000_u32; // 4MB max relative offset

    for rel_start in (0x1000..max_rel).step_by(BLOB_ALIGN as usize) {
        let rel_end = rel_start + total_needed;

        // Check that this range is free for ALL $PL2 directories
        let mut all_free = true;
        for dir in pl2_dirs {
            let spi_start = dir.spi_offset + rel_start;
            let spi_end = dir.spi_offset + rel_end;
            if spi_end as usize > data.len() {
                all_free = false;
                break;
            }

            // Check if this region overlaps with any existing entry
            let mut overlaps_entry = false;
            for entry in &dir.entries {
                if entry.addr_mode == AddrMode::DirRelative || entry.addr_mode == AddrMode::Both {
                    let e_start = entry.spi_offset;
                    let e_end = e_start + entry.size.max(256); // at least 256 bytes for small entries
                    if spi_start < e_end && spi_end as u32 > e_start {
                        overlaps_entry = true;
                        break;
                    }
                }
            }
            if overlaps_entry {
                all_free = false;
                break;
            }

            // Verify the SPI region is actually 0xFF
            let region = &data[spi_start as usize..spi_end as usize];
            if !region.iter().all(|&b| b == 0xFF) {
                all_free = false;
                break;
            }
        }

        if all_free {
            let abl2_rel = rel_start;
            let abl_post_rel = rel_start + abl2_aligned;
            println!("  Found common free region at relative +0x{:06X} ({} KB available)",
                rel_start, total_needed / 1024);
            return Ok((abl2_rel, abl_post_rel));
        }
    }

    bail!("no common free region found for ABL2 ({} bytes) + ABL_POST ({} bytes) \
           across {} $PL2 directories",
        abl2_size, abl_post_size, pl2_dirs.len());
}

fn verify_free_region(data: &[u8], offset: usize, size: usize, label: &str) -> Result<()> {
    let end = offset + size;
    if end > data.len() {
        bail!("{label}: region 0x{offset:06X}-0x{end:06X} extends beyond image");
    }
    let region = &data[offset..end];
    if !region.iter().all(|&b| b == 0xFF) {
        let first_nonff = region.iter().position(|&b| b != 0xFF).unwrap_or(0);
        bail!("{label}: region 0x{offset:06X}-0x{end:06X} is NOT free \
               (first non-FF byte at +0x{first_nonff:X})");
    }
    Ok(())
}

fn write_u32_le(data: &mut [u8], offset: usize, value: u32) {
    let bytes = value.to_le_bytes();
    data[offset..offset + 4].copy_from_slice(&bytes);
}

fn write_u64_le(data: &mut [u8], offset: usize, value: u64) {
    let bytes = value.to_le_bytes();
    data[offset..offset + 8].copy_from_slice(&bytes);
}
