//! AMD PSP (Platform Security Processor) directory parsing.
//!
//! Supports:
//! - Combo/L1 directories ($PSP with 2+ entries pointing to L2 dirs)
//! - L2 PSP directories ($PL2 with firmware entries)
//! - L2 BIOS directories ($BL2 with BIOS component entries)
//!
//! ## Address Modes
//! Directory entry locations use a 64-bit field:
//! - Bit 63 set (mode 2): body location relative to $PL2 base
//! - Bit 62 set (mode 1): SPI flash offset
//! - Neither set (mode 0): direct/relative offset
//!
//! In practice for Rembrandt, mode 2 offsets are relative to the
//! containing $PL2 directory base address.

use anyhow::{Result, bail};
use byteorder::{LittleEndian, ReadBytesExt};
use serde::Serialize;
use std::fmt;
use std::io::Cursor;

// ─── Magic signatures ───

pub const PSP_COOKIE: &[u8; 4] = b"$PSP";
pub const PL2_COOKIE: &[u8; 4] = b"$PL2";
pub const BHD_COOKIE: &[u8; 4] = b"$BHD";
pub const BL2_COOKIE: &[u8; 4] = b"$BL2";

fn is_dir_cookie(tag: &[u8]) -> bool {
    tag == PSP_COOKIE || tag == PL2_COOKIE || tag == BHD_COOKIE || tag == BL2_COOKIE
}

// ─── Firmware entry types ───

/// Known PSP firmware entry types.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize)]
#[repr(u8)]
pub enum FwType {
    PubKey = 0x00,
    PspBl = 0x01,
    FwRecovery = 0x02,
    FwRecoveryAb = 0x03,
    SysDriver = 0x04,
    DbgKey = 0x05,
    Abl0 = 0x07,
    SmuOffChip = 0x08,
    Abl0Ab = 0x09,
    Abl1 = 0x0A,
    Abl1Ab = 0x0B,
    Abl2 = 0x0C,
    Abl3 = 0x0D,
    Abl2Ab = 0x0E,
    Abl3Ab = 0x0F,
    KeyDb = 0x10,
    SmuFw = 0x12,
    DbgUnlock = 0x13,
    SecGasket = 0x15,
    PspTos = 0x1A,
    SecDbg = 0x22,
    Mp2Fw = 0x24,
    AgPcieDriverRestore = 0x25,
    AgesaBl = 0x28,
    Spl = 0x2D,
    L2Dir = 0x30,
    Mp5Fw = 0x31,
    Abl4 = 0x32,
    Abl5 = 0x33,
    Abl6 = 0x34,
    Abl7 = 0x35,
    Sev = 0x39,
    Ikek = 0x3C,
    Drtm = 0x44,
    WarmBootFw = 0x45,
    DxioPhy = 0x47,
    Usb4Dxio = 0x48,
    HwIpCfg = 0x49,
    MicrocodeSmu = 0x4A,
    Apcb = 0x50,
    ApcbBackup = 0x51,
    ApcbSmall = 0x52,
    BiosRtm = 0x54,
    BiosCopy = 0x55,
    PmFw = 0x58,
    MpmFw = 0x5A,
    Smash = 0x5C,
    AblPost = 0x5F,
    BiosDir = 0x60,
    Apob = 0x61,
    ApobNv = 0x62,
    Vbios = 0x63,
    Ucode = 0x64,
    Ucode2 = 0x65,
    Mp2Cfg = 0x66,
    Usb4Fw = 0x67,
    Dxio = 0x68,
    MpioPhy = 0x6A,
    Unknown = 0xFF,
}

