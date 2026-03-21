#!/usr/bin/env python3
"""
EC SPI 全版本深度扫描 + Capstone 反汇编分析

扫描所有 EC SPI dump 的非空区域，检测 ARM Thumb-2 代码模式，
使用 Capstone 反汇编关键代码段，并跨版本对比类似模式。
"""

import os
import struct
import hashlib
from pathlib import Path
from collections import Counter, defaultdict

try:
    from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False
    print("WARNING: capstone not available, disassembly disabled")

BASE = Path(__file__).resolve().parent.parent
SPI_DIR = BASE / "firmware" / "ec_spi"
EC_DIR = BASE / "firmware" / "ec"

BLOCK_SIZE = 0x1000  # 4KB

# Known regions of interest (from N3GHT15W analysis)
R1_START = 0x1C50000
R1_END   = 0x1CB7000
R2_START = 0x1D00000
R2_END   = 0x2000000


def load_file(path):
    with open(path, "rb") as f:
        return f.read()


def scan_nonempty_regions(data, block_size=BLOCK_SIZE, min_blocks=1):
    """扫描 SPI dump 中的非空 (非 0xFF/0x00) 区域"""
    regions = []
    total_blocks = len(data) // block_size
    in_region = False
    region_start = 0

    for i in range(total_blocks):
        blk = data[i * block_size:(i + 1) * block_size]
        is_empty = all(b == 0xFF for b in blk) or all(b == 0x00 for b in blk)

        if not is_empty and not in_region:
            region_start = i * block_size
            in_region = True
        elif is_empty and in_region:
            region_end = i * block_size
            n_blocks = (region_end - region_start) // block_size
            if n_blocks >= min_blocks:
                regions.append((region_start, region_end, n_blocks))
            in_region = False

    if in_region:
        region_end = total_blocks * block_size
        n_blocks = (region_end - region_start) // block_size
        if n_blocks >= min_blocks:
            regions.append((region_start, region_end, n_blocks))

    return regions


def detect_arm_thumb2(data_chunk, sample_size=None):
    """ARM Thumb-2 代码检测: 函数序言、指令模式"""
    if sample_size and len(data_chunk) > sample_size:
        data_chunk = data_chunk[:sample_size]

    prologues = 0
    epilogues = 0
    bl_count = 0
    bx_lr = 0

    for i in range(0, len(data_chunk) - 1, 2):
        w = data_chunk[i] | (data_chunk[i + 1] << 8)
        # PUSH {Rn..., LR} = 0xB5xx
        if (w & 0xFF00) == 0xB500:
            prologues += 1
        # POP {Rn..., PC} = 0xBDxx
        if (w & 0xFF00) == 0xBD00:
            epilogues += 1
        # BL prefix (32-bit) = 0xF0xx-0xF8xx
        hi = (w >> 8) & 0xFF
        if hi in (0xF0, 0xF4, 0xF7, 0xF8):
            bl_count += 1
        # BX LR = 0x4770
        if w == 0x4770:
            bx_lr += 1

    total_hw = len(data_chunk) // 2
    code_score = prologues + epilogues + bl_count // 2 + bx_lr
    code_density = code_score / max(total_hw, 1) * 100

    return {
        "prologues": prologues,
        "epilogues": epilogues,
        "bl_instructions": bl_count,
        "bx_lr": bx_lr,
        "code_score": code_score,
        "code_density_pct": round(code_density, 2),
        "total_halfwords": total_hw,
    }


def find_ec_header(data):
    """查找 _EC 头部"""
    results = []
    search = b"\x5F\x45\x43"  # _EC
    pos = 0
    while True:
        idx = data.find(search, pos)
        if idx == -1:
            break
        # 验证: 后接合理 ver_byte
        if idx + 16 <= len(data):
            ver = data[idx + 3]
            if ver in (1, 2):
                total = struct.unpack_from("<I", data, idx + 4)[0]
                dsize = struct.unpack_from("<I", data, idx + 8)[0]
                if 0x1000 < total < 0x100000 and 0x1000 < dsize < 0x100000:
                    results.append({
                        "offset": idx,
                        "ver": ver,
                        "total": total,
                        "data_size": dsize,
                    })
        pos = idx + 1
    return results


