#!/usr/bin/env python3
"""Check if SPI 0x45000 is an EC backup and verify the dual-image layout."""
import struct
data = open('firmware/ec_spi/N3GHT25W_v1.02.bin','rb').read()

# Check 0x45000 - looks like it starts with "EB" ASCII
d = data[0x45000:0x45040]
print(f"SPI 0x045000: {d[:16].hex()}  ASCII: {d[:8]}")

# Look for _EC header in backup area
for off in range(0x45000, 0xC5000, 0x100):
    if data[off:off+3] == b'_EC':
        print(f"_EC header at SPI {off:#09x}")
        break

# Compare primary EC (0x0000) with what's at 0xC5000 area
# The LADD says entry #7: 0xC5000, size 0x380000 - that's HUGE (3.5MB, not EC)
# Let's check what LADD entry #7 really contains
print(f"\nLADD entry #7 check (SPI 0xC5000, claimed size 0x380000):")
print(f"  First 32 bytes: {data[0xC5000:0xC5020].hex()}")

# Actually, LADD entry #7 offset=0xC5000, size=0x380000 ends at 0x445000
# And entry #20 says offset=0x106000, size=0x380000 ends at 0x486000
# These are the same size! 0x380000 = PSP directory size
# So 0xC5000 might be the PRIMARY PSP directory and 0x106000 is SECONDARY

# Let's check if 0xC5000 has $PL2
if data[0xC5000:0xC5004] == b'$PL2':
    print("  0xC5000 = $PL2 directory (PRIMARY PSP)")
else:
    print(f"  Not $PL2, magic = {data[0xC5000:0xC5004]}")

# Check 0x45000-0xC5000 range content
print(f"\nEC backup region (0x45000-0xC1000):")
# Maybe 0x45000 is EC image copy 2
d = data[0x45000:0x45010]
print(f"  'EB' at 0x45000: {d.hex()}")
# Manually check - it says content starts with 4542 = 'EB'
# Could be EC Backup (EB) marker
# Then 0x45004: 0x45 = 'E', 0x52 = 'R', 0x45 = 'E', 0x42 = 'B'  
# EB08 04 EREB = "EUER" + "EDER"... wait, that's the LADD entry names!
# The LADD entries at SPI 0x44FE2 contain EUER, EDER, EWEB, EREB, ENSR, BGBV, BMBR...
# These are the EC function dispatch table entries!

# Actually 0x45000 continues the LADD at 0x44FE2 (which is inside the EC image)
# The primary EC image is only 0-0x44FFF?
# Let's verify: EC _EC header says total size
ec_hdr = data[0:0x100]
if ec_hdr[:3] == b'_EC':
    ver = ec_hdr[3]
    total = struct.unpack_from("<I", ec_hdr, 8)[0]
    print(f"\n  Primary EC: _EC ver={ver}, total_size={total:#x} ({total//1024}KB)")
    print(f"  EC image ends at SPI {total:#x}")

# So EC is 0-0x4F000 (316KB for N3GHT25W), and the backup area is separate
# The LADD at 0x44FE2 is the EC's own internal LADD

# Now check: is there a second EC copy?
# The LADD at 0x100000 entry #13 says offset=0, size=0x100000
# That means the first 1MB is one logical region
# Entry #6: offset=0xC1000, size=0x1000 
# Entry #7: offset=0xC5000, size=0x380000 = PSP primary
# Entry #20: offset=0x106000, size=0x380000 = PSP secondary  

# So the SPI layout is:
# 0x000000-0x04XXXX = EC image
# 0x04XXXX-0x0C1000 = EC backup / wear-leveling / LADD continuation
# 0x0C1000-0x0C2000 = EC NV config block?  
# 0x0C5000-0x445000 = PSP primary (3.5MB) - if $PL2 not found, it's code
# 0x445000-0x496000 = PSP secondary APCB area
# etc.

# Let me just check if 0xC5000 is Thumb code like the EC
thumb_count = 0
for off in range(0xC5000, 0xC5000+0x2000, 2):
    hw = struct.unpack_from("<H", data, off)[0]
    if (hw & 0xF800) in (0x4800, 0x6800, 0x6000, 0x2000, 0x2800, 0xB400, 0xBD00, 0x4600):
        thumb_count += 1
print(f"\n0xC5000 first 8KB: {thumb_count} Thumb-like halfwords out of 4096")

# Compare with actual EC code
thumb_ec = 0
for off in range(0x1000, 0x3000, 2):
    hw = struct.unpack_from("<H", data, off)[0]
    if (hw & 0xF800) in (0x4800, 0x6800, 0x6000, 0x2000, 0x2800, 0xB400, 0xBD00, 0x4600):
        thumb_ec += 1
print(f"EC 0x1000 first 8KB: {thumb_ec} Thumb-like halfwords out of 4096")

# Is 0x45000-0xC1000 another EC image copy?
# Check if it matches the primary
match_count = 0
for off in range(0, 0x45000):
    backup_off = 0x45000 + off
    if backup_off >= len(data):
        break
    if off < 0x45000 and data[off] == data[backup_off]:
        match_count += 1
pct = 100*match_count/0x45000
print(f"\nEC primary (0-0x45000) vs backup (0x45000-0x8A000): {pct:.1f}% match")

# Check if 0xE2E3A has LADD (the second LADD we found in primary EC)
# The EC image is also present in the backup as a second copy at this offset
ladd2_primary = 0x44FE2  
ladd2_backup = 0xE2E3A
d1 = data[ladd2_primary:ladd2_primary+8]
d2 = data[ladd2_backup:ladd2_backup+8]
print(f"\nLADD in primary EC @ {ladd2_primary:#x}: {d1.hex()} ({d1[:4]})")
print(f"LADD in backup (?) @ {ladd2_backup:#x}: {d2.hex()} ({d2[:4]})")
# 0xE2E3A - 0x44FE2 = 0x9DE58... hmm that's not 0x45000 offset
# 0xE2E3A is within the PSP primary area (0xC5000-0x445000)
# So the LADD at 0xE2E3A is an independent one inside PSP firmware
