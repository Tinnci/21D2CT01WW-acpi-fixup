#!/usr/bin/env python3
"""Deep analysis of Lenovo EC FL2 firmware for Ghidra import preparation.

Determines:
- EC chip type (Nuvoton NPCX vs others)
- ARM Cortex-M vector table location
- Code base address for Ghidra
- Memory map estimation
"""

import struct
import sys
from pathlib import Path

FL2_PATH = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent.parent / "firmware/ec/N3GHT68W.FL2"


def hexdump(data, offset=0, length=None):
    """Print hex dump of data."""
    if length:
        data = data[:length]
    for i in range(0, len(data), 16):
        chunk = data[i : i + 16]
        hex_str = " ".join(f"{b:02X}" for b in chunk)
        ascii_str = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        print(f"  {offset + i:06X}: {hex_str:<48s}  {ascii_str}")


def analyze_headers(data):
    """Analyze _EC1 and _EC2 headers."""
    print("=" * 60)
    print("EC FL2 HEADER ANALYSIS")
    print("=" * 60)

    # _EC1 Header
    print("\n--- _EC1 Header (0x00-0x1F) ---")
    hexdump(data[0:0x20])
    ec1_magic = data[0:4]
    ec1_total = struct.unpack_from("<I", data, 4)[0]
    ec1_data = struct.unpack_from("<I", data, 8)[0]
    ec1_f0c = struct.unpack_from("<I", data, 0xC)[0]
    ec1_f10 = struct.unpack_from("<I", data, 0x10)[0]
    ec1_chk = struct.unpack_from("<I", data, 0x14)[0]
    print(f"  Magic:    {ec1_magic} ({'_EC1' if ec1_magic == b'_EC1' else 'UNKNOWN'})")
    print(f"  Total:    0x{ec1_total:08X} = {ec1_total} (file={len(data)})")
    print(f"  Data sz:  0x{ec1_data:08X} = {ec1_data}")
    print(f"  Field@0C: 0x{ec1_f0c:08X}")
    print(f"  Field@10: 0x{ec1_f10:08X}")
    print(f"  Checksum: 0x{ec1_chk:08X}")

    # _EC2 Header
    print("\n--- _EC2 Header (0x20-0x3F) ---")
    hexdump(data[0x20:0x40], 0x20)
    ec2_magic = data[0x20:0x24]
    ec2_total = struct.unpack_from("<I", data, 0x24)[0]
    ec2_data = struct.unpack_from("<I", data, 0x28)[0]
    ec2_f2c = struct.unpack_from("<I", data, 0x2C)[0]
    ec2_f30 = struct.unpack_from("<I", data, 0x30)[0]
    ec2_chk = struct.unpack_from("<I", data, 0x34)[0]
    print(f"  Magic:    {ec2_magic} ({'_EC2' if ec2_magic == b'_EC2' else 'UNKNOWN'})")
    print(f"  Total:    0x{ec2_total:08X} = {ec2_total}")
    print(f"  Data sz:  0x{ec2_data:08X} = {ec2_data}")
    print(f"  Field@2C: 0x{ec2_f2c:08X}")
    print(f"  Field@30: 0x{ec2_f30:08X}")
    print(f"  Checksum: 0x{ec2_chk:08X}")

    # Header area 0x40-0x100
    print("\n--- Header/Config Area (0x40-0x100) ---")
    for i in range(0x40, 0x100, 16):
        chunk = data[i : i + 16]
        if any(b != 0 and b != 0xFF and b != 0xEC for b in chunk):
            hexdump(data[i : i + 16], i)


