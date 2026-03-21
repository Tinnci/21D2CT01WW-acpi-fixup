#!/usr/bin/env python3
"""Check vector table size and VTOR setup, plus startup code pool"""

import struct
from pathlib import Path

BASE = 0x10070000
SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi"

with open(SPI / "N3GHT15W_z13_own_20260313.bin", "rb") as f:
    data = f.read()
ec = data[0x1000:0x45000]
ec_len = len(ec)

# 1. Extended vector table at EC+0x0100 — check how far it goes
print("Extended vector table scan from EC+0x0100:")
print("Format: [idx] offset → value (classification)")
for i in range(256):  # up to 256 entries
    off = 0x100 + i * 4
    if off + 4 > ec_len:
        break
    val = struct.unpack_from("<I", ec, off)[0]
    if i == 0:
        # SP
        tag = f"SP=0x{val:08X}"
    elif val == 0:
        tag = "(unused)"
    elif (val & 1) and BASE <= (val & ~1) < BASE + ec_len:
        tag = f"Thumb -> EC+0x{(val&~1)-BASE:05X}"
    elif BASE <= val < BASE + ec_len:
        tag = f"-> EC+0x{val-BASE:05X}"
    elif 0x20000000 <= val < 0x20100000:
        tag = f"SRAM 0x{val:08X}"
    else:
        tag = f"invalid? 0x{val:08X}"
    # Check if all subsequent are 0 (end of table)
    if val == 0 and i > 15:
        # Check next 4 entries
        all_zero = True
        for j in range(1, 5):
            if off + j * 4 + 4 <= ec_len:
                if struct.unpack_from("<I", ec, off + j * 4)[0] != 0:
                    all_zero = False
                    break
        if all_zero:
            print(f"  [{i:3d}] EC+0x{off:04X}: 0x{val:08X} {tag}  ← end of table (5+ zeros)")
            break
    # Only print non-zero or first 16
    if i < 16 or val != 0:
        print(f"  [{i:3d}] EC+0x{off:04X}: 0x{val:08X} {tag}")

# 2. Literal pool for startup code at EC+0x02F4
# The startup code uses LDR Rx, [PC, #offset] instructions
# Pool is after the code, around EC+0x0428 onwards
print(f"\nStartup code literal pool (EC+0x0428-0x0448):")
for off in range(0x0420, 0x0458, 4):
    val = struct.unpack_from("<I", ec, off)[0]
    tag = ""
    if BASE <= val < BASE + ec_len:
        tag = f"-> EC+0x{val-BASE:05X}"
    elif (val & ~1) and BASE <= (val & ~1) < BASE + ec_len:
        tag = f"-> EC+0x{(val&~1)-BASE:05X} (Thumb)"
    elif 0x20000000 <= val < 0x20100000:
        tag = f"SRAM"
    elif val == 0xE000ED08:
        tag = "SCB_VTOR"
    elif 0xE0000000 <= val < 0xF0000000:
        tag = "ARM_SYS"
    print(f"  EC+0x{off:04X}: 0x{val:08X} {tag}")

# 3. String versions and copyright
print(f"\nVersion string at EC+0x0500:")
print(f"  {ec[0x500:0x540]}")

print(f"\nCopyright at EC+0x1580:")
print(f"  {ec[0x1580:0x1600]}")

# 4. Check secondary vector table at EC+0x28478
print(f"\nSecondary vector table at EC+0x28478:")
for i in range(8):
    off = 0x28478 + i * 4
    if off + 4 <= ec_len:
        val = struct.unpack_from("<I", ec, off)[0]
        tag = ""
        if i == 0 and 0x20000000 <= val < 0x20100000:
            tag = "SP (SRAM)"
        elif (val & 1) and BASE <= (val & ~1) < BASE + ec_len:
            tag = f"Thumb -> EC+0x{(val&~1)-BASE:05X}"
        print(f"  [{i}] 0x{val:08X} {tag}")

# 5. SPI offset 0x45000+ check: is there more EC firmware?
print(f"\nSPI beyond 0x45000 (check for more firmware):")
beyond = data[0x45000:0x50000]
non_ff = sum(1 for b in beyond if b != 0xFF)
non_00 = sum(1 for b in beyond if b != 0x00)
print(f"  SPI 0x45000-0x50000: {len(beyond)} bytes, non-FF={non_ff}, non-00={non_00}")
if non_ff > 100:
    # Show first non-FF block
    for i in range(len(beyond)):
        if beyond[i] != 0xFF:
            print(f"  First non-FF at SPI 0x{0x45000+i:05X}: {beyond[i:i+32].hex()}")
            break
