#!/usr/bin/env python3
"""Analyze FL2 structure and determine SPI flash mapping for EC SPI operations."""

import struct
import hashlib
import os


def analyze_fl2(path):
    with open(path, "rb") as f:
        data = f.read()

    name = os.path.basename(path)
    print(f"{'=' * 60}")
    print(f"=== {name} ({len(data)} bytes, 0x{len(data):X}) ===")
    print(f"{'=' * 60}")
    print(f"SHA256: {hashlib.sha256(data).hexdigest()}")

    # _EC1 header (0x00-0x1F)
    ec1_magic = data[0:4]
    ec1_total = struct.unpack_from("<I", data, 4)[0]
    ec1_data = struct.unpack_from("<I", data, 8)[0]
    ec1_unk0c = struct.unpack_from("<I", data, 0x0C)[0]
    ec1_unk10 = struct.unpack_from("<I", data, 0x10)[0]
    ec1_cksum = struct.unpack_from("<I", data, 0x14)[0]

    print("\n--- _EC1 Header (0x00-0x1F) ---")
    print(f"  Magic:    {ec1_magic}")
    print(f"  Total:    0x{ec1_total:08X} ({ec1_total})")
    print(f"  DataSize: 0x{ec1_data:08X} ({ec1_data})")
    print(f"  Unk 0x0C: 0x{ec1_unk0c:08X}")
    print(f"  Unk 0x10: 0x{ec1_unk10:08X}")
    print(f"  Checksum: 0x{ec1_cksum:08X}")
    print(f"  Rest:     {data[0x18:0x20].hex()}")

    # _EC2 header (0x20-0x3F)
    ec2_magic = data[0x20:0x24]
    ec2_total = struct.unpack_from("<I", data, 0x24)[0]
    ec2_data = struct.unpack_from("<I", data, 0x28)[0]
    ec2_unk2c = struct.unpack_from("<I", data, 0x2C)[0]
    ec2_unk30 = struct.unpack_from("<I", data, 0x30)[0]
    ec2_cksum = struct.unpack_from("<I", data, 0x34)[0]

    print("\n--- _EC2 Header (0x20-0x3F) ---")
    print(f"  Magic:    {ec2_magic}")
    print(f"  Total:    0x{ec2_total:08X} ({ec2_total})")
    print(f"  DataSize: 0x{ec2_data:08X} ({ec2_data})")
    print(f"  Unk 0x2C: 0x{ec2_unk2c:08X}")
    print(f"  Unk 0x30: 0x{ec2_unk30:08X}")
    print(f"  Checksum: 0x{ec2_cksum:08X}")
    print(f"  Rest:     {data[0x38:0x40].hex()}")

    # Unknown region 0x40-0x7F
    print("\n--- Region 0x40-0x7F ---")
    for off in range(0x40, 0x80, 16):
        print(f"  0x{off:04X}: {data[off : off + 16].hex(' ')}")

    # Signature 0x80-0xBF
    sig = data[0x80:0xC0]
    sig_nonzero = sum(1 for b in sig if b != 0)
    print("\n--- Signature (0x80-0xBF) ---")
    print(f"  Non-zero bytes: {sig_nonzero}/64")
    for off in range(0x80, 0xC0, 16):
        print(f"  0x{off:04X}: {data[off : off + 16].hex(' ')}")

    # Region 0xC0-0x11F
    print("\n--- Region 0xC0-0x11F ---")
    for off in range(0xC0, 0x120, 16):
        line = data[off : off + 16]
        if any(b != 0 and b != 0xFF for b in line):
            print(f"  0x{off:04X}: {line.hex(' ')}")
    empty_count = sum(1 for b in data[0xC0:0x120] if b == 0 or b == 0xFF)
    print(f"  ({empty_count}/{0x120 - 0xC0} bytes are 00/FF)")

    # Payload starts at 0x120
    print("\n--- Payload @ 0x0120 (ARM Vector Table) ---")
    sp = struct.unpack_from("<I", data, 0x120)[0]
    reset = struct.unpack_from("<I", data, 0x124)[0]
    nmi = struct.unpack_from("<I", data, 0x128)[0]
    hf = struct.unpack_from("<I", data, 0x12C)[0]
    print(f"  SP:         0x{sp:08X}")
    print(f"  Reset:      0x{reset:08X} (Thumb={reset & 1})")
    print(f"  NMI:        0x{nmi:08X}")
    print(f"  HardFault:  0x{hf:08X}")

    # NPCX Boot ROM header analysis
    # NPCX Boot ROM typically looks for a header at SPI offset 0
    # The header contains: Tag (4B), Image size (4B), FW load addr (4B), FW entry (4B)
    # Tag = 0x5AA5_9669 for NPCX9
    print("\n--- NPCX Boot ROM Header Search ---")
    npcx_tag = b"\x69\x96\xa5\x5a"  # 0x5AA59669 LE
    npcx_tag2 = b"\xa5\x5a\x69\x96"
    for tag_name, tag in [("0x5AA59669", npcx_tag), ("0x5AA59669-swap", npcx_tag2)]:
        pos = data.find(tag)
        while pos >= 0:
            print(f"  Found {tag_name} at offset 0x{pos:06X}")
            if pos + 16 <= len(data):
                print(f"    Context: {data[pos : pos + 16].hex(' ')}")
            pos = data.find(tag, pos + 1)

    # Also search for other common NPCX signatures
    for tag_name, tag in [("NPCX", b"NPCX"), ("CR50_", b"CR50"), ("GOOG", b"GOOG")]:
        pos = data.find(tag)
        if pos >= 0:
            print(f"  Found '{tag_name}' at offset 0x{pos:06X}")

    # Analyze _EC2 region
    ec2_data_start = 0x1120  # FL2 offset where _EC2 data begins
    print(f"\n--- _EC2 Data Region (starts @ 0x{ec2_data_start:04X}) ---")
    print(f"  First 32B: {data[ec2_data_start : ec2_data_start + 32].hex(' ')}")

    # Check if _EC2 data has its own vector table
    ec2_sp = struct.unpack_from("<I", data, ec2_data_start)[0]
    ec2_reset = struct.unpack_from("<I", data, ec2_data_start + 4)[0]
    if 0x10000000 <= ec2_sp <= 0x30000000:
        print(f"  _EC2 has vector table: SP=0x{ec2_sp:08X}, Reset=0x{ec2_reset:08X}")
    else:
        print(f"  _EC2 first word: 0x{ec2_sp:08X} (not a vector table)")

    # Payload analysis - find regions
    payload = data[0x120:]
    print("\n--- Payload Region Analysis ---")
    print(f"  Total payload: {len(payload)} bytes (0x{len(payload):X})")

    # Find FF-filled regions (gaps/padding)
    in_ff = False
    ff_start = 0
    regions = []
    for i in range(0, len(payload), 256):
        block = payload[i : i + 256]
        is_ff = all(b == 0xFF for b in block)
        if is_ff and not in_ff:
            ff_start = i
            in_ff = True
        elif not is_ff and in_ff:
            regions.append(("FF-gap", ff_start, i))
            in_ff = False
    if in_ff:
        regions.append(("FF-gap", ff_start, len(payload)))

    for rtype, start, end in regions:
        if end - start >= 1024:
            print(f"  {rtype}: 0x{start + 0x120:06X} - 0x{end + 0x120:06X} ({end - start} bytes)")

    # Last meaningful byte
    last = len(data) - 1
    while last > 0 and data[last] in (0xFF, 0x00):
        last -= 1
    print(f"  Last non-00/FF byte at FL2 offset 0x{last:06X}")

    # Check for version strings
    print("\n--- Version Strings ---")
    import re

    for m in re.finditer(rb"N3G[A-Z]{2}\d{2}W", data):
        print(f"  '{m.group().decode()}' at offset 0x{m.start():06X} (payload+0x{m.start() - 0x120:06X})")

    # SPI size estimation
    print("\n--- SPI Size Estimation ---")
    print(f"  _EC1 data size: {ec1_data} = {ec1_data // 1024}KB")
    print(f"  _EC2 data size: {ec2_data} = {ec2_data // 1024}KB")
    print(f"  FL2 total: {len(data)} = {len(data) // 1024}KB")
    print("  Likely SPI capacity: 512KB (4Mbit) or larger")
    print("  Payload maps to SPI: FL2[0x120:] -> SPI[0x0:]")

    return data


