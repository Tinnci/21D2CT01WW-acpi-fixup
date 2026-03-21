#!/usr/bin/env python3
"""
EC 固件基址确定 + 精确反汇编

1. 通过 LDR 指针池 + 字符串位置确定 EC 代码基地址
2. 用正确基址反汇编关键函数
3. 量产版高地址区域基址分析
4. 中断向量表 / Reset handler 定位
"""

import struct
from pathlib import Path
from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB

BASE = Path(__file__).resolve().parent.parent
SPI_DIR = BASE / "firmware" / "ec_spi"


def load(name):
    with open(SPI_DIR / name, "rb") as f:
        return f.read()


def disasm(data, offset, base, n=30):
    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = True
    chunk = data[offset:offset + n * 4]
    results = []
    for insn in md.disasm(chunk, base + offset):
        results.append(insn)
        if len(results) >= n:
            break
    return results


def find_vector_table(data, ec_start=0):
    """ARM Cortex-M 向量表: SP_init, Reset, NMI, HardFault, ...
    SP typically points to end of SRAM (0x2000xxxx)
    Reset handler points to code (odd address for Thumb)
    """
    results = []
    for off in range(ec_start, min(ec_start + 0x2000, len(data) - 64), 4):
        sp = struct.unpack_from("<I", data, off)[0]
        reset = struct.unpack_from("<I", data, off + 4)[0]
        nmi = struct.unpack_from("<I", data, off + 8)[0]
        hf = struct.unpack_from("<I", data, off + 12)[0]

        # SP should point to SRAM end (0x2000xxxx, upper range)
        if not (0x20000100 <= sp <= 0x20080000):
            continue
        # Reset handler should be odd (Thumb) and reasonable
        if not (reset & 1):
            continue
        # Reset, NMI, HardFault should be in similar range
        reset_addr = reset & ~1
        nmi_addr = nmi & ~1 if nmi & 1 else nmi
        hf_addr = hf & ~1 if hf & 1 else hf

        # All handlers should point to roughly the same memory region
        if reset_addr < 0x100000 and nmi_addr < 0x100000 and hf_addr < 0x100000:
            results.append({
                "offset": off,
                "sp_init": sp,
                "reset": reset_addr,
                "nmi": nmi_addr,
                "hardfault": hf_addr,
            })

    return results


def analyze_ldr_targets(data, ec_offset, ec_size, test_base):
    """Analyze LDR PC-relative loads to find pointer pool targets,
    then check if they point to known strings/data"""
    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = True
    ec_data = data[ec_offset:ec_offset + ec_size]

    # Find known strings in EC
    strings = {}
    ibm = b"(C) Copyright IBM"
    idx = ec_data.find(ibm)
    if idx != -1:
        strings[idx] = "IBM copyright"

    n3g = b"N3GHT"
    idx = ec_data.find(n3g)
    if idx != -1:
        end = ec_data.index(0, idx) if 0 in ec_data[idx:idx+20] else idx + 10
        strings[idx] = ec_data[idx:end].decode("ascii", errors="replace")

    print(f"  已知字符串位置 (EC blob 内偏移):")
    for off, s in sorted(strings.items()):
        print(f"    EC+0x{off:05X} = \"{s}\"")

    # Disassemble and find LDR Rx, [PC, #imm] instructions
    ldr_hits = []
    chunk_size = min(ec_size, 0x8000)
    for insn in md.disasm(ec_data[:chunk_size], test_base):
        if insn.mnemonic == "ldr" and "pc" in insn.op_str:
            # PC-relative LDR
            # Target = (PC & ~3) + 4 + imm
            # In Thumb mode, PC is current_addr + 4
            if len(insn.operands) == 2 and insn.operands[1].type == 4:  # MEM
                mem = insn.operands[1].mem
                if mem.base == 15:  # PC
                    target_addr = ((insn.address + 4) & ~3) + mem.disp
                    # Read the value at that address
                    target_off = target_addr - test_base
                    if 0 <= target_off < ec_size - 4:
                        value = struct.unpack_from("<I", ec_data, target_off)[0]
                        ldr_hits.append({
                            "insn_addr": insn.address,
                            "pool_addr": target_addr,
                            "pool_off": target_off,
                            "value": value,
                        })

    return ldr_hits, strings