def find_vector_tables(data):
    """Search for ARM Cortex-M vector tables."""
    print("\n" + "=" * 60)
    print("ARM CORTEX-M VECTOR TABLE SEARCH")
    print("=" * 60)

    candidates = []

    for off in range(0, min(0x10000, len(data) - 64), 4):
        sp = struct.unpack_from("<I", data, off)[0]
        reset = struct.unpack_from("<I", data, off + 4)[0]
        nmi = struct.unpack_from("<I", data, off + 8)[0]
        hardfault = struct.unpack_from("<I", data, off + 12)[0]

        # SP must be in SRAM range (0x20000000-0x200FFFFF for Cortex-M)
        if not (0x20000000 <= sp <= 0x200FFFFF):
            continue

        # Reset must be Thumb (odd address)
        if reset & 1 == 0:
            continue

        # Reset vector must be in code range
        reset_addr = reset & ~1
        if reset_addr == 0:
            continue

        # NMI and HardFault should also be Thumb
        if nmi & 1 == 0 or hardfault & 1 == 0:
            continue

        # All vectors should be in same address space
        nmi & ~1
        hardfault & ~1

        # Score: how many of the first 16 vectors look valid?
        score = 0
        all_vectors = []
        for v in range(16):
            vec = struct.unpack_from("<I", data, off + v * 4)[0]
            all_vectors.append(vec)
            if v == 0:  # SP
                if 0x20000000 <= vec <= 0x200FFFFF:
                    score += 2
            else:
                if vec == 0:  # Unused vector
                    score += 1
                elif vec & 1 == 1:  # Thumb address
                    vec_addr = vec & ~1
                    # Should be in reasonable code range
                    if 0 < vec_addr < 0x100000 or 0x10000000 <= vec_addr <= 0x100FFFFF:
                        score += 2

        if score >= 12:  # Reasonable threshold
            candidates.append((off, score, sp, reset, nmi, hardfault, all_vectors))

    # Sort by score descending
    candidates.sort(key=lambda x: -x[1])

    for c in candidates[:10]:
        off, score, sp, reset, nmi, hf, vecs = c
        print(f"\n  === Candidate at FL2 offset 0x{off:04X} (score={score}) ===")
        print(f"  SP           = 0x{sp:08X}")
        print(f"  Reset        = 0x{reset:08X}  (entry=0x{reset & ~1:08X})")
        print(f"  NMI          = 0x{nmi:08X}")
        print(f"  HardFault    = 0x{hf:08X}")
        for v in range(4, min(16, len(vecs))):
            vec = vecs[v]
            names = {
                4: "MemManage",
                5: "BusFault",
                6: "UsageFault",
                7: "Rsvd7",
                8: "Rsvd8",
                9: "Rsvd9",
                10: "Rsvd10",
                11: "SVCall",
                12: "DebugMon",
                13: "Rsvd13",
                14: "PendSV",
                15: "SysTick",
            }
            name = names.get(v, f"Vec{v}")
            if vec != 0:
                print(f"  {name:12s} = 0x{vec:08X}")

        # Show hex dump around the candidate
        print(f"  Raw hex at 0x{off:04X}:")
        hexdump(data[off : off + 64], off)

    return candidates


def find_address_patterns(data):
    """Analyze address references to determine base address."""
    print("\n" + "=" * 60)
    print("ADDRESS PATTERN ANALYSIS")
    print("=" * 60)

    # Count references to different address ranges (by 64KB page)
    addr_pages = {}
    for off in range(0, len(data) - 4, 2):
        val = struct.unpack_from("<I", data, off)[0]
        page = val >> 16

        # Filter for interesting ranges
        if page in range(0x4000, 0x4100):  # 0x4000xxxx-0x40FFxxxx (Cortex-M peripherals)
            key = f"0x{page:04X}0000"
            addr_pages[key] = addr_pages.get(key, 0) + 1
        elif page in range(0x1007, 0x100B):  # 0x1007xxxx-0x100Axxxx (NPCX code RAM)
            key = f"0x{page:04X}0000"
            addr_pages[key] = addr_pages.get(key, 0) + 1
        elif page in range(0x200B, 0x2010):  # 0x200Bxxxx-0x200Fxxxx (SRAM)
            key = f"0x{page:04X}0000"
            addr_pages[key] = addr_pages.get(key, 0) + 1
        elif page in range(0xE000, 0xE010):  # 0xE000xxxx (Cortex-M system)
            key = f"0x{page:04X}0000"
            addr_pages[key] = addr_pages.get(key, 0) + 1

    print("\nPeripheral/system address references (sorted by frequency):")
    for addr, count in sorted(addr_pages.items(), key=lambda x: -x[1])[:30]:
        print(f"  {addr}: {count} refs")

    # Also look at the most common 32-bit aligned values that look like code addresses
    print("\nCode address range analysis:")
    code_ranges = {}
    for off in range(0x100, len(data) - 4, 4):
        val = struct.unpack_from("<I", data, off)[0]
        if val & 1 == 1:  # Thumb address
            addr = val & ~1
            # Check which range it falls in
            if 0 < addr < 0x80000:
                code_ranges["0x00000000 (flash-mapped)"] = code_ranges.get("0x00000000 (flash-mapped)", 0) + 1
            elif 0x10000000 <= addr < 0x10100000:
                code_ranges["0x10000000 (NPCX code)"] = code_ranges.get("0x10000000 (NPCX code)", 0) + 1
            elif 0x100A0000 <= addr < 0x100E0000:
                code_ranges["0x100A0000 (NPCX code RAM)"] = code_ranges.get("0x100A0000 (NPCX code RAM)", 0) + 1

    for range_name, count in sorted(code_ranges.items(), key=lambda x: -x[1]):
        print(f"  {range_name}: {count} Thumb refs")


