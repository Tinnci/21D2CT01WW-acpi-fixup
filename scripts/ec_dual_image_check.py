#!/usr/bin/env python3
"""Investigate the second EC image at SPI 0xA0000 and map the full EC SPI area."""
import struct
data = open('firmware/ec_spi/N3GHT25W_v1.02.bin','rb').read()

# Second _EC header at 0xA0000
off = 0xA0000
hdr = data[off:off+0x100]
ver = hdr[3]
total = struct.unpack_from("<I", hdr, 8)[0]
print(f"Second EC @ SPI {off:#09x}: _EC ver={ver}, total={total:#x} ({total//1024}KB)")
print(f"  Header bytes: {hdr[:32].hex()}")

# First EC
off0 = 0
hdr0 = data[off0:off0+0x100]
total0 = struct.unpack_from("<I", hdr0, 8)[0]
print(f"\nFirst  EC @ SPI {off0:#09x}: _EC ver={hdr0[3]}, total={total0:#x} ({total0//1024}KB)")

# Compare version strings
vt_off_1 = 0x0100 if hdr0[3] == 2 else 0x0120  
# Version string is at EC+0x508  
for label, base in [("Primary", 0), ("Secondary", 0xA0000)]:
    ver_str = data[base+0x508:base+0x520].split(b'\x00')[0]
    print(f"  {label} version: {ver_str}")

# Are they identical?
match = sum(1 for i in range(total0) if data[i] == data[0xA0000+i])
print(f"\nByte-for-byte match: {match}/{total0} ({100*match/total0:.1f}%)")

# What's between EC1 end and EC2 start?
ec1_end = total0
ec2_start = 0xA0000
gap = data[ec1_end:ec2_start]
nz = sum(1 for b in gap if b != 0 and b != 0xFF)
print(f"\nGap between EC1 (end {ec1_end:#x}) and EC2 (start {ec2_start:#x}):")
print(f"  Size: {ec2_start-ec1_end:#x} ({(ec2_start-ec1_end)//1024}KB)")
print(f"  Non-trivial bytes: {nz}")

# Check what's in the gap
for off in range(ec1_end, ec2_start, 0x10000):
    chunk = data[off:off+0x1000]
    nz_chunk = sum(1 for b in chunk if b != 0 and b != 0xFF)
    if nz_chunk > 64:
        first8 = data[off:off+8].hex()
        print(f"    SPI {off:#09x}: {nz_chunk} nz bytes, start: {first8}")

# What's after EC2?
ec2_end = 0xA0000 + total0
print(f"\nEC2 ends at SPI {ec2_end:#x}")
for off in [ec2_end, 0xC1000, 0xC2000, 0xC5000]:
    d = data[off:off+16]
    nz_d = sum(1 for b in d if b != 0 and b != 0xFF)
    print(f"  SPI {off:#x}: {d.hex()} ({'content' if nz_d > 0 else 'empty'})")

# Check the 0xC5000 area - PSP or EC boot shim?
# The LADD says 0xC5000 size=0x380000
# But 0xC5000 contains Thumb code (671 hits), not $PL2
# Let's look for strings
strings = []
region = data[0xC5000:0xC5000+0x2000]
s = b''
for i, b in enumerate(region):
    if 32 <= b < 127:
        s += bytes([b])
    else:
        if len(s) >= 6:
            strings.append((i-len(s), s.decode()))
        s = b''
print(f"\nStrings at 0xC5000-0xC7000:")
for off, s in strings[:10]:
    print(f"  +{off:#06x}: \"{s}\"")

# Summary: the 1MB EC SPI area layout
print(f"\n{'='*60}")
print(f"EC SPI Chip (W25Q256) Layout (first 1MB)")
print(f"{'='*60}")
print(f"  0x000000-{total0:#07x}  EC image 1 ({total0//1024}KB)")
print(f"  {total0:#07x}-0x0A0000  Gap / EC overlay data")
print(f"  0x0A0000-{0xA0000+total0:#07x}  EC image 2 ({total0//1024}KB)")
print(f"  {0xA0000+total0:#07x}-0x0C1000  Gap")
print(f"  0x0C1000-0x0C2000  EC NV config (4KB)")
print(f"  0x0C5000-0x100000  EC boot shim / Thumb code")
