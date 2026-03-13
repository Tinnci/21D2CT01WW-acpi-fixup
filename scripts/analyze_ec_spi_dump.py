#!/usr/bin/env python3
"""分析 EC SPI dump 并与 FL2 比较，确定布局映射。

Usage: python3 analyze_ec_spi_dump.py <spi_dump.bin> [fl2_dir]

默认 FL2 目录: firmware/ec/
"""

import struct
import hashlib
import sys
import os
import re


def analyze_dump(dump_path, fl2_paths):
    with open(dump_path, "rb") as f:
        dump = f.read()

    print(f"{'=' * 60}")
    print(f"EC SPI Dump Analysis: {dump_path}")
    print(f"{'=' * 60}")
    print(f"  Size: {len(dump)} bytes ({len(dump) // 1024}KB, {len(dump) * 8 // 1024 // 1024}Mbit)")
    print(f"  SHA256: {hashlib.sha256(dump).hexdigest()}")

    # 空白分析
    ff_count = dump.count(b"\xff")
    zero_count = dump.count(b"\x00")
    print(f"  0xFF bytes: {ff_count} ({100 * ff_count / len(dump):.1f}%)")
    print(f"  0x00 bytes: {zero_count} ({100 * zero_count / len(dump):.1f}%)")
    print(
        f"  Data bytes: {len(dump) - ff_count - zero_count} ({100 * (len(dump) - ff_count - zero_count) / len(dump):.1f}%)"
    )

    # 搜索 ARM 向量表 (SP=0x200C7C00)
    print("\n--- ARM Vector Table Search ---")
    sp_bytes = struct.pack("<I", 0x200C7C00)
    found_vectors = []
    pos = dump.find(sp_bytes)
    while pos >= 0:
        reset = struct.unpack_from("<I", dump, pos + 4)[0]
        if 0x10070000 <= reset <= 0x100FFFFF:
            nmi = struct.unpack_from("<I", dump, pos + 8)[0]
            hf = struct.unpack_from("<I", dump, pos + 12)[0]
            print(f"  ★ Found at SPI offset 0x{pos:06X}")
            print(f"    SP         = 0x{struct.unpack_from('<I', dump, pos)[0]:08X}")
            print(f"    Reset      = 0x{reset:08X} (Thumb={reset & 1})")
            print(f"    NMI        = 0x{nmi:08X}")
            print(f"    HardFault  = 0x{hf:08X}")
            found_vectors.append(pos)
        pos = dump.find(sp_bytes, pos + 1)

    if not found_vectors:
        print("  NOT FOUND — dump may be encrypted or SPI is empty")

    # 搜索 boot config magic
    print("\n--- Boot Config Block Search ---")
    magic = bytes.fromhex("5e4d3b2a1eab0403")
    pos = dump.find(magic)
    if pos >= 0:
        print(f"  ★ Found at SPI offset 0x{pos:06X}")
        # 打印完整 boot config block (64 bytes)
        for i in range(0, 64, 16):
            line = dump[pos + i : pos + i + 16]
            print(f"    +0x{i:02X}: {line.hex(' ')}")
    else:
        print("  NOT found in dump")

    # 搜索 Insyde _EC headers
    print("\n--- Insyde _EC Headers Search ---")
    for tag, name in [(b"_EC\x01", "_EC1"), (b"_EC\x02", "_EC2")]:
        pos = dump.find(tag)
        if pos >= 0:
            print(f"  {name} found at SPI offset 0x{pos:06X}")
            total = struct.unpack_from("<I", dump, pos + 4)[0]
            data = struct.unpack_from("<I", dump, pos + 8)[0]
            print(f"    Total: 0x{total:08X}, Data: 0x{data:08X}")
        else:
            print(f"  {name} NOT found")

    # 搜索签名区域 (64 non-zero bytes)
    print("\n--- Signature Search ---")
    for fl2_path in fl2_paths:
        with open(fl2_path, "rb") as f:
            fl2 = f.read()
        sig = fl2[0x80:0xC0]
        fl2_name = os.path.basename(fl2_path)
        pos = dump.find(sig)
        if pos >= 0:
            print(f"  Signature from {fl2_name} found at SPI offset 0x{pos:06X}")
        else:
            print(f"  Signature from {fl2_name} NOT found")

    # 搜索版本字符串
    print("\n--- Version Strings ---")
    for m in re.finditer(rb"N3G[A-Z]{2}\d{2}W", dump):
        print(f"  '{m.group().decode()}' at SPI offset 0x{m.start():06X}")

    # 与 FL2 payload 比较
    print("\n--- FL2 Payload Mapping ---")
    for fl2_path in fl2_paths:
        with open(fl2_path, "rb") as f:
            fl2 = f.read()
        payload = fl2[0x120:]
        fl2_name = os.path.basename(fl2_path)

        # 在 dump 中搜索 payload 的前 64 字节
        needle = payload[:64]
        pos = dump.find(needle)
        if pos >= 0:
            print(f"\n  ★ {fl2_name} payload found at SPI offset 0x{pos:06X}")
            print(f"    FL2[0x120:] → SPI[0x{pos:06X}:]")

            # 比较全部 payload
            end = pos + len(payload)
            if end <= len(dump):
                matched = sum(1 for i in range(len(payload)) if dump[pos + i] == payload[i])
                total = len(payload)
                print(f"    Match: {matched}/{total} bytes ({100 * matched / total:.1f}%)")

                if matched != total:
                    # 找到第一个和最后一个不同的字节
                    first_diff = next(i for i in range(total) if dump[pos + i] != payload[i])
                    last_diff = next(i for i in range(total - 1, -1, -1) if dump[pos + i] != payload[i])
                    print(f"    First diff at payload offset 0x{first_diff:06X}")
                    print(f"    Last diff at payload offset 0x{last_diff:06X}")
            else:
                overlap = len(dump) - pos
                matched = sum(1 for i in range(overlap) if dump[pos + i] == payload[i])
                print(f"    Partial overlap: {overlap} bytes, {matched} match")
        else:
            print(f"\n  {fl2_name} payload NOT found (not exact match at any offset)")

            # 尝试搜索版本字符串位置来推断偏移
            ver_str = fl2_name[:8].encode()  # e.g., N3GHT68W
            ver_in_fl2 = fl2.find(ver_str)
            ver_in_dump = dump.find(ver_str)
            if ver_in_fl2 >= 0 and ver_in_dump >= 0:
                estimated_offset = ver_in_dump - (ver_in_fl2 - 0x120)
                print(f"    Version string suggests SPI base ≈ 0x{estimated_offset:06X}")

    # 区域映射
    print("\n--- SPI Region Map (256-byte blocks) ---")
    block_size = 256
    regions = []
    current_type = None
    region_start = 0

    for i in range(0, len(dump), block_size):
        block = dump[i : i + block_size]
        if all(b == 0xFF for b in block):
            btype = "FF"
        elif all(b == 0x00 for b in block):
            btype = "00"
        else:
            btype = "DATA"

        if btype != current_type:
            if current_type is not None:
                regions.append((current_type, region_start, i))
            current_type = btype
            region_start = i

    if current_type is not None:
        regions.append((current_type, region_start, len(dump)))

    for rtype, start, end in regions:
        size = end - start
        if size >= 4096 or rtype == "DATA":
            label = {"FF": "ERASED", "00": "ZERO", "DATA": "FIRMWARE"}[rtype]
            print(f"  0x{start:06X}-0x{end - 1:06X}  {size:>8} bytes  [{label}]")

    print(f"\n{'=' * 60}")
    print("MAPPING CONCLUSION:")
    if found_vectors:
        vt_offset = found_vectors[0]
        if vt_offset == 0:
            print("  SPI[0x000000] = ARM Vector Table")
            print("  → FL2[0x120:] maps directly to SPI[0x0:]")
            print("  → Write image = FL2 payload (strip first 0x120 bytes)")
        else:
            print(f"  SPI[0x{vt_offset:06X}] = ARM Vector Table")
            print(f"  → SPI has {vt_offset} bytes of header/boot data before firmware")
            print(f"  → Preserve SPI[0x0:0x{vt_offset:X}] from backup when writing")
    else:
        print("  No ARM Vector Table found — further analysis needed")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <spi_dump.bin> [fl2_dir]")
        sys.exit(1)

    fl2_dir = sys.argv[2] if len(sys.argv) > 2 else "firmware/ec"
    fl2_files = []
    if os.path.isdir(fl2_dir):
        fl2_files = [os.path.join(fl2_dir, f) for f in sorted(os.listdir(fl2_dir)) if f.endswith(".FL2")]

    analyze_dump(sys.argv[1], fl2_files)