def main():
    print("=" * 70)
    print("EC 固件基址确定 + 精确反汇编")
    print("=" * 70)

    own = load("N3GHT15W_z13_own_20260313.bin")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第一部分: 向量表搜索")
    print("=" * 70)

    # Search in the first 4KB (boot sector)
    boot_vt = find_vector_table(own, ec_start=0)
    print(f"  引导区 (0x0000-0x1000): {len(boot_vt)} 个候选向量表")
    for vt in boot_vt[:3]:
        print(f"    @ 0x{vt['offset']:06X}: SP=0x{vt['sp_init']:08X} "
              f"Reset=0x{vt['reset']:08X} NMI=0x{vt['nmi']:08X} "
              f"HardFault=0x{vt['hardfault']:08X}")

    # Search in EC firmware area
    ec_vt = find_vector_table(own, ec_start=0x1000)
    print(f"  EC 固件区 (0x1000-0x3000): {len(ec_vt)} 个候选向量表")
    for vt in ec_vt[:5]:
        print(f"    @ 0x{vt['offset']:06X}: SP=0x{vt['sp_init']:08X} "
              f"Reset=0x{vt['reset']:08X} NMI=0x{vt['nmi']:08X} "
              f"HardFault=0x{vt['hardfault']:08X}")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第二部分: 基址推导 — LDR 指针池分析")
    print("=" * 70)

    # Test with different base addresses
    ec_offset = 0x1000
    ec_size = 0x44000

    for test_base_label, test_base in [
        ("base=0x00000000", 0x00000000),
        ("base=0x00001000", 0x00001000),
        ("base=0x10000000", 0x10000000),
        ("base=0x08000000", 0x08000000),
    ]:
        print(f"\n─── 测试 {test_base_label} ───")
        ldr_hits, strings = analyze_ldr_targets(own, ec_offset, ec_size, test_base)
        print(f"  LDR [PC] 指令: {len(ldr_hits)} 个")

        if not ldr_hits:
            continue

        # Categorize pool values
        sram_refs = 0      # 0x2000xxxx
        flash_refs = 0     # within EC code range
        peripheral_refs = 0 # 0x4000xxxx
        system_refs = 0    # 0xE000xxxx
        string_refs = 0    # pointing to known strings
        other_refs = 0

        for h in ldr_hits:
            v = h["value"]
            if 0x20000000 <= v < 0x20100000:
                sram_refs += 1
            elif test_base <= v < test_base + ec_size:
                flash_refs += 1
                # Check if it points to a known string
                target_in_ec = v - test_base
                for soff in strings:
                    if abs(target_in_ec - soff) < 4:
                        string_refs += 1
                        print(f"    ★ 字符串指针: LDR @ 0x{h['insn_addr']:08X} → "
                              f"0x{v:08X} → \"{strings[soff]}\" (EC+0x{soff:05X})")
            elif 0x40000000 <= v < 0x50000000:
                peripheral_refs += 1
            elif 0xE0000000 <= v < 0xF0000000:
                system_refs += 1
            else:
                other_refs += 1

        print(f"  SRAM (0x2000xxxx): {sram_refs}")
        print(f"  Flash (本EC范围): {flash_refs}")
        print(f"  外设 (0x4000xxxx): {peripheral_refs}")
        print(f"  系统 (0xE000xxxx): {system_refs}")
        print(f"  其他: {other_refs}")
        print(f"  字符串命中: {string_refs}")

        # Show first few "flash" pointer hits (code references)
        flash_ldr = [h for h in ldr_hits if test_base <= h["value"] < test_base + ec_size]
        if flash_ldr:
            print(f"  Flash 指针样本:")
            for h in flash_ldr[:5]:
                target_ec_off = h["value"] - test_base
                print(f"    @ 0x{h['insn_addr']:08X}: LDR → 0x{h['value']:08X} (EC+0x{target_ec_off:05X})")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第三部分: 确定最佳基址后的反汇编")
    print("=" * 70)

    # Based on analysis, determine the best base
    # Let's check the first word at SPI 0x0000 — if it's a vector table
    first_32 = struct.unpack_from("<8I", own, 0)
    print(f"\n  SPI[0x0000] 前 8 个 32-bit 字:")
    for i, w in enumerate(first_32):
        print(f"    [{i}] 0x{w:08X}")

    first_32_ec = struct.unpack_from("<8I", own, 0x1000)
    print(f"\n  SPI[0x1000] (_EC header) 前 8 个 32-bit 字:")
    for i, w in enumerate(first_32_ec):
        print(f"    [{i}] 0x{w:08X}")

    # Check if SPI[0x0000] looks like IVT
    sp_candidate = first_32[0]
    reset_candidate = first_32[1]
    if 0x20000000 <= sp_candidate < 0x20100000 and (reset_candidate & 1):
        print(f"\n  ★ SPI[0x0000] 可能是 IVT: SP=0x{sp_candidate:08X} Reset=0x{reset_candidate:08X}")
        # The Reset handler address reveals the base address
        # If Reset=0x00001234, and the actual code is at SPI offset 0x1234,
        # then base=0x0000
        # If Reset=0x00002234, and the actual code is at SPI offset 0x1234+0x1000=0x2234,
        # then base=0x0000 (and EC starts at SPI 0x1000)
        print(f"  Reset handler 地址: 0x{reset_candidate & ~1:08X}")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第四部分: 量产版高地址区域基址分析")
    print("=" * 70)

    n25 = load("N3GHT25W_v1.02.bin")
    n64 = load("N3GHT64W_v1.64.bin")

    for name, data in [("N3GHT25W", n25), ("N3GHT64W", n64)]:
        print(f"\n─── {name} ───")

        # Check for vector tables in 0x100000 area (region A)
        vts = find_vector_table(data, ec_start=0x100000)
        if vts:
            print(f"  向量表 @ 0x100000+:")
            for vt in vts[:3]:
                print(f"    @ 0x{vt['offset']:06X}: SP=0x{vt['sp_init']:08X} "
                      f"Reset=0x{vt['reset']:08X}")

        # Check first 32 words at 0x100000
        if len(data) > 0x100080:
            words = struct.unpack_from("<8I", data, 0x100000)
            print(f"  SPI[0x100000] 前 8 个字:")
            for i, w in enumerate(words):
                print(f"    [{i}] 0x{w:08X}")

        # Region B start
        region_b_start = 0x12B000 if name == "N3GHT25W" else 0x12B000
        if len(data) > region_b_start + 64:
            words = struct.unpack_from("<8I", data, region_b_start)
            print(f"  SPI[0x{region_b_start:06X}] (Region B) 前 8 个字:")
            for i, w in enumerate(words):
                print(f"    [{i}] 0x{w:08X}")

            # Check for IVT
            if 0x20000000 <= words[0] < 0x20100000 and (words[1] & 1):
                print(f"    ★ 可能是 IVT!")

        # Region C
        region_c_start = 0x1DC000 if name == "N3GHT25W" else 0x1DC000
        vts_c = find_vector_table(data, ec_start=region_c_start)
        if vts_c:
            print(f"  Region C 向量表:")
            for vt in vts_c[:3]:
                print(f"    @ 0x{vt['offset']:06X}: SP=0x{vt['sp_init']:08X} "
                      f"Reset=0x{vt['reset']:08X}")

    # ================================================================
    print(f"\n{'=' * 70}")
    print("第五部分: EC 固件 SRAM 地址指针模式分析")
    print("=" * 70)

    # Scan main EC for 32-bit values that look like SRAM addresses
    ec_data = own[0x1000:0x45000]
    sram_addrs = {}
    for i in range(0, len(ec_data) - 3, 4):
        v = struct.unpack_from("<I", ec_data, i)[0]
        if 0x20000000 <= v < 0x20010000:
            bucket = v & 0xFFFFF000
            sram_addrs[bucket] = sram_addrs.get(bucket, 0) + 1

    if sram_addrs:
        print("  SRAM 地址 4KB 桶分布:")
        for addr, count in sorted(sram_addrs.items(), key=lambda x: -x[1])[:10]:
            print(f"    0x{addr:08X}: {count} 次")

    # Peripheral addresses
    periph_addrs = {}
    for i in range(0, len(ec_data) - 3, 4):
        v = struct.unpack_from("<I", ec_data, i)[0]
        if 0x40000000 <= v < 0x50000000:
            bucket = v & 0xFFFFF000
            periph_addrs[bucket] = periph_addrs.get(bucket, 0) + 1

    if periph_addrs:
        print("  外设地址 4KB 桶分布:")
        for addr, count in sorted(periph_addrs.items(), key=lambda x: -x[1])[:10]:
            print(f"    0x{addr:08X}: {count} 次")

    # System control addresses (SCB, NVIC, etc.)
    sys_addrs = {}
    for i in range(0, len(ec_data) - 3, 4):
        v = struct.unpack_from("<I", ec_data, i)[0]
        if 0xE0000000 <= v < 0xF0000000:
            bucket = v & 0xFFFFF000
            sys_addrs[bucket] = sys_addrs.get(bucket, 0) + 1

    if sys_addrs:
        print("  系统控制地址分布:")
        for addr, count in sorted(sys_addrs.items(), key=lambda x: -x[1])[:10]:
            print(f"    0x{addr:08X}: {count} 次")

    print(f"\n{'=' * 70}")
    print("分析完成")
    print("=" * 70)


if __name__ == "__main__":
    main()
