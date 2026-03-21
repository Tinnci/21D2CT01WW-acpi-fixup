#!/usr/bin/env python3
"""EC base address detection via direct LDR literal (Thumb T1) byte scanning.

Thumb T1 LDR Rt, [PC, #imm8]:
  encoding: 0100 1ttt iiii iiii
  halfword range: 0x4800 - 0x4FFF
  literal_addr = Align(PC+4, 4) + imm8*4
"""

import struct
from pathlib import Path
from collections import Counter

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"

with open(SPI / "N3GHT15W_z13_own_20260313.bin", "rb") as f:
    data = f.read()
ec = data[0x1000:0x45000]
ec_len = len(ec)
print(f"EC size: {ec_len} bytes ({ec_len/1024:.0f} KB)")

for test_base in [0x10070000, 0x10060000, 0x10080000, 0x0000]:
    ldr_hits = []

    for off in range(0, ec_len - 1, 2):
        hw = struct.unpack_from("<H", ec, off)[0]
        if (hw & 0xF800) == 0x4800:
            rt = (hw >> 8) & 7
            imm8 = hw & 0xFF
            insn_addr = test_base + off
            pc_val = insn_addr + 4
            pool_addr = (pc_val & ~3) + imm8 * 4
            pool_off = pool_addr - test_base
            if 0 <= pool_off <= ec_len - 4:
                val = struct.unpack_from("<I", ec, pool_off)[0]
                ldr_hits.append((off, insn_addr, rt, pool_off, val))

    print(f"\n{'='*60}")
    print(f"base=0x{test_base:08X}: {len(ldr_hits)} LDR Rt,[PC,#imm] hits")

    sram = []
    flash = []
    periph = []
    small = []
    other = []
    for off, ia, rt, po, val in ldr_hits:
        if 0x20000000 <= val < 0x20100000:
            sram.append((off, ia, rt, po, val))
        elif test_base <= val < test_base + ec_len:
            flash.append((off, ia, rt, po, val))
        elif 0x40000000 <= val < 0x50000000:
            periph.append((off, ia, rt, po, val))
        elif val < 0x10000:
            small.append((off, ia, rt, po, val))
        else:
            other.append((off, ia, rt, po, val))

    print(f"  SRAM(0x2000xxxx): {len(sram)}")
    print(f"  Flash(self-ref):  {len(flash)}")
    print(f"  Periph(0x4xxx):   {len(periph)}")
    print(f"  Small(<0x10000):  {len(small)}")
    print(f"  Other:            {len(other)}")

    string_refs = []
    for off, ia, rt, po, val in flash:
        target_off = val - test_base
        if 0 <= target_off < ec_len - 4:
            s = ec[target_off:target_off + 40]
            if all(32 <= b < 127 or b == 0 for b in s[:16]) and s[0] >= 32:
                end = s.index(0) if 0 in s else min(40, len(s))
                if end > 3:
                    string_refs.append((off, ia, val, s[:end].decode("ascii", "replace")))

    if string_refs:
        print(f"  String references ({len(string_refs)}):")
        for off, ia, val, s in string_refs[:20]:
            print(f"    EC+0x{off:05X} (addr 0x{ia:08X}): -> 0x{val:08X} \"{s}\"")

    if sram:
        sram_vals = Counter(val for _, _, _, _, val in sram)
        print(f"  Top SRAM addresses:")
        for val, cnt in sram_vals.most_common(10):
            print(f"    0x{val:08X}: {cnt} refs")

    if periph:
        periph_vals = Counter(val for _, _, _, _, val in periph)
        print(f"  Top Periph addresses:")
        for val, cnt in periph_vals.most_common(10):
            print(f"    0x{val:08X}: {cnt} refs")

    if other:
        print(f"  Other samples:")
        for off, ia, rt, po, val in other[:10]:
            print(f"    EC+0x{off:05X}: -> 0x{val:08X}")

# Also check Thumb-2 32-bit LDR.W literal (T2 encoding)
# first halfword: 0xF8DF (positive offset) or 0xF85F (negative)
print(f"\n{'='*60}")
print("Thumb-2 32-bit LDR.W [PC, #imm12] scan (base=0x1000):")
test_base = 0x1000
ldr32_hits = []
for off in range(0, ec_len - 3, 2):
    hw1 = struct.unpack_from("<H", ec, off)[0]
    hw2 = struct.unpack_from("<H", ec, off + 2)[0]
    if hw1 == 0xF8DF:
        rt = (hw2 >> 12) & 0xF
        imm12 = hw2 & 0xFFF
        insn_addr = test_base + off
        pc_val = insn_addr + 4
        pool_addr = (pc_val & ~3) + imm12
        pool_off = pool_addr - test_base
        if 0 <= pool_off <= ec_len - 4:
            val = struct.unpack_from("<I", ec, pool_off)[0]
            ldr32_hits.append((off, insn_addr, rt, pool_off, val))
    elif hw1 == 0xF85F:
        rt = (hw2 >> 12) & 0xF
        imm12 = hw2 & 0xFFF
        insn_addr = test_base + off
        pc_val = insn_addr + 4
        pool_addr = (pc_val & ~3) - imm12
        pool_off = pool_addr - test_base
        if 0 <= pool_off <= ec_len - 4:
            val = struct.unpack_from("<I", ec, pool_off)[0]
            ldr32_hits.append((off, insn_addr, rt, pool_off, val))

print(f"LDR.W hits: {len(ldr32_hits)}")
sram32 = sum(1 for _, _, _, _, v in ldr32_hits if 0x20000000 <= v < 0x20100000)
flash32 = sum(1 for _, _, _, _, v in ldr32_hits if test_base <= v < test_base + ec_len)
periph32 = sum(1 for _, _, _, _, v in ldr32_hits if 0x40000000 <= v < 0x50000000)
print(f"  SRAM: {sram32}  Flash: {flash32}  Periph: {periph32}")
for off, ia, rt, po, val in ldr32_hits[:15]:
    tag = ""
    if 0x20000000 <= val < 0x20100000:
        tag = "SRAM"
    elif test_base <= val < test_base + ec_len:
        tag = "FLASH"
        target_off = val - test_base
        s = ec[target_off:target_off + 20]
        if all(32 <= b < 127 or b == 0 for b in s[:8]) and s[0] >= 32:
            end = s.index(0) if 0 in s else 20
            tag += f' "{s[:end].decode("ascii","replace")}"'
    elif 0x40000000 <= val < 0x50000000:
        tag = "PERIPH"
    print(f"  EC+0x{off:05X} r{rt}: -> 0x{val:08X} {tag}")
