#!/usr/bin/env python3
"""
EC 固件跨版本深度对比 + 函数级 Capstone 分析

1. R1 独有 348KB 代码在量产版 (N3GHT25W/64W) 高地址区搜索
2. 量产版 0x100000+ ARM 代码区与主 EC 的关系
3. EC0.11_eng_rev0.4 巨型 ARM 块分析
4. 函数级反汇编对比
"""

import os
import struct
import hashlib
from pathlib import Path
from collections import Counter

from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB

BASE = Path(__file__).resolve().parent.parent
SPI_DIR = BASE / "firmware" / "ec_spi"
EC_DIR = BASE / "firmware" / "ec"


def load(name):
    p = SPI_DIR / name
    if not p.exists():
        p = EC_DIR / name
    with open(p, "rb") as f:
        return f.read()


def find_probe_in_data(probe, data, start=0):
    """Search for probe bytes in data, return all match offsets"""
    results = []
    pos = start
    while True:
        idx = data.find(probe, pos)
        if idx == -1:
            break
        results.append(idx)
        pos = idx + 1
        if len(results) > 20:  # cap
            break
    return results


def measure_match(a, a_off, b, b_off, max_len=None):
    """Measure consecutive matching bytes between a[a_off:] and b[b_off:]"""
    limit = min(len(a) - a_off, len(b) - b_off)
    if max_len:
        limit = min(limit, max_len)
    count = 0
    for i in range(limit):
        if a[a_off + i] == b[b_off + i]:
            count += 1
        else:
            break
    return count


def disasm_at(data, offset, base_addr, n_insns=20):
    """Disassemble n instructions at offset"""
    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = False
    chunk = data[offset:offset + n_insns * 4]
    lines = []
    for insn in md.disasm(chunk, base_addr):
        lines.append(f"  0x{insn.address:08X}: {insn.mnemonic:8s} {insn.op_str}")
        if len(lines) >= n_insns:
            break
    return lines


def find_function_entries(data, start_off, length, max_funcs=500):
    """Find PUSH {.., LR} entries"""
    entries = []
    end = min(start_off + length, len(data) - 1)
    for i in range(start_off, end, 2):
        w = data[i] | (data[i + 1] << 8)
        if (w & 0xFF00) == 0xB500:
            entries.append(i)
            if len(entries) >= max_funcs:
                break
    return entries


def function_signature(data, offset, sig_len=16):
    """Extract a function signature (first sig_len bytes after PUSH)"""
    return data[offset:offset + sig_len]


