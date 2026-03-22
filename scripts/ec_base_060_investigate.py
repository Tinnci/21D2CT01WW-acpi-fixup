#!/usr/bin/env python3
"""Investigate why some EC blobs show best base=0x10060000 instead of 0x10070000.

Hypothesis: 320KB blobs from the 0x10060000 group have a different _EC header/data 
layout where the actual code region starts 0x10000 bytes into the blob, so 
base=0x10060000+0x10000=0x10070000 for the code area.

Test: compare blob content at various offsets between the two groups."""

import struct, os, glob

EC_SPI_DIR = "firmware/ec_spi"

# Group A: base=0x10070000, 320KB blobs
GROUP_A = {
    "N3GHT15W_z13_own_20260313.bin": "N3GHT15W",
}

# Group B: base=0x10060000, 320KB blobs  
GROUP_B = {
    "EC0.01_eng_rev0.4.bin": "N3GHT14T",
    "EC0.11_eng_rev0.2.bin": "N3GHT11M",
    "N3GHT12W_EC0.12_eng_rev0.3.bin": "N3GHT12W",
}

def extract_ec_blob(path):
    """Extract first _EC blob from SPI dump."""
    data = open(path, "rb").read()
    # Search for _EC header - magic is '_EC' followed by version byte
    for off in range(0, min(len(data), 0x200000), 0x1000):
        if data[off:off+3] == b'_EC':
            ver = data[off+3]  # version is the 4th byte
            # Read header fields (after the 4-byte magic+ver)
            total = struct.unpack_from("<I", data, off+8)[0]
            data_off = struct.unpack_from("<I", data, off+12)[0]
            if total > 0 and total < 0x100000:  # sanity check
                blob = data[off:off+total]
                return blob, ver, total, data_off, off
    return None, 0, 0, 0, 0

def analyze_blob(name, blob, ver, total, data_off, spi_off):
    """Deep analysis of blob structure."""
    print(f"\n{'='*70}")
    print(f"  {name}")
    print(f"  _EC ver={ver}, total={total:#x}, data_off={data_off:#x}, SPI={spi_off:#x}")
    print(f"  Blob size: {len(blob)} bytes ({len(blob)//1024} KB)")
    
    # Check _EC header fields in detail
    print(f"\n  Header (first 32 bytes):")
    for i in range(0, 32, 4):
        val = struct.unpack_from("<I", blob, i)[0]
        print(f"    +{i:#04x}: {val:#010x}  ({val})")
    
    # Check what's at offset 0x100 (expected VT for ver=2)
    sp_100 = struct.unpack_from("<I", blob, 0x100)[0]
    reset_100 = struct.unpack_from("<I", blob, 0x104)[0]
    print(f"\n  @ EC+0x0100: SP={sp_100:#010x}, Reset={reset_100:#010x}")
    
    # Scan for version string
    for off in range(0, min(len(blob), 0x2000)):
        if blob[off:off+5] == b'N3GHT':
            ver_str = blob[off:off+8].decode('ascii', errors='replace')
            print(f"  Version string '{ver_str}' @ EC+{off:#06x}")
            break
    
    # Check if first 64KB (0x10000 bytes) is different from main code area
    # Compare byte distribution in first 64KB vs rest
    first_64k = blob[:0x10000] if len(blob) >= 0x10000 else blob
    rest = blob[0x10000:] if len(blob) >= 0x10000 else b''
    
    # Count non-zero bytes
    nz_first = sum(1 for b in first_64k if b != 0x00 and b != 0xFF)
    nz_rest = sum(1 for b in rest if b != 0x00 and b != 0xFF) if rest else 0
    
    print(f"\n  First 64KB (0x00000-0x0FFFF): {nz_first} non-trivial bytes / {len(first_64k)}")
    if rest:
        print(f"  Rest       (0x10000-{len(blob)-1:#07x}): {nz_rest} non-trivial bytes / {len(rest)}")
    
    # Check what data_off field means
    # In _EC header: offset 0x08 = total size, 0x0C = data_offset
    # The actual firmware code starts at data_offset within the blob
    actual_code_start = data_off
    print(f"\n  _EC data_offset field: {data_off:#x}")
    
    # If data_off > 0x100, there's extra header data
    if data_off > 0x100:
        print(f"  ⚠ data_offset ({data_off:#x}) > 0x100 — extra header space!")
        # Check what's between 0x100 and data_off
        extra = blob[0x100:data_off]
        nz_extra = sum(1 for b in extra if b != 0x00 and b != 0xFF)
        print(f"  Extra region 0x0100-{data_off:#05x}: {nz_extra} non-trivial bytes / {len(extra)}")
    
    # Check VT at data_off (the actual firmware might have VT here)
    if data_off + 8 <= len(blob):
        sp_do = struct.unpack_from("<I", blob, data_off)[0]
        reset_do = struct.unpack_from("<I", blob, data_off + 4)[0]
        print(f"  @ EC+{data_off:#06x}: word0={sp_do:#010x}, word1={reset_do:#010x}")
    
    # LDR T1 scan for base candidates focused comparison
    print(f"\n  LDR T1 flash ref comparison:")
    for base in [0x10060000, 0x10070000]:
        count = 0
        for off in range(0, len(blob)-1, 2):
            hw = struct.unpack_from("<H", blob, off)[0]
            if 0x4800 <= hw <= 0x4FFF:
                reg_off = (hw & 0xFF) * 4
                pc_aligned = (off + 4) & ~3
                lit_off = pc_aligned + reg_off
                if lit_off + 4 <= len(blob):
                    val = struct.unpack_from("<I", blob, lit_off)[0]
                    if base <= val < base + len(blob):
                        count += 1
        print(f"    base={base:#010x}: {count} flash self-refs")
    
    # Critical check: is the VT always at a fixed virtual address?
    # If base=0x10060000 and VT is EC+0x0100, then VT vaddr = 0x10060100
    # If base=0x10070000 and VT is EC+0x0100, then VT vaddr = 0x10070100
    # But Reset is always 0x100701F5 — this points to 0x10070000+0x1F4
    # For base=0x10060000 group, that's EC+0x101F4 (64KB + 0x1F4 into the blob)
    
    # Check EC+0x101F4 — is there code there?
    off_101f4 = 0x101F4
    if off_101f4 + 16 <= len(blob):
        code_bytes = blob[off_101f4:off_101f4+16]
        print(f"\n  @ EC+0x101F4 (Reset target for base=0x10060000):")
        print(f"    bytes: {code_bytes.hex()}")
        # Compare with EC+0x01F4
        if 0x1F4 + 16 <= len(blob):
            code_bytes2 = blob[0x1F4:0x1F4+16]
            print(f"  @ EC+0x001F4 (Reset target for base=0x10070000):")
            print(f"    bytes: {code_bytes2.hex()}")
            if code_bytes == code_bytes2:
                print(f"    ✓ IDENTICAL — same code at both offsets!")
            else:
                print(f"    ✗ Different content")
    
    # Check if blob[0x10000:] is same as a 224KB blob's beginning
    # The 0x10060000 group's code might be at blob+0x10000
    # while 0x10070000 group's code starts at blob+0x0000
    
    # Check for _EC sub-header at blob+0x10000
    if len(blob) > 0x10004:
        sub_check = blob[0x10000:0x10004]
        print(f"\n  @ EC+0x10000: {sub_check.hex()}")
        sp_10100 = struct.unpack_from("<I", blob, 0x10100)[0] if len(blob) >= 0x10104 else 0
        reset_10100 = struct.unpack_from("<I", blob, 0x10104)[0] if len(blob) >= 0x10108 else 0
        print(f"  @ EC+0x10100: SP={sp_10100:#010x}, Reset={reset_10100:#010x}")
        
        is_vt_at_10100 = (
            0x20000000 <= sp_10100 <= 0x200FFFFF and
            0x10060000 <= reset_10100 <= 0x100FFFFF and
            (reset_10100 & 1) == 1
        )
        print(f"  Looks like VT @ +0x10100? {is_vt_at_10100}")

    return