def find_version_strings(data):
    """查找 N3GHTxxW 版本字符串"""
    results = []
    search = b"N3GHT"
    pos = 0
    while True:
        idx = data.find(search, pos)
        if idx == -1:
            break
        end = min(idx + 20, len(data))
        s = data[idx:end]
        try:
            ver = s[:s.index(0)].decode("ascii") if 0 in s else s[:10].decode("ascii")
        except Exception:
            ver = s[:10].hex()
        results.append((idx, ver))
        pos = idx + 1
    return results


def capstone_disasm(data_chunk, base_addr=0, max_insns=50):
    """使用 Capstone 反汇编 ARM Thumb-2 代码"""
    if not HAS_CAPSTONE:
        return []

    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = False
    insns = []
    for insn in md.disasm(data_chunk, base_addr):
        insns.append(f"  0x{insn.address:08X}:  {insn.mnemonic:8s} {insn.op_str}")
        if len(insns) >= max_insns:
            break
    return insns


def disasm_function_prologues(data_chunk, base_addr=0, max_funcs=20, context_insns=12):
    """找到函数序言 (PUSH {.., LR}) 并反汇编前 N 条指令"""
    if not HAS_CAPSTONE:
        return []

    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = False
    funcs = []

    for i in range(0, len(data_chunk) - 1, 2):
        w = data_chunk[i] | (data_chunk[i + 1] << 8)
        if (w & 0xFF00) == 0xB500:
            # PUSH found
            chunk = data_chunk[i:i + context_insns * 4]
            insns = []
            for insn in md.disasm(chunk, base_addr + i):
                insns.append(f"  0x{insn.address:08X}:  {insn.mnemonic:8s} {insn.op_str}")
                if len(insns) >= context_insns:
                    break
            if len(insns) >= 3:
                funcs.append({
                    "offset": i,
                    "addr": base_addr + i,
                    "disasm": insns,
                })
            if len(funcs) >= max_funcs:
                break

    return funcs


