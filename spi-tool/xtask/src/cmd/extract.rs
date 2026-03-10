//! `xtask extract` — Extract a firmware entry from a SPI image.

use anyhow::{Context, Result, bail};
use spi_image::psp::FwType;
use spi_image::SpiImage;
use std::fs;

pub fn run(image_path: &str, fw_type_name: &str, output_path: &str, dir_index: usize, skip: usize) -> Result<()> {
    let raw = fs::read(image_path).with_context(|| format!("reading {image_path}"))?;
    let data = &raw[skip..];
    let img = SpiImage::parse(data)?;

    let fw_type = match_fw_type(fw_type_name)?;

    // Find the right directory
    let pl2_dirs: Vec<_> = img.directories.iter()
        .filter(|d| d.cookie == "$PL2")
        .collect();

    if pl2_dirs.is_empty() {
        bail!("no $PL2 directories found in image");
    }

    let dir = pl2_dirs.get(dir_index)
        .ok_or_else(|| anyhow::anyhow!("directory index {dir_index} out of range (found {})", pl2_dirs.len()))?;

    let entry = dir.find_entry(fw_type)
        .ok_or_else(|| anyhow::anyhow!("{} not found in $PL2[{dir_index}]", fw_type_name))?;

    let blob = entry.extract(&data)
        .ok_or_else(|| anyhow::anyhow!("entry @0x{:06X} size 0x{:X} extends beyond image", entry.spi_offset, entry.size))?;

    fs::write(output_path, blob)
        .with_context(|| format!("writing to {output_path}"))?;

    println!("Extracted {} from $PL2[{dir_index}] → {} ({} bytes)",
        fw_type_name, output_path, blob.len());

    Ok(())
}

pub fn match_fw_type(name: &str) -> Result<FwType> {
    let upper = name.to_uppercase();
    Ok(match upper.as_str() {
        "ABL0" => FwType::Abl0,
        "ABL1" => FwType::Abl1,
        "ABL2" => FwType::Abl2,
        "ABL3" => FwType::Abl3,
        "ABL4" => FwType::Abl4,
        "ABL5" => FwType::Abl5,
        "ABL6" => FwType::Abl6,
        "ABL7" => FwType::Abl7,
        "ABL_POST" | "ABLPOST" => FwType::AblPost,
        "PSP_BL" | "PSPBL" => FwType::PspBl,
        "SMU_FW" | "SMUFW" => FwType::SmuFw,
        "AGESA_BL" | "AGESABL" => FwType::AgesaBl,
        "DXIO_PHY" | "DXIOPHY" => FwType::DxioPhy,
        "USB4_DXIO" | "USB4DXIO" => FwType::Usb4Dxio,
        "USB4_FW" | "USB4FW" => FwType::Usb4Fw,
        "APCB" => FwType::Apcb,
        "APCB_BK" | "APCBBK" => FwType::ApcbBackup,
        "PUB_KEY" | "PUBKEY" => FwType::PubKey,
        "DXIO" => FwType::Dxio,
        "MPIO_PHY" | "MPIOPHY" => FwType::MpioPhy,
        _ => bail!("unknown firmware type: {name}. Use names like ABL2, ABL_POST, APCB, etc."),
    })
}
