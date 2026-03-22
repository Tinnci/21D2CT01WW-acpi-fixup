#!/usr/bin/env python3
"""Quick check: why do 0x10060000 and 0x10070000 get same flash ref count for N3GHT14T"""
import struct

data = open('firmware/ec_spi/EC0.01_eng_rev0.4.bin','rb').read()
blob = data[0x1000:0x1000+0x50000]

for base in [0x10060000, 0x10070000, 0x10080000]:
    refs = []
    for off in range(0, len(blob)-1, 2):
        hw = struct.unpack_from('<H', blob, off)[0]
        if 0x4800 <= hw <= 0x4FFF:
            reg_off = (hw & 0xFF) * 4
            pc_aligned = (off + 4) & ~3
            lit_off = pc_aligned + reg_off
            if lit_off + 4 <= len(blob):
                val = struct.unpack_from('<I', blob, lit_off)[0]
                if base <= val < base + len(blob):
                    refs.append((off, val))
    
    lo = sum(1 for _,v in refs if v < base + 0x10000)
    hi = sum(1 for _,v in refs if v >= base + 0x10000)
    print(f'base={base:#010x}: {len(refs)} total refs, {lo} in first 64K, {hi} in upper region')
    
    if refs:
        vals = [v for _,v in refs]
        print(f'  target range: {min(vals):#010x} - {max(vals):#010x}')
        thumb = sum(1 for v in vals if v & 1)
        print(f'  Thumb func ptrs: {thumb}, data ptrs: {len(vals)-thumb}')

# Now check: for base=0x10060000, refs in range [0x10060000, 0x10070000) 
# correspond to blob[0:0x10000] — these are addresses in the first 64K
# For base=0x10070000, refs in [0x10070000, 0x100C0000) are the same literal values
# but they map to the FULL blob

# The key: 0x10060000+blob_size = 0x100B0000
#           0x10070000+blob_size = 0x100C0000
# So base=0x10060000 has window [0x10060000, 0x100B0000)
#    base=0x10070000 has window [0x10070000, 0x100C0000)
# They overlap at [0x10070000, 0x100B0000)

# Check: are the refs pointing to overlapping or non-overlapping ranges?
print("\n--- Overlap analysis ---")
for base in [0x10060000, 0x10070000]:
    refs = []
    for off in range(0, len(blob)-1, 2):
        hw = struct.unpack_from('<H', blob, off)[0]
        if 0x4800 <= hw <= 0x4FFF:
            reg_off = (hw & 0xFF) * 4
            pc_aligned = (off + 4) & ~3
            lit_off = pc_aligned + reg_off
            if lit_off + 4 <= len(blob):
                val = struct.unpack_from('<I', blob, lit_off)[0]
                if base <= val < base + len(blob):
                    refs.append(val)
    
    overlap = [v for v in refs if 0x10070000 <= v < 0x100B0000]
    only_lo = [v for v in refs if 0x10060000 <= v < 0x10070000]
    only_hi = [v for v in refs if 0x100B0000 <= v < 0x100C0000]
    print(f'base={base:#010x}: {len(refs)} total')
    print(f'  overlap [0x10070000,0x100B0000): {len(overlap)}')
    print(f'  only-low [0x10060000,0x10070000): {len(only_lo)}')
    print(f'  only-high [0x100B0000,0x100C0000): {len(only_hi)}')

# SAME for N3GHT15W
print("\n\n=== N3GHT15W comparison ===")
data2 = open('firmware/ec_spi/N3GHT15W_z13_own_20260313.bin','rb').read()
blob2 = data2[0x1000:0x1000+0x50000]

for base in [0x10060000, 0x10070000]:
    refs = []
    for off in range(0, len(blob2)-1, 2):
        hw = struct.unpack_from('<H', blob2, off)[0]
        if 0x4800 <= hw <= 0x4FFF:
            reg_off = (hw & 0xFF) * 4
            pc_aligned = (off + 4) & ~3
            lit_off = pc_aligned + reg_off
            if lit_off + 4 <= len(blob2):
                val = struct.unpack_from('<I', blob2, lit_off)[0]
                if base <= val < base + len(blob2):
                    refs.append(val)
    
    overlap = [v for v in refs if 0x10070000 <= v < 0x100B0000]
    only_lo = [v for v in refs if 0x10060000 <= v < 0x10070000]
    only_hi = [v for v in refs if 0x100B0000 <= v < 0x100C0000]
    print(f'base={base:#010x}: {len(refs)} total')
    print(f'  overlap [0x10070000,0x100B0000): {len(overlap)}')
    print(f'  only-low [0x10060000,0x10070000): {len(only_lo)}')
    print(f'  only-high [0x100B0000,0x100C0000): {len(only_hi)}')
