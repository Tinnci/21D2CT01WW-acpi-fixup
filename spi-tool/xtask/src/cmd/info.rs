//! `xtask info` — Display SPI image structure.

use anyhow::{Context, Result};
use colored::Colorize;
use spi_image::psp::FwType;
use spi_image::SpiImage;
use std::fs;

pub fn run(path: &str, skip: usize) -> Result<()> {
    let raw = fs::read(path).with_context(|| format!("reading {path}"))?;
    let data = &raw[skip..];
    let img = SpiImage::parse(data)?;

    // ── EFS ──
    println!("{}", "═══ Embedded Firmware Structure ═══".bright_cyan());
    println!("  Image size:    {} bytes ({:.1} MB)", img.size, img.size as f64 / 1048576.0);
    println!("  EFS offset:    0x{:06X}", img.efs.offset);
    println!("  PSP dir ptr:   0x{:06X}", img.efs.psp_dir_ptr);
    println!("  BIOS dir ptr:  0x{:06X}", img.efs.bios_dir_ptr);

    // ── Directories ──
    println!("\n{}", "═══ PSP/BIOS Directories ═══".bright_cyan());
    for dir in &img.directories {
        println!("\n  {} @ 0x{:06X} ({} entries)",
            dir.cookie.bright_yellow(), dir.spi_offset, dir.entry_count);
        for entry in &dir.entries {
            let name = entry.fw_type.name();
            let marker = if entry.fw_type.is_usb4() {
                " ★ USB4".bright_magenta().to_string()
            } else if entry.fw_type.is_abl() {
                " [ABL]".bright_green().to_string()
            } else if matches!(entry.fw_type, FwType::Apcb | FwType::ApcbBackup | FwType::ApcbSmall) {
                " [APCB]".bright_blue().to_string()
            } else if matches!(entry.fw_type, FwType::DxioPhy | FwType::Dxio | FwType::MpioPhy) {
                " [DXIO]".yellow().to_string()
            } else {
                String::new()
            };

            let has_data = if entry.has_data(data) { "●" } else { "○" };

            println!("    [{:2}] {has_data} {:<12} type=0x{:08X} sz=0x{:06X} @0x{:06X} {:?}{}",
                entry.index,
                name,
                entry.raw_type,
                entry.size,
                entry.spi_offset,
                entry.addr_mode,
                marker
            );
        }
    }

    // ── APCB ──
    if !img.apcb_regions.is_empty() {
        println!("\n{}", "═══ APCB Regions ═══".bright_cyan());
        for region in &img.apcb_regions {
            let checksum = if region.checksum_ok {
                "✓".green().to_string()
            } else {
                "✗".red().to_string()
            };
            println!("  @0x{:06X} size=0x{:06X} ver={} board=0x{:08X} cksum=0x{:02X} {}",
                region.spi_offset,
                region.size,
                region.header.version,
                region.header.unique_apcb_instance,
                region.header.checksum_byte,
                checksum
            );
        }
    }

    // ── Summary ──
    println!("\n{}", "═══ Summary ═══".bright_cyan());
    let psp_l2 = img.primary_psp_l2();
    if let Some(d) = psp_l2 {
        let abl_count = d.entries.iter().filter(|e| e.fw_type.is_abl()).count();
        let usb4_count = d.entries.iter().filter(|e| e.fw_type.is_usb4()).count();
        let has_abl_post = d.find_entry(FwType::AblPost).is_some();
        println!("  PSP L2 entries: {}", d.entry_count);
        println!("  ABL modules:    {}", abl_count);
        println!("  USB4 modules:   {}", if usb4_count > 0 {
            format!("{usb4_count}").green().to_string()
        } else {
            "0 (MISSING)".red().to_string()
        });
        println!("  ABL_POST:       {}", if has_abl_post {
            "present".green().to_string()
        } else {
            "MISSING".red().to_string()
        });
    }

    Ok(())
}
