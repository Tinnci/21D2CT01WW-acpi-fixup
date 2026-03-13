#!/usr/bin/env python3
"""Detailed boot config block analysis for NPCX9 SPI mapping."""

import struct

for name in ["firmware/ec/N3GHT68W.FL2", "firmware/ec/N3GHT69W.FL2"]:
    with open(name, "rb") as f:
        data = f.read()

    short = name.split("/")[-1]
    print(f"=== {short}: Boot Config Block (0xE0-0x11F) ===")

    block = data[0xE0:0x120]

    for i in range(0, len(block), 4):
        val = struct.unpack_from("<I", block, i)[0]
        off = 0xE0 + i
        anno = ""
        if val == 0x200C7C00:
            anno = " <- SP (matches vector table)"
        elif val == 0x100701F5:
            anno = " <- Reset vector (Thumb)"
        elif val == 0x10070000:
            anno = " <- Load base address"
        elif val == 0x10070291:
            anno = " <- NMI vector"
        elif 0x10070000 < val < 0x100FFFFF:
            anno = f" <- Code addr (base+0x{val - 0x10070000:X})"
        elif 0x0004E000 <= val <= 0x00051000:
            anno = f" <- Size? ~{val // 1024}KB ({val})"
        elif 0x200C0000 <= val <= 0x200D0000:
            anno = " <- SRAM addr"
        print(f"  [{off:04X}] 0x{val:08X}{anno}")

    # Check if boot block exists inside payload
    boot_block = data[0xE0:0x100]
    payload = data[0x120:]
    pos = payload.find(boot_block)
    if pos >= 0:
        print(f"  Boot block found in payload at SPI offset 0x{pos:06X}")
    else:
        print("  Boot block NOT found in payload")
    print()

# Now decode the 0xE0 block structure
print("=== Boot Config Decoded Structure ===")
data = open("firmware/ec/N3GHT68W.FL2", "rb").read()
block = data[0xE0:0x120]

print(f"  [E0-E3] 0x{struct.unpack_from('<I', block, 0)[0]:08X}  <- Magic/Tag?")
print(f"  [E4-E5] 0x{struct.unpack_from('<H', block, 4)[0]:04X}  <- Boot config version?")

# Decode byte-by-byte for the first 16 bytes
for i in range(16):
    print(f"    byte[{i:2d}] @0x{0xE0 + i:04X} = 0x{block[i]:02X} ({block[i]:3d})")

print()
# Compare boot blocks between versions
data2 = open("firmware/ec/N3GHT69W.FL2", "rb").read()
b1 = data[0xE0:0x120]
b2 = data2[0xE0:0x120]
print("=== Boot Config Comparison (68W vs 69W) ===")
for i in range(0, len(b1), 4):
    v1 = struct.unpack_from("<I", b1, i)[0]
    v2 = struct.unpack_from("<I", b2, i)[0]
    marker = "  SAME" if v1 == v2 else "  **DIFF**"
    off = 0xE0 + i
    print(f"  [{off:04X}] 68W=0x{v1:08X}  69W=0x{v2:08X}{marker}")

print()
print("=== Key Findings ===")
# The 0xE0 block is IDENTICAL between versions except last 8 bytes (checksums)
# This means: addresses, sizes, entry points are all the same
# Only version-specific checksums differ
#
# For NPCX9 flashless boot:
# 1. Boot ROM reads from SPI offset 0
# 2. The "booter" header tells where to load firmware to SRAM
# 3. There might be a separate NPCX9 boot header prepended to the FL2 payload on SPI
#
# We MUST read the actual SPI to determine:
# a) Whether the FL2 0x00-0x11F header is stored on SPI or just packaging
# b) Whether there's additional NPCX9 boot header at SPI offset 0
# c) The total SPI chip capacity
