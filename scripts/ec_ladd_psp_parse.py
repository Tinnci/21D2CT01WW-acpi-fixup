#!/usr/bin/env python3
"""Parse the LADD descriptor at SPI 0x100000 which serves as a flash directory.

The LADD at 0x100000 is a different format from the EC LADD - it's a SPI flash
region directory that maps firmware components to SPI offsets and sizes.
"""

import struct
from pathlib import Path

EC_SPI_DIR = Path("firmware/ec_spi")

def parse_ladd_directory(data, ladd_offset=0x100000):
    """Parse LADD directory entries."""
    print(f"\n{'='*70}")
    print(f"  LADD Flash Directory @ SPI {ladd_offset:#09x}")
    print(f"{'='*70}")
    
    # Header: "LADDR\x00" + 2 bytes
    hdr = data[ladd_offset:ladd_offset+8]
    print(f"  Header: {hdr.hex()}")
    print(f"  Magic: {hdr[:6]}")
    
    # The entries seem to be pairs of (offset, size) in 32-bit words
    # Let's dump all entries systematically
    off = ladd_offset + 8
    entry_num = 0
    entries = []
    
    while off < ladd_offset + 0x200:
        vals = struct.unpack_from("<II", data, off)
        spi_off, region_size = vals
        
        if spi_off == 0xFFFFFFFF and region_size == 0xFFFFFFFF:
            print(f"\n  [End marker at +{off-ladd_offset:#06x}]")
            break
        
        if spi_off == 0 and region_size == 0:
            off += 8
            entry_num += 1
            continue
        
        entries.append((entry_num, spi_off, region_size))
        off += 8
        entry_num += 1
    
    print(f"\n  {'#':>3} {'SPI Offset':>12} {'Size':>12} {'End':>12}  Description")
    print(f"  {'─'*3} {'─'*12} {'─'*12} {'─'*12}  {'─'*30}")
    
    for idx, spi_off, size in entries:
        end = spi_off + size if size > 0 else spi_off
        # Try to identify what's at this offset
        desc = ""
        if spi_off < len(data):
            peek = data[spi_off:spi_off+16]
            if peek[:3] == b'_EC':
                desc = f"EC firmware (ver={peek[3]})"
            elif peek[:4] == b'LADD':
                desc = "LADD sub-descriptor"
            elif b'$PL2' in peek[:8]:
                desc = "$PL2 - PSP Level 2 directory"
            elif b'$PS1' in peek[:8] or peek[16:20] == b'$PS1':
                desc = "$PS1 - PSP signature"
            elif b'_FVH' in peek[:32]:
                desc = "UEFI Firmware Volume"
            elif peek == b'\xff' * 16:
                desc = "(empty/erased)"
            elif peek == b'\x00' * 16:
                desc = "(zeroed, data follows later)"
            else:
                # Check for code patterns
                magic32 = struct.unpack_from("<I", peek, 0)[0]
                desc = f"data ({peek[:8].hex()})"
        
        print(f"  {idx:3d} {spi_off:#012x} {size:#012x} {end:#012x}  {desc}")
    
    return entries