print("="*70)
print("  0x10060000 vs 0x10070000 Base Address Investigation")
print("="*70)

# Analyze Group B (0x10060000)
print("\n\n>>> GROUP B: base=0x10060000 <<<")
for fname, ver_name in GROUP_B.items():
    path = os.path.join(EC_SPI_DIR, fname)
    if os.path.exists(path):
        blob, ver, total, data_off, spi_off = extract_ec_blob(path)
        if blob:
            analyze_blob(f"{fname} ({ver_name})", blob, ver, total, data_off, spi_off)

# Analyze Group A (0x10070000) for comparison
print("\n\n>>> GROUP A: base=0x10070000 (reference) <<<")
for fname, ver_name in GROUP_A.items():
    path = os.path.join(EC_SPI_DIR, fname)
    if os.path.exists(path):
        blob, ver, total, data_off, spi_off = extract_ec_blob(path)
        if blob:
            analyze_blob(f"{fname} ({ver_name})", blob, ver, total, data_off, spi_off)

# Direct comparison: do 0x10060000 group's blobs have code at +0x10000
# that matches 0x10070000 group's code at +0x00000?
print("\n\n>>> CROSS-GROUP BYTE COMPARISON <<<")
ref_path = os.path.join(EC_SPI_DIR, "N3GHT15W_z13_own_20260313.bin")
ref_blob, *_ = extract_ec_blob(ref_path)

for fname, ver_name in GROUP_B.items():
    path = os.path.join(EC_SPI_DIR, fname)
    if not os.path.exists(path):
        continue
    blob, *_ = extract_ec_blob(path)
    if not blob:
        continue
    
    # Compare blob_B[0x10000:0x10000+N] with blob_A[0x00000:N]
    # where N = min of available sizes
    if len(blob) > 0x10000 and ref_blob:
        n = min(len(blob) - 0x10000, len(ref_blob))
        match = sum(1 for i in range(n) if blob[0x10000+i] == ref_blob[i])
        print(f"\n  {fname} blob[0x10000:] vs N3GHT15W blob[0x0:]:")
        print(f"    Compared {n} bytes: {match} match ({100*match/n:.1f}%)")
        
        # Also check at +0x0100 vs +0x10100
        if len(blob) >= 0x10200:
            vt_match = sum(1 for i in range(0x140) 
                         if blob[0x10100+i] == ref_blob[0x100+i])
            print(f"    VT area (320 bytes): {vt_match}/320 match ({100*vt_match/320:.1f}%)")