def find_strings(data):
    """Find interesting strings in the firmware."""
    print("\n" + "=" * 60)
    print("STRING ANALYSIS")
    print("=" * 60)

    # Find all printable strings >= 6 chars
    interesting = []
    i = 0
    while i < len(data):
        if 32 <= data[i] < 127:
            start = i
            while i < len(data) and 32 <= data[i] < 127:
                i += 1
            s = data[start:i].decode("ascii")
            if len(s) >= 6:
                interesting.append((start, s))
        else:
            i += 1

    # Filter for USB/mux/UCSI/PD related
    keywords = [
        "USB",
        "usb",
        "MUX",
        "mux",
        "UCSI",
        "ucsi",
        "PD",
        "Type-C",
        "typec",
        "TCPC",
        "tcpc",
        "retimer",
        "GPIO",
        "gpio",
        "SMB",
        "smb",
        "I2C",
        "i2c",
        "port",
        "PORT",
        "hub",
        "HUB",
        "alt",
        "ALT",
        "mode",
        "MODE",
        "NPCX",
        "Nuvoton",
        "Lenovo",
        "lenovo",
        "LENOVO",
        "EC",
        "KBC",
        "kbc",
        "ACPI",
        "acpi",
        "SCI",
        "SMI",
        "battery",
        "power",
        "charge",
        "thermal",
        "fan",
        "N3G",
        "version",
        "Version",
    ]

    print("\n--- USB/Mux/EC Related Strings ---")
    for off, s in interesting:
        if any(kw in s for kw in keywords):
            print(f'  0x{off:06X}: "{s}"')

    print(f"\n--- All Strings >= 8 chars (total: {len([s for _, s in interesting if len(s) >= 8])}) ---")
    for off, s in interesting:
        if len(s) >= 8:
            print(f'  0x{off:06X}: "{s}"')


def find_npcx_peripherals(data):
    """Search for Nuvoton NPCX peripheral register access patterns."""
    print("\n" + "=" * 60)
    print("NUVOTON NPCX PERIPHERAL ANALYSIS")
    print("=" * 60)

    # NPCX7/NPCX9 peripheral base addresses
    npcx_periphs = {
        0x400C1000: "MIWU0 (Multi-Input Wake-Up)",
        0x400C3000: "MIWU1",
        0x400C5000: "MIWU2",
        0x400C7000: "GPIO",
        0x400C9000: "CDCG (Clock Distribution)",
        0x400CB000: "PM Channel",
        0x400CD000: "UART",
        0x400CF000: "SHI (SPI Host Interface)",
        0x400D1000: "SHM (Shared Memory)",
        0x400D3000: "KBC (Keyboard Controller)",
        0x400D5000: "ADC",
        0x400D7000: "SMB0 (I2C/SMBus)",
        0x400D9000: "SMB1",
        0x400DB000: "SMB2",
        0x400DD000: "SMB3",
        0x400DF000: "TWD (Timer/Watchdog)",
        0x400E1000: "ITIM (Internal Timer)",
        0x400E3000: "PWM",
        0x400E5000: "eSPI (Enhanced SPI)",
        0x40080000: "SMB4",
        0x40082000: "SMB5",
        0x40084000: "SMB6",
        0x40086000: "SMB7",
        0x4000C000: "PECI",
        0x4000E000: "SPIP (SPI Peripheral)",
    }

    print("\nSearching for NPCX peripheral register references:")
    found_periphs = {}
    for off in range(0, len(data) - 4, 2):
        val = struct.unpack_from("<I", data, off)[0]
        # Round to 4KB page
        page = val & 0xFFFFF000
        if page in npcx_periphs:
            name = npcx_periphs[page]
            if name not in found_periphs:
                found_periphs[name] = []
            if len(found_periphs[name]) < 5:  # Keep first 5 refs
                found_periphs[name].append((off, val))

    if found_periphs:
        print("  *** NPCX PERIPHERAL ADDRESSES FOUND! ***")
        for name, refs in sorted(found_periphs.items()):
            print(f"\n  {name}:")
            for off, val in refs:
                print(f"    FL2 offset 0x{off:06X}: reg 0x{val:08X}")
    else:
        print("  No NPCX peripheral addresses found")

    # Also check for ITE EC patterns (alternative)
    ite_periphs = {
        0x00F01000: "ITE EC2I",
        0x00F01800: "ITE KBC",
        0x00F02000: "ITE PMC",
        0x00F02800: "ITE GPIO",
        0x00F03000: "ITE PWM",
        0x00F03800: "ITE ADC",
        0x00F04000: "ITE SMBUS",
    }

    print("\n\nChecking ITE IT8xxx EC patterns:")
    for off in range(0, min(len(data), 0x50000) - 4, 2):
        val = struct.unpack_from("<I", data, off)[0]
        page = val & 0xFFFFF800
        if page in ite_periphs:
            print(f"  Found ITE ref at 0x{off:06X}: 0x{val:08X} = {ite_periphs[page]}")
            break
    else:
        print("  No ITE peripheral addresses found")


def main():
    data = FL2_PATH.read_bytes()
    print(f"FL2 file: {FL2_PATH}")
    print(f"FL2 size: {len(data)} bytes (0x{len(data):X})")

    analyze_headers(data)
    find_vector_tables(data)
    find_address_patterns(data)
    find_npcx_peripherals(data)
    find_strings(data)


if __name__ == "__main__":
    main()
