//! AMD Embedded Firmware Structure (EFS) parsing.
//!
//! The EFS is located at a fixed offset in the SPI flash (typically 0x020000)
//! and contains pointers to PSP and BIOS directory structures.

use anyhow::{Context, Result, bail};
use byteorder::{LittleEndian, ReadBytesExt};
use serde::Serialize;
use std::io::{Cursor, Read};

/// Known EFS locations to probe in a 32MB SPI flash.
pub const EFS_PROBE_OFFSETS: &[u32] = &[0x020000, 0x040000, 0x820000, 0x840000];

/// EFS signature: `AA 55 AA 55`.
pub const EFS_SIGNATURE: u32 = 0x55AA55AA;

/// Embedded Firmware Structure — the root of all PSP/BIOS firmware references.
#[derive(Debug, Clone, Serialize)]
pub struct Efs {
    /// SPI offset where this EFS was found.
    pub offset: u32,

    /// Raw signature (should be 0x55AA55AA).
    pub signature: u32,

    /// Pointer to the PSP combo/L1 directory.
    pub psp_dir_ptr: u32,

    /// Pointer to the BIOS combo/L1 directory (if present).
    pub bios_dir_ptr: u32,

    /// Second PSP directory pointer (for A/B scheme).
    pub psp_dir_ptr_b: u32,
}

impl Efs {
    /// Try to find and parse the EFS from a SPI flash image.
    pub fn find(data: &[u8]) -> Result<Self> {
        for &probe in EFS_PROBE_OFFSETS {
            let off = probe as usize;
            if off + 64 > data.len() {
                continue;
            }
            let sig = u32::from_le_bytes(data[off..off + 4].try_into().unwrap());
            if sig == EFS_SIGNATURE {
                return Self::parse(data, probe);
            }
        }
        bail!("EFS signature (AA55AA55) not found at any known offset");
    }

    fn parse(data: &[u8], offset: u32) -> Result<Self> {
        let off = offset as usize;
        let mut cur = Cursor::new(&data[off..off + 64]);

        let signature = cur.read_u32::<LittleEndian>()?;

        // Skip to PSP directory pointer at +0x14
        let mut _skip = [0u8; 0x10];
        cur.read_exact(&mut _skip)
            .context("reading EFS padding")?;
        let psp_dir_ptr = cur.read_u32::<LittleEndian>()?;

        // BIOS dir at +0x20
        let mut _skip2 = [0u8; 8];
        cur.read_exact(&mut _skip2)?;
        let bios_dir_ptr = cur.read_u32::<LittleEndian>()?;

        // Second PSP dir at +0x24 (or same location)
        let psp_dir_ptr_b = cur.read_u32::<LittleEndian>().unwrap_or(0);

        Ok(Efs {
            offset,
            signature,
            psp_dir_ptr,
            bios_dir_ptr,
            psp_dir_ptr_b,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_efs_signature() {
        assert_eq!(EFS_SIGNATURE, 0x55AA55AA);
        let bytes = EFS_SIGNATURE.to_le_bytes();
        assert_eq!(bytes, [0xAA, 0x55, 0xAA, 0x55]);
    }
}
