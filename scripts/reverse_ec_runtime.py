#!/usr/bin/env python3
"""Reverse engineer the runtime data regions in N3GHT15W EC SPI dump."""

import struct
import hashlib
import re
from collections import Counter
from pathlib import Path

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi" / "N3GHT15W_z13_own_20260313.bin"

def hexdump(data, base_addr, count=512):
    """Print hex dump with ASCII."""
    for i in range(0, min(count, len(data)), 16):
        chunk = data[i:i+16]
        hex_part = ' '.join(f'{b:02x}' for b in chunk)
        ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        print(f'  {base_addr+i:08X}: {hex_part:<48s} |{ascii_part}|')


def find_strings(data, base_addr, min_len=6):
    """Find printable ASCII strings."""
    results = []
    for m in re.finditer(rb'[\x20-\x7e]{' + str(min_len).encode() + rb',}', data):
        s = m.group().decode('ascii', errors='replace')
        results.append((base_addr + m.start(), s))
    return results


def analyze_block_structure(data, base_addr, block_size=0x1000):
    """Analyze block-level structure."""
    blocks = []
    for off in range(0, len(data), block_size):
        blk = data[off:off+block_size]
        h = hashlib.sha256(blk).hexdigest()[:8]
        ff_pct = blk.count(0xFF) / len(blk) * 100
        zero_pct = blk.count(0x00) / len(blk) * 100
        is_ff = ff_pct > 99.9
        is_00 = zero_pct > 99.9
        first4 = blk[:4].hex()
        blocks.append({
            'offset': off,
            'spi_addr': base_addr + off,
            'hash': h,
            'ff_pct': ff_pct,
            'zero_pct': zero_pct,
            'is_empty': is_ff or is_00,
            'first4': first4
        })
    return blocks


def find_record_boundaries(data, base_addr):
    """Try to identify record/entry boundaries by looking for header patterns."""
    # Look for repeating header patterns at regular intervals
    # Check common record sizes: 16, 32, 64, 128, 256, 512
    print("\n  记录边界探测:")
    for rec_size in [8, 16, 32, 64, 128, 256]:
        # Check if data has repeating structure at this interval
        matches = 0
        total = 0
        for off in range(0, len(data) - rec_size * 2, rec_size):
            total += 1
            b1 = data[off]
            b2 = data[off + rec_size]
            if b1 == b2 and b1 != 0xFF and b1 != 0x00:
                matches += 1
        if total > 0:
            ratio = matches / total * 100
            if ratio > 20:
                print(f"    {rec_size}B 对齐: {ratio:.0f}% 首字节重复率 ({matches}/{total})")


def scan_for_timestamps(data, base_addr):
    """Look for potential timestamp values (Unix epoch, BCD dates, etc.)."""
    print("\n  时间戳/日期搜索:")

    # BCD date patterns: YYYY/MM/DD or YYYYMMDD
    for m in re.finditer(rb'20[12][0-9][01][0-9][0-3][0-9]', data):
        val = m.group().decode()
        off = base_addr + m.start()
        print(f"    BCD日期 @ 0x{off:08X}: {val}")

    for m in re.finditer(rb'202[0-9]/[01][0-9]/[0-3][0-9]', data):
        val = m.group().decode()
        off = base_addr + m.start()
        print(f"    ASCII日期 @ 0x{off:08X}: {val}")

    # Unix timestamps around 2022-2026 (0x63000000 - 0x6C000000)
    found_ts = []
    for i in range(0, len(data) - 3, 4):
        val = struct.unpack_from('<I', data, i)[0]
        if 0x63000000 <= val <= 0x6C000000:
            import datetime
            try:
                dt = datetime.datetime.fromtimestamp(val, tz=datetime.timezone.utc)
                if 2022 <= dt.year <= 2026:
                    found_ts.append((base_addr + i, val, dt.strftime('%Y-%m-%d %H:%M')))
            except (OSError, ValueError):
                pass
    if found_ts:
        for off, val, dtstr in found_ts[:30]:
            print(f"    Unix时间戳 @ 0x{off:08X}: 0x{val:08X} = {dtstr}")
    else:
        print("    未找到 Unix 时间戳")


