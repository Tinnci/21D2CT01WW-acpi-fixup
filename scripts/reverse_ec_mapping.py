#!/usr/bin/env python3
"""Precise mapping analysis: R1/R2 vs main EC firmware."""

import struct
import hashlib
from pathlib import Path

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi" / "N3GHT15W_z13_own_20260313.bin"

def main():
    data = SPI.read_bytes()
    main_ec = data[0x1000:0x45000]   # 272KB main EC at SPI 0x1000
    r1 = data[0x1C50000:0x1CB7000]   # Region 1 (412KB)
    r2 = data[0x1D00000:0x2000000]   # Region 2 (3MB)

    # ====== R1 vs main EC ======
    print("=" * 70)
    print("R1 (412KB, 0x1C50000) vs 主EC (272KB, 0x1000)")
    print("=" * 70)

    # Try to find where R1's code begins relative to main EC
    for ec_off in range(0, len(main_ec) - 64, 0x100):
        snippet = main_ec[ec_off:ec_off + 64]
        idx = r1.find(snippet)
        if idx >= 0 and idx < 0x100:
            ml = 0
            for j in range(min(len(main_ec) - ec_off, len(r1) - idx)):
                if main_ec[ec_off + j] == r1[idx + j]:
                    ml += 1
                else:
                    break
            if ml > 32:
                print(f"  R1[0x{idx:X}] = EC[0x{ec_off:X}], 连续匹配: {ml}B ({ml/1024:.1f}KB)")
                break

    # Is R1 content same as some part of R2?
    print(f"\n  R1 vs R2 交叉检查:")
    r1_sample = r1[:64]
    idx = r2.find(r1_sample)
    if idx >= 0:
        ml = sum(1 for a, b in zip(r1, r2[idx:idx + len(r1)]) if a == b)
        print(f"  R1前64B在R2[0x{idx:X}]处匹配, 全长比较: {ml}/{len(r1)} ({ml/len(r1)*100:.1f}%)")
    else:
        print(f"  R1前64B在R2中未找到")

    # ====== R2 mapping pattern ======
    print(f"\n{'='*70}")
    print("R2 → 主EC 映射解码 (无cap)")
    print("=" * 70)

    # Detailed mapping for first 128 pages
    mappings = []
    for r2_page in range(min(128, len(r2) // 0x1000)):
        r2_off = r2_page * 0x1000
        blk = r2[r2_off:r2_off + 32]
        best_off = -1
        best_len = 0
        pos = 0
        while pos < len(main_ec) - 32:
            idx = main_ec.find(blk, pos)
            if idx < 0:
                break
            ml = 0
            for j in range(min(4096, len(main_ec) - idx, len(r2) - r2_off)):
                if main_ec[idx + j] == r2[r2_off + j]:
                    ml += 1
                else:
                    break
            if ml > best_len:
                best_len = ml
                best_off = idx
            pos = idx + 1

        mappings.append((r2_page, r2_off, best_off, best_len))
        if best_len > 16:
            print(f"  R2[0x{r2_off:06X}] p{r2_page:3d} → EC[0x{best_off:05X}] {best_len:5d}B")

    # Analyze the mapping pattern
    print(f"\n  映射模式分析:")
    # Group by EC target offset to find stripes
    ec_targets = [(p, eo) for p, _, eo, ml in mappings if ml > 16]
    if len(ec_targets) > 16:
        # Check if every 16 pages, EC offset increases by 0x100
        for stride in [16, 8, 32]:
            consistent = True
            deltas = []
            for i in range(stride, min(len(ec_targets), stride * 4), stride):
                if i < len(ec_targets):
                    delta = ec_targets[i][1] - ec_targets[i - stride][1]
                    deltas.append(delta)
                    if delta != deltas[0]:
                        consistent = False
            if deltas:
                print(f"  每{stride}页EC偏移变化: {set(deltas)} (一致={consistent})")

    # ====== R2 structure: check if it's multiple EC FW versions ======
    print(f"\n{'='*70}")
    print("R2 结构: 是否包含多个EC版本?")
    print("=" * 70)

    # See how many distinct code blocks R2 has
    # Compare R2 pages more carefully
    # Take 16-page groups (each should cover same EC range but different version)
    group_size = 16  # 16 pages = 64KB
    groups = []
    for g in range(0, min(len(r2) // 0x1000, 192), group_size):
        group_data = r2[g * 0x1000:(g + group_size) * 0x1000]
        h = hashlib.sha256(group_data).hexdigest()[:12]
        groups.append((g, h))

    print(f"  64KB组哈希 (首12组):")
    for g, h in groups[:12]:
        print(f"    组{g//group_size:2d} (R2页{g:3d}-{g+group_size-1:3d}): {h}")

    # Check inter-group similarity within first 4 groups
    print(f"\n  组间相似度:")
    for i in range(min(4, len(groups))):
        for j in range(i + 1, min(4, len(groups))):
            g1_data = r2[groups[i][0] * 0x1000:(groups[i][0] + group_size) * 0x1000]
            g2_data = r2[groups[j][0] * 0x1000:(groups[j][0] + group_size) * 0x1000]
            diff = sum(1 for a, b in zip(g1_data, g2_data) if a != b)
            sim = 1 - diff / len(g1_data)
            print(f"    组{i} vs 组{j}: {sim*100:.1f}% ({diff} diff)")

    # ====== What if the pattern is: R2 is EC code XOR with something? ======
    print(f"\n{'='*70}")
    print("XOR/偏移分析: R2[0] vs EC code")
    print("=" * 70)

    # Compare first few bytes of mapping
    r2_byte0 = r2[:256]
    # Find the best EC match
    best_ec_off = -1
    best_ml = 0
    for ec_off in range(0, len(main_ec) - 256):
        ml = sum(1 for a, b in zip(r2_byte0, main_ec[ec_off:ec_off + 256]) if a == b)
        if ml > best_ml:
            best_ml = ml
            best_ec_off = ec_off
    print(f"  R2前256B最佳EC匹配: EC[0x{best_ec_off:X}], {best_ml}/256 匹配")

    if best_ec_off >= 0:
        ec_chunk = main_ec[best_ec_off:best_ec_off + 256]
        r2_chunk = r2[:256]
        # Check XOR
        xor_vals = [a ^ b for a, b in zip(r2_chunk, ec_chunk)]
        from collections import Counter
        xor_common = Counter(xor_vals).most_common(10)
        print(f"  XOR 值分布 (top 10): {[(hex(v), c) for v, c in xor_common]}")

    # ====== Check if R2 is wear-leveled old pages ======
    print(f"\n{'='*70}")
    print("磨损均衡分析: R2 是否为旧页面备份?")
    print("=" * 70)

    # If R2 contains old versions of EC flash pages, they should
    # be similar to current pages but with small differences
    # Check: for each R2 4KB page, find best 4KB page in main EC
    match_stats = []
    for r2_page in range(0, min(48, len(r2) // 0x1000)):
        r2_off = r2_page * 0x1000
        r2_blk = r2[r2_off:r2_off + 0x1000]

        best_sim = 0
        best_ec_page = -1
        for ec_page in range(len(main_ec) // 0x1000):
            ec_off = ec_page * 0x1000
            ec_blk = main_ec[ec_off:ec_off + 0x1000]
            sim = sum(1 for a, b in zip(r2_blk, ec_blk) if a == b) / 0x1000
            if sim > best_sim:
                best_sim = sim
                best_ec_page = ec_page

        match_stats.append((r2_page, best_ec_page, best_sim))
        if best_sim > 0.05:
            print(f"  R2页{r2_page:3d} → EC页{best_ec_page:3d} (EC+0x{best_ec_page*0x1000:05X}): {best_sim*100:.1f}%")

    # ====== Check for bootloader / recovery code ======
    print(f"\n{'='*70}")
    print("Recovery/Bootloader 检测")
    print("=" * 70)

    # Look for known Insyde EC bootloader patterns
    for region_name, region_data, base in [("R1", r1, 0x1C50000), ("R2", r2, 0x1D00000)]:
        # ARM vector table
        for off in range(0, min(len(region_data), 0x100), 4):
            sp = struct.unpack_from('<I', region_data, off)[0]
            reset = struct.unpack_from('<I', region_data, off + 4)[0] if off + 4 < len(region_data) else 0
            if 0x200C0000 <= sp <= 0x200CFFFF and 0x10070000 <= reset <= 0x100FFFFF:
                print(f"  {region_name}@+0x{off:X}: 向量表! SP=0x{sp:08X} Reset=0x{reset:08X}")

        # _EC header search (broader)
        for off in range(0, min(len(region_data), 0x2000), 4):
            if region_data[off:off + 3] == b'\x5f\x45\x43':
                ver = region_data[off + 3]
                print(f"  {region_name}@+0x{off:X}: _EC (ver={ver})")


if __name__ == "__main__":
    main()
