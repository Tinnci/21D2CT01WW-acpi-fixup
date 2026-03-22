#!/usr/bin/env python3
"""Deep-dive into key large regions from ec_large_regions.py output.

Focus on:
1. SPI 0x106000 region - "FW type/signature" strings → likely USB4 retimer FW tool
2. SPI 0x2C1000/0x2C7000 region - "TPSHTRMP" strings → TPS65983/65988 PD controller FW
3. SPI 0x386000/0x38C000 region - "PD" strings → possibly PD config
4. Find actual LADD descriptors and vector tables throughout dump
"""

import struct, hashlib
from pathlib import Path

try:
    from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False

EC_SPI_DIR = Path("firmware/ec_spi")


def hex_dump(data, offset=0, lines=8):
    for i in range(min(lines, (len(data)+15)//16)):
        addr = offset + i * 16
        chunk = data[i*16:(i+1)*16]
        hexstr = ' '.join(f'{b:02x}' for b in chunk)
        ascstr = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        print(f"    {addr:08X}: {hexstr:<48s}  {ascstr}")


def find_ladd(data:bytes):
    """Find all LADD descriptors in the entire dump."""
    results = []
    off = 0
    while True:
        pos = data.find(b'LADD', off)
        if pos < 0:
            break
        results.append(pos)
        off = pos + 4
    return results


def find_all_strings(data, start, size, min_len=6):
    """Find all printable ASCII strings of min_len or more chars."""
    region = data[start:start+size]
    results = []
    s = b''
    s_start = 0
    for i, b in enumerate(region):
        if 32 <= b < 127:
            if not s:
                s_start = i
            s += bytes([b])
        else:
            if len(s) >= min_len:
                results.append((start + s_start, s.decode('ascii')))
            s = b''
    if len(s) >= min_len:
        results.append((start + s_start, s.decode('ascii')))
    return results


def analyze_tps_region(data, start, size, label):
    """Analyze TPS (PD controller) firmware region."""
    region = data[start:start+size]
    print(f"\n{'='*70}")
    print(f"  {label}: SPI 0x{start:07X} - 0x{start+size:07X} ({size//1024} KB)")
    print(f"{'='*70}")
    
    # First 256 bytes
    print("\n  Header (first 256 bytes):")
    hex_dump(region, start, 16)
    
    # Search for "TPSHTRMP" pattern in detail
    off = 0
    tps_hits = []
    while True:
        pos = region.find(b'TPSHTRMP', off)
        if pos < 0:
            break
        tps_hits.append(pos)
        off = pos + 8
    
    print(f"\n  TPSHTRMP hits: {len(tps_hits)}")
    for pos in tps_hits[:5]:
        print(f"    @ SPI+{start+pos:#09x} (region+{pos:#08x}):")
        hex_dump(region[pos:pos+64], start+pos, 4)
    
    # Search for TPS65983 / TPS65988 strings
    for pattern in [b'TPS65', b'PD', b'CYPD', b'CCG']:
        gpos = 0
        hits = []
        while True:
            p = region.find(pattern, gpos)
            if p < 0:
                break
            hits.append(p)
            gpos = p + len(pattern)
        if hits:
            print(f"\n  '{pattern.decode()}' found {len(hits)} times (showing first 5):")
            for p in hits[:5]:
                ctx = region[p:p+40]
                s = ctx.split(b'\x00')[0].decode('ascii', errors='replace')
                print(f"    @ region+{p:#08x}: \"{s}\"")
    
    # Look for possible FW header or image table
    # TPS65988 firmware has specific structures
    # Check for repeated 0x00000000 followed by addresses
    print("\n  Searching for address tables...")
    for off in range(0, min(len(region), 0x2000), 4):
        val = struct.unpack_from("<I", region, off)[0]
        if 0x10000 <= val <= 0x100000:
            # Could be an offset/address
            nxt = struct.unpack_from("<I", region, off+4)[0]
            if 0x10000 <= nxt <= 0x100000:
                print(f"    @ +{off:#06x}: {val:#010x}, {nxt:#010x}")
                break  # just show first one
    
    return tps_hits


def analyze_fw_region(data, start, size, label):
    """Analyze firmware tool/loader region."""
    region = data[start:start+size]
    print(f"\n{'='*70}")
    print(f"  {label}: SPI 0x{start:07X} - 0x{start+size:07X} ({size//1024} KB)")
    print(f"{'='*70}")
    
    # Header
    print("\n  Header (first 256 bytes):")
    hex_dump(region, start, 16)
    
    # Find all meaningful strings
    strings = find_all_strings(data, start, min(size, 0x20000), min_len=8)
    print(f"\n  Strings in first 128KB ({len(strings)} found, showing up to 30):")
    for spi_off, s in strings[:30]:
        print(f"    SPI {spi_off:#09x}: \"{s[:80]}\"")
    
    # Try Capstone disassembly from start
    if HAS_CAPSTONE:
        cs = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
        cs.detail = False
        code = region[:256]
        print(f"\n  Disassembly from start (first 256 bytes):")
        for insn in cs.disasm(code, start):
            print(f"    {insn.address:08X}: {insn.mnemonic:8s} {insn.op_str}")
            if insn.address - start > 0x40:
                break


def main():
    fname = "N3GHT25W_v1.02.bin"
    path = EC_SPI_DIR / fname
    data = path.read_bytes()
    
    print(f"Analyzing {fname}")
    
    # 1. Find ALL LADD descriptors
    ladds = find_ladd(data)
    print(f"\n{'='*70}")
    print(f"  LADD descriptors: {len(ladds)} found")
    print(f"{'='*70}")
    for pos in ladds:
        print(f"\n  LADD @ SPI {pos:#09x}:")
        # Show context around LADD
        if pos >= 16:
            hex_dump(data[pos-16:pos+64], pos-16, 5)
        else:
            hex_dump(data[pos:pos+64], pos, 4)
        # Try to parse entries after LADD
        off = pos
        while off + 32 <= pos + 512:
            tag = data[off:off+4]
            if tag == b'\x00' * 4 and off > pos:
                break
            name = data[off:off+8]
            vals = struct.unpack_from("<IIIIII", data, off+8)
            name_str = name.rstrip(b'\x00').decode('ascii', errors='replace')
            if any(v > 0 for v in vals):
                print(f"    [{name_str:8s}] {' '.join(f'{v:#010x}' for v in vals)}")
            off += 32
            if off - pos > 2048:
                break
    
    # 2. Analyze key regions
    # Region with "FW type" strings (USB4/retimer tool)
    analyze_fw_region(data, 0x106000, 0x1E000, "FW Tool Region")
    
    # Region with "TPSHTRMP" strings (TPS PD controller)
    analyze_tps_region(data, 0x2C1000, 0xA9000, "TPS PD Controller Region") 
    
    # Region with "PD" strings
    analyze_tps_region(data, 0x386000, 0x59000, "PD Config Region")
    
    # The 6.7MB region (likely compressed/encrypted BIOS or large FW)
    region_big = data[0x787000:0x787000+256]
    print(f"\n{'='*70}")
    print(f"  Large Region: SPI 0x0787000 (6700 KB)")
    print(f"{'='*70}")
    print("\n  Header:")
    hex_dump(region_big, 0x787000, 16)
    # Check if it starts with known magic
    magic32 = struct.unpack_from("<I", data, 0x787000)[0]
    print(f"\n  First DWORD: {magic32:#010x}")
    if magic32 == 0x55AA55AA or magic32 == 0xAA55AA55:
        print("  → Looks like PSP/BIOS region marker!")
    
    # 3. SPI 0x12A000 region (692KB, 81.7% match, high entropy code)
    analyze_fw_region(data, 0x12A000, 0x20000, "Code Region 0x12A000")
    
    # 4. PSP BL region (SPI 0x22D000, 520KB)
    analyze_fw_region(data, 0x22D000, 0x20000, "PSP BL Region 0x22D000")
    
    # 5. Also check N3GHT64W for the same regions
    fname64 = "N3GHT64W_v1.64.bin"
    path64 = EC_SPI_DIR / fname64
    data64 = path64.read_bytes()
    
    print(f"\n\n{'='*70}")
    print(f"  N3GHT64W LADD descriptors")
    print(f"{'='*70}")
    ladds64 = find_ladd(data64)
    print(f"  Found {len(ladds64)}")
    for pos in ladds64:
        print(f"\n  LADD @ SPI {pos:#09x}:")
        hex_dump(data64[pos:pos+64], pos, 4)


if __name__ == "__main__":
    main()
