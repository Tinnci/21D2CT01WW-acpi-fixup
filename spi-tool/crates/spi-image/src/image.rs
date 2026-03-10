//! High-level SPI flash image representation.
//!
//! Ties together EFS, PSP directories, and APCB structures into
//! a unified view of the firmware image.

use crate::apcb::{self, ApcbRegion};
use crate::efs::Efs;
use crate::psp::{self, Directory, FwType};
use anyhow::{Context, Result};
use serde::Serialize;

/// A parsed SPI flash image.
#[derive(Debug, Serialize)]
pub struct SpiImage {
    /// Raw image size.
    pub size: usize,

    /// Embedded Firmware Structure.
    pub efs: Efs,

    /// All discovered PSP/BIOS directories.
    pub directories: Vec<Directory>,

    /// APCB regions found via PSP directory references.
    pub apcb_regions: Vec<ApcbRegion>,
}

impl SpiImage {
    /// Parse a SPI flash image from raw bytes.
    pub fn parse(data: &[u8]) -> Result<Self> {
        let efs = Efs::find(data).context("locating Embedded Firmware Structure")?;

        // Scan for all directories in the first 16MB region
        let directories = psp::scan_directories(data, 0x0100_0000);

        // Find APCB entries from PSP L2 directories
        let mut apcb_refs = Vec::new();
        for dir in &directories {
            for entry in &dir.entries {
                if matches!(
                    entry.fw_type,
                    FwType::Apcb | FwType::ApcbBackup | FwType::ApcbSmall
                ) {
                    apcb_refs.push((entry.spi_offset, entry.size));
                }
            }
        }
        let apcb_regions = apcb::find_apcb_regions(data, &apcb_refs);

        Ok(SpiImage {
            size: data.len(),
            efs,
            directories,
            apcb_regions,
        })
    }

    /// Get the primary PSP L2 directory ($PL2), if found.
    pub fn primary_psp_l2(&self) -> Option<&Directory> {
        self.directories
            .iter()
            .find(|d| d.cookie == "$PL2")
    }

    /// Get the primary BIOS L2 directory ($BL2), if found.
    pub fn primary_bios_l2(&self) -> Option<&Directory> {
        self.directories
            .iter()
            .find(|d| d.cookie == "$BL2")
    }

    /// Summary of firmware entry counts by type.
    pub fn entry_summary(&self) -> Vec<(String, usize)> {
        let mut counts = std::collections::BTreeMap::new();
        for dir in &self.directories {
            for entry in &dir.entries {
                *counts.entry(entry.fw_type.name().to_string()).or_insert(0) += 1;
            }
        }
        counts.into_iter().collect()
    }
}