impl FwType {
    pub fn from_u8(v: u8) -> Self {
        match v {
            0x00 => Self::PubKey,
            0x01 => Self::PspBl,
            0x02 => Self::FwRecovery,
            0x03 => Self::FwRecoveryAb,
            0x04 => Self::SysDriver,
            0x05 => Self::DbgKey,
            0x07 => Self::Abl0,
            0x08 => Self::SmuOffChip,
            0x09 => Self::Abl0Ab,
            0x0A => Self::Abl1,
            0x0B => Self::Abl1Ab,
            0x0C => Self::Abl2,
            0x0D => Self::Abl3,
            0x0E => Self::Abl2Ab,
            0x0F => Self::Abl3Ab,
            0x10 => Self::KeyDb,
            0x12 => Self::SmuFw,
            0x13 => Self::DbgUnlock,
            0x15 => Self::SecGasket,
            0x1A => Self::PspTos,
            0x22 => Self::SecDbg,
            0x24 => Self::Mp2Fw,
            0x25 => Self::AgPcieDriverRestore,
            0x28 => Self::AgesaBl,
            0x2D => Self::Spl,
            0x30 => Self::L2Dir,
            0x31 => Self::Mp5Fw,
            0x32 => Self::Abl4,
            0x33 => Self::Abl5,
            0x34 => Self::Abl6,
            0x35 => Self::Abl7,
            0x39 => Self::Sev,
            0x3C => Self::Ikek,
            0x44 => Self::Drtm,
            0x45 => Self::WarmBootFw,
            0x47 => Self::DxioPhy,
            0x48 => Self::Usb4Dxio,
            0x49 => Self::HwIpCfg,
            0x4A => Self::MicrocodeSmu,
            0x50 => Self::Apcb,
            0x51 => Self::ApcbBackup,
            0x52 => Self::ApcbSmall,
            0x54 => Self::BiosRtm,
            0x55 => Self::BiosCopy,
            0x58 => Self::PmFw,
            0x5A => Self::MpmFw,
            0x5C => Self::Smash,
            0x5F => Self::AblPost,
            0x60 => Self::BiosDir,
            0x61 => Self::Apob,
            0x62 => Self::ApobNv,
            0x63 => Self::Vbios,
            0x64 => Self::Ucode,
            0x65 => Self::Ucode2,
            0x66 => Self::Mp2Cfg,
            0x67 => Self::Usb4Fw,
            0x68 => Self::Dxio,
            0x6A => Self::MpioPhy,
            _ => Self::Unknown,
        }
    }

    pub fn name(&self) -> &'static str {
        match self {
            Self::PubKey => "PUB_KEY",
            Self::PspBl => "PSP_BL",
            Self::FwRecovery => "FW_REC",
            Self::FwRecoveryAb => "FW_REC_AB",
            Self::SysDriver => "SYS_DRV",
            Self::DbgKey => "DBG_KEY",
            Self::Abl0 => "ABL0",
            Self::SmuOffChip => "SMU_OFF",
            Self::Abl0Ab => "ABL0_AB",
            Self::Abl1 => "ABL1",
            Self::Abl1Ab => "ABL1_AB",
            Self::Abl2 => "ABL2",
            Self::Abl3 => "ABL3",
            Self::Abl2Ab => "ABL2_AB",
            Self::Abl3Ab => "ABL3_AB",
            Self::KeyDb => "KEY_DB",
            Self::SmuFw => "SMU_FW",
            Self::DbgUnlock => "DBG_UNLK",
            Self::SecGasket => "SEC_GASK",
            Self::PspTos => "PSP_TOS",
            Self::SecDbg => "SEC_DBG",
            Self::Mp2Fw => "MP2_FW",
            Self::AgPcieDriverRestore => "AG_PCIE_RST",
            Self::AgesaBl => "AGESA_BL",
            Self::Spl => "SPL",
            Self::L2Dir => "L2_DIR",
            Self::Mp5Fw => "MP5_FW",
            Self::Abl4 => "ABL4",
            Self::Abl5 => "ABL5",
            Self::Abl6 => "ABL6",
            Self::Abl7 => "ABL7",
            Self::Sev => "SEV",
            Self::Ikek => "IKEK",
            Self::Drtm => "DRTM",
            Self::WarmBootFw => "WARM_BOOT",
            Self::DxioPhy => "DXIO_PHY",
            Self::Usb4Dxio => "USB4_DXIO",
            Self::HwIpCfg => "HW_IP_CFG",
            Self::MicrocodeSmu => "MSMU",
            Self::Apcb => "APCB",
            Self::ApcbBackup => "APCB_BK",
            Self::ApcbSmall => "APCB_SM",
            Self::BiosRtm => "BIOS_RTM",
            Self::BiosCopy => "BIOS_CPY",
            Self::PmFw => "PM_FW",
            Self::MpmFw => "MPM_FW",
            Self::Smash => "SMASH",
            Self::AblPost => "ABL_POST",
            Self::BiosDir => "BIOS_DIR",
            Self::Apob => "APOB",
            Self::ApobNv => "APOB_NV",
            Self::Vbios => "VBIOS",
            Self::Ucode => "UCODE",
            Self::Ucode2 => "UCODE2",
            Self::Mp2Cfg => "MP2_CFG",
            Self::Usb4Fw => "USB4_FW",
            Self::Dxio => "DXIO",
            Self::MpioPhy => "MPIO_PHY",
            Self::Unknown => "UNKNOWN",
        }
    }

    /// Returns true if this type is an ABL (AGESA Boot Loader) module.
    pub fn is_abl(&self) -> bool {
        matches!(
            self,
            Self::Abl0
                | Self::Abl0Ab
                | Self::Abl1
                | Self::Abl1Ab
                | Self::Abl2
                | Self::Abl3
                | Self::Abl2Ab
                | Self::Abl3Ab
                | Self::Abl4
                | Self::Abl5
                | Self::Abl6
                | Self::Abl7
                | Self::AblPost
        )
    }

    /// Returns true if this type is USB4-related.
    pub fn is_usb4(&self) -> bool {
        matches!(self, Self::Usb4Dxio | Self::Usb4Fw)
    }
}

