#!/usr/bin/env python3
"""Debug: check disassembly coverage and LDR patterns"""

import struct
from pathlib import Path
from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB
from capstone.arm import ARM_OP_MEM, ARM_REG_PC

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"

with open(SPI / "N3GHT15W_z13_own_20260313.bin", "rb") as f:
    data = f.read()
ec = data[0x1000:0x45000]
print(f"EC size: {len(ec)} bytes")

md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
md.detail = True

# Count total instructions and LDR variants
total = 0
ldr_count = 0
ldr_pc_count = 0
last_addr = 0
first_gap = None

for insn in md.disasm(ec, 0x1000):
    total += 1
    last_addr = insn.address
    if insn.mnemonic == "ldr":
        ldr_count += 1
        if len(insn.operands) >= 2:
            op2 = insn.operands[1]
            if op2.type == ARM_OP_MEM and op2.mem.base == ARM_REG_PC:
                ldr_pc_count += 1
                if ldr_pc_count <= 5:
                    disp = op2.mem.disp
                    pool_addr = ((insn.address + 4) & ~3) + disp
                    pool_off = pool_addr - 0x1000
                    if 0 <= pool_off <= len(ec) - 4:
                        val = struct.unpack_from("<I", ec, pool_off)[0]
                    else:
                        val = None
                    print(f"  LDR [PC] @ 0x{insn.address:05X}: {insn.mnemonic} {insn.op_str}  disp={disp}  pool_off=0x{pool_off:X}  val={'0x%08X'%val if val else 'OOB'}")

print(f"\nTotal instructions: {total}")
print(f"Last address: 0x{last_addr:05X}")
print(f"LDR total: {ldr_count}")
print(f"LDR [PC]: {ldr_pc_count}")

# Also check: what does the EC header look like?
print(f"\nEC header bytes [0:32]: {ec[:32].hex()}")
print(f"EC bytes [0x500:0x520]: {ec[0x500:0x520]}")

# Check if there's a data region blocking disassembly
# Look at the first LDR instruction manually
print(f"\nFirst 20 instructions:")
md2 = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
md2.detail = True
for i, insn in enumerate(md2.disasm(ec, 0x1000)):
    if i >= 20:
        break
    print(f"  0x{insn.address:05X}: {insn.mnemonic:10s} {insn.op_str}")

# Check where disassembly stops
print(f"\nInstructions around gap (if any):")
md3 = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
md3.detail = False
prev = None
for insn in md3.disasm(ec, 0x1000):
    if prev and insn.address > prev.address + prev.size + 4:
        if first_gap is None:
            first_gap = (prev.address, insn.address)
            print(f"  Gap at 0x{prev.address:05X}+{prev.size} -> 0x{insn.address:05X}")
    prev = insn

if first_gap:
    print(f"First gap: 0x{first_gap[0]:05X} -> 0x{first_gap[1]:05X}")
else:
    print("No gaps detected in linear disassembly")
