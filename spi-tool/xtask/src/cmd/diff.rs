//! `xtask diff` — Compare two SPI images.

use anyhow::{Context, Result};
use colored::Colorize;
use spi_image::psp::{FwType, PspFwHeader};
use spi_image::SpiImage;
use std::fs;

pub fn run(eng_path: &str, prod_path: &str, prod_skip: usize) -> Result<()> {
    let eng_raw = fs::read(eng_path).with_context(|| format!("reading {eng_path}"))?;
    let prod_raw = fs::read(prod_path).with_context(|| format!("reading {prod_path}"))?;

    let eng_data = &eng_raw[..];
    let prod_data = &prod_raw[prod_skip..];

    let eng = SpiImage::parse(eng_data).context("parsing engineering image")?;
    let prod = SpiImage::parse(prod_data).context("parsing production image")?;

    println!("{}", "═══ PSP Directory Comparison ═══".bright_cyan());

    let eng_l2 = eng.primary_psp_l2();
    let prod_l2 = prod.primary_psp_l2();

    if let (Some(ed), Some(pd)) = (eng_l2, prod_l2) {
        println!("\n  {} entries: ENG={} PROD={}",
            "$PL2".bright_yellow(),
            ed.entry_count,
            pd.entry_count
        );

        // Build maps by (fw_type, sub_type)
        let eng_map: std::collections::HashMap<(u8, u32), &_> = ed.entries.iter()
            .map(|e| (((e.raw_type & 0xFF) as u8, e.sub_type), e))
            .collect();
        let prod_map: std::collections::HashMap<(u8, u32), &_> = pd.entries.iter()
            .map(|e| (((e.raw_type & 0xFF) as u8, e.sub_type), e))
            .collect();

        // All unique keys
        let mut all_keys: Vec<_> = eng_map.keys().chain(prod_map.keys()).copied().collect();
        all_keys.sort();
        all_keys.dedup();

        println!("\n  {:<14} {:>10} {:>10} {:>10} {}", "Type", "ENG Size", "PROD Size", "Δ", "Notes");
        println!("  {}", "─".repeat(70));

        for key in &all_keys {
            let ee = eng_map.get(key);
            let pe = prod_map.get(key);
            let ft = FwType::from_u8(key.0);
            let name = if key.1 > 0 {
                format!("{}_{:03X}", ft.name(), key.1)
            } else {
                ft.name().to_string()
            };

            match (ee, pe) {
                (Some(e), Some(p)) => {
                    let es = e.size as i64;
                    let ps = p.size as i64;
                    let delta = ps - es;
                    let delta_str = if delta > 0 {
                        format!("+0x{:X}", delta).green().to_string()
                    } else if delta < 0 {
                        format!("-0x{:X}", -delta).red().to_string()
                    } else {
                        "=".dimmed().to_string()
                    };

                    let mut notes = Vec::new();
                    if ft.is_abl() { notes.push("[ABL]".bright_green().to_string()); }
                    if ft.is_usb4() { notes.push("★ USB4".bright_magenta().to_string()); }

                    // Check $PS1 headers
                    if let (Some(eb), Some(pb)) = (e.extract(eng_data), p.extract(prod_data)) {
                        if let (Some(eh), Some(ph)) = (PspFwHeader::parse(eb), PspFwHeader::parse(pb)) {
                            if eh.is_valid && ph.is_valid {
                                notes.push("$PS1".dimmed().to_string());
                            }
                        }
                    }

                    println!("  {name:<14} 0x{:06X}   0x{:06X}   {delta_str:<10} {}",
                        e.size, p.size, notes.join(" "));
                }
                (Some(e), None) => {
                    println!("  {name:<14} 0x{:06X}   {}         {}",
                        e.size, "---".dimmed(), "ENG only".red());
                }
                (None, Some(p)) => {
                    let mut notes = vec!["PROD only".bright_green().to_string()];
                    if ft.is_abl() { notes.push("[ABL]".bright_green().to_string()); }
                    if ft.is_usb4() { notes.push("★ USB4".bright_magenta().to_string()); }
                    println!("  {name:<14} {}         0x{:06X}   {}",
                        "---".dimmed(), p.size, notes.join(" "));
                }
                (None, None) => unreachable!(),
            }
        }

        // ── Root key comparison ──
        println!("\n{}", "═══ Root Public Key ═══".bright_cyan());
        let eng_pk = ed.find_entry(FwType::PubKey);
        let prod_pk = pd.find_entry(FwType::PubKey);
        if let (Some(ek), Some(pk)) = (eng_pk, prod_pk) {
            if let (Some(ed_blob), Some(pd_blob)) = (ek.extract(eng_data), pk.extract(prod_data)) {
                if ed_blob == pd_blob {
                    println!("  Root key: {} (ABL replacement feasible!)", "IDENTICAL ✓".green());
                } else {
                    println!("  Root key: {} (ABL replacement BLOCKED)", "DIFFERENT ✗".red());
                }
            }
        }

        // ── ABL_POST check ──
        println!("\n{}", "═══ USB4 Readiness ═══".bright_cyan());
        let eng_post = ed.find_entry(FwType::AblPost);
        let prod_post = pd.find_entry(FwType::AblPost);
        match (eng_post, prod_post) {
            (None, Some(p)) => {
                println!("  ABL_POST: {} in ENG, {} in PROD (0x{:X} bytes)",
                    "MISSING".red(), "present".green(), p.size);
                println!("  → Engineering BIOS lacks post-memory USB4 initialization");
            }
            (Some(_), Some(_)) => {
                println!("  ABL_POST: present in both images");
            }
            _ => {
                println!("  ABL_POST: not found in production (unexpected)");
            }
        }

        // ABL2 USB4 string check
        let eng_abl2 = ed.find_entry(FwType::Abl2);
        let prod_abl2 = pd.find_entry(FwType::Abl2);
        if let (Some(ea), Some(pa)) = (eng_abl2, prod_abl2) {
            let check_usb4_strings = |blob: &[u8]| -> usize {
                blob.windows(4).filter(|w| w == b"USB4").count()
            };
            let eng_usb4 = ea.extract(eng_data).map(check_usb4_strings).unwrap_or(0);
            let prod_usb4 = pa.extract(prod_data).map(check_usb4_strings).unwrap_or(0);
            println!("  ABL2 USB4 refs: ENG={} PROD={}",
                if eng_usb4 > 0 { eng_usb4.to_string().green().to_string() }
                else { "0".red().to_string() },
                if prod_usb4 > 0 { prod_usb4.to_string().green().to_string() }
                else { "0".red().to_string() }
            );
        }
    }

    // ── BIOS directory comparison ──
    println!("\n{}", "═══ BIOS Directory Comparison ═══".bright_cyan());
    let eng_bl2 = eng.primary_bios_l2();
    let prod_bl2 = prod.primary_bios_l2();
    if let (Some(ed), Some(pd)) = (eng_bl2, prod_bl2) {
        println!("  $BL2 entries: ENG={} PROD={}", ed.entry_count, pd.entry_count);
    }

    Ok(())
}