def identify_psp_directory(data, offset):
    """Try to identify PSP/BIOS directory structure."""
    magic = data[offset:offset+4]
    print(f"\n  Checking PSP directory at SPI {offset:#09x}: magic = {magic.hex()} ({magic})")
    
    if magic == b'$PL2':
        print("  → PSP Level 2 Directory ($PL2)")
        # $PL2 header: magic(4), checksum(4), num_entries(4), reserved(4)
        # Then entries of: type(1), subprog(1), rom_id(2), size(4), location(8)
        num_entries = struct.unpack_from("<I", data, offset+8)[0] & 0xFFF  # lower 12 bits
        print(f"  Entries: {num_entries}")
        
        entry_off = offset + 16
        for i in range(min(num_entries, 50)):
            entry = data[entry_off:entry_off+16]
            if len(entry) < 16:
                break
            etype = entry[0]
            subprog = entry[1]
            rom_id = struct.unpack_from("<H", entry, 2)[0]
            esize = struct.unpack_from("<I", entry, 4)[0]
            eloc = struct.unpack_from("<Q", entry, 8)[0]
            
            # Decode entry type
            type_names = {
                0x00: "AMD_PUBLIC_KEY",
                0x01: "PSP_FW_BOOT_LOADER",
                0x02: "PSP_FW_TRUSTED_OS",
                0x03: "PSP_FW_RECOVERY_BOOT_LOADER",
                0x04: "PSP_NV_DATA",
                0x05: "BIOS_PUBLIC_KEY_AMD",
                0x06: "BIOS_RTM_FIRMWARE (BIOS code)",
                0x07: "BIOS_RTM_SIGNATURE",
                0x08: "SMU_OFFCHIP_FW",
                0x09: "AMD_SEC_DBG_PUBLIC_KEY",
                0x0A: "OEM_PSP_FW_PUBLIC_KEY",
                0x0B: "AMD_SOFT_FUSE_CHAIN_01",
                0x0C: "PSP_BOOT_TIME_TRUSTLETS",
                0x0D: "PSP_AGESA_BOOT_LOADER_0",
                0x10: "PSP_AGESA_BOOT_LOADER_1", 
                0x12: "PSP_BOOT_TIME_TRUSTLETS_KEY",
                0x13: "PSP_AGESA_RESUME_FW",
                0x20: "WRAPPED_IKEK",
                0x21: "TOKEN_UNLOCK",
                0x22: "SEC_GASKET_BINARY",
                0x24: "MP2_FW",
                0x25: "DRIVER_ENTRIES",
                0x28: "MP2_FW_2",
                0x30: "ABL0",
                0x31: "ABL1",
                0x32: "ABL2",
                0x33: "ABL3",
                0x34: "ABL4",
                0x35: "ABL5",
                0x36: "ABL6",
                0x37: "ABL7",
                0x3A: "FW_PSP_SMUSCS",
                0x40: "PSP_L2_DIRECTORY",
                0x44: "DIAG_BOOT_LOADER",
                0x47: "PSP_SEV",
                0x48: "PSP_RIB",
                0x49: "BIOS_L2_DIRECTORY",
                0x4A: "DXIO_PHY_SRAM",
                0x5A: "USB4_DXIO_PHY_FW",
                0x5F: "DXIO_PHY_FW",
                0x62: "TOS_SEC_POLICY",
                0x63: "DRTM_TA",
                0x64: "KEY_DB_TOS",
                0x6B: "USB4_RETIMER_FW",
                0x73: "TPMSPI",
            }
            
            name = type_names.get(etype, f"TYPE_{etype:#04x}")
            
            if esize == 0 and eloc == 0:
                continue
            
            loc_str = f"{eloc:#012x}"
            # Location can be relative to PSP dir start or absolute SPI offset
            if eloc & 0xFF000000 == 0x80000000:
                # Relative to PSP dir
                abs_loc = (eloc & 0x00FFFFFF) + offset
                loc_str = f"PSP+{eloc & 0x00FFFFFF:#08x} (SPI {abs_loc:#09x})"
            elif eloc < len(data):
                loc_str = f"SPI {eloc:#012x}"
            
            if esize > 0 or eloc > 0:
                print(f"    [{i:3d}] type={etype:#04x} sub={subprog} size={esize:#010x} loc={loc_str}  {name}")
            
            entry_off += 16
    
    elif magic == b'$PS1':
        print("  → PSP Signature ($PS1)")
    else:
        print(f"  → Unknown: {data[offset:offset+32].hex()}")


def main():
    for fname in ["N3GHT25W_v1.02.bin", "N3GHT64W_v1.64.bin"]:
        path = EC_SPI_DIR / fname
        if not path.exists():
            continue
        
        data = path.read_bytes()
        print(f"\n\n{'#'*70}")
        print(f"  {fname}")
        print(f"{'#'*70}")
        
        # Parse LADD directory at 0x100000
        entries = parse_ladd_directory(data, 0x100000)
        
        # Identify key regions
        # Find $PL2 directory
        for idx, spi_off, size in entries:
            if spi_off < len(data):
                peek = data[spi_off:spi_off+4]
                if peek == b'$PL2':
                    identify_psp_directory(data, spi_off)
        
        # Also check the $PL2 at 0x106000
        if data[0x106000:0x106004] == b'$PL2':
            identify_psp_directory(data, 0x106000)
        
        # Check for $PS1 signatures
        for offset in [0x386000, 0x38C000]:
            if offset < len(data):
                peek16 = data[offset:offset+32]
                if b'$PS1' in peek16:
                    print(f"\n  $PS1 found at SPI {offset:#09x}")
                    print(f"    First 32 bytes: {peek16.hex()}")
        
        # The _FVH at 0x787000 region
        fvh_scan = data[0x787000:0x787100]
        fvh_pos = fvh_scan.find(b'_FVH')
        if fvh_pos >= 0:
            print(f"\n  UEFI Firmware Volume Header at SPI {0x787000+fvh_pos:#09x}")
            # Parse FV header
            fv_off = 0x787000 + fvh_pos - 0x28  # _FVH is at offset 0x28 in FV header
            if fv_off >= 0:
                fv_len = struct.unpack_from("<Q", data, fv_off + 0x20)[0]
                print(f"    FV Length: {fv_len:#x} ({fv_len//1024} KB)")
                # GUID at start
                guid_bytes = data[fv_off+0x10:fv_off+0x20]
                guid = f"{struct.unpack_from('<IHH', guid_bytes)[0]:08x}-" \
                       f"{struct.unpack_from('<IHH', guid_bytes)[1]:04x}-" \
                       f"{struct.unpack_from('<IHH', guid_bytes)[2]:04x}-" \
                       f"{guid_bytes[8]:02x}{guid_bytes[9]:02x}-" \
                       f"{''.join(f'{b:02x}' for b in guid_bytes[10:16])}"
                print(f"    FV GUID: {guid}")


if __name__ == "__main__":
    main()
