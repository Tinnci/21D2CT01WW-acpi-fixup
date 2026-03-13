#!/usr/bin/env python3
"""
APCB USB4 Enable Patch Tool for ThinkPad Z13 Gen 1 Engineering Sample
=====================================================================

Creates a patched SPI image with USB4 enablement changes to the APCB region.
Only modifies APCB configuration bytes — NO PSP/EC/UEFI changes.

CHANGES APPLIED:
  1. GNBG port configs: byte14 bit5 (NHI enable) — 0x10→0x30 (×4 ports, ×2 APCB copies)
  2. FCHG SuperSpeed enable: +0x24 — 0x00→0x01 (×2 APCB copies)
  3. Token 0x4367CBD2 (USB4 NHI): 0→1 (×2 APCB copies)
  4. Token 0x4967F4FC (USB4 CM): 0→1 (×2 APCB copies)
  5. Token 0xFEDB01F8 (USB4 Tunnel): 0→1 (×2 APCB copies)
  6. APCB checksums recalculated (×2)

SAFETY:
  - Input: original engineering SPI dump (read-only)
  - Output: new file with "_usb4_patched" suffix
  - All changes are verified before and after
  - Checksum integrity maintained

REQUIRES: SPI programmer (CH341A / Pomona clip) for flashing.
WARNING: Test with read-back verify after flashing. Keep original dump for recovery.
"""

import struct
import sys
import os
import hashlib
from datetime import datetime

# === Configuration ===
SPI_PATH = "/home/drie/桌面/acpi-fixup/firmware/spi_dump/bios_dump_20260306_104957.bin"
OUTPUT_DIR = "/home/drie/桌面/acpi-fixup/build"

# APCB instance addresses (primary + backup)
APCB_INSTANCES = {
    "primary": {
        "base": 0x449000,
        "size": 0x75F4,
        "uid": 0x269C,
        "checksum_offset": 0x10,  # relative to APCB base
    },
    "backup": {
        "base": 0x811000,
        "size": 0x75F4,
        "uid": 0x269C,
        "checksum_offset": 0x10,
    },
}

# Also patch small APCB (contains its own GNBG port configs)
SMALL_APCB = {
    "base": 0x446000,
    "size": 0x410,
    "uid": 0x9F9494,
    "checksum_offset": 0x10,
}

# GNBG port configuration patches (offsets relative to APCB base)
# Internal APCB offset to GNBG: 0x6DA4
# Port offsets within GNBG: +0xA4, +0xB4, +0xC4, +0xD4
GNBG_OFFSET = 0x6DA4  # within main APCB
GNBG_PORT_PATCHES = [
    # (port_offset_in_gnbg, byte_index, old_value, new_value, description)
    (0xA4, 2, 0x00, 0x30, "Port1: USB4 mode enable"),
    (0xB4, 2, 0x10, 0x30, "Port2: NHI enable (bit5)"),
    (0xC4, 0, 0x00, 0x02, "Port3: NHI device remap byte0"),
    (0xC4, 2, 0x10, 0x30, "Port3: NHI enable (bit5)"),
    (0xC4, 3, 0x00, 0x20, "Port3: NHI device remap byte3"),
    (0xD4, 2, 0x10, 0x30, "Port4: NHI enable (bit5)"),
]

# Small APCB GNBG port patches (different layout, GNBG at APCB+0x80)
# Port data at GNBG+0x66, +0x76, +0x86 (byte5 of each port block)
SMALL_GNBG_OFFSET = 0x80  # within small APCB
SMALL_GNBG_PORT_PATCHES = [
    # (offset_from_gnbg_start, byte_index, old, new, description)
    (0x66, 0, 0x10, 0x30, "SmallAPCB Port2: USB4 mode"),
    (0x76, 0, 0x10, 0x30, "SmallAPCB Port3: USB4 mode"),
    (0x86, 0, 0x10, 0x30, "SmallAPCB Port4: USB4 mode"),
]

# FCHG SuperSpeed enable (offset relative to APCB base)
FCHG_OFFSET = 0x7014  # within main APCB
FCHG_SS_BYTE_OFFSET = 0x24  # within FCHG block
FCHG_PATCH = (FCHG_OFFSET + FCHG_SS_BYTE_OFFSET, 0x00, 0x01, "FCHG: SuperSpeed enable")

# Token patches (token_id, value_offset_from_token_start, old_value, new_value, description)
# Tokens are found at specific offsets within the main APCB:
#   0x4367CBD2 at APCB+0x7314, value at +4
#   0x4967F4FC at APCB+0x7334, value at +4
#   0xFEDB01F8 at APCB+0x7264, value at +4
TOKEN_PATCHES = [
    (0x4367CBD2, 0x7314, "USB4 NHI Enable"),
    (0x4967F4FC, 0x7334, "USB4 Connection Manager"),
    (0xFEDB01F8, 0x7264, "USB4 PCIe Tunneling"),
]


def verify_byte(data, offset, expected, desc):
    """Verify a byte at offset matches expected value."""
    actual = data[offset]
    if actual != expected:
        print(f"  ✗ VERIFY FAIL at 0x{offset:06X}: expected 0x{expected:02X}, got 0x{actual:02X} ({desc})")
        return False
    return True


