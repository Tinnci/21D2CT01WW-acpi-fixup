#!/usr/bin/env python3
"""Disassemble EC startup code and identify vector table at base=0x10070000"""

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
    """Disassemble from given EC blob offset"""
    if label:
        print(f"\n{'='*60}")
        print(f"{label} (EC+0x{offset:05X}, vaddr 0x{BASE+offset:08X}):")
        print(f"{'='*60}")
    chunk = ec[offset:offset + count * 4]
    n = 0
    for insn in md.disasm(chunk, BASE + offset):
        # Check for literal pool references
        comment = ""
        if insn.mnemonic == "ldr" and "[pc" in insn.op_str:
            pass  # Would need detailed mode
        print(f"  0x{insn.address:08X}:  {insn.bytes.hex():12s}  {insn.mnemonic:10s} {insn.op_str}")
        n += 1
        if n >= count:
            break
    return n

# 1. Check what's at EC+0x0140 (Thumb entry from startup pool: 0x10070141)
disasm_at(0x0140, 40, "Entry point from startup (0x10070141)")

# 2. Startup code area (EC+0x02E0)
disasm_at(0x02E0, 50, "Startup code (EC+0x02E0)")

# 3. Check EC+0x1448 (referenced in startup pool)
disasm_at(0x1448, 30, "EC+0x1448 (from startup pool)")

# 4. Check EC+0x1480 (referenced in startup pool)
disasm_at(0x1480, 30, "EC+0x1480 (from startup pool)")

# 5. Find the _EC header structure
print(f"\n{'='*60}")
print("_EC Header (EC+0x0000):")
print(f"{'='*60}")
print(f"  Magic:    {ec[0:3]}")
print(f"  Version:  0x{ec[3]:02X}")
for i in range(0, 0x100, 4):
    val = struct.unpack_from("<I", ec, i)[0]
    tag = ""
    if BASE <= val < BASE + ec_len:
        tag = f"-> EC+0x{val-BASE:05X}"
    elif 0x20000000 <= val < 0x20100000:
        tag = "SRAM"
    elif val and val < 0x100:
        tag = f"= {val}"
    print(f"  [{i:04X}] 0x{val:08X} {tag}")

# 6. Look for PUSH {r4-r7, lr} function prologues and disassemble each
print(f"\n{'='*60}")
print("First 10 function prologues:")
print(f"{'='*60}")
func_count = 0
for i in range(0, ec_len - 1, 2):
    hw = struct.unpack_from("<H", ec, i)[0]
    if (hw & 0xFF00) == 0xB500:
        n = disasm_at(i, 12, f"Function @ EC+0x{i:05X}")
        func_count += 1
        if func_count >= 10:
            break

# 7. Check the vector table candidate at EC+0x0100
print(f"\n{'='*60}")
print("Potential vector table at various offsets:")
for start in [0x0000, 0x0100, 0x0140, 0x0200, 0x0400, 0x1000, 0x1400, 0x1448]:
    vals = [struct.unpack_from("<I", ec, start + i * 4)[0] for i in range(4)]
    sp_like = 0x20000000 <= vals[0] < 0x20100000
    reset_like = BASE <= (vals[1] & ~1) < BASE + ec_len and (vals[1] & 1)
    nmi_like = BASE <= (vals[2] & ~1) < BASE + ec_len and (vals[2] & 1)
    tag = ""
    if sp_like and reset_like:
        tag = " ← VECTOR TABLE CANDIDATE!"
    print(f"  [{start:04X}]: SP=0x{vals[0]:08X}{'✓' if sp_like else '✗'} "
          f"Reset=0x{vals[1]:08X}{'✓' if reset_like else '✗'} "
          f"NMI=0x{vals[2]:08X}{'✓' if nmi_like else '✗'} "
          f"HF=0x{vals[3]:08X}{tag}")

# 8. Scan entire EC for vector table pattern: [SRAM_addr, Thumb_addr, Thumb_addr, Thumb_addr]
print(f"\n{'='*60}")
print("Full vector table scan (SP+3 consecutive Thumb ptrs):")
for i in range(0, ec_len - 15, 4):
    sp = struct.unpack_from("<I", ec, i)[0]
    if not (0x200C0000 <= sp <= 0x200C8000):
        continue
    v1 = struct.unpack_from("<I", ec, i + 4)[0]
    v2 = struct.unpack_from("<I", ec, i + 8)[0]
    v3 = struct.unpack_from("<I", ec, i + 12)[0]
    if all((v & 1) and BASE <= (v & ~1) < BASE + ec_len for v in [v1, v2, v3]):
        print(f"  EC+0x{i:05X}: SP=0x{sp:08X} Reset=0x{v1:08X} NMI=0x{v2:08X} HF=0x{v3:08X}")
