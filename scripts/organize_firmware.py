#!/usr/bin/env python3
"""Copy and rename all unique firmware binaries into organized firmware/ subdirectories."""

import shutil
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
Z_DIR = BASE / "Z13Z16刷机包"
FW = BASE / "firmware"

# Create target directories
(FW / "bios").mkdir(exist_ok=True)
(FW / "ec_spi").mkdir(exist_ok=True)
(FW / "vbios").mkdir(exist_ok=True)

def cp(src, dst):
    """Copy file, skip if dst already exists."""
    if dst.exists():
        print(f"  SKIP (exists): {dst.name}")
        return
    shutil.copy2(src, dst)
    print(f"  OK: {dst.name}")


print("=== BIOS SPI (U2101) ===")
bios_map = [
    # (source_path_relative_to_Z_DIR, target_name)
    # Engineering versions (ordered by BIOS ID)
    ("BIOS/1-bios-0.T3-ec-0.26-rev-0.2/u2101.BIN",        "N3GET04T_eng_rev0.2_machine1.bin"),
    ("BIOS/2-bios-0.T3-ec-0.26-rev-0.2/u2101.BIN",        "N3GET04T_eng_rev0.2_machine2.bin"),
    ("BIOS/3-bios-0.05-ec-0.08-rev-0.3/u2101.BIN",        "N3GET05M_eng_rev0.3_ec0.08.bin"),
    ("BIOS/4-bios-0.05-ec-0.07-rev-0.3/U2101.bin",        "N3GET05M_eng_rev0.3_ec0.07.bin"),
    ("BIOS/nm-e161-0.3-不开机/u2101.bin",                    "N3GET05M_eng_rev0.3_nme161_dead.bin"),
    ("BIOS/4-bios-0.06-ec-0.01A-rev-0.2/u2102.BIN",       "N3GET06W_eng_rev0.2_u2102.bin"),
    ("BIOS/1-bios-0.05-ec-0.11-rev-0.3/u2101.bin",        "N3GET09W_eng_rev0.3_ec0.11_dir0.05.bin"),
    ("BIOS/4-bios-0.09-ec-0.11-rev-0.3/u2101.bin",        "N3GET09W_eng_rev0.3_ec0.11.bin"),
    ("BIOS/5-bios-0.09-ec-0.11-rev-0.4/U2101.bin",        "N3GET09W_eng_rev0.4_ec0.11.bin"),
    ("BIOS/6-bios-0.1-ec-0.01-rev-0.4/U2101.bin",         "N3GET10M_eng_rev0.4_ec0.01.bin"),
    ("BIOS/rec-0.4/u2101.bin",                              "N3GET10M_eng_rev0.4_recovery.bin"),
    # Note: 3-bios-ec-rev.0.4/u2101-bak.bin is same as N3GET10M above (skip)
    ("BIOS/3-bios-ec-rev.0.4/bios 74M25J U2101 工程版不亮机的bk.bin", "N3GET10M_eng_rev0.4_dead.bin"),
    ("BIOS/5-bios-0.1-ec-0.12-rev-0.3/u2101.BIN",        "N3GET10W_eng_rev0.3_ec0.12.bin"),
    # Official versions
    ("BIOS/7-bios=1.02-ec-0.-rec-0.4/u2101.bin",          "N3GET21W_v1.02_rev0.4_7.bin"),
    ("BIOS/bios-1.02/U2101.BIN",                           "N3GET21W_v1.02_rev0.4.bin"),
    ("BIOS/bios-1.02/NM-E161.BIN",                         "N3GET42W_v1.02_nme161_full.bin"),
    ("BIOS/bios-1.64-ec-1.64-rec-0.4/U2101-TEST-1.64.bin","N3GET64W_v1.64_rev0.4_test.bin"),
    ("BIOS/bios-1.64-ec-1.64-rec-0.4/U2101.bin",          "N3GET64W_v1.64_rev0.4.bin"),
    # Note: bios-1.65/U2101.bin is identical to bios-1.64/U2101.bin (skip)
    ("Z13-0.4-1.66-BIOS.bin",                              "N3GET66W_v1.66_rev0.4.bin"),
]

for src_rel, dst_name in bios_map:
    src = Z_DIR / src_rel
    if not src.exists():
        print(f"  MISSING: {src_rel}")
        continue
    cp(src, FW / "bios" / dst_name)


