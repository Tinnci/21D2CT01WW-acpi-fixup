#!/usr/bin/env python3
"""Analyze large non-empty regions above SPI 0x100000 in N3GHT25W/64W.

These regions may contain separate firmware for PD controllers, USB4 retimers,
or other embedded processors.
"""

import struct, os, hashlib
from pathlib import Path

try:
    from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False

EC_SPI_DIR = Path("firmware/ec_spi")

def find_regions(data, start=0x100000, min_size=0x10000):
    """Find contiguous non-empty (not all 0x00 or 0xFF) regions."""
    regions = []
    page_size = 0x1000
    in_region = False
    region_start = 0
    
    for off in range(start, len(data), page_size):
        page = data[off:off+page_size]
        # Check if page has meaningful content
        nz = sum(1 for b in page if b != 0x00 and b != 0xFF)
        is_content = nz > 64  # At least 64 non-trivial bytes
        
        if is_content and not in_region:
            region_start = off
            in_region = True
        elif not is_content and in_region:
            size = off - region_start
            if size >= min_size:
                regions.append((region_start, size))
            in_region = False
    
    if in_region:
        size = len(data) - region_start
        if size >= min_size:
            regions.append((region_start, size))
    
    return regions


def analyze_region(data, start, size, label=""):
    """Analyze a large region for ARM code patterns."""
    region = data[start:start+size]
    
    print(f"\n  {'─'*60}")
    print(f"  Region SPI 0x{start:07X} - 0x{start+size:07X} ({size//1024} KB) {label}")
    
    # Check for known signatures
    # _EC header
    if region[:3] == b'_EC':
        ver = region[3]
        total = struct.unpack_from("<I", region, 8)[0]
        print(f"  → _EC header! ver={ver}, total={total:#x}")
        return "EC_BLOB"
    
    # LADD descriptor  
    if b'LADD' in region[:0x100]:
        ladd_off = region.index(b'LADD')
        print(f"  → LADD descriptor at offset +{ladd_off:#x}")
        # Parse LADD entries
        off = ladd_off
        while off + 32 <= len(region):
            entry = region[off:off+32]
            if entry[:4] == b'\x00' * 4:
                break
            name = entry[:8].rstrip(b'\x00').decode('ascii', errors='replace')
            vals = struct.unpack_from("<IIIIII", entry, 8)
            if any(v > 0 for v in vals):
                print(f"    [{name:8s}] {' '.join(f'{v:#010x}' for v in vals)}")
            off += 32
            if off - ladd_off > 0x1000:
                break
        return "LADD"
    
    # Search for ARM vector table patterns
    vt_candidates = []
    for off in range(0, min(len(region), 0x10000), 4):
        sp = struct.unpack_from("<I", region, off)[0]
        if not (0x20000000 <= sp <= 0x20FFFFFF):
            continue
        # Check next 3 entries
        v1 = struct.unpack_from("<I", region, off+4)[0]
        v2 = struct.unpack_from("<I", region, off+8)[0]
        v3 = struct.unpack_from("<I", region, off+12)[0]
        if all((v & 1) and 0x00001000 <= (v & ~1) <= 0x20000000 for v in [v1, v2, v3]):
            vt_candidates.append((off, sp, v1, v2, v3))
    
    if vt_candidates:
        print(f"  → Found {len(vt_candidates)} vector table candidate(s)")
        for off, sp, v1, v2, v3 in vt_candidates[:3]:
            print(f"    @ +{off:#06x}: SP={sp:#010x} Reset={v1:#010x} NMI={v2:#010x} HF={v3:#010x}")
            # Try to determine base address from Reset vector
            reset_addr = v1 & ~1
            # If Reset points within the region, base = region_virtual_start
            # Try a few common base candidates
            for base_candidate in [0x00000000, 0x00200000, 0x08000000, 0x10000000]:
                if base_candidate <= reset_addr < base_candidate + size:
                    offset_in_region = reset_addr - base_candidate
                    if 0 <= offset_in_region < size:
                        print(f"      Possible base: {base_candidate:#010x} (Reset -> region+{offset_in_region:#x})")
    
    # Check for string patterns
    strings_found = []
    for off in range(0, len(region) - 8):
        chunk = region[off:off+8]
        # Look for version-like strings
        if chunk[:3] in (b'N3G', b'N3H', b'TPS', b'RTK', b'USB', b'PD ', b'FW '):
            s = region[off:off+32].split(b'\x00')[0]
            if len(s) > 4:
                strings_found.append((off, s.decode('ascii', errors='replace')))
        # Look for "Copyright"
        if chunk == b'Copyrigh':
            s = region[off:off+64].split(b'\x00')[0]
            strings_found.append((off, s.decode('ascii', errors='replace')))
    
    if strings_found:
        print(f"  → Found {len(strings_found)} string(s):")
        for off, s in strings_found[:10]:
            print(f"    @ +{off:#06x}: \"{s}\"")
    
    # Byte pattern analysis
    # Count instruction-like patterns
    thumb_count = 0
    data_count = 0
    for off in range(0, min(len(region), 0x10000), 2):
        hw = struct.unpack_from("<H", region, off)[0]
        # Common Thumb instruction prefixes
        if (hw & 0xF800) in (0x4800, 0x6800, 0x6000, 0x2000, 0x2800, 0xB400, 0xBD00, 0x4600):
            thumb_count += 1
        if hw == 0x0000 or hw == 0xFFFF:
            data_count += 1
    
    total_hw = min(len(region), 0x10000) // 2
    print(f"  → First 64KB: {thumb_count} Thumb-like / {data_count} zero/FF / {total_hw} total halfwords")
    
    # Entropy estimate (from first 4KB)
    sample = region[:4096]
    byte_counts = [0] * 256
    for b in sample:
        byte_counts[b] += 1
    import math
    entropy = 0
    for c in byte_counts:
        if c > 0:
            p = c / len(sample)
            entropy -= p * math.log2(p)
    print(f"  → Entropy (first 4KB): {entropy:.2f} bits/byte", end="")
    if entropy > 7.5:
        print(" (compressed/encrypted)")
    elif entropy > 5:
        print(" (code)")
    elif entropy > 3:
        print(" (structured data)")
    else:
        print(" (sparse/repetitive)")
    
    # Hash for cross-file comparison
    h = hashlib.md5(region[:min(len(region), 0x10000)]).hexdigest()[:12]
    print(f"  → First 64KB MD5: {h}")
    
    return "UNKNOWN"