def check_r2_pattern(data, main_ec):
    """检查 R2 交错映射模式是否存在"""
    r2 = data[R2_START:R2_END]
    if all(b == 0xFF for b in r2[:4096]):
        return None

    # 用 N3GHT15W 的公式检测前几个页
    matches = 0
    total_checked = 0
    for group in range(min(3, len(r2) // 0x10000)):
        for page in range(16):
            r2_off = group * 0x10000 + page * 0x1000
            ec_off = 0x1C000 + page * 0x1000 + group * 0x100 + 1
            if r2_off + 32 > len(r2) or ec_off + 32 > len(main_ec):
                continue
            total_checked += 1
            if r2[r2_off:r2_off + 32] == main_ec[ec_off:ec_off + 32]:
                matches += 1

    if total_checked == 0:
        return None

    return {
        "checked": total_checked,
        "matches": matches,
        "match_rate": round(matches / total_checked * 100, 1),
    }


def cross_match_region(region_data, all_ec_firmwares, min_match=1024):
    """将一个区域的数据与所有已知 EC 固件交叉匹配"""
    results = []
    probe = region_data[0xFF:0xFF + 64]  # Use the same offset as R1

    for name, fw_data in all_ec_firmwares.items():
        idx = fw_data.find(probe)
        if idx != -1:
            # Measure match length
            ml = 0
            for j in range(min(len(region_data) - 0xFF, len(fw_data) - idx)):
                if region_data[0xFF + j] == fw_data[idx + j]:
                    ml += 1
                else:
                    break
            if ml >= min_match:
                results.append({
                    "ec_name": name,
                    "ec_offset": idx,
                    "match_length": ml,
                })

    return results


def analyze_one_dump(filepath, all_main_ecs=None):
    """分析单个 EC SPI dump"""
    name = filepath.name
    data = load_file(filepath)

    result = {"name": name, "size": len(data)}

    # 1. _EC 头部
    ec_headers = find_ec_header(data)
    result["ec_headers"] = ec_headers

    # 2. 版本字符串
    versions = find_version_strings(data)
    result["versions"] = versions

    # 3. 非空区域扫描
    regions = scan_nonempty_regions(data, min_blocks=2)
    result["regions"] = []

    for start, end, nblocks in regions:
        region_data = data[start:end]
        region_size = end - start

        rinfo = {
            "start": start,
            "end": end,
            "size": region_size,
            "blocks": nblocks,
        }

        # ARM 检测
        arm = detect_arm_thumb2(region_data, sample_size=min(region_size, 65536))
        rinfo["arm"] = arm

        # 区域特征分类
        in_r1 = (start >= R1_START - 0x10000 and start < R1_END + 0x10000)
        in_r2 = (start >= R2_START - 0x10000 and start < R2_END + 0x10000)
        rinfo["zone"] = "R1-like" if in_r1 else "R2-like" if in_r2 else "other"

        # Hash
        rinfo["sha256_16k"] = hashlib.sha256(region_data[:min(16384, region_size)]).hexdigest()[:16]

        result["regions"].append(rinfo)

    # 4. 主 EC 固件提取 (偏移 0x1000)
    if len(data) >= 0x45000:
        main_ec = data[0x1000:0x45000]
        result["main_ec_hash"] = hashlib.sha256(main_ec).hexdigest()[:16]

        # 检查 R2 交错模式
        if len(data) >= R2_END:
            r2_check = check_r2_pattern(data, main_ec)
            result["r2_pattern"] = r2_check

    return result


def main():
    print("=" * 70)
    print("EC SPI 全版本深度扫描 + Capstone 反汇编")
    print("=" * 70)

    # 收集所有 SPI dumps
    spi_files = sorted(SPI_DIR.glob("*.bin"))
    print(f"\nSPI dumps: {len(spi_files)} 个")
    for f in spi_files:
        print(f"  {f.name} ({f.stat().st_size:,} bytes)")

    # 收集独立 EC 固件
    ec_files = sorted(EC_DIR.glob("*"))
    print(f"\n独立 EC: {len(ec_files)} 个")
    for f in ec_files:
        print(f"  {f.name} ({f.stat().st_size:,} bytes)")

    # 加载所有主 EC 固件 (用于交叉匹配)
    all_main_ecs = {}
    for f in spi_files:
        d = load_file(f)
        all_main_ecs[f.name] = d[0x1000:0x45000]
    for f in ec_files:
        d = load_file(f)
        all_main_ecs[f.name] = d

    print("\n" + "=" * 70)
    print("第一部分: 全 SPI dump 非空区域扫描")
    print("=" * 70)

    all_results = []
    # 跨dump区域fingerprint统计
    region_fingerprints = defaultdict(list)  # hash -> [(dump_name, start, end)]

    for filepath in spi_files:
        r = analyze_one_dump(filepath, all_main_ecs)
        all_results.append(r)

        print(f"\n{'─' * 60}")
        print(f"📦 {r['name']}")
        print(f"  _EC 头部: {len(r['ec_headers'])} 个")
        for h in r["ec_headers"]:
            print(f"    @ 0x{h['offset']:06X}  ver={h['ver']}  total=0x{h['total']:X}  data=0x{h['data_size']:X}")
        print(f"  版本字符串: {len(r['versions'])} 个")
        for offset, ver in r["versions"][:5]:
            print(f"    @ 0x{offset:06X}: {ver}")
        print(f"  非空区域: {len(r['regions'])} 个")
        for reg in r["regions"]:
            arm_flag = "★ARM" if reg["arm"]["code_density_pct"] > 2.0 else " data"
            print(f"    0x{reg['start']:07X}-0x{reg['end']:07X}  "
                  f"{reg['size']:>10,}B ({reg['blocks']:>4} blk)  "
                  f"{arm_flag} d={reg['arm']['code_density_pct']:5.2f}%  "
                  f"prol={reg['arm']['prologues']:>4}  "
                  f"[{reg['zone']:>7}]  #{reg['sha256_16k']}")
            region_fingerprints[reg["sha256_16k"]].append(
                (r["name"], reg["start"], reg["end"])
            )

        if r.get("r2_pattern"):
            p = r["r2_pattern"]
            print(f"  R2 交错模式: {p['matches']}/{p['checked']} 匹配 ({p['match_rate']}%)")

    # 区域fingerprint重复检测
    print(f"\n{'=' * 70}")
    print("第二部分: 跨 dump 区域指纹对比")
    print("=" * 70)

    duplicates = {k: v for k, v in region_fingerprints.items() if len(v) > 1}
    if duplicates:
        for h, locs in sorted(duplicates.items(), key=lambda x: -len(x[1])):
            print(f"\n  指纹 #{h} 出现 {len(locs)} 次:")
            for dname, start, end in locs:
                print(f"    {dname} @ 0x{start:07X}-0x{end:07X}")
    else:
        print("  无跨 dump 重复区域")

    # 特别分析: 哪些dump在R1/R2地址范围有数据
    print(f"\n{'=' * 70}")
    print("第三部分: R1/R2 地址范围数据分布")
    print("=" * 70)

    for r in all_results:
        has_r1 = any(reg["zone"] == "R1-like" for reg in r["regions"])
        has_r2 = any(reg["zone"] == "R2-like" for reg in r["regions"])
        r2p = r.get("r2_pattern")
        r2_str = ""
        if r2p:
            r2_str = f"  R2模式={r2p['match_rate']}%"
        print(f"  {r['name']:45s}  R1={'✅' if has_r1 else '❌'}  R2={'✅' if has_r2 else '❌'}{r2_str}")

    # Capstone 反汇编
    print(f"\n{'=' * 70}")
    print("第四部分: Capstone 反汇编关键代码")
    print("=" * 70)

    if not HAS_CAPSTONE:
        print("  Capstone 未安装，跳过反汇编")
    else:
        # 1. 反汇编 N3GHT15W 主 EC 入口
        own_path = SPI_DIR / "N3GHT15W_z13_own_20260313.bin"
        if own_path.exists():
            own_data = load_file(own_path)
            main_ec = own_data[0x1000:0x45000]

            print("\n─── N3GHT15W 主 EC 入口 (偏移 0x1000, 即 _EC header) ───")
            insns = capstone_disasm(main_ec[0:200], base_addr=0x1000, max_insns=30)
            for line in insns:
                print(line)

            # _EC header 后的代码起点 (通常在0x100之后)
            # 找第一个 PUSH
            for i in range(0, min(len(main_ec), 0x2000), 2):
                w = main_ec[i] | (main_ec[i+1] << 8)
                if (w & 0xFF00) == 0xB500 and i > 0x100:
                    print(f"\n─── 首个函数序言 @ EC+0x{i:X} (SPI 0x{0x1000+i:X}) ───")
                    insns = capstone_disasm(main_ec[i:i+100], base_addr=0x1000+i, max_insns=20)
                    for line in insns:
                        print(line)
                    break

            # 2. 反汇编 R1 的前 255B (EC匹配前的代码)
            r1 = own_data[R1_START:R1_END]
            print(f"\n─── R1 头部 (0x1C50000, EC匹配前 255B) ───")
            insns = capstone_disasm(r1[:256], base_addr=R1_START, max_insns=40)
            for line in insns:
                print(line)

            # 3. R1 匹配后的不同代码段采样
            r1_diverge = r1[0x10000:0x10000 + 256]
            print(f"\n─── R1 分歧点 (0x1C60000, EC不匹配的旧版代码) ───")
            insns = capstone_disasm(r1_diverge, base_addr=R1_START + 0x10000, max_insns=40)
            for line in insns:
                print(line)

            # 4. 反汇编 R1 中间区域采样
            r1_mid = r1[0x30000:0x30000 + 256]
            print(f"\n─── R1 中段 (0x1C80000, 旧版代码中部) ───")
            insns = capstone_disasm(r1_mid, base_addr=R1_START + 0x30000, max_insns=40)
            for line in insns:
                print(line)

            # 5. 反汇编 R2 首页
            r2 = own_data[R2_START:R2_END]
            print(f"\n─── R2 首页 (0x1D00000) ───")
            insns = capstone_disasm(r2[:256], base_addr=R2_START, max_insns=40)
            for line in insns:
                print(line)

            # 6. 对应 EC 位置反汇编 (用于对比)
            ec_r2_base = 0x1C000
            print(f"\n─── EC[0x1C000] 对应区域 (与R2首页+1应一致) ───")
            insns = capstone_disasm(main_ec[ec_r2_base:ec_r2_base + 256],
                                   base_addr=0x1000 + ec_r2_base, max_insns=40)
            for line in insns:
                print(line)

            # 7. R1 vs EC 函数序言对比
            print(f"\n─── R1 函数序言采样 (独有代码区 0x10000+) ───")
            funcs = disasm_function_prologues(r1[0x10000:], base_addr=R1_START + 0x10000,
                                             max_funcs=10, context_insns=8)
            for f in funcs:
                print(f"\n  函数 @ 0x{f['addr']:08X} (R1+0x{f['offset'] + 0x10000:X}):")
                for line in f["disasm"]:
                    print(f"  {line}")

        # 反汇编 EC0.11 的 R1/R2 区域 (另一个有数据的 dump)
        ec011_path = SPI_DIR / "EC0.11_eng_rev0.4.bin"
        if ec011_path.exists():
            ec011 = load_file(ec011_path)
            ec011_main = ec011[0x1000:0x45000]

            if not all(b == 0xFF for b in ec011[R1_START:R1_START + 4096]):
                print(f"\n{'─' * 60}")
                print(f"─── EC0.11 R1 区域 (0x1C50000) ───")
                r1_011 = ec011[R1_START:R1_END]
                arm_011 = detect_arm_thumb2(r1_011, sample_size=65536)
                print(f"  ARM 检测: prol={arm_011['prologues']} density={arm_011['code_density_pct']}%")
                insns = capstone_disasm(r1_011[:256], base_addr=R1_START, max_insns=40)
                for line in insns:
                    print(line)

                # 与 N3GHT15W R1 对比
                own_r1 = own_data[R1_START:R1_END]
                match_count = sum(1 for a, b in zip(own_r1[:65536], r1_011[:65536]) if a == b)
                print(f"  vs N3GHT15W R1 首64KB: {match_count}/65536 匹配 ({match_count/655.36:.1f}%)")

            if not all(b == 0xFF for b in ec011[R2_START:R2_START + 4096]):
                print(f"\n─── EC0.11 R2 区域 (0x1D00000) ───")
                r2_011 = ec011[R2_START:R2_END]
                arm_011 = detect_arm_thumb2(r2_011, sample_size=65536)
                print(f"  ARM 检测: prol={arm_011['prologues']} density={arm_011['code_density_pct']}%")
                insns = capstone_disasm(r2_011[:256], base_addr=R2_START, max_insns=40)
                for line in insns:
                    print(line)

                # R2 交错模式检测 (用 EC0.11 自己的主 EC)
                r2_check = check_r2_pattern(ec011, ec011_main)
                if r2_check:
                    print(f"  R2→自身EC 交错模式: {r2_check['matches']}/{r2_check['checked']} ({r2_check['match_rate']}%)")

                # 用 N3GHT15W 的主 EC 试
                own_main = own_data[0x1000:0x45000]
                r2_check2 = check_r2_pattern(ec011, own_main)
                if r2_check2:
                    print(f"  R2→N3GHT15W EC 交错模式: {r2_check2['matches']}/{r2_check2['checked']} ({r2_check2['match_rate']}%)")

    # 第五部分: 所有dump中高地址区域(>0x100000)的非空数据分析
    print(f"\n{'=' * 70}")
    print("第五部分: 高地址区域 (>0x100000) 非空数据概览")
    print("=" * 70)

    for r in all_results:
        hi_regions = [reg for reg in r["regions"] if reg["start"] >= 0x100000]
        if hi_regions:
            print(f"\n  {r['name']}:")
            for reg in hi_regions:
                arm_flag = "ARM" if reg["arm"]["code_density_pct"] > 2.0 else "DAT"
                print(f"    0x{reg['start']:07X}-0x{reg['end']:07X}  {reg['size']:>10,}B  "
                      f"{arm_flag} d={reg['arm']['code_density_pct']:.2f}%  prol={reg['arm']['prologues']}")

    # 第六部分: 量产版双镜像与运行时数据区域分析
    print(f"\n{'=' * 70}")
    print("第六部分: 量产版 (N3GHT25W/64W) 运行时数据区 Capstone 采样")
    print("=" * 70)

    for fname in ["N3GHT25W_v1.02.bin", "N3GHT64W_v1.64.bin"]:
        fpath = SPI_DIR / fname
        if not fpath.exists():
            continue

        data = load_file(fpath)
        print(f"\n─── {fname} ───")

        # 扫描 0x100000 之后的区域
        regions = scan_nonempty_regions(data[0x100000:], min_blocks=4)
        for start_rel, end_rel, nblocks in regions[:5]:
            start = start_rel + 0x100000
            end = end_rel + 0x100000
            chunk = data[start:end]

            arm = detect_arm_thumb2(chunk, sample_size=65536)
            arm_flag = "★ARM" if arm["code_density_pct"] > 2.0 else " DATA"
            print(f"  0x{start:07X}-0x{end:07X}  {end-start:>10,}B  {arm_flag}  "
                  f"d={arm['code_density_pct']:.2f}%  prol={arm['prologues']}")

            if HAS_CAPSTONE and arm["code_density_pct"] > 2.0:
                insns = capstone_disasm(chunk[:128], base_addr=start, max_insns=15)
                for line in insns:
                    print(f"    {line}")

    print(f"\n{'=' * 70}")
    print("分析完成")
    print("=" * 70)


if __name__ == "__main__":
    main()
