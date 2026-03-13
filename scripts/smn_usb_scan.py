#!/usr/bin/env python3
"""
AMD SMN Register Reader for USB4/PHY Mux diagnosis.

AMD System Management Network (SMN) is accessed via the Root Complex:
  SMN_INDEX: PCI Config Space offset 0x60 (32-bit write)
  SMN_DATA:  PCI Config Space offset 0x64 (32-bit read/write)

Key SMN register regions for USB on Rembrandt:
  0x166xxxxx: XHCI extended
  0x16Axxxxx: USB PHY Lane
  0x16Cxxxxx: USB4 PHY
  0x16Dxxxxx: USB4 Router

This script reads SMN registers to diagnose USB4/PHY mux state.
READ-ONLY - does not modify any registers.
"""

import os
import struct
import sys


def smn_read(pci_fd, addr):
    """Read a 32-bit SMN register via PCI config space"""
    # Write SMN address to index (offset 0x60)
    os.lseek(pci_fd, 0x60, os.SEEK_SET)
    os.write(pci_fd, struct.pack("<I", addr))
    # Read data from offset 0x64
    os.lseek(pci_fd, 0x64, os.SEEK_SET)
    data = os.read(pci_fd, 4)
    return struct.unpack("<I", data)[0]


def scan_smn_region(pci_fd, name, base, count=16, step=4):
    """Scan an SMN register region"""
    print(f"\n=== {name} (base=0x{base:08X}) ===")
    for i in range(count):
        addr = base + i * step
        val = smn_read(pci_fd, addr)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  [0x{addr:08X}] = 0x{val:08X}")


def main():
    # Open root complex PCI config space
    pci_path = "/sys/bus/pci/devices/0000:00:00.0/config"
    try:
        pci_fd = os.open(pci_path, os.O_RDWR)
    except PermissionError:
        print("ERROR: Need root. Run with sudo.", file=sys.stderr)
        sys.exit(1)

    print("=== AMD SMN USB4/PHY Register Scan ===\n")

    # 1. Check USB IP Discovery / Version
    print("--- USB IP Discovery ---")
    for addr in [0x16600000, 0x16600004, 0x16600008, 0x1660000C]:
        val = smn_read(pci_fd, addr)
        print(f"  [0x{addr:08X}] = 0x{val:08X}")

    # 2. USB4 Router registers
    print("\n--- USB4 Router Registers ---")
    # USB4 Router capability registers - try several known bases
    for base in [0x16D00000, 0x16D10000, 0x16D20000]:
        val = smn_read(pci_fd, base)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  Router at 0x{base:08X}: 0x{val:08X}")
            for off in range(4, 0x40, 4):
                val2 = smn_read(pci_fd, base + off)
                if val2 != 0 and val2 != 0xFFFFFFFF:
                    print(f"    [+0x{off:02X}] = 0x{val2:08X}")
        else:
            print(f"  Router at 0x{base:08X}: NOT PRESENT (0x{val:08X})")

    # 3. USB4 PHY registers
    print("\n--- USB4 PHY Registers ---")
    for base in [0x16C00000, 0x16C10000, 0x16C20000]:
        val = smn_read(pci_fd, base)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  PHY at 0x{base:08X}: 0x{val:08X}")
            for off in range(4, 0x40, 4):
                val2 = smn_read(pci_fd, base + off)
                if val2 != 0 and val2 != 0xFFFFFFFF:
                    print(f"    [+0x{off:02X}] = 0x{val2:08X}")
        else:
            print(f"  PHY at 0x{base:08X}: NOT PRESENT (0x{val:08X})")

    # 4. USB PHY Lane configuration
    print("\n--- USB PHY Lane Config ---")
    for base in [0x16A00000, 0x16A10000, 0x16A20000, 0x16A30000]:
        val = smn_read(pci_fd, base)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  Lane at 0x{base:08X}: 0x{val:08X}")

    # 5. FCH USB registers (IO hub)
    print("\n--- FCH USB Configuration ---")
    # FCH::USB::USB3 registers (from AGESA openSIL):
    # USB3 Control = 0x16EF_xxxx region on some generations
    for base in [0x16EF0000, 0x16EF0100, 0x16EF0200]:
        val = smn_read(pci_fd, base)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  FCH USB at 0x{base:08X}: 0x{val:08X}")

    # 6. Broader scan of 0x166xxxxx for XHCI extended
    print("\n--- XHCI Extended Register Scan ---")
    # Try XHCI extended capability base ranges
    for port_base in [0x16600000, 0x16610000, 0x16620000, 0x16630000, 0x16640000, 0x16650000, 0x16660000, 0x16670000]:
        val = smn_read(pci_fd, port_base)
        if val != 0 and val != 0xFFFFFFFF:
            print(f"  [0x{port_base:08X}] = 0x{val:08X}")

    # 7. SMU (System Management Unit) - USB4 enable bits
    print("\n--- SMU USB4 Config ---")
    # SMU args / result for USB4 config queries
    for addr in [0x03B10528, 0x03B10564, 0x03B10A00]:
        val = smn_read(pci_fd, addr)
        print(f"  [0x{addr:08X}] = 0x{val:08X}")

    # 8. IOHC (IO Hub Controller) - port map
    print("\n--- IOHC Port Configuration ---")
    for addr in [0x13B10000, 0x13B10004, 0x13B10008, 0x13B1000C, 0x13B10010, 0x13B10014, 0x13B10018, 0x13B1001C]:
        val = smn_read(pci_fd, addr)
        if val != 0:
            print(f"  [0x{addr:08X}] = 0x{val:08X}")

    # 9. Quick broad scan for any non-zero registers in USB4-related ranges
    print("\n--- Quick Scan: Non-zero USB registers ---")
    interesting = set()
    for region_base in [0x16600000, 0x16A00000, 0x16C00000, 0x16D00000]:
        for offset in range(0, 0x1000, 0x100):
            addr = region_base + offset
            val = smn_read(pci_fd, addr)
            if val != 0 and val != 0xFFFFFFFF:
                print(f"  [0x{addr:08X}] = 0x{val:08X}")
                interesting.add(region_base)

    if not interesting:
        print("  No USB4-related SMN registers found with non-zero values.")
        print("  USB4 subsystem appears to be completely disabled in firmware.")

    os.close(pci_fd)
    print("\nDone.")


if __name__ == "__main__":
    main()
