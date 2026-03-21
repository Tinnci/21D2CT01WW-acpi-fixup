#!/usr/bin/env python3
"""Disassemble Reset handler & full vector table at base=0x10070000"""

import struct
from pathlib import Path
from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB

BASE = 0x10070000
SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"

with open(SPI / "N3GHT15W_z13_own_20260313.bin", "rb") as f:
    data = f.read()
ec = data[0x1000:0x45000]
ec_len = len(ec)

md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
md.detail = False

def disasm_at(offset, count=30, label=""):
    if label:
        print(f"\n{'='*60}")
        print(f"{label}")
    chunk = ec[offset:offset + count * 4]
    for i, insn in enumerate(md.disasm(chunk, BASE + offset)):
        print(f"  0x{insn.address:08X}: {insn.bytes.hex():12s} {insn.mnemonic:10s} {insn.op_str}")
        if i >= count - 1:
            break

# Full vector table at EC+0x0100
print("=" * 60)
print("Cortex-M Vector Table (EC+0x0100, vaddr 0x10070100):")
print("=" * 60)

vector_names = [
    "Initial SP", "Reset", "NMI", "HardFault",
    "MemManage", "BusFault", "UsageFault", "Reserved7",
    "Reserved8", "Reserved9", "Reserved10", "SVCall",
    "DebugMon", "Reserved13", "PendSV", "SysTick",
]

for i in range(min(64, (ec_len - 0x100) // 4)):
    val = struct.unpack_from("<I", ec, 0x100 + i * 4)[0]
    name = vector_names[i] if i < len(vector_names) else f"IRQ{i-16}"
    tag = ""
    if i == 0:
        tag = "SRAM" if 0x20000000 <= val < 0x20100000 else ""
    else:
        if BASE <= (val & ~1) < BASE + ec_len:
            target = (val & ~1) - BASE
            tag = f"-> EC+0x{target:05X}"
        elif val == 0:
            tag = "(unused)"
    print(f"  [{i:3d}] {name:14s}: 0x{val:08X} {tag}")

# Reset handler
disasm_at(0x01F4, 60, "Reset Handler (EC+0x01F4, entry 0x100701F5)")

# NMI handler
disasm_at(0x0290, 20, "NMI Handler (EC+0x0290, entry 0x10070291)")

# HardFault handler
disasm_at(0x029C, 20, "HardFault Handler (EC+0x029C, entry 0x1007029D)")

# Key helper: what does the code at EC+0x02F4 do? (the init loop we saw)
disasm_at(0x02F4, 40, "Flash Init / CRC check (EC+0x02F4)")

# First real function (from prologue scan)
disasm_at(0x166C, 20, "First PUSH function (EC+0x166C)")

# Check the _EC header fields more carefully
print(f"\n{'='*60}")
print("_EC Header interpretation:")
print(f"{'='*60}")
print(f"  [0x00] Magic: _EC")
print(f"  [0x03] Header ver: {ec[3]}")
print(f"  [0x04] 0x{struct.unpack_from('<I', ec, 4)[0]:08X}  (0x00050140)")
ec_off_4 = struct.unpack_from("<H", ec, 4)[0]
ec_off_6 = struct.unpack_from("<H", ec, 6)[0]
print(f"         low16=0x{ec_off_4:04X}={ec_off_4}  high16=0x{ec_off_6:04X}={ec_off_6}")
print(f"  [0x08] Size? 0x{struct.unpack_from('<I', ec, 8)[0]:08X} = {struct.unpack_from('<I', ec, 8)[0]}")
print(f"  [0x0C] Flags? 0x{struct.unpack_from('<I', ec, 0xC)[0]:08X}")
print(f"  [0x10] Version? 0x{struct.unpack_from('<I', ec, 0x10)[0]:08X}")
print(f"  [0x14] CRC/hash? 0x{struct.unpack_from('<I', ec, 0x14)[0]:08X}")
print(f"  [0x40-0x5F] Pad 0xEC")
print(f"  [0x60-0x9F] Hash/Sig (64 bytes)")
print(f"  [0xA0-0xBF] Pad 0xEC")

# Sub-header at 0xC0
print(f"\n  Sub-header at 0xC0:")
for i in range(0xC0, 0x100, 4):
    val = struct.unpack_from("<I", ec, i)[0]
    print(f"    [0x{i:02X}] 0x{val:08X}")

# Known strings in firmware
print(f"\n{'='*60}")
print("Known strings:")
print(f"{'='*60}")
for offset in range(0, ec_len - 8):
    chunk = ec[offset:offset + 40]
    if chunk[:8] == b"N3GHT15W":
        s = chunk[:chunk.index(0)] if 0 in chunk else chunk[:40]
        print(f"  EC+0x{offset:05X} (0x{BASE+offset:08X}): \"{s.decode('ascii','replace')}\"")
    elif chunk[:9] == b"Copyright":
        end = chunk.index(0) if 0 in chunk else 40
        print(f"  EC+0x{offset:05X} (0x{BASE+offset:08X}): \"{chunk[:end].decode('ascii','replace')}\"")
    elif chunk[:4] == b"_EC\x02":
        print(f"  EC+0x{offset:05X} (0x{BASE+offset:08X}): \"_EC\" header marker")

# Summary
print(f"\n{'='*60}")
print("EC FIRMWARE SUMMARY (N3GHT15W)")
print(f"{'='*60}")
print(f"  Architecture:    ARM Cortex-M (Thumb-2)")
print(f"  Flash base:      0x{BASE:08X}")
print(f"  Flash end:       0x{BASE+ec_len:08X}")
print(f"  Flash size:      {ec_len} bytes ({ec_len//1024} KB)")
print(f"  _EC header:      0x{BASE:08X} - 0x{BASE+0xFF:08X} (256 B)")
print(f"  Vector table:    0x{BASE+0x100:08X} - 0x{BASE+0x200:08X}?")
print(f"  Reset handler:   0x{BASE+0x1F4:08X}")
print(f"  NMI handler:     0x{BASE+0x290:08X}")
print(f"  HardFault:       0x{BASE+0x29C:08X}")
print(f"  SRAM:            0x200C0000 - 0x200C8000 (32 KB)")
print(f"  Initial SP:      0x200C8000")
print(f"  VTOR register:   0xE000ED08 (referenced)")
print(f"  Peripheral base: 0x40000000")
