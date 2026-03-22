#!/usr/bin/env python3
"""Parse the BIOS L2 directory and create final SPI flash map."""

import struct
from pathlib import Path

EC_SPI_DIR = Path("firmware/ec_spi")

def parse_bios_l2(data, psp_base, bios_l2_rel):
    """Parse BIOS L2 directory."""
    abs_off = psp_base + bios_l2_rel
    magic = data[abs_off:abs_off+4]
    print(f"\n  BIOS L2 Directory @ SPI {abs_off:#09x}: magic = {magic}")
    
    if magic == b'$BL2':
        num_entries = struct.unpack_from("<I", data, abs_off + 8)[0] & 0xFFF
        print(f"  Entries: {num_entries}")
        
        bios_type_names = {
            0x60: "APCB_DATA",
            0x61: "APOB_NV",
            0x62: "BIOS_RTM_VOLUME",
            0x63: "APOB",
            0x64: "BIOS_RTM_SIGNATURE",
            0x65: "BIOS_COPY",
            0x66: "BIOS_COPY_2",
            0x68: "BIOS_PSP_PROVISION",
            0x6A: "MP2_FW_CONFIG",
        }
        
        entry_off = abs_off + 16
        for i in range(min(num_entries, 30)):
            entry = data[entry_off:entry_off+16]
            if len(entry) < 16:
                break
            etype = entry[0]
            subprog = entry[1]
            rom_id = struct.unpack_from("<H", entry, 2)[0]
            esize = struct.unpack_from("<I", entry, 4)[0]
            eloc = struct.unpack_from("<Q", entry, 8)[0]
            
            name = bios_type_names.get(etype, f"BIOS_TYPE_{etype:#04x}")
            
            if esize == 0 and eloc == 0:
                continue
            
            loc_str = f"{eloc:#012x}"
            if eloc & 0xFF000000_00000000 == 0x80000000_00000000:
                rel = eloc & 0x00FFFFFF_FFFFFFFF
                abs_loc = psp_base + rel
                loc_str = f"PSP+{rel:#08x} → SPI {abs_loc:#09x}"
            elif eloc & 0xFF000000_00000000 == 0x40000000_00000000:
                spi_loc = eloc & 0x00FFFFFF_FFFFFFFF
                loc_str = f"SPI {spi_loc:#012x}"
            
            print(f"    [{i:3d}] type={etype:#04x} sub={subprog} size={esize:#010x} loc={loc_str}  {name}")
            
            entry_off += 16


