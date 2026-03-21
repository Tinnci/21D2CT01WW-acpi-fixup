#!/usr/bin/env python3
"""Detailed EC base address verification at 0x10070000.

Verifies: Thumb function pointers (odd), string refs, known data,
entry point structure, memory map.
"""

import struct
from pathlib import Path
from collections import Counter

BASE = 0x10070000
SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"

with open(SPI / "N3GHT15W_z13_own_20260313.bin", "rb") as f:
    data = f.read()
ec = data[0x1000:0x45000]
ec_len = len(ec)
EC_END = BASE + ec_len

print(f"EC: SPI 0x1000-0x45000 ({ec_len} bytes)")
print(f"Virtual: 0x{BASE:08X}-0x{EC_END:08X}")

# Collect ALL LDR literal references (T1 + T2)
refs = []

# T1: 16-bit LDR Rt,[PC,#imm8]
for off in range(0, ec_len - 1, 2):
    hw = struct.unpack_from("<H", ec, off)[0]
    if (hw & 0xF800) == 0x4800:
        imm8 = hw & 0xFF
        ia = BASE + off
        pool_addr = ((ia + 4) & ~3) + imm8 * 4
        pool_off = pool_addr - BASE
        if 0 <= pool_off <= ec_len - 4:
            val = struct.unpack_from("<I", ec, pool_off)[0]
            refs.append(("T1", off, pool_off, val))

# T2: 32-bit LDR.W Rt,[PC,#+imm12] (0xF8DF)
for off in range(0, ec_len - 3, 2):
    hw1, hw2 = struct.unpack_from("<HH", ec, off)
    if hw1 == 0xF8DF:
        imm12 = hw2 & 0xFFF
        ia = BASE + off
        pool_addr = ((ia + 4) & ~3) + imm12
        pool_off = pool_addr - BASE
        if 0 <= pool_off <= ec_len - 4:
            val = struct.unpack_from("<I", ec, pool_off)[0]
            refs.append(("T2", off, pool_off, val))
    elif hw1 == 0xF85F:
        imm12 = hw2 & 0xFFF
        ia = BASE + off
        pool_addr = ((ia + 4) & ~3) - imm12
        pool_off = pool_addr - BASE
        if 0 <= pool_off <= ec_len - 4:
            val = struct.unpack_from("<I", ec, pool_off)[0]
            refs.append(("T2n", off, pool_off, val))

print(f"\nTotal LDR literal refs: {len(refs)}")

# Categorize
flash_refs = [(t,o,p,v) for t,o,p,v in refs if BASE <= v < EC_END]
sram_refs =  [(t,o,p,v) for t,o,p,v in refs if 0x20000000 <= v < 0x20100000]
periph_refs = [(t,o,p,v) for t,o,p,v in refs if 0x40000000 <= v < 0x50000000]
arm_sys = [(t,o,p,v) for t,o,p,v in refs if 0xE0000000 <= v < 0xF0000000]
other = [(t,o,p,v) for t,o,p,v in refs
         if not (BASE <= v < EC_END) and not (0x20000000 <= v < 0x20100000)
         and not (0x40000000 <= v < 0x50000000) and not (0xE0000000 <= v < 0xF0000000)]

print(f"  Flash self-ref:    {len(flash_refs)}")
print(f"  SRAM:              {len(sram_refs)}")
print(f"  Peripheral:        {len(periph_refs)}")
print(f"  ARM system:        {len(arm_sys)}")
print(f"  Other:             {len(other)}")

# Analyze flash self-refs: Thumb function pointers vs data pointers
thumb_funcs = []
data_ptrs = []
for t, o, p, v in flash_refs:
    target_off = v - BASE
    if v & 1:  # Thumb function pointer (LSB = 1)
        thumb_funcs.append((o, v, target_off))
    else:
        data_ptrs.append((o, v, target_off))

print(f"\n  Flash refs: {len(thumb_funcs)} Thumb func ptrs + {len(data_ptrs)} data ptrs")

# Verify Thumb function pointers: do they point to PUSH instructions?
valid_push = 0
for o, v, toff in thumb_funcs:
    real_off = toff & ~1  # Clear Thumb bit
    if real_off < ec_len - 1:
        hw = struct.unpack_from("<H", ec, real_off)[0]
        if (hw & 0xFF00) == 0xB500:  # PUSH {.., LR}
            valid_push += 1

print(f"  Thumb ptrs -> PUSH {{..LR}}: {valid_push}/{len(thumb_funcs)} ({100*valid_push/max(1,len(thumb_funcs)):.1f}%)")