print("\n=== EC SPI (U8505) ===")
ec_spi_map = [
    ("BIOS/1-bios-0.T3-ec-0.26-rev-0.2/u8505.BIN",        "EC0.26_eng_rev0.2_machine1.bin"),
    ("BIOS/2-bios-0.T3-ec-0.26-rev-0.2/u8505.BIN",        "EC0.26_eng_rev0.2_machine2.bin"),
    ("BIOS/3-bios-0.05-ec-0.08-rev-0.3/u8505.BIN",        "EC0.08_eng_rev0.3.bin"),
    ("BIOS/4-bios-0.05-ec-0.07-rev-0.3/U8505.bin",        "EC0.07_eng_rev0.3.bin"),
    # Note: nm-e161-不开机/u8505 is same hash as EC0.07 (skip)
    ("BIOS/3-bios-ec-rev.0.4/U8505 25Q256J BK.bin",       "EC_eng_rev0.4_25q256j_bk.bin"),
    ("BIOS/ec-0.11-rev-0.2/u8505.bin",                     "EC0.11_eng_rev0.2.bin"),
    # Note: 4-bios-0.09-ec-0.11/u8505 + 7-bios=1.02/U8505 are same hash as EC0.11 above (skip)
    ("BIOS/5-bios-0.09-ec-0.11-rev-0.4/U8505.bin",        "EC0.11_eng_rev0.4.bin"),
    ("BIOS/6-bios-0.1-ec-0.01-rev-0.4/U8505.bin",         "EC0.01_eng_rev0.4.bin"),
    # Note: 3-bios-ec-rev.0.4/u8505-bak is same hash (skip)
    ("BIOS/5-bios-0.1-ec-0.12-rev-0.3/u8505.BIN",         "N3GHT12W_EC0.12_eng_rev0.3.bin"),
    ("BIOS/rec-0.4/U8505.bin",                             "EC_eng_rev0.4_recovery.bin"),
    # Official
    ("BIOS/bios-1.02/U8505.BIN",                           "N3GHT25W_v1.02.bin"),
    ("BIOS/bios-1.64-ec-1.64-rec-0.4/U8505.bin",          "N3GHT64W_v1.64.bin"),
    # Note: U8505-TEST-1.64 and bios-1.65/U8505 are same hash (skip)
]

for src_rel, dst_name in ec_spi_map:
    src = Z_DIR / src_rel
    if not src.exists():
        print(f"  MISSING: {src_rel}")
        continue
    cp(src, FW / "ec_spi" / dst_name)


print("\n=== Standalone EC FW ===")
# ec-test-1.64.bin (320KB)
src = Z_DIR / "BIOS/bios-1.64-ec-1.64-rec-0.4/ec-test-1.64.bin"
if src.exists():
    cp(src, FW / "ec" / "N3GHT64W_v1.64_standalone.bin")


print("\n=== VBIOS ===")
src = Z_DIR / "1_z16-rx6500m-vbios/vbios.rom"
if src.exists():
    cp(src, FW / "vbios" / "RX6500M_028_094773.rom")


print("\n=== 用户自己机器 (Z13 21D2) ===")
# BIOS preflash backup
src = BASE / "build" / "fresh_backup_preflash_20260310.bin"
if src.exists():
    cp(src, FW / "bios" / "N3GET04W_z13_own_preflash_20260310.bin")

# BIOS from chinafix
src = FW / "BIOS from chinafix.bin"
if src.exists():
    cp(src, FW / "bios" / "N3GET47W_z13_own_chinafix.bin")

# EC SPI dump
src = FW / "spi_dump" / "ec_spi_read_20260313_104036.bin"
if src.exists():
    cp(src, FW / "ec_spi" / "N3GHT15W_z13_own_20260313.bin")


print("\n=== Done ===")
# Count results
bios_count = len(list((FW / "bios").glob("*.bin")))
ec_spi_count = len(list((FW / "ec_spi").glob("*.bin")))
ec_count = len(list((FW / "ec").glob("*")))
vbios_count = len(list((FW / "vbios").glob("*")))
print(f"firmware/bios/: {bios_count} files")
print(f"firmware/ec_spi/: {ec_spi_count} files")
print(f"firmware/ec/: {ec_count} files")
print(f"firmware/vbios/: {vbios_count} files")