def analyze_entropy_windows(data, base_addr, window=256):
    """Compute entropy per window to find high/low entropy regions."""
    import math
    print(f"\n  熵分析 ({window}B 窗口, 仅显示变化):")
    prev_cat = None
    region_start = 0
    for off in range(0, len(data), window):
        chunk = data[off:off+window]
        if len(chunk) < window:
            break
        counts = Counter(chunk)
        entropy = -sum((c / window) * math.log2(c / window) for c in counts.values() if c > 0)
        if entropy < 0.5:
            cat = "空白/零"
        elif entropy < 3.0:
            cat = "低熵(结构化)"
        elif entropy < 6.0:
            cat = "中熵(数据)"
        else:
            cat = "高熵(压缩/加密)"

        if cat != prev_cat:
            if prev_cat is not None:
                print(f"    0x{base_addr+region_start:08X} - 0x{base_addr+off:08X} ({(off-region_start)/1024:.1f}KB): {prev_cat}")
            region_start = off
            prev_cat = cat
    if prev_cat:
        print(f"    0x{base_addr+region_start:08X} - 0x{base_addr+len(data):08X} ({(len(data)-region_start)/1024:.1f}KB): {prev_cat}")


def byte_value_histogram(data, label):
    """Show byte value distribution."""
    counts = Counter(data)
    print(f"\n  字节值分布 (top 20, 排除 0x00/0xFF):")
    filtered = [(v, c) for v, c in counts.most_common() if v not in (0x00, 0xFF)]
    for val, cnt in filtered[:20]:
        bar = '#' * min(40, cnt * 40 // max(c for _, c in filtered))
        print(f"    0x{val:02X} ({chr(val) if 32 <= val < 127 else '.'}): {cnt:6d} {bar}")


def scan_ec_nvram_vars(data, base_addr):
    """Look for NVRAM variable-like structures (key-value, TLV, etc.)."""
    print("\n  NVRAM 变量结构探测:")

    # Look for TLV-like patterns: type(1-2B) + length(1-2B) + data
    # Common: type != FF/00, length < 256, followed by that many bytes
    tlv_candidates = []
    i = 0
    while i < len(data) - 4:
        if data[i] == 0xFF or data[i] == 0x00:
            i += 1
            continue
        tag = data[i]
        length = data[i+1]
        if 1 <= length <= 200 and i + 2 + length <= len(data):
            # Check if next record also looks like TLV
            next_off = i + 2 + length
            if next_off < len(data) - 2:
                next_tag = data[next_off]
                next_len = data[next_off + 1]
                if next_tag != 0xFF and next_tag != 0x00 and 1 <= next_len <= 200:
                    tlv_candidates.append((i, tag, length))
        i += 1

    if tlv_candidates:
        print(f"    找到 {len(tlv_candidates)} 个潜在 TLV 记录")
        if len(tlv_candidates) > 5:
            print(f"    前 10 个:")
            for off, tag, length in tlv_candidates[:10]:
                payload = data[off+2:off+2+length]
                hex_payload = payload[:16].hex()
                print(f"      0x{base_addr+off:08X}: tag=0x{tag:02X} len={length} data={hex_payload}...")
    else:
        print("    未发现明显 TLV 结构")

    # Look for key=value style (0x00 delimited strings)
    kv_items = []
    for m in re.finditer(rb'[\x20-\x7e]{2,64}=[\x20-\x7e]{1,64}', data):
        kv_items.append((base_addr + m.start(), m.group().decode()))
    if kv_items:
        print(f"\n    Key=Value 对 ({len(kv_items)}个):")
        for off, kv in kv_items[:20]:
            print(f"      0x{off:08X}: {kv}")


def analyze_region(data, base_addr, name):
    """Full analysis of a data region."""
    print(f"\n{'='*70}")
    print(f"  {name}")
    print(f"  SPI 地址: 0x{base_addr:08X} - 0x{base_addr+len(data):08X}")
    print(f"{'='*70}")
    print(f"  大小: {len(data):,} bytes ({len(data)/1024:.0f} KB)")
    print(f"  SHA256: {hashlib.sha256(data).hexdigest()[:32]}")

    ff_cnt = data.count(0xFF)
    zero_cnt = data.count(0x00)
    data_cnt = len(data) - ff_cnt - zero_cnt
    print(f"  0xFF: {ff_cnt:,} ({ff_cnt/len(data)*100:.1f}%)")
    print(f"  0x00: {zero_cnt:,} ({zero_cnt/len(data)*100:.1f}%)")
    print(f"  数据: {data_cnt:,} ({data_cnt/len(data)*100:.1f}%)")

    print(f"\n  === 前 512 字节 ===")
    hexdump(data, base_addr, 512)

    # Last 256 bytes of data region
    # Find where data ends (last non-FF byte)
    last_data = len(data) - 1
    while last_data > 0 and data[last_data] == 0xFF:
        last_data -= 1
    if last_data > 512:
        print(f"\n  === 数据末尾 (最后非FF: 0x{base_addr+last_data:08X}) ===")
        dump_start = max(0, last_data - 255)
        hexdump(data[dump_start:last_data+1], base_addr + dump_start, 256)

    # 4KB blocks
    blocks = analyze_block_structure(data, base_addr)
    print(f"\n  4KB 块概览:")
    for b in blocks:
        if not b['is_empty']:
            print(f"    0x{b['spi_addr']:08X}: first4={b['first4']}  hash={b['hash']}  ff={b['ff_pct']:.0f}%")
        else:
            pass  # skip empty blocks in summary

    empty_count = sum(1 for b in blocks if b['is_empty'])
    data_count = len(blocks) - empty_count
    print(f"    数据块: {data_count}/{len(blocks)}  空白块: {empty_count}/{len(blocks)}")

    # Strings
    strings = find_strings(data, base_addr)
    if strings:
        print(f"\n  可读字符串 ({len(strings)}个):")
        for off, s in strings[:50]:
            print(f"    0x{off:08X}: \"{s[:120]}\"")
    else:
        print(f"\n  未找到可读字符串 (>=6字节)")

    byte_value_histogram(data, name)
    analyze_entropy_windows(data, base_addr)
    scan_for_timestamps(data, base_addr)
    find_record_boundaries(data, base_addr)
    scan_ec_nvram_vars(data, base_addr)


def main():
    data = SPI.read_bytes()
    print("=" * 70)
    print("N3GHT15W EC SPI — 运行时数据区域逆向分析")
    print("=" * 70)

    # Region 1
    r1 = data[0x1C50000:0x1CB7000]
    analyze_region(r1, 0x1C50000, "Region 1: 运行时 NVRAM/日志")

    # Region 2
    r2 = data[0x1D00000:0x2000000]
    analyze_region(r2, 0x1D00000, "Region 2: 大块运行时数据")

    # Also check the gap and surrounding context
    print(f"\n{'='*70}")
    print("  周边区域扫描")
    print(f"{'='*70}")

    # What's between 0x1CB7000 and 0x1D00000?
    gap = data[0x1CB7000:0x1D00000]
    ff_in_gap = gap.count(0xFF)
    print(f"  间隔 0x1CB7000-0x1D00000 ({len(gap)/1024:.0f}KB): FF={ff_in_gap/len(gap)*100:.1f}%")

    # What's around 0x1C50000? Check before region 1
    pre = data[0x1C4F000:0x1C50000]
    print(f"  Region1 前 4KB (0x1C4F000): FF={pre.count(0xFF)/len(pre)*100:.1f}%")

    # What's after region 2?
    if len(data) > 0x2000000:
        post = data[0x2000000:0x2001000]
        print(f"  Region2 后 4KB (0x2000000): FF={post.count(0xFF)/len(post)*100:.1f}%")

    # Compare with same regions in other SPI dumps to see if these regions are unique or shared
    print(f"\n{'='*70}")
    print("  其他 SPI dump 同区域对比")
    print(f"{'='*70}")

    other_spis = sorted((Path(__file__).resolve().parent.parent / "firmware" / "ec_spi").glob("*.bin"))
    for spi in other_spis:
        if "N3GHT15W" in spi.name:
            continue
        d = spi.read_bytes()
        r1_other = d[0x1C50000:0x1CB7000]
        r2_other = d[0x1D00000:0x2000000]
        r1_ff = all(b == 0xFF for b in r1_other[:0x1000])
        r2_ff = all(b == 0xFF for b in r2_other[:0x1000])
        r1_tag = "all-FF" if all(b == 0xFF for b in r1_other) else f"data({sum(1 for b in r1_other if b != 0xFF and b != 0x00)}B)"
        r2_tag = "all-FF" if all(b == 0xFF for b in r2_other) else f"data({sum(1 for b in r2_other if b != 0xFF and b != 0x00)}B)"
        print(f"  {spi.name:40s} R1={r1_tag:20s} R2={r2_tag}")


if __name__ == "__main__":
    main()
