#!/usr/bin/env python3
"""Quick checks on remaining unidentified SPI regions."""
import struct
data = open('firmware/ec_spi/N3GHT25W_v1.02.bin','rb').read()

# Check APCB at 0x487000 and 0x496000
for off in [0x487000, 0x496000]:
    magic = data[off:off+8]
    print(f'SPI {off:#09x}: {magic.hex()} ({magic[:4]})')

# Check APOB at 0x499000
off = 0x499000
magic = data[off:off+16]
print(f'SPI {off:#09x}: {magic.hex()} ({magic[:4]})')

# Secondary copy at 0x4D7000
for off in [0x4D7000, 0x4D7010, 0x4D7020]:
    d = data[off:off+16]
    print(f'SPI {off:#09x}: {d.hex()}')

# PSP directory pointer at 0x105000
off = 0x105000
d = data[off:off+16]
print(f'SPI {off:#09x}: {d.hex()} ({d[:4]})')

# R1/R2 journal
for label, off in [('R1', 0x1C50000), ('R2', 0x1D00000)]:
    nz = sum(1 for b in data[off:off+0x1000] if b != 0 and b != 0xFF)
    print(f'{label} @ SPI {off:#09x}: {nz} non-trivial bytes in first 4KB')

# EC area gaps in first 1MB
# 0xC1000 and 0xC5000
for off in [0xC1000, 0xC5000]:
    d = data[off:off+32]
    print(f'SPI {off:#09x}: {d[:16].hex()}')

# EC second copy check
ec2_off = 0xC5000
if data[ec2_off:ec2_off+3] == b'_EC':
    print(f'_EC header found at SPI {ec2_off:#09x}!')
else:
    # Search for _EC in 0xC0000-0xD0000
    for off in range(0xC0000, 0xD0000, 0x100):
        if data[off:off+3] == b'_EC':
            print(f'_EC header found at SPI {off:#09x}!')
            break

# Check gap between EC and PSP
for off in range(0x045000, 0x100000, 0x10000):
    nz = sum(1 for b in data[off:off+0x1000] if b != 0 and b != 0xFF)
    if nz > 32:
        d = data[off:off+8]
        print(f'SPI {off:#09x}: {nz} nz bytes, first 8: {d.hex()}')

# Full 32MB layout summary
print("\n=== SPI Size Utilization ===")
regions = [
    (0x000000, 0x045000, "EC Image (primary)"),
    (0x045000, 0x0C1000, "Gap (EC backup?)"),
    (0x0C1000, 0x0C2000, "Unknown 4KB block"),
    (0x0C5000, 0x100000, "EC code+data (secondary, 0xC5000=LADD#7: 3.5MB)"),
    (0x100000, 0x106000, "LADD dir + PSP cookies"),
    (0x106000, 0x486000, "PSP L2 Directory + FW components"),
    (0x486000, 0x4D7000, "BIOS L2 + APCB + APOB"),
    (0x4D7000, 0x787000, "Secondary PSP/BIOS area"),
    (0x787000, 0xE87000, "UEFI Firmware Volume (7MB)"),
    (0xE87000, 0xF48000, "Post-UEFI region"),
    (0xF48000, 0x1000000, "Gap to 16MB"),
    (0x1000000, 0x2000000, "Upper 16MB (R1/R2, backups)"),
]
for start, end, desc in regions:
    size = end - start
    nz = sum(1 for b in data[start:start+0x1000] if b != 0 and b != 0xFF)
    print(f"  {start:#09x}-{end:#09x} ({size//1024:>5d}KB)  {desc}  [first4KB: {nz}nz]")