def main():
    files = [
        "N3GHT25W_v1.02.bin",
        "N3GHT64W_v1.64.bin",
    ]
    
    for fname in files:
        path = EC_SPI_DIR / fname
        if not path.exists():
            print(f"Missing: {fname}")
            continue
        
        data = path.read_bytes()
        print(f"\n{'='*70}")
        print(f"  {fname} ({len(data)//1024//1024} MB)")
        print(f"{'='*70}")
        
        regions = find_regions(data, start=0x100000, min_size=0x10000)
        print(f"\n  Found {len(regions)} large regions above SPI 0x100000:")
        for start, size in regions:
            print(f"    SPI 0x{start:07X} - 0x{start+size:07X} ({size//1024} KB)")
        
        for start, size in regions:
            analyze_region(data, start, size)
        
        # Also check known areas
        # R1 region (0x1C50000)
        r1_start = 0x1C50000
        if r1_start + 0x1000 < len(data):
            nz = sum(1 for b in data[r1_start:r1_start+0x1000] if b != 0 and b != 0xFF)
            if nz > 64:
                print(f"\n  R1 region (SPI 0x{r1_start:07X}): {nz} non-trivial bytes in first 4KB")
        
        # R2 region (0x1D00000)
        r2_start = 0x1D00000
        if r2_start + 0x1000 < len(data):
            nz = sum(1 for b in data[r2_start:r2_start+0x1000] if b != 0 and b != 0xFF)
            if nz > 64:
                print(f"  R2 region (SPI 0x{r2_start:07X}): {nz} non-trivial bytes in first 4KB")
    
    # Cross-file comparison
    print(f"\n\n{'='*70}")
    print("  Cross-File Region Comparison")
    print(f"{'='*70}")
    
    data25 = (EC_SPI_DIR / files[0]).read_bytes()
    data64 = (EC_SPI_DIR / files[1]).read_bytes()
    
    regions25 = find_regions(data25, 0x100000)
    regions64 = find_regions(data64, 0x100000)
    
    print(f"\n  N3GHT25W: {len(regions25)} regions")
    print(f"  N3GHT64W: {len(regions64)} regions")
    
    # Compare matching regions by position
    for s25, sz25 in regions25:
        for s64, sz64 in regions64:
            if abs(s25 - s64) < 0x10000:  # Same approximate position
                n = min(sz25, sz64, 0x10000)
                match = sum(1 for i in range(n) if data25[s25+i] == data64[s64+i])
                print(f"\n  SPI ~0x{s25:07X} ({sz25//1024}KB vs {sz64//1024}KB):")
                print(f"    First {n//1024}KB match: {match}/{n} ({100*match/n:.1f}%)")


if __name__ == "__main__":
    main()