def build_flash_map(data, psp_base=0x106000):
    """Build comprehensive flash map by resolving PSP directory references."""
    regions = []
    
    # PSP L2 directory
    num = struct.unpack_from("<I", data, psp_base + 8)[0] & 0xFFF
    entry_off = psp_base + 16
    
    for i in range(min(num, 60)):
        entry = data[entry_off:entry_off+16]
        if len(entry) < 16:
            break
        etype = entry[0]
        subprog = entry[1]
        esize = struct.unpack_from("<I", entry, 4)[0]
        eloc = struct.unpack_from("<Q", entry, 8)[0]
        
        # Resolve absolute SPI offset
        spi_off = None
        if eloc & 0xFF000000_00000000 == 0x80000000_00000000:
            rel = eloc & 0x00FFFFFF_FFFFFFFF
            spi_off = psp_base + rel
        elif eloc & 0xFF000000_00000000 == 0x40000000_00000000:
            spi_off = eloc & 0x00FFFFFF_FFFFFFFF
        
        if spi_off is not None and esize > 0 and esize < 0xFFFFFFFF:
            type_names = {
                0x00: "AMD_PUBLIC_KEY", 0x01: "PSP_BOOT_LOADER", 0x02: "PSP_TRUSTED_OS",
                0x04: "PSP_NV_DATA", 0x08: "SMU_FW", 0x09: "SEC_DBG_KEY",
                0x0B: "SOFT_FUSE", 0x0C: "BOOT_TRUSTLETS", 0x12: "TRUSTLETS_KEY",
                0x13: "AGESA_RESUME", 0x20: "IKEK", 0x21: "TOKEN_UNLOCK",
                0x22: "SEC_GASKET", 0x24: "MP2_FW", 0x25: "DRIVER_ENTRIES",
                0x28: "MP2_FW_2", 0x2D: "TYPE2D", 0x30: "ABL0",
                0x3C: "TYPE3C", 0x44: "DIAG_BL", 0x45: "TYPE45",
                0x47: "PSP_SEV", 0x49: "BIOS_L2_DIR",
                0x50: "TYPE50", 0x51: "TYPE51", 0x54: "TYPE54", 0x55: "TYPE55",
                0x5A: "USB4_DXIO_PHY", 0x5C: "TYPE5C", 0x5F: "DXIO_PHY",
                0x71: "TYPE71", 0x73: "TPM_SPI", 0x76: "TYPE76",
                0x85: "TYPE85", 0x86: "TYPE86", 0x87: "TYPE87",
                0x88: "TYPE88", 0x89: "TYPE89", 0x8D: "TYPE8D",
                0x98: "TYPE98",
            }
            name = type_names.get(etype, f"T{etype:02X}")
            if subprog > 0:
                name += f"_sub{subprog}"
            regions.append((spi_off, esize, f"PSP:{name}"))
        
        entry_off += 16
    
    # Add known fixed regions
    regions.append((0x000000, 0x001000, "EC:_EC_header+VT"))
    regions.append((0x001000, 0x044000, "EC:code+data"))
    regions.append((0x100000, 0x001000, "LADD_DIRECTORY"))
    if data[0x787028:0x78702C] == b'_FVH':
        fv_len = struct.unpack_from("<Q", data, 0x787020)[0]
        regions.append((0x787000, fv_len, "UEFI_FV"))
    
    # Sort by SPI offset
    regions.sort(key=lambda x: x[0])
    
    print(f"\n{'='*70}")
    print(f"  Complete SPI Flash Map (sorted by address)")
    print(f"{'='*70}")
    print(f"  {'SPI Start':>12} {'SPI End':>12} {'Size':>10} {'Component'}")
    print(f"  {'─'*12} {'─'*12} {'─'*10} {'─'*30}")
    
    for spi_off, size, name in regions:
        if spi_off + size <= len(data):
            end = spi_off + size
            print(f"  {spi_off:#012x} {end:#012x} {size:>8d}B  {name}")
    
    return regions


def main():
    fname = "N3GHT25W_v1.02.bin"
    path = EC_SPI_DIR / fname
    data = path.read_bytes()
    
    print(f"  {fname}")
    
    # Parse BIOS L2 directory (at PSP+0x380000 = SPI 0x486000)
    bios_l2_abs = 0x106000 + 0x380000  # = 0x486000
    if data[bios_l2_abs:bios_l2_abs+4] == b'$BL2':
        parse_bios_l2(data, 0x106000, 0x380000)
    else:
        print(f"  BIOS L2 at {bios_l2_abs:#09x}: {data[bios_l2_abs:bios_l2_abs+8].hex()}")
        # Try scanning nearby
        for off in range(bios_l2_abs - 0x1000, bios_l2_abs + 0x1000, 4):
            if data[off:off+4] == b'$BL2':
                print(f"  Found $BL2 at {off:#09x}")
                parse_bios_l2(data, 0x106000, off - 0x106000)
                break
    
    # Build comprehensive flash map
    build_flash_map(data, 0x106000)
    
    # Check what the $PS1 at 0x386000 actually belongs to
    ps1_data = data[0x386000:0x386100]
    print(f"\n  $PS1 region analysis @ SPI 0x386000:")
    print(f"    First 16 bytes: {ps1_data[:16].hex()}")
    # $PS1 = PSP Signature table
    if ps1_data[0x10:0x14] == b'$PS1':
        print(f"    $PS1 signature at +0x10")
    
    # Check what's at 0x4D7000 (zeroed region per LADD - the "secondary" PSP area)
    print(f"\n  Secondary PSP area check:")
    for off in [0x4D7000, 0x499000]:
        peek = data[off:off+32]
        nz = sum(1 for b in peek if b != 0 and b != 0xFF)
        print(f"    SPI {off:#09x}: {'non-zero' if nz > 0 else 'empty/zero'} ({peek[:16].hex()})")


if __name__ == "__main__":
    main()
