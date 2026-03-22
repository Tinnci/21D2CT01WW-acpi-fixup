#!/usr/bin/env python3
"""Map all EC images across all SPI dumps to understand the A/B layout."""
import struct, os
from pathlib import Path

EC_SPI_DIR = Path("firmware/ec_spi")

def find_ec_headers(data):
    """Find all _EC headers in the dump."""
    results = []
    off = 0
    while off < len(data):
        pos = data.find(b'_EC', off)
        if pos < 0:
            break
        # Validate: check version byte and size
        if pos + 16 <= len(data):
            ver = data[pos+3]
            if ver in (1, 2):
                total = struct.unpack_from("<I", data, pos+8)[0]
                if 0x20000 <= total <= 0x80000:  # 128KB-512KB reasonable
                    # Get version string
                    ver_off = pos + 0x508 if ver == 2 else pos + 0x528
                    ver_str = data[ver_off:ver_off+16].split(b'\x00')[0].decode('ascii', errors='replace')
                    results.append((pos, ver, total, ver_str))
        off = pos + 4
    return results

def main():
    files = sorted(EC_SPI_DIR.glob("*.bin"))
    
    print(f"{'='*80}")
    print(f"  EC Image A/B Layout Across All SPI Dumps")
    print(f"{'='*80}")
    print(f"{'File':>40s}  {'Slot':>4s} {'SPI Offset':>12s} {'Size':>8s} {'Ver':>10s}")
    print(f"{'─'*40}  {'─'*4} {'─'*12} {'─'*8} {'─'*10}")
    
    for path in files:
        data = path.read_bytes()
        ecs = find_ec_headers(data)
        
        if not ecs:
            print(f"{path.name:>40s}  (no EC images found)")
            continue
        
        for i, (off, ver, total, ver_str) in enumerate(ecs):
            slot = chr(ord('A') + i) if i < 26 else f"#{i}"
            print(f"{path.name if i==0 else '':>40s}  {slot:>4s} {off:#012x} {total//1024:>6d}KB {ver_str:>10s}")
    
    # Detailed analysis of N3GHT25W
    print(f"\n\n{'='*80}")
    print(f"  Detailed: N3GHT25W_v1.02.bin")
    print(f"{'='*80}")
    
    data = (EC_SPI_DIR / "N3GHT25W_v1.02.bin").read_bytes()
    ecs = find_ec_headers(data)
    
    for off, ver, total, ver_str in ecs:
        print(f"\n  EC @ SPI {off:#09x}: ver={ver}, size={total:#x} ({total//1024}KB), version={ver_str}")
        
        # VT analysis
        vt_off = off + (0x100 if ver == 2 else 0x120)
        sp = struct.unpack_from("<I", data, vt_off)[0]
        reset = struct.unpack_from("<I", data, vt_off+4)[0]
        print(f"    SP={sp:#010x}, Reset={reset:#010x}")
        
        # Show copyright
        cr_off = off + 0x1584
        cr = data[cr_off:cr_off+64].split(b'\x00')[0]
        if len(cr) > 4:
            print(f"    Copyright: {cr.decode('ascii', errors='replace')}")
    
    # Check the first 4KB - is slot A empty or erased?
    first_4k = data[0:0x1000]
    is_erased = all(b == 0xFF for b in first_4k)
    is_zeroed = all(b == 0x00 for b in first_4k)
    print(f"\n  Slot A (SPI 0x000000): {'ERASED (0xFF)' if is_erased else 'ZEROED' if is_zeroed else 'HAS DATA'}")
    print(f"    First 16 bytes: {first_4k[:16].hex()}")
    
    # Check N3GHT64W too
    print(f"\n\n{'='*80}")
    print(f"  Detailed: N3GHT64W_v1.64.bin")
    print(f"{'='*80}")
    
    data64 = (EC_SPI_DIR / "N3GHT64W_v1.64.bin").read_bytes()
    ecs64 = find_ec_headers(data64)
    
    for off, ver, total, ver_str in ecs64:
        print(f"\n  EC @ SPI {off:#09x}: ver={ver}, size={total:#x} ({total//1024}KB), version={ver_str}")
        vt_off = off + (0x100 if ver == 2 else 0x120)
        sp = struct.unpack_from("<I", data64, vt_off)[0]
        reset = struct.unpack_from("<I", data64, vt_off+4)[0]
        print(f"    SP={sp:#010x}, Reset={reset:#010x}")
    
    first_4k = data64[0:0x1000]
    is_erased = all(b == 0xFF for b in first_4k)
    print(f"\n  Slot A (SPI 0x000000): {'ERASED (0xFF)' if is_erased else 'HAS DATA'}")
    print(f"    First 16 bytes: {first_4k[:16].hex()}")
    
    # Check all other dumps for slot A status
    print(f"\n\n{'='*80}")
    print(f"  Slot A Status Across All Dumps")
    print(f"{'='*80}")
    for path in files:
        data = path.read_bytes()
        first8 = data[:8].hex()
        is_erased = all(b == 0xFF for b in data[:0x100])
        has_ec = data[:3] == b'_EC'
        ecs = find_ec_headers(data)
        ec_count = len(ecs)
        slots = ', '.join(f"SPI {off:#07x}={vs}" for off, _, _, vs in ecs)
        status = "ERASED" if is_erased else ("_EC present" if has_ec else "other data")
        print(f"  {path.name:>40s}: A={status:12s} | {ec_count} images: {slots}")

if __name__ == "__main__":
    main()
