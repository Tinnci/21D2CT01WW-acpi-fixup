#!/usr/bin/env python3
"""Extract and analyze PD controller firmware blobs from EC FL2 file.

The EC FL2 contains embedded Microchip USB PD controller firmware that the EC
normally writes to the PD chip(s) over I2C/SMBus during boot. On engineering
EC (N3GHT15W), this never happens, leaving the PD controller in DFU mode.

This script extracts the PD firmware blobs for potential DFU programming.
"""

import struct
import sys
from pathlib import Path

fl2_path = Path(sys.argv[1])
out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else fl2_path.parent
data = fl2_path.read_bytes()

ec_name = None
for i in range(0, min(len(data), 0x1000)):
    if data[i : i + 4] == b"N3GH":
        ec_name = data[i : i + 8].decode("ascii", errors="replace")
        break

print(f"FL2: {fl2_path} ({len(data)} bytes)")
print(f"EC firmware: {ec_name or 'unknown'}")

# Find PD firmware blobs by looking for the header pattern
# Each PD blob has a consistent header starting with bytes before the ID:
#   ... ff ff 01 00 XX XX (size?) XX XX XX XX 00 00 00 00 00 00
#   00 00 30 78 31 20 ("0x1 ") fa XX 54 00 1a XX XX 06 00 07
#   N3GPxxxx (8-byte ID)

pd_blobs = []

# Method: Find each PD firmware ID and trace back to the blob start
for pd_prefix in [b"N3GPD", b"N3GPH"]:
    pos = 0
    while True:
        pos = data.find(pd_prefix, pos)
        if pos == -1:
            break

        fw_id = data[pos : pos + 8].decode("ascii", errors="replace")

        # Skip if this is in the version index table (IDs are null-separated there)
        if pos > 0 and data[pos - 1] == 0 and pos > 2 and data[pos - 2 : pos - 1] in [b"W", b"\x00"]:
            # This might be the index table, skip
            if data[pos + 8] == 0:
                pos += 1
                continue

        # Look for the header pattern: 14 bytes before the ID should have "0x1 " marker
        marker_pos = pos - 0x1E  # "0x1 " is typically 0x1E bytes before the ID
        if marker_pos >= 0 and data[marker_pos : marker_pos + 4] == b"0x1 ":
            # Found the blob start area
            # The actual blob starts 0x14 bytes before "0x1 " (with the ff ff 01 00 XX XX header)
            blob_header_start = marker_pos - 0x14

            # Check for the 01 00 prefix
            if blob_header_start >= 2 and data[blob_header_start : blob_header_start + 2] == b"\x01\x00":
                blob_start = blob_header_start
            else:
                # Try to find the ff ff boundary before
                search_back = max(0, marker_pos - 0x20)
                blob_start = marker_pos
                for i in range(marker_pos - 1, search_back, -1):
                    if data[i] == 0xFF and data[i - 1] == 0xFF:
                        blob_start = i + 1
                        break

            # Read blob size from header (2 bytes at offset +2)
            blob_size_field = struct.unpack_from("<H", data, blob_start + 2)[0]

            # The actual blob extends much further than the size field suggests
            # Look for the end: large block of 0xFF or next blob
            blob_end = min(len(data), blob_start + 0x10000)  # Max 64KB per blob
            for i in range(pos + 8, blob_end - 16):
                if data[i : i + 16] == b"\xff" * 16:
                    blob_end = i
                    break

            actual_size = blob_end - blob_start
            pd_blobs.append(
                {
                    "id": fw_id,
                    "offset": blob_start,
                    "size": actual_size,
                    "size_field": blob_size_field,
                    "id_offset": pos,
                }
            )

        pos += 1

# Deduplicate (keep the ones with actual blob headers, not index table entries)
seen_ids = {}
unique_blobs = []
for blob in pd_blobs:
    key = f"{blob['id']}_{blob['offset']}"
    if key not in seen_ids:
        seen_ids[key] = True
        unique_blobs.append(blob)

print(f"\n{'=' * 60}")
print(f"Found {len(unique_blobs)} PD firmware blobs:")
print(f"{'=' * 60}")

