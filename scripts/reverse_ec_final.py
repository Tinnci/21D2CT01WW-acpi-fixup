#!/usr/bin/env python3
"""Final verification: What exactly is R2's relationship to main EC?"""
import struct
from pathlib import Path

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi" / "N3GHT15W_z13_own_20260313.bin"

def main():
    data = SPI.read_bytes()
    main_ec = data[0x1000:0x45000]
    r2 = data[0x1D00000:0x2000000]

    print("=" * 70)
    print("R2 页级映射验证")
    print("=" * 70)

    # Verify complete mapping pattern
    # Expected: R2[group*0x10000 + page*0x1000] = EC[0x1C000 + page*0x1000 + group*0x100 + 1]
    total_pages = len(r2) // 0x1000  # 768
    pages_per_group = 16
    num_groups = total_pages // pages_per_group  # 48

    perfect_match = 0
    partial_match = 0
    no_match = 0

    for group in range(num_groups):
        for page in range(pages_per_group):
            r2_off = group * 0x10000 + page * 0x1000
            ec_off = 0x1C000 + page * 0x1000 + group * 0x100 + 1

            if ec_off + 4096 > len(main_ec):
                continue

            r2_blk = r2[r2_off:r2_off + 4096]
            ec_blk = main_ec[ec_off:ec_off + 4096]

            match = sum(1 for a, b in zip(r2_blk, ec_blk) if a == b)
            if match == 4096:
                perfect_match += 1
            elif match > 3000:
                partial_match += 1
                print(f"  部分匹配: g{group}p{page} R2[0x{r2_off:06X}]→EC[0x{ec_off:05X}] {match}/4096")
            else:
                no_match += 1
                if no_match <= 10:
                    print(f"  不匹配:   g{group}p{page} R2[0x{r2_off:06X}]→EC[0x{ec_off:05X}] {match}/4096")

    print(f"\n  总结 ({num_groups} groups × {pages_per_group} pages = {num_groups*pages_per_group} 总页):")
    print(f"    完全匹配 (4096/4096): {perfect_match}")
    print(f"    部分匹配 (>3000): {partial_match}")
    print(f"    不匹配:           {no_match}")

    # Check what's at the "skipped" byte (the +1 offset)
    print(f"\n{'='*70}")
    print("被跳过的字节分析 (+1 offset)")
    print("=" * 70)
    print("  每页在EC中的起始: EC[0x1C000 + page*0x1000 + group*0x100]")
    print("  R2存储的是: 从+1开始的4096字节 (跳过第一个字节)")
    print("  被跳过字节的值:")
    skipped_vals = []
    for group in range(min(8, num_groups)):
        for page in range(pages_per_group):
            ec_off = 0x1C000 + page * 0x1000 + group * 0x100
            if ec_off < len(main_ec):
                skipped = main_ec[ec_off]
                skipped_vals.append(skipped)
                if group < 3:
                    print(f"    g{group}p{page:2d}: EC[0x{ec_off:05X}] = 0x{skipped:02X}")

    from collections import Counter
    print(f"\n  跳过字节的值分布: {Counter(skipped_vals).most_common(10)}")

    # Now: what is R2's "extra" data? Check the first byte of each R2 page
    print(f"\n{'='*70}")
    print("R2 每页首字节 vs EC匹配偏移")
    print("=" * 70)
    for group in range(min(4, num_groups)):
        for page in range(pages_per_group):
            r2_off = group * 0x10000 + page * 0x1000
            ec_off = 0x1C000 + page * 0x1000 + group * 0x100

            r2_first = r2[r2_off]
            ec_at_off = main_ec[ec_off] if ec_off < len(main_ec) else None
            ec_at_off1 = main_ec[ec_off + 1] if ec_off + 1 < len(main_ec) else None

            if ec_at_off is not None:
                print(f"    g{group}p{page:2d}: R2[0]={r2_first:02X}  EC[+0]={ec_at_off:02X}  EC[+1]={ec_at_off1:02X}  {'✓ R2=EC+1' if r2_first == ec_at_off1 else '? R2=EC+0' if r2_first == ec_at_off else '✗'}")

    # ====== R1 detailed analysis ======
    print(f"\n{'='*70}")
    print("R1 详细分析")
    print("=" * 70)

    r1 = data[0x1C50000:0x1CB7000]

    # R1[0xFF] matches EC[0x1B600] for 63.8KB
    r1_code = r1[0xFF:]
    ec_part = main_ec[0x1B600:]
    match_len = 0
    for j in range(min(len(r1_code), len(ec_part))):
        if r1_code[j] == ec_part[j]:
            match_len += 1
        else:
            break

    print(f"  R1[0xFF:] vs EC[0x1B600:]: 连续匹配 {match_len:,}B ({match_len/1024:.1f}KB)")
    first_diff = match_len
    print(f"  首个差异 @ R1[0x{0xFF + first_diff:X}] = EC[0x{0x1B600 + first_diff:X}]")
    if first_diff < len(r1_code) and first_diff < len(ec_part):
        print(f"    R1: 0x{r1_code[first_diff]:02X}  EC: 0x{ec_part[first_diff]:02X}")

    # What's in R1[0:0xFF]? (the 255 bytes before the EC match)
    print(f"\n  R1[0x00-0xFF] (EC匹配前的 {0xFF} 字节 = 页头?):")
    for i in range(0, 0xFF, 16):
        chunk = r1[i:min(i + 16, 0xFF)]
        hex_part = ' '.join(f'{b:02x}' for b in chunk)
        ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        print(f"    {0x1C50000+i:08X}: {hex_part:<48s} |{ascii_part}|")

    # What's after the match in R1?
    post_match_start = 0xFF + first_diff
    remaining = len(r1) - post_match_start
    if remaining > 0:
        print(f"\n  R1 匹配后: {remaining:,}B ({remaining/1024:.1f}KB) 剩余")
        # Is the remaining data also EC code?
        r1_post = r1[post_match_start:]
        # Search for it in main_ec
        probe = r1_post[:32]
        idx = main_ec.find(probe)
        if idx >= 0:
            ml2 = 0
            for j in range(min(1024, len(main_ec) - idx, len(r1_post))):
                if main_ec[idx + j] == r1_post[j]:
                    ml2 += 1
                else:
                    break
            print(f"  R1 后续部分 → EC[0x{idx:05X}] 匹配 {ml2}B")
        else:
            print(f"  R1 后续部分在主EC中未找到")

        # Try matching with OTHER SPI dumps' EC code
        print(f"\n  R1 后续部分 vs 其他版本 EC:")
        ec_spi = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"
        for other in sorted(ec_spi.glob("*.bin")):
            if "N3GHT15W" in other.name:
                continue
            od = other.read_bytes()
            other_ec = od[0x1000:0x45000]
            probe = r1_post[:32]
            idx = other_ec.find(probe)
            if idx >= 0:
                ml3 = 0
                for j in range(min(4096, len(other_ec) - idx, len(r1_post))):
                    if other_ec[idx + j] == r1_post[j]:
                        ml3 += 1
                    else:
                        break
                if ml3 > 64:
                    print(f"    {other.name}: EC[0x{idx:05X}] 匹配 {ml3}B ({ml3/1024:.1f}KB)")


if __name__ == "__main__":
    main()
