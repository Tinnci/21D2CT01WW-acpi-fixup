#!/usr/bin/env python3
"""Deep diff analysis between BIOS and EC firmware versions."""

import hashlib
import re
from pathlib import Path

FW = Path(__file__).resolve().parent.parent / "firmware"

# Standard AMD 32MB SPI layout (approximate 4MB blocks)
REGIONS = [
    ("EFS+PSP_dir", 0x000000, 0x020000),
    ("PSP_FW",      0x020000, 0x3E0000),
    ("BIOS_low",    0x400000, 0x400000),
    ("BIOS_upper",  0x800000, 0x400000),
    ("NVRAM_vars",  0xC00000, 0x400000),
    ("Upper_4MB",   0x1000000, 0x400000),
    ("Mid_8MB",     0x1400000, 0x800000),
    ("Top_4MB",     0x1C00000, 0x400000),
]
REGION_NAMES = [r[0] for r in REGIONS]


def region_hashes(path):
    """Return dict of region -> (hash12, is_empty) for 32MB SPI dump."""
    data = path.read_bytes()
    if len(data) != 0x2000000:
        return None
    result = {}
    for name, start, sz in REGIONS:
        chunk = data[start:start + sz]
        h = hashlib.sha256(chunk).hexdigest()[:12]
        is_ff = all(b == 0xFF for b in chunk[:4096])
        result[name] = (h, is_ff)
    return result


def print_region_table(items, region_names, name_width=48):
    """Pretty-print a region hash table."""
    print(f"\n{'文件名':<{name_width}} ", end="")
    for rn in region_names:
        print(f"{rn:>14}", end="")
    print()
    print("-" * (name_width + 14 * len(region_names)))
    for name, regions in items:
        short = name[:name_width - 2]
        print(f"{short:<{name_width}} ", end="")
        for rn in region_names:
            h, is_ff = regions[rn]
            print(f"{'[EMPTY]' if is_ff else h[:10]:>14}", end="")
        print()


def main():
    print("=" * 90)
    print("固件版本深度对比分析")
    print("=" * 90)

    # --- BIOS ---
    print("\n" + "=" * 90)
    print("一、BIOS SPI (U2101) 区域级对比")
    print("=" * 90)

    bios_dir = FW / "bios"
    bios_data = {}
    for f in sorted(bios_dir.glob("*.bin")):
        rh = region_hashes(f)
        if rh:
            bios_data[f.stem] = rh

    print_region_table(sorted(bios_data.items()), REGION_NAMES, 50)

    # Adjacent version diff
    print("\n" + "=" * 90)
    print("二、相邻版本差异分析 (BIOS)")
    print("=" * 90)

    ordered = sorted(bios_data.keys())
    for i in range(1, len(ordered)):
        prev, curr = ordered[i - 1], ordered[i]
        diffs = [rn for rn in REGION_NAMES if bios_data[prev][rn][0] != bios_data[curr][rn][0]]
        if diffs:
            print(f"\n  {prev}")
            print(f"  → {curr}")
            print(f"    变化区域: {', '.join(diffs)}")
        else:
            print(f"\n  {prev} == {curr}")

    # --- EC SPI ---
    print("\n" + "=" * 90)
    print("三、EC SPI (U8505) 区域级对比")
    print("=" * 90)

    ec_dir = FW / "ec_spi"
    ec_data = {}
    for f in sorted(ec_dir.glob("*.bin")):
        rh = region_hashes(f)
        if rh:
            ec_data[f.stem] = rh

    print_region_table(sorted(ec_data.items()), REGION_NAMES, 45)

    # --- Standalone EC FW ---
    print("\n" + "=" * 90)
    print("四、独立 EC 固件对比 (320KB)")
    print("=" * 90)

    for f in sorted((FW / "ec").iterdir()):
        if f.name.startswith("."):
            continue
        data = f.read_bytes()
        h = hashlib.sha256(data).hexdigest()[:16]
        versions = sorted(set(m.decode() for m in re.findall(rb"N3GHT\d\dW", data)))
        hdr = data[:16].hex()
        print(f"\n  {f.name}: {f.stat().st_size:,} bytes  SHA256={h}...")
        print(f"    Header: {hdr}")
        if versions:
            print(f"    EC Version: {', '.join(versions)}")

    # --- User machine comparison ---
    print("\n" + "=" * 90)
    print("五、用户Z13机器固件与最新版本对比")
    print("=" * 90)

    pairs = [
        ("BIOS", "N3GET04W_z13_own_preflash_20260310", "N3GET66W_v1.66_rev0.4", bios_data),
        ("BIOS", "N3GET47W_z13_own_chinafix", "N3GET66W_v1.66_rev0.4", bios_data),
        ("EC",   "N3GHT15W_z13_own_20260313", "N3GHT64W_v1.64", ec_data),
    ]
    for label, user_key, latest_key, data_dict in pairs:
        if user_key in data_dict and latest_key in data_dict:
            print(f"\n  {label}: {user_key.split('_')[0]} vs {latest_key.split('_')[0]}:")
            for rn in REGION_NAMES:
                h1, _ = data_dict[user_key][rn]
                h2, _ = data_dict[latest_key][rn]
                status = "相同" if h1 == h2 else "不同 ✗"
                print(f"    {rn:>16}: {status}  ({h1[:10]} → {h2[:10]})")


if __name__ == "__main__":
    main()