def main():
    print("=" * 70)
    print("EC 固件跨版本深度对比")
    print("=" * 70)

    # Load key dumps
    own = load("N3GHT15W_z13_own_20260313.bin")
    n25 = load("N3GHT25W_v1.02.bin")
    n64 = load("N3GHT64W_v1.64.bin")
    e11 = load("EC0.11_eng_rev0.4.bin")

    own_ec = own[0x1000:0x45000]  # 272KB main EC
    r1 = own[0x1C50000:0x1CB7000]  # R1 412KB
    r1_unique = r1[0x10000:]  # R1 unique 348KB portion

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第一部分: R1 独有代码 (348KB) 在其他 dump 中搜索")
    print("=" * 70)

    # Use multiple probes from R1 unique area
    probe_offsets = [0, 0x1000, 0x5000, 0x10000, 0x20000, 0x30000, 0x40000, 0x50000]
    targets = {
        "N3GHT25W": n25,
        "N3GHT64W": n64,
        "EC0.11_rev0.4": e11,
    }

    for probe_rel in probe_offsets:
        if probe_rel + 32 > len(r1_unique):
            continue
        probe = r1_unique[probe_rel:probe_rel + 32]
        probe_hex = probe[:8].hex()
        print(f"\n  探针 R1[0x{0x10000+probe_rel:05X}] = {probe_hex}...")

        for tname, tdata in targets.items():
            matches = find_probe_in_data(probe, tdata)
            if matches:
                for m in matches[:3]:
                    ml = measure_match(r1_unique, probe_rel, tdata, m, max_len=4096)
                    print(f"    {tname} @ 0x{m:07X}: 匹配 {ml}B")
            else:
                print(f"    {tname}: 未找到")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第二部分: 量产版高地址 ARM 区域与主 EC 交叉匹配")
    print("=" * 70)

    for name, data, ec_start in [
        ("N3GHT25W", n25, 0x1000),
        ("N3GHT64W", n64, 0x1000),
    ]:
        main_ec = data[ec_start:ec_start + 0x50000]
        backup_ec = data[0xA0000:0xA0000 + 0x50000] if len(data) > 0xF0000 else None

        print(f"\n─── {name} ───")

        # ARM code regions above 0x100000
        arm_regions = [
            (0x100000, 0x125000, "区域A"),
            (0x12B000, 0x1DB000, "区域B"),
            (0x1DC000, 0x2B5000, "区域C"),
        ]

        for rs, re, label in arm_regions:
            if rs >= len(data):
                continue
            chunk = data[rs:min(re, len(data))]
            if len(chunk) < 64:
                continue

            # Check if it matches main EC
            probe = chunk[:32]
            # Search in main EC
            ec_match = find_probe_in_data(probe, main_ec)
            if ec_match:
                ml = measure_match(chunk, 0, main_ec, ec_match[0], max_len=len(chunk))
                pct = ml / len(chunk) * 100
                print(f"  {label} 0x{rs:06X}-0x{re:06X} ({len(chunk):,}B)")
                print(f"    → 主EC[0x{ec_match[0]:05X}] 匹配 {ml:,}B ({pct:.1f}%)")
            else:
                # Try backup EC
                if backup_ec:
                    bk_match = find_probe_in_data(probe, backup_ec)
                    if bk_match:
                        ml = measure_match(chunk, 0, backup_ec, bk_match[0], max_len=len(chunk))
                        print(f"  {label} 0x{rs:06X}-0x{re:06X} ({len(chunk):,}B)")
                        print(f"    → 备份EC[0x{bk_match[0]:05X}] 匹配 {ml:,}B")
                    else:
                        # Search in own N3GHT15W EC
                        own_match = find_probe_in_data(probe, own_ec)
                        if own_match:
                            ml = measure_match(chunk, 0, own_ec, own_match[0], max_len=len(chunk))
                            print(f"  {label} 0x{rs:06X}-0x{re:06X} ({len(chunk):,}B)")
                            print(f"    → N3GHT15W EC[0x{own_match[0]:05X}] 匹配 {ml:,}B")
                        else:
                            print(f"  {label} 0x{rs:06X}-0x{re:06X} ({len(chunk):,}B)")
                            print(f"    → 无匹配 (独立代码块)")

            # Function count and first few functions
            funcs = find_function_entries(data, rs, re - rs, max_funcs=500)
            print(f"    函数序言: {len(funcs)} 个")
            if funcs:
                print(f"    前3个函数:")
                for fi, faddr in enumerate(funcs[:3]):
                    insns = disasm_at(data, faddr, faddr, n_insns=8)
                    print(f"      [{fi}] @ 0x{faddr:07X}:")
                    for line in insns:
                        print(f"        {line}")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第三部分: EC0.11 巨型 ARM 块 (21.9MB) 结构分析")
    print("=" * 70)

    e11_arm_start = 0x092A000
    e11_arm_end = 0x1E0F000
    e11_arm = e11[e11_arm_start:e11_arm_end]
    print(f"  区域: 0x{e11_arm_start:07X}-0x{e11_arm_end:07X} ({len(e11_arm):,}B)")

    # Look for _EC headers inside
    ec_magic = b"\x5F\x45\x43"
    pos = 0
    ec_found = []
    while True:
        idx = e11_arm.find(ec_magic, pos)
        if idx == -1:
            break
        if idx + 16 <= len(e11_arm):
            ver = e11_arm[idx + 3]
            if ver in (1, 2):
                total = struct.unpack_from("<I", e11_arm, idx + 4)[0]
                if 0x1000 < total < 0x100000:
                    ec_found.append((e11_arm_start + idx, ver, total))
        pos = idx + 1

    print(f"  有效 _EC 头部: {len(ec_found)} 个 (在 21.9MB ARM 块内)")

    # Look for version strings
    ver_magic = b"N3GHT"
    pos = 0
    ver_found = []
    while True:
        idx = e11_arm.find(ver_magic, pos)
        if idx == -1:
            break
        end = min(idx + 20, len(e11_arm))
        s = e11_arm[idx:end]
        try:
            ver = s[:s.index(0)].decode("ascii") if 0 in s else s[:10].decode("ascii")
        except Exception:
            ver = "?"
        ver_found.append((e11_arm_start + idx, ver))
        pos = idx + 1

    print(f"  N3GHT 版本字符串: {len(ver_found)} 个")
    for off, ver in ver_found[:10]:
        print(f"    @ 0x{off:07X}: {ver}")

    # Sample blocks at regular intervals to check code quality
    print(f"\n  代码质量采样 (每 2MB):")
    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = False

    for sample_off in range(0, len(e11_arm), 0x200000):
        chunk = e11_arm[sample_off:sample_off + 256]
        if all(b == 0xFF for b in chunk) or all(b == 0x00 for b in chunk):
            print(f"    @ 0x{e11_arm_start + sample_off:07X}: 空白")
            continue

        # Count prologues in 64KB
        sample_64k = e11_arm[sample_off:sample_off + 65536]
        prols = 0
        for i in range(0, min(len(sample_64k) - 1, 65536), 2):
            w = sample_64k[i] | (sample_64k[i + 1] << 8)
            if (w & 0xFF00) == 0xB500:
                prols += 1

        insns = []
        for insn in md.disasm(chunk, e11_arm_start + sample_off):
            insns.append(f"{insn.mnemonic:8s} {insn.op_str}")
            if len(insns) >= 10:
                break

        print(f"    @ 0x{e11_arm_start + sample_off:07X}: prol={prols} "
              f"{'★ARM' if prols > 5 else ' data'}")
        for line in insns[:5]:
            print(f"      {line}")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第四部分: 函数签名跨版本匹配")
    print("=" * 70)

    # Extract function signatures from N3GHT15W main EC
    own_funcs = find_function_entries(own, 0x1000, 0x44000, max_funcs=500)
    print(f"  N3GHT15W 主 EC 函数: {len(own_funcs)} 个")

    # Extract from R1 unique area
    r1u_funcs = find_function_entries(own, 0x1C50000 + 0x10000, 0x57000, max_funcs=500)
    print(f"  R1 独有区 函数: {len(r1u_funcs)} 个")

    # Cross-match: for each R1 function, search its signature in main EC
    matched = 0
    unmatched_samples = []
    for faddr in r1u_funcs[:200]:
        sig = own[faddr:faddr + 16]
        if sig in own[0x1000:0x45000]:
            matched += 1
        elif len(unmatched_samples) < 5:
            unmatched_samples.append(faddr)

    print(f"  R1 函数签名 → 主 EC: {matched}/{min(200, len(r1u_funcs))} 匹配 "
          f"({matched/max(1,min(200,len(r1u_funcs)))*100:.1f}%)")

    # Disassemble unmatched R1 functions
    if unmatched_samples:
        print(f"  不匹配的 R1 函数样本 (可能属于旧版):")
        for faddr in unmatched_samples:
            insns = disasm_at(own, faddr, faddr, n_insns=10)
            print(f"\n    @ 0x{faddr:07X}:")
            for line in insns:
                print(f"    {line}")

    # Cross-match: R1 functions in N3GHT25W/64W
    print(f"\n  R1 函数签名 → 量产版搜索:")
    for tname, tdata in [("N3GHT25W", n25), ("N3GHT64W", n64)]:
        found = 0
        for faddr in r1u_funcs[:100]:
            sig = own[faddr:faddr + 16]
            if sig in tdata:
                found += 1
        print(f"    → {tname}: {found}/{min(100, len(r1u_funcs))} 匹配")

    # Cross-match: R1 functions in EC0.11
    found_e11 = 0
    found_e11_locations = []
    for faddr in r1u_funcs[:100]:
        sig = own[faddr:faddr + 16]
        idx = e11.find(sig)
        if idx != -1:
            found_e11 += 1
            if len(found_e11_locations) < 5:
                found_e11_locations.append((faddr, idx))
    print(f"    → EC0.11_rev0.4: {found_e11}/{min(100, len(r1u_funcs))} 匹配")
    for faddr, eidx in found_e11_locations:
        print(f"      R1[0x{faddr:07X}] → EC0.11[0x{eidx:07X}]")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第五部分: N3GHT25W 双版本 (22W/25W) 备份镜像对比")
    print("=" * 70)

    n25_primary = n25[0x1000:0x50000]   # Primary at 0x1000
    n25_backup = n25[0xA0000:0xEF000]   # Backup at 0xA0000

    # Version strings
    for label, d, base in [("主镜像", n25_primary, 0x1000), ("备份镜像", n25_backup, 0xA0000)]:
        idx = d.find(b"N3GHT")
        ver = "?"
        if idx != -1:
            end = min(idx + 15, len(d))
            s = d[idx:end]
            try:
                ver = s[:s.index(0)].decode("ascii") if 0 in s else s[:10].decode("ascii")
            except Exception:
                pass
        print(f"  {label} (@ 0x{base:05X}): {ver}")

    # Compare primary vs backup
    match_count = sum(1 for a, b in zip(n25_primary, n25_backup) if a == b)
    total = min(len(n25_primary), len(n25_backup))
    print(f"  主 vs 备份: {match_count}/{total} 字节匹配 ({match_count/total*100:.1f}%)")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第六部分: EC 版权/IBM 字符串位置对比")
    print("=" * 70)

    ibm_str = b"Copyright IBM"
    for fname in sorted(SPI_DIR.glob("*.bin")):
        d = load(fname.name)
        idx = d.find(ibm_str)
        if idx != -1:
            print(f"  {fname.name:45s} @ 0x{idx:06X}")
        else:
            print(f"  {fname.name:45s} NOT FOUND")

    print(f"\n{'=' * 70}")
    print("分析完成")
    print("=" * 70)


if __name__ == "__main__":
    main()
