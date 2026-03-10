mod cmd;

use anyhow::Result;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "xtask", about = "AMD SPI flash image analysis toolkit")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Parse and display SPI image structure (EFS, PSP dirs, APCB)
    Info {
        /// Path to SPI flash dump or BIOS FL1 file
        #[arg(short, long)]
        image: String,

        /// Offset to skip (e.g., 0x320 for FL1 capsule header)
        #[arg(long, default_value = "0")]
        skip: String,
    },

    /// Compare two SPI images (engineering vs production)
    Diff {
        /// Path to first (engineering) image
        #[arg(short = 'a', long)]
        eng: String,

        /// Path to second (production) image
        #[arg(short = 'b', long)]
        prod: String,

        /// Skip bytes for production FL1 capsule header
        #[arg(long, default_value = "0")]
        prod_skip: String,
    },

    /// Extract a firmware entry from a SPI image
    Extract {
        /// Path to SPI flash dump
        #[arg(short, long)]
        image: String,

        /// Firmware type to extract (e.g., "ABL2", "ABL_POST", "APCB")
        #[arg(short = 't', long)]
        fw_type: String,

        /// Output file path
        #[arg(short, long)]
        output: String,

        /// Which directory to use (0 = first $PL2, 1 = second, etc.)
        #[arg(short, long, default_value = "0")]
        dir_index: usize,

        /// Offset to skip (e.g., 0x320 for FL1 capsule header)
        #[arg(long, default_value = "0")]
        skip: String,
    },

    /// Patch a firmware entry in a SPI image
    Patch {
        /// Path to base SPI flash image
        #[arg(short, long)]
        image: String,

        /// Firmware type to replace (e.g., "ABL2")
        #[arg(short = 't', long)]
        fw_type: String,

        /// Path to replacement firmware blob
        #[arg(short, long)]
        blob: String,

        /// Output path for patched image
        #[arg(short, long)]
        output: String,
    },

    /// Transplant ABL2 + ABL_POST from production BIOS to engineering SPI
    Transplant {
        /// Path to engineering SPI flash dump
        #[arg(short = 'a', long)]
        eng: String,

        /// Path to production BIOS FL1 file
        #[arg(short = 'b', long)]
        prod: String,

        /// Skip bytes for production FL1 capsule header
        #[arg(long, default_value = "0")]
        prod_skip: String,

        /// Output path for transplanted image
        #[arg(short, long)]
        output: String,
    },
}

fn parse_hex_offset(s: &str) -> usize {
    if let Some(hex) = s.strip_prefix("0x").or_else(|| s.strip_prefix("0X")) {
        usize::from_str_radix(hex, 16).unwrap_or(0)
    } else {
        s.parse().unwrap_or(0)
    }
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Info { image, skip } => {
            let skip = parse_hex_offset(&skip);
            cmd::info::run(&image, skip)
        }
        Commands::Diff {
            eng,
            prod,
            prod_skip,
        } => {
            let prod_skip = parse_hex_offset(&prod_skip);
            cmd::diff::run(&eng, &prod, prod_skip)
        }
        Commands::Extract {
            image,
            fw_type,
            output,
            dir_index,
            skip,
        } => {
            let skip = parse_hex_offset(&skip);
            cmd::extract::run(&image, &fw_type, &output, dir_index, skip)
        }
        Commands::Patch {
            image,
            fw_type,
            blob,
            output,
        } => cmd::patch::run(&image, &fw_type, &blob, &output),
        Commands::Transplant {
            eng,
            prod,
            prod_skip,
            output,
        } => {
            let prod_skip = parse_hex_offset(&prod_skip);
            cmd::transplant::run(&eng, &prod, prod_skip, &output)
        }
    }
}