def patch_byte(data, offset, old_val, new_val, desc):
    """Patch a single byte, with verification."""
    actual = data[offset]
    if actual != old_val:
        print(f"  ✗ PATCH FAIL at 0x{offset:06X}: expected old=0x{old_val:02X}, got 0x{actual:02X} ({desc})")
        return False
    data[offset] = new_val
    print(f"  ✓ 0x{offset:06X}: 0x{old_val:02X} → 0x{new_val:02X}  ({desc})")
    return True


def fix_apcb_checksum(data, apcb_base, apcb_size, cs_offset):
    """Recalculate APCB checksum (8-bit sum of all bytes mod 256 == 0)."""
    cs_abs = apcb_base + cs_offset
    # Zero out checksum byte
    data[cs_abs] = 0
    # Calculate sum of all bytes
    byte_sum = sum(data[apcb_base : apcb_base + apcb_size]) & 0xFF
    # Checksum = (256 - sum) mod 256
    new_cs = (256 - byte_sum) & 0xFF
    data[cs_abs] = new_cs
    # Verify
    verify_sum = sum(data[apcb_base : apcb_base + apcb_size]) & 0xFF
    return new_cs, verify_sum == 0


def main():
    print("=" * 70)
    print("APCB USB4 Enable Patch Tool")
    print("ThinkPad Z13 Gen 1 (21D2CT01WW) Engineering Sample")
    print(f"Date: {datetime.now().isoformat()}")
    print("=" * 70)

    # Read original SPI dump
    print(f"\nReading: {SPI_PATH}")
    with open(SPI_PATH, "rb") as f:
        original = f.read()

    print(f"  Size: {len(original):,} bytes (0x{len(original):X})")
    print(f"  SHA256: {hashlib.sha256(original).hexdigest()}")

    # Create mutable copy
    data = bytearray(original)

    # Track all changes
    changes = 0
    failures = 0

    # === Patch main APCB instances (primary + backup) ===
    for instance_name, info in APCB_INSTANCES.items():
        base = info["base"]
        size = info["size"]

        print(f"\n{'=' * 60}")
        print(f"Patching {instance_name} APCB @0x{base:06X} (size=0x{size:X})")
        print(f"{'=' * 60}")

        # Verify APCB signature
        sig = data[base : base + 4]
        if sig != b"APCB":
            print(f"  ✗ APCB signature missing at 0x{base:06X}: {sig}")
            failures += 1
            continue

        # Verify size and UID
        stored_size = struct.unpack_from("<I", data, base + 8)[0]
        stored_uid = struct.unpack_from("<I", data, base + 0xC)[0]
        if stored_size != size or stored_uid != info["uid"]:
            print(
                f"  ✗ APCB metadata mismatch: size=0x{stored_size:X} (exp 0x{size:X}), uid=0x{stored_uid:X} (exp 0x{info['uid']:X})"
            )
            failures += 1
            continue

        old_cs = data[base + info["checksum_offset"]]
        print(f"  APCB verified: sig=APCB, size=0x{size:X}, uid=0x{stored_uid:X}, cs=0x{old_cs:02X}")

        # 1. GNBG Port configs
        print("\n  --- GNBG Port Configurations ---")
        gnbg_abs = base + GNBG_OFFSET
        gnbg_sig = data[gnbg_abs : gnbg_abs + 4]
        if gnbg_sig != b"GNBG":
            print(f"  ✗ GNBG signature missing at 0x{gnbg_abs:06X}: {gnbg_sig}")
            failures += 1
        else:
            for port_off, byte_idx, old, new, desc in GNBG_PORT_PATCHES:
                abs_addr = gnbg_abs + port_off + byte_idx
                if patch_byte(data, abs_addr, old, new, desc):
                    changes += 1
                else:
                    failures += 1

        # 2. FCHG SuperSpeed
        print("\n  --- FCHG SuperSpeed Enable ---")
        fchg_abs = base + FCHG_OFFSET
        fchg_sig = data[fchg_abs : fchg_abs + 4]
        if fchg_sig != b"FCHG":
            print(f"  ✗ FCHG signature missing at 0x{fchg_abs:06X}: {fchg_sig}")
            failures += 1
        else:
            abs_addr = base + FCHG_PATCH[0]
            if patch_byte(data, abs_addr, FCHG_PATCH[1], FCHG_PATCH[2], FCHG_PATCH[3]):
                changes += 1
            else:
                failures += 1

        # 3. Token patches
        print("\n  --- Token Patches ---")
        for token_id, token_apcb_off, desc in TOKEN_PATCHES:
            token_abs = base + token_apcb_off
            # Verify token ID is at this offset
            stored_id = struct.unpack_from("<I", data, token_abs)[0]
            if stored_id != token_id:
                print(f"  ✗ Token 0x{token_id:08X} not found at 0x{token_abs:06X} (got 0x{stored_id:08X})")
                failures += 1
                continue

            # Value is 4 bytes after token ID
            val_addr = token_abs + 4
            old_val = struct.unpack_from("<I", data, val_addr)[0]
            if old_val != 0:
                print(f"  ✗ Token 0x{token_id:08X} value already non-zero: 0x{old_val:08X}")
                failures += 1
                continue

            data[val_addr] = 0x01  # Set to 1 (little-endian, low byte)
            print(f"  ✓ Token 0x{token_id:08X} @0x{val_addr:06X}: 0→1  ({desc})")
            changes += 1

        # 4. Fix APCB checksum
        print("\n  --- Checksum Update ---")
        new_cs, valid = fix_apcb_checksum(data, base, size, info["checksum_offset"])
        print(f"  Checksum: 0x{old_cs:02X} → 0x{new_cs:02X}  {'✓ valid' if valid else '✗ INVALID'}")
        if not valid:
            failures += 1

    # === Patch small APCB @0x446000 (optional but recommended) ===
    print(f"\n{'=' * 60}")
    print(f"Patching small APCB @0x{SMALL_APCB['base']:06X} (size=0x{SMALL_APCB['size']:X})")
    print(f"{'=' * 60}")

    small_base = SMALL_APCB["base"]
    small_sig = data[small_base : small_base + 4]
    if small_sig != b"APCB":
        print(f"  ✗ Small APCB signature missing: {small_sig}")
        failures += 1
    else:
        small_gnbg_abs = small_base + SMALL_GNBG_OFFSET
        small_gnbg_sig = data[small_gnbg_abs : small_gnbg_abs + 4]
        if small_gnbg_sig != b"GNBG":
            print(f"  ✗ Small GNBG signature missing at 0x{small_gnbg_abs:06X}: {small_gnbg_sig}")
            failures += 1
        else:
            old_cs = data[small_base + SMALL_APCB["checksum_offset"]]
            for off, byte_idx, old, new, desc in SMALL_GNBG_PORT_PATCHES:
                abs_addr = small_gnbg_abs + off + byte_idx
                if patch_byte(data, abs_addr, old, new, desc):
                    changes += 1
                else:
                    failures += 1

            new_cs, valid = fix_apcb_checksum(data, small_base, SMALL_APCB["size"], SMALL_APCB["checksum_offset"])
            print(f"  Checksum: 0x{old_cs:02X} → 0x{new_cs:02X}  {'✓ valid' if valid else '✗ INVALID'}")
            if not valid:
                failures += 1

    # === Summary ===
    print(f"\n{'=' * 70}")
    print("PATCH SUMMARY")
    print(f"{'=' * 70}")
    print(f"  Changes applied:  {changes}")
    print(f"  Failures:         {failures}")

    if failures > 0:
        print(f"\n  ✗ PATCHING FAILED — {failures} errors. Output NOT written.")
        sys.exit(1)

    # Verify only APCB regions changed
    diff_count = sum(1 for a, b in zip(original, data) if a != b)
    print(f"  Total bytes changed: {diff_count}")

    # Show all changed bytes
    print("\n  Changed byte map:")
    for i in range(len(original)):
        if original[i] != data[i]:
            print(f"    0x{i:06X}: 0x{original[i]:02X} → 0x{data[i]:02X}")

    # Verify no changes outside APCB regions
    apcb_ranges = [
        (0x446000, 0x446000 + 0x410),
        (0x449000, 0x449000 + 0x75F4),
        (0x811000, 0x811000 + 0x75F4),
    ]
    outside_changes = 0
    for i in range(len(original)):
        if original[i] != data[i]:
            in_apcb = any(start <= i < end for start, end in apcb_ranges)
            if not in_apcb:
                print(f"    ✗ UNEXPECTED change outside APCB at 0x{i:06X}")
                outside_changes += 1

    if outside_changes > 0:
        print(f"\n  ✗ {outside_changes} changes outside APCB — ABORTING")
        sys.exit(1)

    print("\n  ✓ All changes are within APCB regions")

    # Write output
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = os.path.join(OUTPUT_DIR, f"spi_usb4_patched_{timestamp}.bin")
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    with open(output_path, "wb") as f:
        f.write(data)

    print(f"\n  Output: {output_path}")
    print(f"  SHA256: {hashlib.sha256(bytes(data)).hexdigest()}")
    print(f"  Size:   {len(data):,} bytes")

    print(f"\n{'=' * 70}")
    print("NEXT STEPS")
    print(f"{'=' * 70}")
    print("  1. Connect SPI programmer (CH341A) to Winbond W25Q256JW")
    print("  2. Verify chip ID: flashrom -p ch341a_spi")
    print("  3. Read-back verify: flashrom -p ch341a_spi -r /tmp/readback.bin")
    print("  4. Compare: sha256sum /tmp/readback.bin  (should match original dump)")
    print(f"  5. Flash: flashrom -p ch341a_spi -w {output_path}")
    print("  6. Read-back verify again after flashing")
    print("  7. Boot and check: lspci -s 00:08 -vv  (look for USB4 NHI)")
    print("  8. If USB4 NHI appears: modprobe thunderbolt")
    print(f"  9. Recovery: flashrom -p ch341a_spi -w {SPI_PATH}")


if __name__ == "__main__":
    main()
