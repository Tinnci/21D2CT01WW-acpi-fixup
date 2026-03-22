#!/usr/bin/env python3
"""Extract EC firmware blob from SPI dump for loading into Ghidra/IDA.

Usage:
    python3 ec_extract_blob.py <spi_dump.bin> [output.bin]

Extracts the first _EC blob and writes it as a raw binary suitable for
loading at base address 0x10070000 in a disassembler.

Also prints a load summary with key addresses for manual reference.
"""

import struct
import sys
from pathlib import Path


def find_ec_blobs(data):
    """Find all _EC headers in the data."""
    blobs = []
    for off in range(0, len(data) - 16, 0x1000):
        if data[off:off+3] == b'_EC':
            ver = data[off + 3]
            # Sanity check header fields
            w4 = struct.unpack_from("<I", data, off + 4)[0]
            total = struct.unpack_from("<I", data, off + 8)[0]
            if 0x1000 < total < 0x100000:
                blob = data[off:off + total]
                # Find version string
                version = "unknown"
                for s_off in range(0, min(len(blob), 0x2000)):
                    if blob[s_off:s_off+5] == b'N3GHT':
                        version = blob[s_off:s_off+8].decode('ascii', errors='replace')
                        break
                blobs.append({
                    'spi_offset': off,
                    'header_ver': ver,
                    'total': total,
                    'version': version,
                    'blob': blob,
                })
    return blobs


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    input_path = Path(sys.argv[1])
    data = input_path.read_bytes()
    print(f"Read {len(data)} bytes from {input_path.name}")

    blobs = find_ec_blobs(data)
    if not blobs:
        print("Error: No _EC headers found in the input file.")
        # Check if the file itself might be a standalone EC blob
        if len(data) < 0x100000 and data[:3] == b'_EC':
            print("  (File appears to be a standalone EC blob already)")
        sys.exit(1)

    print(f"\nFound {len(blobs)} EC blob(s):")
    for i, b in enumerate(blobs):
        print(f"  [{i}] {b['version']} @ SPI 0x{b['spi_offset']:06X}, "
              f"ver={b['header_ver']}, size={b['total']:#x} ({b['total']//1024}KB)")

    # Extract the first (or user-selected) blob
    idx = 0
    if len(blobs) > 1 and len(sys.argv) < 3:
        print(f"\nMultiple blobs found. Extracting blob [0] ({blobs[0]['version']}).")
        print("  To extract a different one, specify output path.")

    blob_info = blobs[idx]
    blob = blob_info['blob']

    # Determine output path
    if len(sys.argv) >= 3:
        output_path = Path(sys.argv[2])
    else:
        output_path = input_path.with_suffix(f'.ec_blob.bin')

    output_path.write_bytes(blob)
    print(f"\nExtracted to: {output_path}")
    print(f"  Size: {len(blob)} bytes ({len(blob)//1024} KB)")

    # Print load summary
    vt_offset = 0x0120 if blob_info['header_ver'] == 1 else 0x0100
    sp = struct.unpack_from("<I", blob, vt_offset)[0] if vt_offset + 4 <= len(blob) else 0
    reset = struct.unpack_from("<I", blob, vt_offset + 4)[0] if vt_offset + 8 <= len(blob) else 0

    print(f"\n{'='*50}")
    print(f"  Ghidra / IDA Load Parameters")
    print(f"{'='*50}")
    print(f"  Processor:    ARM Cortex-M (Little Endian)")
    print(f"  Mode:         Thumb")
    print(f"  Base Address: 0x{0x10070000:08X}")
    print(f"  _EC Version:  {blob_info['header_ver']}")
    print(f"  FW Version:   {blob_info['version']}")
    print(f"  VT Offset:    +0x{vt_offset:04X}")
    print(f"  SP:           0x{sp:08X}")
    print(f"  Reset Entry:  0x{reset:08X}")
    print(f"  SRAM:         0x200C0000 - 0x{sp:08X}")
    print(f"\n  After loading, run the appropriate loader script:")
    print(f"    Ghidra: ghidra_ec_loader.py")
    print(f"    IDA:    ida_ec_loader.py")


if __name__ == "__main__":
    main()