impl fmt::Display for FwType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.name())
    }
}

// ─── Address mode ───

/// How to interpret the 64-bit location field in a directory entry.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub enum AddrMode {
    /// Bits [61:0] are a direct/relative offset.
    Direct,
    /// Bit 62 set — SPI flash offset.
    SpiFlash,
    /// Bit 63 set — body location relative to containing directory base.
    DirRelative,
    /// Both bits 62 and 63 set.
    Both,
}

impl AddrMode {
    pub fn from_raw(loc: u64) -> Self {
        match (loc >> 62) & 0x3 {
            0 => Self::Direct,
            1 => Self::SpiFlash,
            2 => Self::DirRelative,
            3 => Self::Both,
            _ => unreachable!(),
        }
    }
}

// ─── Directory entry ───

/// A single entry in a PSP or BIOS directory.
#[derive(Debug, Clone, Serialize)]
pub struct DirEntry {
    /// Raw 32-bit type field (includes sub-type in upper bytes).
    pub raw_type: u32,

    /// Decoded firmware type (lower 8 bits).
    pub fw_type: FwType,

    /// Sub-type / instance (upper 24 bits of raw_type).
    pub sub_type: u32,

    /// Entry body size in bytes.
    pub size: u32,

    /// Raw 64-bit location field.
    pub raw_location: u64,

    /// Decoded address mode.
    pub addr_mode: AddrMode,

    /// Resolved SPI offset (absolute, ready for indexing into flash data).
    pub spi_offset: u32,

    /// Index within the directory.
    pub index: usize,
}

impl DirEntry {
    /// Resolve the absolute SPI offset given the directory's own SPI base.
    pub fn resolve_spi_offset(raw_location: u64, dir_base: u32) -> u32 {
        let mode = AddrMode::from_raw(raw_location);
        let addr = (raw_location & 0x3FFFFFFFFFFFFFFF) as u32;
        match mode {
            AddrMode::DirRelative | AddrMode::Both => dir_base.wrapping_add(addr),
            AddrMode::SpiFlash => addr,
            AddrMode::Direct => addr,
        }
    }

    /// Check if data at this entry's SPI offset is populated (not all 0xFF).
    pub fn has_data(&self, flash: &[u8]) -> bool {
        let off = self.spi_offset as usize;
        let end = (off + 256).min(flash.len());
        if off >= flash.len() {
            return false;
        }
        flash[off..end].iter().any(|&b| b != 0xFF)
    }

    /// Extract the blob data from the flash image.
    pub fn extract<'a>(&self, flash: &'a [u8]) -> Option<&'a [u8]> {
        let off = self.spi_offset as usize;
        let end = off + self.size as usize;
        if end <= flash.len() {
            Some(&flash[off..end])
        } else {
            None
        }
    }
}

// ─── Directory ───

/// A parsed PSP or BIOS directory ($PL2, $BL2, etc.).
#[derive(Debug, Clone, Serialize)]
pub struct Directory {
    /// The 4-byte cookie ("$PSP", "$PL2", "$BHD", "$BL2").
    pub cookie: String,

    /// SPI offset of this directory.
    pub spi_offset: u32,

    /// Number of entries.
    pub entry_count: u32,

    /// Parsed entries.
    pub entries: Vec<DirEntry>,
}