# Show some Thumb function pointers
print(f"\n  Sample Thumb function pointers:")
for o, v, toff in thumb_funcs[:15]:
    real_off = toff & ~1
    hw = struct.unpack_from("<H", ec, real_off)[0] if real_off < ec_len - 1 else 0
    mnemonic = "PUSH" if (hw & 0xFF00) == 0xB500 else f"0x{hw:04X}"
    print(f"    EC+0x{o:05X}: -> 0x{v:08X} (EC+0x{real_off:05X}) [{mnemonic}]")

# Show data pointers — check for strings
print(f"\n  Sample data pointers (strings):")
for o, v, toff in data_ptrs[:30]:
    if toff < ec_len - 4:
        chunk = ec[toff:toff + 60]
        if all(32 <= b < 127 or b == 0 for b in chunk[:20]) and chunk[0] >= 32:
            end = chunk.index(0) if 0 in chunk else min(60, len(chunk))
            if end > 2:
                s = chunk[:end].decode("ascii", "replace")
                print(f"    EC+0x{o:05X}: -> 0x{v:08X} (EC+0x{toff:05X}) \"{s[:50]}\"")

# ARM System Space
print(f"\n  ARM system registers:")
for t, o, p, v in arm_sys:
    names = {
        0xE000E010: "SysTick_CTRL",
        0xE000E100: "NVIC_ISER0",
        0xE000E180: "NVIC_ICER0",
        0xE000E200: "NVIC_ISPR0",
        0xE000E280: "NVIC_ICPR0",
        0xE000ED00: "SCB_CPUID",
        0xE000ED04: "SCB_ICSR",
        0xE000ED08: "SCB_VTOR",
        0xE000ED0C: "SCB_AIRCR",
        0xE000ED10: "SCB_SCR",
        0xE000EF00: "SCB_STIR",
    }
    name = names.get(v, "")
    print(f"    EC+0x{o:05X}: -> 0x{v:08X} {name}")

# Check the initial words at EC start (potential vector table info)
print(f"\nEC header analysis (first 64 bytes):")
for i in range(0, 64, 4):
    val = struct.unpack_from("<I", ec, i)[0]
    tag = ""
    if BASE <= val < EC_END:
        tag = f"-> EC+0x{val-BASE:05X}"
    elif (val & ~1) and BASE <= (val & ~1) < EC_END:
        tag = f"-> EC+0x{(val&~1)-BASE:05X} (Thumb)"
    elif 0x20000000 <= val < 0x20100000:
        tag = f"SRAM"
    print(f"  [{i:3d}] 0x{val:08X} {tag}")

# Check EC+0x2F0 area (where 0x10070000 pointer was found)
print(f"\nEC+0x2F0 area (startup code / reset vector):")
for i in range(0x2E0, 0x380, 4):
    val = struct.unpack_from("<I", ec, i)[0]
    tag = ""
    if BASE <= val < EC_END:
        tag = f"-> EC+0x{val-BASE:05X}"
    elif (val & ~1) and BASE <= (val & ~1) < EC_END:
        tag = f"-> EC+0x{(val&~1)-BASE:05X} (Thumb)"
    elif 0x20000000 <= val < 0x20100000:
        tag = "SRAM"
    elif 0xE0000000 <= val < 0xF0000000:
        tag = "ARM_SYS"
    print(f"  [0x{i:04X}] 0x{val:08X} {tag}")

# Memory map summary
print(f"\n{'='*60}")
print("Memory Map Summary:")
print(f"  Code Flash:  0x{BASE:08X} - 0x{EC_END:08X} (272KB)")
sram_lo = min(v for _, _, _, v in sram_refs)
sram_hi = max(v for _, _, _, v in sram_refs) + 4
print(f"  SRAM:        0x{sram_lo:08X} - 0x{sram_hi:08X} (~{(sram_hi-sram_lo)/1024:.0f}KB)")
periph_lo = min(v for _, _, _, v in periph_refs)
periph_hi = max(v for _, _, _, v in periph_refs)
print(f"  Peripherals: 0x{periph_lo:08X} - 0x{periph_hi:08X}")
if arm_sys:
    print(f"  ARM System:  {', '.join(f'0x{v:08X}' for _, _, _, v in arm_sys[:5])}")

# "Other" value distribution
print(f"\nOther value ranges:")
other_vals = [v for _, _, _, v in other]
ranges = Counter()
for v in other_vals:
    if v < 0x10000:
        ranges["< 0x10000"] += 1
    elif 0x10000000 <= v < 0x10070000:
        ranges["0x1000-0x1006xxxx (before EC)"] += 1
    elif 0x100B4000 <= v < 0x11000000:
        ranges["0x100B4-0x10FF (after EC)"] += 1
    else:
        ranges[f"0x{v>>28:X}xxxxxxx"] += 1
for r, c in ranges.most_common():
    print(f"  {r}: {c}")