for i, blob in enumerate(unique_blobs):
    fw_id = blob["id"]
    offset = blob["offset"]
    size = blob["size"]
    size_field = blob["size_field"]

    print(f"\n--- Blob {i + 1}: {fw_id} ---")
    print(f"  FL2 offset: 0x{offset:06X}")
    print(f"  Size: {size} bytes (header field: 0x{size_field:04X} = {size_field})")
    print(f"  FW ID at: 0x{blob['id_offset']:06X}")

    blob_data = data[offset : offset + size]

    # Hex dump of header
    print("  Header (first 64 bytes):")
    for j in range(0, min(64, len(blob_data)), 16):
        chunk = blob_data[j : j + 16]
        hex_str = " ".join(f"{b:02x}" for b in chunk)
        asc = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        print(f"    {offset + j:06X}: {hex_str:<48s}  {asc}")

    # Analyze the blob structure
    print("\n  Structure analysis:")
    if len(blob_data) >= 0x30:
        field_02 = struct.unpack_from("<H", blob_data, 2)[0]
        field_04 = struct.unpack_from("<I", blob_data, 4)[0]
        field_08 = struct.unpack_from("<H", blob_data, 8)[0]
        print(f"    +0x02: size/type = 0x{field_02:04X} ({field_02})")
        print(f"    +0x04: hash/crc  = 0x{field_04:08X}")
        print(f"    +0x08: param     = 0x{field_08:04X}")

        # Check if the data after the header looks like Microchip PD firmware
        # Microchip PD firmware typically starts with a specific boot header
        # Look for TLV-like structures
        tlv_off = 0x20  # After the Lenovo header
        print("\n  TLV-like structures (starting at +0x20):")
        tlv_count = 0
        while tlv_off < min(256, len(blob_data)):
            if tlv_off + 4 > len(blob_data):
                break
            tag = blob_data[tlv_off]
            if tag == 0xFF or tag == 0x00:
                break
            length = struct.unpack_from("<H", blob_data, tlv_off + 1)[0] if tlv_off + 3 <= len(blob_data) else 0
            value_preview = blob_data[tlv_off + 3 : tlv_off + 3 + min(8, length)] if length > 0 else b""
            hex_preview = " ".join(f"{b:02x}" for b in value_preview)
            print(f"    +0x{tlv_off:04X}: tag=0x{tag:02X}, len={length}, value={hex_preview}...")
            tlv_off += 3 + length
            tlv_count += 1
            if tlv_count > 20:
                break

    # Extract the blob
    out_file = out_dir / f"{fw_id}_blob.bin"
    out_file.write_bytes(blob_data)
    print(f"\n  Extracted: {out_file} ({len(blob_data)} bytes)")

    # Also try to extract just the firmware data (skip Lenovo header)
    # The Lenovo header seems to end around the FW ID + some config bytes
    # The actual Microchip firmware probably starts after all the TLV config
    # Let's also save a raw version starting from different offsets
    for skip in [0x20, 0x30, 0x40]:
        if skip < len(blob_data):
            raw_file = out_dir / f"{fw_id}_raw_{skip:02x}.bin"
            raw_file.write_bytes(blob_data[skip:])
            print(f"  Raw (skip 0x{skip:02X}): {raw_file} ({len(blob_data) - skip} bytes)")

# Also extract the version index table
print(f"\n{'=' * 60}")
print("PD Firmware Version Index Table")
print(f"{'=' * 60}")
idx_pos = data.find(b"N3GPD17W\x00N3GPH")
if idx_pos >= 0:
    table_data = data[idx_pos : idx_pos + 128]
    print(f"Index table at 0x{idx_pos:06X}:")

    # Parse the table
    table_pos = 0
    fw_names = []
    while table_pos < 64:
        if table_data[table_pos : table_pos + 4] == b"N3GP":
            name = table_data[table_pos : table_pos + 8].decode("ascii")
            fw_names.append(name)
            table_pos += 9  # 8 bytes + null terminator
        elif table_data[table_pos] == 0:
            table_pos += 1
        else:
            break

    print(f"  FW names: {fw_names}")

    # After the names, there should be a config table
    config_start = idx_pos + table_pos
    print(f"\n  Config table at 0x{config_start:06X}:")
    config_data = data[config_start : config_start + 96]
    for j in range(0, min(96, len(config_data)), 16):
        chunk = config_data[j : j + 16]
        hex_str = " ".join(f"{b:02x}" for b in chunk)
        asc = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        print(f"    {config_start + j:06X}: {hex_str:<48s}  {asc}")

    # Parse as potential address/size entries (3 FW × some config)
    print("\n  Parsed config entries (LE32):")
    for j in range(0, min(72, len(config_data)), 4):
        val = struct.unpack_from("<I", config_data, j)[0]
        print(f"    +{j:02X}: 0x{val:08X} ({val})")
