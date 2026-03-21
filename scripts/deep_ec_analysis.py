#!/usr/bin/env python3
"""Deep EC firmware analysis — locate EC FW regions in SPI dumps and compare versions."""

import hashlib
import re
import struct
from pathlib import Path

FW = Path(__file__).resolve().parent.parent / "firmware"
EC_SPI = FW / "ec_spi"
EC_FW = FW / "ec"

EC_MAGIC = b"\x5f\x45\x43"  # _EC header magic


def find_ec_regions(data):
    """Find EC firmware regions in a 32MB SPI dump by searching for _EC magic."""
    regions = []
    offset = 0
    while True:
        idx = data.find(EC_MAGIC, offset)
        if idx == -1:
            break
        if idx + 16 <= len(data):
            hdr = data[idx:idx+16]
            ver_byte = hdr[3]
            if ver_byte in (0x01, 0x02):
                regions.append({"offset": idx, "header": hdr.hex(), "ver_byte": ver_byte})
        offset = idx + 1
    return regions


def find_lenovo_ec_strings(data):
    """Find Lenovo EC version strings and copyright."""
    results = {}
    matches = re.findall(rb"N3GHT(\d\d)W", data)
    if matches:
        results["ec_versions"] = sorted(set(f"N3GHT{m.decode()}W" for m in matches))

    idx = data.find(b"(C) Copyright IBM")
    if idx >= 0:
        end = data.find(b"\x00", idx)
        if end > idx:
            results["copyright"] = data[idx:min(end, idx+200)].decode("ascii", errors="replace")
        results["copyright_offset"] = idx

    date_matches = re.findall(rb"(\d{4}/\d{2}/\d{2})", data)
    if date_matches:
        results["build_dates"] = sorted(set(m.decode() for m in date_matches))
    return results


def analyze_ec_spi(path, label):
    """Comprehensive EC SPI dump analysis."""
    data = path.read_bytes()
    size = len(data)

    print(f"\n{'='*70}")
    print(f"  {label}")
    print(f"  文件: {path.name}  ({size:,} bytes)")
    print(f"{'='*70}")

    print(f"  SHA256: {hashlib.sha256(data).hexdigest()[:24]}...")

    ec_regions = find_ec_regions(data)
    if ec_regions:
        print(f"\n  找到 {len(ec_regions)} 个 _EC 头部:")
        for i, r in enumerate(ec_regions):
            print(f"    [{i}] offset=0x{r['offset']:06X}  header={r['header']}  ver_byte={r['ver_byte']}")
    else:
        print(f"\n  未找到 _EC 头部")

    strings = find_lenovo_ec_strings(data)
    if "ec_versions" in strings:
        print(f"\n  EC版本: {', '.join(strings['ec_versions'])}")
    if "copyright" in strings:
        print(f"  版权: {strings['copyright'][:80]}")
        print(f"  版权偏移: 0x{strings['copyright_offset']:06X}")
    if "build_dates" in strings:
        print(f"  构建日期: {', '.join(strings['build_dates'])}")

    # Block diversity analysis
    block_size = 0x1000
    empty_ff = 0
    empty_00 = 0
    unique_hashes = set()
    blocks = []

    for off in range(0, min(size, 0x2000000), block_size):
        block = data[off:off+block_size]
        if all(b == 0xFF for b in block):
            empty_ff += 1
            blocks.append(("FF", off))
        elif all(b == 0x00 for b in block):
            empty_00 += 1
            blocks.append(("00", off))
        else:
            h = hashlib.sha256(block).hexdigest()[:8]
            unique_hashes.add(h)
            blocks.append((h, off))

    total_blocks = len(blocks)
    data_blocks = total_blocks - empty_ff - empty_00

    print(f"\n  4KB块统计 (总{total_blocks}块 = {size/(1024*1024):.0f}MB):")
    print(f"    数据块: {data_blocks} ({data_blocks*4}KB)")
    print(f"    空白(FF): {empty_ff} ({empty_ff*4}KB)")
    print(f"    零(00): {empty_00} ({empty_00*4}KB)")
    print(f"    唯一数据块: {len(unique_hashes)}")

    # Map contiguous data regions
    in_data = False
    regions = []
    region_start = 0
    for h, off in blocks:
        if h not in ("FF", "00"):
            if not in_data:
                region_start = off
                in_data = True
        else:
            if in_data:
                regions.append((region_start, off - region_start))
                in_data = False
    if in_data:
        regions.append((region_start, size - region_start))

    print(f"\n  连续数据区域:")
    for start, sz in regions:
        end = start + sz
        rh = hashlib.sha256(data[start:end]).hexdigest()[:12]
        print(f"    0x{start:06X} - 0x{end:06X}  ({sz/1024:.0f}KB)  hash={rh}")

    return {"ec_regions": ec_regions, "strings": strings, "data_regions": regions, "data_blocks": data_blocks}


