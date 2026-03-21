#!/usr/bin/env python3
"""
EC 基址确定 v2 — 修正 LDR 指针池分析 + LADD 描述符解析
"""

import struct
from pathlib import Path
from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB, CS_MODE_ARM
from capstone.arm import ARM_OP_MEM

BASE = Path(__file__).resolve().parent.parent
SPI_DIR = BASE / "firmware" / "ec_spi"


def load(name):
    with open(SPI_DIR / name, "rb") as f:
        return f.read()


def main():
    print("=" * 70)
    print("EC 基址确定 v2")
    print("=" * 70)

    own = load("N3GHT15W_z13_own_20260313.bin")
    ec_data = own[0x1000:0x45000]  # 272KB main EC

    # ================================================================
    # 第一部分: 修正 LDR [PC] 分析
    # ================================================================
    print(f"\n{'=' * 70}")
    print("第一部分: LDR 指针池 (修正版)")
    print("=" * 70)

    for test_base in [0x0000, 0x1000]:
        md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
        md.detail = True

        ldr_pool = []  # (insn_addr, pool_addr, loaded_value)

        # Only disasm from the code start (skip _EC header)
        code_start = 0x166C  # first function prologue from previous analysis
        chunk = ec_data[code_start:]

        for insn in md.disasm(chunk, test_base + code_start):
            if insn.mnemonic == "ldr" and len(insn.operands) == 2:
                op2 = insn.operands[1]
                if op2.type == ARM_OP_MEM and op2.mem.base == 15:  # PC
                    disp = op2.mem.disp
                    pool_addr = ((insn.address + 4) & ~3) + disp
                    pool_ec_off = pool_addr - test_base
                    if 0 <= pool_ec_off <= len(ec_data) - 4:
                        val = struct.unpack_from("<I", ec_data, pool_ec_off)[0]
                        ldr_pool.append((insn.address, pool_addr, pool_ec_off, val))
            if len(ldr_pool) >= 200:
                break

        print(f"\n─── base=0x{test_base:04X} ───")
        print(f"  LDR [PC] 命中: {len(ldr_pool)} 个")

        # Classify values
        sram = flash_self = periph = sys_ctrl = small = other = 0
        string_hits = []
        for ia, pa, po, val in ldr_pool:
            if 0x20000000 <= val < 0x20100000:
                sram += 1
            elif test_base <= val < test_base + len(ec_data):
                flash_self += 1
                # Check if it points to a printable string
                str_off = val - test_base
                if str_off < len(ec_data) - 4:
                    s = ec_data[str_off:str_off + 32]
                    if all(32 <= b < 127 or b == 0 for b in s) and s[0] >= 32:
                        end = s.index(0) if 0 in s else len(s)
                        if end > 3:
                            string_hits.append((ia, val, s[:end].decode("ascii")))
            elif 0x40000000 <= val < 0x50000000:
                periph += 1
            elif 0xE0000000 <= val < 0xF0000000:
                sys_ctrl += 1
            elif val < 0x10000:
                small += 1
            else:
                other += 1

        print(f"  SRAM (0x2000xxxx): {sram}")
        print(f"  自身代码: {flash_self}")
        print(f"  外设: {periph}")
        print(f"  系统: {sys_ctrl}")
        print(f"  小值 (<0x10000): {small}")
        print(f"  其他: {other}")
        print(f"  字符串命中: {len(string_hits)}")

        for ia, val, s in string_hits[:10]:
            print(f"    0x{ia:06X}: LDR → 0x{val:08X} → \"{s}\"")

        # Show SRAM pointer samples
        sram_samples = [(ia, pa, po, val) for ia, pa, po, val in ldr_pool
                       if 0x20000000 <= val < 0x20100000]
        if sram_samples:
            print(f"  SRAM 指针样本:")
            for ia, pa, po, val in sram_samples[:8]:
                print(f"    0x{ia:06X}: LDR → 0x{val:08X}")

        # Show peripheral pointer samples
        periph_samples = [(ia, pa, po, val) for ia, pa, po, val in ldr_pool
                         if 0x40000000 <= val < 0x50000000]
        if periph_samples:
            print(f"  外设指针样本:")
            for ia, pa, po, val in periph_samples[:8]:
                print(f"    0x{ia:06X}: LDR → 0x{val:08X}")

        # Show flash-self pointer samples
        flash_samples = [(ia, pa, po, val) for ia, pa, po, val in ldr_pool
                        if test_base <= val < test_base + len(ec_data) and
                        not any(val == s[1] for s in string_hits)]
        if flash_samples:
            print(f"  自身代码指针样本:")
            for ia, pa, po, val in flash_samples[:8]:
                print(f"    0x{ia:06X}: LDR → 0x{val:08X} (EC+0x{val-test_base:05X})")

    # ================================================================
    # 第二部分: LADD 描述符表解析
    # ================================================================
    print(f"\n{'=' * 70}")
    print("第二部分: LADD 固件布局描述符")
    print("=" * 70)

    n25 = load("N3GHT25W_v1.02.bin")
    n64 = load("N3GHT64W_v1.64.bin")

    for name, data in [("N3GHT25W", n25), ("N3GHT64W", n64)]:
        ladd_magic = b"LADD"
        idx = data.find(ladd_magic, 0x100000)
        if idx == -1:
            continue

        print(f"\n─── {name} LADD @ 0x{idx:06X} ───")

        # Parse LADD header
        sig = data[idx:idx + 4]
        flags = struct.unpack_from("<I", data, idx + 4)[0]
        print(f"  Signature: {sig}  Flags/Size: 0x{flags:08X}")

        # Parse entries (assuming 8-byte entries: address + size)
        print(f"  条目:")
        for i in range(20):
            entry_off = idx + 8 + i * 8
            if entry_off + 8 > len(data):
                break
            addr = struct.unpack_from("<I", data, entry_off)[0]
            size = struct.unpack_from("<I", data, entry_off + 4)[0]
            if addr == 0 and size == 0:
                break
            if addr == 0xFFFFFFFF:
                break
            print(f"    [{i:2d}] addr=0x{addr:08X}  size=0x{size:08X} ({size:>10,}B)")

        # Dump raw hex around LADD
        print(f"  原始数据 (前128字节):")
        for off in range(0, 128, 16):
            hexb = data[idx + off:idx + off + 16].hex()
            print(f"    0x{idx + off:06X}: {hexb}")

    # ================================================================
    # 第三部分: N3GHT64W Region B — ARM 32-bit 模式分析
    # ================================================================
    print(f"\n{'=' * 70}")
    print("第三部分: N3GHT64W Region B ARM 32-bit 分析")
    print("=" * 70)

    chunk = n64[0x12B000:0x12B000 + 512]
    md_arm = Cs(CS_ARCH_ARM, CS_MODE_ARM)
    md_arm.detail = False

    print(f"\n  ARM 32-bit 反汇编 (0x12B000):")
    for insn in md_arm.disasm(chunk, 0x12B000):
        print(f"    0x{insn.address:08X}: {insn.mnemonic:10s} {insn.op_str}")
        if insn.address - 0x12B000 > 200:
            break

    # Also try Thumb
    md_thumb = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md_thumb.detail = False

    print(f"\n  Thumb-2 反汇编 (0x12B000):")
    count = 0
    for insn in md_thumb.disasm(chunk, 0x12B000):
        print(f"    0x{insn.address:08X}: {insn.mnemonic:10s} {insn.op_str}")
        count += 1
        if count > 30:
            break

    # N3GHT25W Region B — Thumb
    chunk25 = n25[0x12B000:0x12B000 + 512]
    print(f"\n  N3GHT25W Region B Thumb-2 反汇编 (0x12B000):")
    count = 0
    for insn in md_thumb.disasm(chunk25, 0x12B000):
        print(f"    0x{insn.address:08X}: {insn.mnemonic:10s} {insn.op_str}")
        count += 1
        if count > 30:
            break

    # ================================================================
    # 第四部分: 扫描更多 LDR 池 (覆盖完整 EC)
    # ================================================================
    print(f"\n{'=' * 70}")
    print("第四部分: 完整 EC LDR 池扫描 (base=0x0)")
    print("=" * 70)

    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = True
    test_base = 0

    all_ldr = []
    for insn in md.disasm(ec_data, test_base):
        if insn.mnemonic == "ldr" and len(insn.operands) == 2:
            op2 = insn.operands[1]
            if op2.type == ARM_OP_MEM and op2.mem.base == 15:
                disp = op2.mem.disp
                pool_addr = ((insn.address + 4) & ~3) + disp
                pool_off = pool_addr - test_base
                if 0 <= pool_off <= len(ec_data) - 4:
                    val = struct.unpack_from("<I", ec_data, pool_off)[0]
                    all_ldr.append((insn.address, val))

    print(f"  总 LDR [PC] 指令: {len(all_ldr)} 个")

    # Categorize
    cats = {"SRAM": 0, "periph": 0, "flash_0base": 0, "flash_1000base": 0,
            "small": 0, "system": 0, "other": 0}
    for ia, val in all_ldr:
        if 0x20000000 <= val < 0x20100000:
            cats["SRAM"] += 1
        elif 0x40000000 <= val < 0x50000000:
            cats["periph"] += 1
        elif 0 <= val < 0x44000:
            cats["flash_0base"] += 1
        elif 0x1000 <= val < 0x45000:
            cats["flash_1000base"] += 1
        elif val < 0x10000:
            cats["small"] += 1
        elif 0xE0000000 <= val < 0xF0000000:
            cats["system"] += 1
        else:
            cats["other"] += 1

    for k, v in cats.items():
        print(f"  {k}: {v}")

    # Find string references
    print(f"\n  字符串引用:")
    for ia, val in all_ldr:
        for candidate_base in [0, 0x1000]:
            str_off = val - candidate_base
            if 0 <= str_off < len(ec_data) - 4:
                s = ec_data[str_off:str_off + 40]
                if all(32 <= b < 127 or b == 0 for b in s[:20]) and s[0] >= 32:
                    end = s.index(0) if 0 in s else 20
                    if end > 3:
                        txt = s[:end].decode("ascii", errors="replace")
                        print(f"    0x{ia:05X}: LDR → 0x{val:08X} "
                              f"(base={candidate_base:#x}) → \"{txt}\"")
                        break

    print(f"\n{'=' * 70}")
    print("分析完成")
    print("=" * 70)


if __name__ == "__main__":
    main()