impl Directory {
    /// Parse a directory at the given SPI offset.
    pub fn parse(data: &[u8], spi_offset: u32) -> Result<Self> {
        let off = spi_offset as usize;
        if off + 16 > data.len() {
            bail!("directory offset 0x{spi_offset:06X} out of range");
        }

        let cookie_bytes = &data[off..off + 4];
        if !is_dir_cookie(cookie_bytes) {
            bail!(
                "invalid directory cookie at 0x{:06X}: {:02X?}",
                spi_offset,
                cookie_bytes
            );
        }
        let cookie = String::from_utf8_lossy(cookie_bytes).to_string();

        let mut cur = Cursor::new(&data[off + 4..off + 16]);
        let _checksum = cur.read_u32::<LittleEndian>()?;
        let entry_count = cur.read_u32::<LittleEndian>()?;
        let _reserved = cur.read_u32::<LittleEndian>()?;

        if entry_count > 200 {
            bail!(
                "directory at 0x{spi_offset:06X} has suspicious entry count: {entry_count}"
            );
        }

        let mut entries = Vec::with_capacity(entry_count as usize);
        for i in 0..entry_count as usize {
            let eoff = off + 16 + i * 16;
            if eoff + 16 > data.len() {
                break;
            }

            let mut cur = Cursor::new(&data[eoff..eoff + 16]);
            let raw_type = cur.read_u32::<LittleEndian>()?;
            let size = cur.read_u32::<LittleEndian>()?;
            let raw_location = cur.read_u64::<LittleEndian>()?;

            let fw_type_byte = (raw_type & 0xFF) as u8;
            let fw_type = FwType::from_u8(fw_type_byte);
            let sub_type = raw_type >> 8;
            let addr_mode = AddrMode::from_raw(raw_location);
            let spi_off = DirEntry::resolve_spi_offset(raw_location, spi_offset);

            entries.push(DirEntry {
                raw_type,
                fw_type,
                sub_type,
                size,
                raw_location,
                addr_mode,
                spi_offset: spi_off,
                index: i,
            });
        }

        Ok(Directory {
            cookie,
            spi_offset,
            entry_count,
            entries,
        })
    }

    /// Find all entries of a given firmware type.
    pub fn find_entries(&self, fw_type: FwType) -> Vec<&DirEntry> {
        self.entries
            .iter()
            .filter(|e| e.fw_type == fw_type)
            .collect()
    }

    /// Find the first entry of a given firmware type.
    pub fn find_entry(&self, fw_type: FwType) -> Option<&DirEntry> {
        self.entries.iter().find(|e| e.fw_type == fw_type)
    }
}

// ─── Directory scanner ───

/// Scan an entire flash image for all PSP/BIOS directories.
pub fn scan_directories(data: &[u8], max_offset: usize) -> Vec<Directory> {
    let limit = max_offset.min(data.len());
    let mut dirs = Vec::new();

    // Scan on 4-byte aligned boundaries
    let mut off = 0;
    while off + 16 <= limit {
        if is_dir_cookie(&data[off..off + 4]) {
            let entry_count =
                u32::from_le_bytes(data[off + 8..off + 12].try_into().unwrap_or([0; 4]));
            if entry_count > 0 && entry_count < 200 {
                if let Ok(dir) = Directory::parse(data, off as u32) {
                    dirs.push(dir);
                }
            }
        }
        off += 4;
    }
    dirs
}

// ─── PSP Firmware Header ───

/// PSP firmware blob header ($PS1).
#[derive(Debug, Clone, Serialize)]
pub struct PspFwHeader {
    /// The "$PS1" magic (0x31535024).
    pub magic: u32,

    /// Body size from header.
    pub body_size: u32,

    /// Whether the header magic is valid.
    pub is_valid: bool,
}

impl PspFwHeader {
    pub const MAGIC: u32 = 0x3153_5024; // "$PS1" as LE u32: bytes [24, 50, 53, 31]

    /// Parse a PSP FW header from a blob.
    /// Header starts at +0x10 from the beginning of the entry data.
    pub fn parse(blob: &[u8]) -> Option<Self> {
        if blob.len() < 0x18 {
            return None;
        }
        let magic = u32::from_le_bytes(blob[0x10..0x14].try_into().ok()?);
        let body_size = u32::from_le_bytes(blob[0x14..0x18].try_into().ok()?);
        let is_valid = magic == Self::MAGIC;
        Some(PspFwHeader {
            magic,
            body_size,
            is_valid,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_fw_type_roundtrip() {
        assert_eq!(FwType::from_u8(0x0C), FwType::Abl2);
        assert_eq!(FwType::Abl2.name(), "ABL2");
        assert!(FwType::Abl2.is_abl());
        assert!(!FwType::Abl2.is_usb4());
        assert!(FwType::Usb4Dxio.is_usb4());
    }

    #[test]
    fn test_addr_mode() {
        assert_eq!(AddrMode::from_raw(0x8000000000070900), AddrMode::DirRelative);
        assert_eq!(AddrMode::from_raw(0x4000000000855000), AddrMode::SpiFlash);
        assert_eq!(AddrMode::from_raw(0x000000000000C001), AddrMode::Direct);
    }

    #[test]
    fn test_resolve_offset() {
        // Mode 2 (bit63): base-relative
        let spi = DirEntry::resolve_spi_offset(0x8000000000070900, 0x0C5000);
        assert_eq!(spi, 0x0C5000 + 0x070900);
    }
}