def compare_ec_fw(fw_files):
    """Compare standalone EC firmware files byte by byte."""
    print(f"\n{'='*70}")
    print("  独立 EC 固件 (320KB) 详细对比")
    print(f"{'='*70}")

    fw_data = {}
    for f in sorted(fw_files):
        if f.name.startswith("."):
            continue
        data = f.read_bytes()
        versions = re.findall(rb"N3GHT(\d\d)W", data)
        ver = f"N3GHT{versions[0].decode()}W" if versions else "unknown"
        fw_data[f.name] = {"data": data, "version": ver}

        print(f"\n  {f.name}  ({len(data):,} bytes)  EC={ver}")
        print(f"    Header (32B): {data[:32].hex()}")
        if data[:3] == EC_MAGIC:
            vb = data[3]
            f1 = struct.unpack_from("<I", data, 4)[0]
            f2 = struct.unpack_from("<I", data, 8)[0]
            f3 = struct.unpack_from("<I", data, 12)[0]
            print(f"    EC Header: ver={vb}  field1=0x{f1:08X} field2=0x{f2:08X} field3=0x{f3:08X}")

    names = sorted(fw_data.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            n1, n2 = names[i], names[j]
            d1, d2 = fw_data[n1]["data"], fw_data[n2]["data"]
            min_len = min(len(d1), len(d2))
            diff_count = sum(1 for a, b in zip(d1[:min_len], d2[:min_len]) if a != b)

            print(f"\n  对比: {fw_data[n1]['version']} vs {fw_data[n2]['version']}")
            print(f"    大小差异: {abs(len(d1) - len(d2))} bytes")
            print(f"    字节差异: {diff_count} / {min_len} ({diff_count/min_len*100:.1f}%)")

            diffs = [(off, d1[off], d2[off]) for off in range(min_len) if d1[off] != d2[off]]
            if diffs:
                print(f"    前10个差异位置:")
                for off, b1, b2 in diffs[:10]:
                    print(f"      0x{off:06X}: {b1:02X} → {b2:02X}")

                # Diff regions
                in_diff = False
                diff_regions = []
                ds = 0
                prev_off = 0
                for off, b1, b2 in diffs:
                    if not in_diff:
                        ds = off
                        in_diff = True
                    elif off > prev_off + 16:
                        diff_regions.append((ds, prev_off - ds + 1))
                        ds = off
                    prev_off = off
                if in_diff:
                    diff_regions.append((ds, prev_off - ds + 1))

                print(f"    差异区间 ({len(diff_regions)}个):")
                for start, sz in diff_regions[:20]:
                    print(f"      0x{start:06X} - 0x{start+sz:06X} ({sz} bytes)")


def main():
    print("=" * 70)
    print("EC 固件深度分析报告")
    print("=" * 70)

    # Analyze EC SPI dumps
    for f in sorted(EC_SPI.glob("*.bin")):
        analyze_ec_spi(f, f.stem)

    # Compare standalone EC FW
    ec_fw_files = [f for f in EC_FW.iterdir() if not f.name.startswith(".")]
    if ec_fw_files:
        compare_ec_fw(ec_fw_files)

    # Cross-reference EC FW in SPI dumps
    print(f"\n{'='*70}")
    print("  EC FW 在 SPI dump 中的位置匹配")
    print(f"{'='*70}")

    spi_files = sorted(EC_SPI.glob("*.bin"))
    for fw_file in sorted(ec_fw_files):
        fw_data = fw_file.read_bytes()
        print(f"\n  查找 {fw_file.name} (前64B)...")
        for spi_file in spi_files:
            spi_data = spi_file.read_bytes()
            idx = spi_data.find(fw_data[:64])
            if idx >= 0:
                match_len = 0
                for k in range(min(len(fw_data), len(spi_data) - idx)):
                    if fw_data[k] == spi_data[idx + k]:
                        match_len += 1
                    else:
                        break
                pct = match_len / len(fw_data) * 100
                print(f"    → {spi_file.name}: 偏移 0x{idx:06X}, 匹配 {match_len}/{len(fw_data)} bytes ({pct:.1f}%)")


if __name__ == "__main__":
    main()