def compare_payloads(data1, data2, name1, name2):
    """Compare the payloads of two FL2 files."""
    p1 = data1[0x120:]
    p2 = data2[0x120:]

    minlen = min(len(p1), len(p2))
    diff = sum(1 for i in range(minlen) if p1[i] != p2[i])

    print(f"\n{'=' * 60}")
    print(f"=== Payload Comparison: {name1} vs {name2} ===")
    print(f"  Payload 1: {len(p1)} bytes")
    print(f"  Payload 2: {len(p2)} bytes")
    print(f"  Different bytes: {diff}/{minlen} ({100 * diff / minlen:.1f}%)")

    # Compare headers separately
    h1 = data1[0:0x120]
    h2 = data2[0:0x120]
    hdiff = sum(1 for i in range(0x120) if h1[i] != h2[i])
    print(f"  Header diff (0x00-0x11F): {hdiff}/{0x120} bytes")


if __name__ == "__main__":
    fl2_dir = "firmware/ec"
    files = sorted([f for f in os.listdir(fl2_dir) if f.endswith(".FL2")])

    datas = {}
    for f in files:
        path = os.path.join(fl2_dir, f)
        datas[f] = analyze_fl2(path)

    if len(datas) >= 2:
        names = list(datas.keys())
        compare_payloads(datas[names[0]], datas[names[1]], names[0], names[1])
