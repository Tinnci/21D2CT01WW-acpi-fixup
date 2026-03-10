//! APCB (AMD PSP Configuration Block) parsing.
//!
//! APCB contains board-specific configuration including:
//! - GNBG (GNB/IO configuration) with port descriptors
//! - Token entries (USB4_NHI_0, USB4_NHI_1, USB4_CM, etc.)
//! - Board ID and instance masking

use anyhow::{Result, bail};
use byteorder::{LittleEndian, ReadBytesExt};
use serde::Serialize;
use std::io::Cursor;

/// APCB V3 header magic.
pub const APCB_MAGIC: u32 = 0x4342_5041; // "APCB" LE

/// APCB header (first 64 bytes of an APCB blob).
#[derive(Debug, Clone, Serialize)]
pub struct ApcbHeader {
    /// Magic signature.
    pub signature: u32,
    /// Header size.
    pub header_size: u16,
    /// APCB version.
    pub version: u16,
    /// Total APCB size including all groups.
    pub apcb_size: u32,
    /// Unique board ID.
    pub unique_apcb_instance: u32,
    /// Checksum byte.
    pub checksum_byte: u8,
}

impl ApcbHeader {
    pub fn parse(data: &[u8]) -> Result<Self> {
        if data.len() < 32 {
            bail!("APCB data too short: {} bytes", data.len());
        }
        let mut c = Cursor::new(data);
        let signature = c.read_u32::<LittleEndian>()?;
        let header_size = c.read_u16::<LittleEndian>()?;
        let version = c.read_u16::<LittleEndian>()?;
        let apcb_size = c.read_u32::<LittleEndian>()?;
        let unique_apcb_instance = c.read_u32::<LittleEndian>()?;
        let checksum_byte = c.read_u8()?;

        Ok(Self {
            signature,
            header_size,
            version,
            apcb_size,
            unique_apcb_instance,
            checksum_byte,
        })
    }

    pub fn is_valid(&self) -> bool {
        self.signature == APCB_MAGIC
    }
}

/// APCB group header.
#[derive(Debug, Clone, Serialize)]
pub struct ApcbGroupHeader {
    /// Group signature/magic.
    pub signature: u32,
    /// Group ID.
    pub group_id: u16,
    /// Group header size.
    pub header_size: u16,
    /// Group version.
    pub version: u16,
    /// Reserved.
    pub reserved: u16,
    /// Total group size (header + all type entries).
    pub group_size: u32,
}

/// APCB type header (within a group).
#[derive(Debug, Clone, Serialize)]
pub struct ApcbTypeHeader {
    /// Group ID this type belongs to.
    pub group_id: u16,
    /// Type ID.
    pub type_id: u16,
    /// Type header size.
    pub header_size: u16,
    /// Instance ID.
    pub instance_id: u16,
    /// Context type.
    pub context_type: u16,
    /// Context format.
    pub context_format: u16,
    /// Unit size.
    pub unit_size: u32,
    /// Type data size (not including header).
    pub type_size: u32,
    /// Key size.
    pub key_size: u16,
    /// Key position.
    pub key_pos: u16,
    /// Board-specific instance mask.
    pub board_mask: u16,
}

/// Compute APCB checksum (sum of all bytes should be 0).
pub fn compute_checksum(data: &[u8]) -> u8 {
    let sum: u8 = data.iter().fold(0u8, |acc, &b| acc.wrapping_add(b));
    0u8.wrapping_sub(sum)
}

/// Verify APCB checksum.
pub fn verify_checksum(data: &[u8]) -> bool {
    data.iter().fold(0u8, |acc, &b| acc.wrapping_add(b)) == 0
}

/// Scan for APCB instances in a SPI image at known PSP-directory-referenced offsets.
pub fn find_apcb_regions(
    data: &[u8],
    dir_entries: &[(u32, u32)], // (spi_offset, size) pairs
) -> Vec<ApcbRegion> {
    let mut regions = Vec::new();
    for &(offset, size) in dir_entries {
        let off = offset as usize;
        let end = off + size as usize;
        if end > data.len() {
            continue;
        }
        let blob = &data[off..end];
        if let Ok(header) = ApcbHeader::parse(blob) {
            if header.is_valid() {
                let checksum_ok = verify_checksum(blob);
                regions.push(ApcbRegion {
                    spi_offset: offset,
                    size,
                    header,
                    checksum_ok,
                });
            }
        }
    }
    regions
}

/// A located APCB region in the SPI image.
#[derive(Debug, Clone, Serialize)]
pub struct ApcbRegion {
    pub spi_offset: u32,
    pub size: u32,
    pub header: ApcbHeader,
    pub checksum_ok: bool,
}
