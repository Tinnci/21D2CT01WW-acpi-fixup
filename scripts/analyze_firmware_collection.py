#!/usr/bin/env python3
"""Analyze all binary firmware files in the Z13Z16刷机包 collection."""

import os
import hashlib
import subprocess
from pathlib import Path
from collections import defaultdict

BASE = Path(__file__).resolve().parent.parent / "Z13Z16刷机包"


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def extract_bios_version(path):
    """Extract N3GETxxW style BIOS version from binary."""
    try:
        data = open(path, "rb").read()
        # Look for RESERVE marker
        idx = data.find(b"RESERVEN3GET")
        if idx >= 0:
            tag = data[idx:idx+30]
            # Extract version string
            ver = tag.decode("ascii", errors="replace").strip().rstrip("\x00 ")
            return ver.replace("RESERVE", "")
        # Look for N3GETxxW pattern
        import re
        matches = re.findall(rb"N3GET(\d\dW)", data)
        if matches:
            versions = sorted(set(m.decode() for m in matches))
            return "N3GET" + versions[-1]  # highest version
        # Check for N3GET04T (engineering)
        matches = re.findall(rb"N3GET\d\d[A-Z]", data)
        if matches:
            versions = sorted(set(m.decode() for m in matches))
            return versions[-1]
    except Exception:
        pass
    return None


def extract_ec_version(path):
    """Try to extract EC version identifier."""
    try:
        data = open(path, "rb").read()
        # Look for N3GHT pattern (EC uses H instead of E)
        import re
        matches = re.findall(rb"N3GHT(\d\d)W", data)
        if matches:
            versions = sorted(set(m.decode() for m in matches))
            return "N3GHT" + versions[-1] + "W"
        # Check copyright string as EC marker
        if b"(C) Copyright IBM Corp" in data or b"LENOVO" in data:
            return "(has EC strings)"
    except Exception:
        pass
    return None


def main():
    print("=" * 80)
    print("Z13/Z16 刷机包 固件分析报告")
    print("=" * 80)

    all_files = []
    for root, dirs, files in os.walk(BASE):
        for fname in sorted(files):
            if fname == ".DS_Store":
                continue
            fpath = Path(root) / fname
            rel = fpath.relative_to(BASE)
            size = fpath.stat().st_size
            all_files.append((rel, fpath, size))

    # Group by hash
    hash_groups = defaultdict(list)
    file_info = {}
    for rel, fpath, size in all_files:
        if size < 10:  # Skip StatusRegVal etc
            continue
        h = sha256_file(fpath)
        hash_groups[h].append(rel)
        file_info[str(rel)] = {"hash": h[:16], "size": size, "path": fpath}

    # Categorize files
    print("\n" + "=" * 80)
    print("一、VBIOS 文件 (Z16 RX6500M 独显)")
    print("=" * 80)
    vbios_dir = BASE / "1_z16-rx6500m-vbios"
    if vbios_dir.exists():
        for item in sorted(vbios_dir.iterdir()):
            if item.name == ".DS_Store":
                continue
            h = sha256_file(item)
            print(f"  {item.name}: {item.stat().st_size:,} bytes  SHA256={h[:16]}...")
        # Check if all same
        vhashes = set()
        for item in vbios_dir.iterdir():
            if item.name == ".DS_Store":
                continue
            vhashes.add(sha256_file(item))
        if len(vhashes) == 1:
            print(f"  → 三个文件完全相同 (RX 6500M VBIOS, AMD device 028)")

    print("\n" + "=" * 80)
    print("二、SPI Flash 芯片说明")
    print("=" * 80)
    print("  U2101 = BIOS SPI 闪存 (32MB/256Mbit, Winbond 25Q256)")
    print("  U8505 = EC SPI 闪存 (32MB/256Mbit, Winbond 25Q256)")
    print("  U2102 = 另一颗 SPI 闪存 (可能是另一台机器)")
    print("  NM-E161 = 主板型号名称 (ThinkPad Z13 Gen1 / Z16 Gen1)")
    print("  StatusRegVal = SPI 状态寄存器备份 (CH341A 编程器读取)")

    print("\n" + "=" * 80)
    print("三、BIOS (U2101) 固件版本清单")
    print("=" * 80)

    # Collect all unique U2101 hashes
    u2101_entries = []
    for rel, fpath, size in all_files:
        name_lower = str(rel).lower()
        if size != 33554432:  # 32MB
            continue
        if "u2101" in name_lower or "nm-e161" in name_lower or "z13" in str(rel).lower():
            h = sha256_file(fpath)
            bios_ver = extract_bios_version(fpath)
            u2101_entries.append((rel, h, bios_ver, size))

    # Also add Z13-0.4-1.66-BIOS.bin
    z13_file = BASE / "Z13-0.4-1.66-BIOS.bin"
    if z13_file.exists() and z13_file.stat().st_size == 33554432:
        h = sha256_file(z13_file)
        bios_ver = extract_bios_version(z13_file)
        u2101_entries.append((z13_file.relative_to(BASE), h, bios_ver, z13_file.stat().st_size))

    # Deduplicate and show
    seen_hashes = {}
    for rel, h, bios_ver, size in u2101_entries:
        if h not in seen_hashes:
            seen_hashes[h] = []
        seen_hashes[h].append((rel, bios_ver))

    for h, entries in sorted(seen_hashes.items(), key=lambda x: str(x[1][0][0])):
        ver = entries[0][1] or "(未识别版本)"
        print(f"\n  SHA256: {h[:16]}...  BIOS版本: {ver}")
        for rel, _ in entries:
            parent = str(rel.parent)
            print(f"    - {rel}")
        if len(entries) > 1:
            print(f"    → {len(entries)} 个文件完全相同（重复副本）")

    print("\n" + "=" * 80)
    print("四、EC (U8505) 固件版本清单")
    print("=" * 80)

    u8505_entries = []
    for rel, fpath, size in all_files:
        name_lower = str(rel).lower()
        if size != 33554432:
            continue
        if "u8505" in name_lower or "ec" in name_lower:
            if "u2101" in name_lower:
                continue
            h = sha256_file(fpath)
            ec_ver = extract_ec_version(fpath)
            u8505_entries.append((rel, h, ec_ver, size))

    seen_hashes_ec = {}
    for rel, h, ec_ver, size in u8505_entries:
        if h not in seen_hashes_ec:
            seen_hashes_ec[h] = []
        seen_hashes_ec[h].append((rel, ec_ver))

    for h, entries in sorted(seen_hashes_ec.items(), key=lambda x: str(x[1][0][0])):
        ver = entries[0][1] or "(未识别版本)"
        print(f"\n  SHA256: {h[:16]}...  EC信息: {ver}")
        for rel, _ in entries:
            print(f"    - {rel}")
        if len(entries) > 1:
            print(f"    → {len(entries)} 个文件完全相同（重复副本）")

    print("\n" + "=" * 80)
    print("五、特殊文件")
    print("=" * 80)

    # ec-test-1.64.bin (320K)
    ec_test = BASE / "BIOS" / "bios-1.64-ec-1.64-rec-0.4" / "ec-test-1.64.bin"
    if ec_test.exists():
        h = sha256_file(ec_test)
        print(f"\n  ec-test-1.64.bin: {ec_test.stat().st_size:,} bytes  SHA256={h[:16]}...")
        print(f"    独立 EC 固件镜像 (非完整 SPI dump, 仅 320KB EC FW 区域)")
        ec_ver = extract_ec_version(ec_test)
        if ec_ver:
            print(f"    EC版本: {ec_ver}")

    # U2101-TEST-1.64.bin
    u2101_test = BASE / "BIOS" / "bios-1.64-ec-1.64-rec-0.4" / "U2101-TEST-1.64.bin"
    if u2101_test.exists():
        h = sha256_file(u2101_test)
        bv = extract_bios_version(u2101_test)
        print(f"\n  U2101-TEST-1.64.bin: {u2101_test.stat().st_size:,} bytes  SHA256={h[:16]}...")
        print(f"    测试用 BIOS SPI dump, BIOS版本: {bv or '未识别'}")

    # U8505-TEST-1.64.bin  
    u8505_test = BASE / "BIOS" / "bios-1.64-ec-1.64-rec-0.4" / "U8505-TEST-1.64.bin"
    if u8505_test.exists():
        h = sha256_file(u8505_test)
        h_u8505 = sha256_file(BASE / "BIOS" / "bios-1.64-ec-1.64-rec-0.4" / "U8505.bin")
        print(f"\n  U8505-TEST-1.64.bin: {u8505_test.stat().st_size:,} bytes  SHA256={h[:16]}...")
        if h == h_u8505:
            print(f"    与同目录 U8505.bin 完全相同")

    # U2102 (different chip)
    u2102 = BASE / "BIOS" / "4-bios-0.06-ec-0.01A-rev-0.2" / "u2102.BIN"
    if u2102.exists():
        h = sha256_file(u2102)
        bv = extract_bios_version(u2102)
        print(f"\n  u2102.BIN (4-bios-0.06-ec-0.01A-rev-0.2): {u2102.stat().st_size:,} bytes")
        print(f"    不同芯片位号 u2102，可能是另一台机器或改版板")
        print(f"    BIOS版本: {bv or '未识别'}")

    # rar file
    rar_file = BASE / "BIOS" / "3-bios-ec-rev.0.4" / "U8505 2..BK.rar"
    if rar_file.exists():
        print(f"\n  U8505 2..BK.rar: {rar_file.stat().st_size:,} bytes")
        print(f"    压缩的 U8505 备份 (需解压)")

    print("\n" + "=" * 80)
    print("六、目录重复分析")
    print("=" * 80)
    print("  许多目录成对出现 (rev-0.x 和 rev.0.x)，其中文件完全相同:")
    # Find duplicate pairs
    bios_dir = BASE / "BIOS"
    dirs = sorted([d for d in bios_dir.iterdir() if d.is_dir()])
    checked = set()
    for d1 in dirs:
        for d2 in dirs:
            if d1 >= d2 or str(d1) in checked or str(d2) in checked:
                continue
            # Check if all files match
            f1 = sorted([f.name.lower() for f in d1.iterdir() if f.is_file() and f.name != ".DS_Store" and not f.name.endswith("StatusRegVal")])
            f2 = sorted([f.name.lower() for f in d2.iterdir() if f.is_file() and f.name != ".DS_Store" and not f.name.endswith("StatusRegVal")])
            if f1 and f1 == f2:
                # Check actual content
                all_match = True
                for fn1, fn2 in zip(
                    sorted([f for f in d1.iterdir() if f.is_file() and f.name != ".DS_Store" and not f.name.endswith("StatusRegVal")], key=lambda x: x.name.lower()),
                    sorted([f for f in d2.iterdir() if f.is_file() and f.name != ".DS_Store" and not f.name.endswith("StatusRegVal")], key=lambda x: x.name.lower())
                ):
                    if sha256_file(fn1) != sha256_file(fn2):
                        all_match = False
                        break
                if all_match:
                    print(f"  ✓ {d1.name} == {d2.name}")

    print("\n" + "=" * 80)
    print("七、版本时间线总结")
    print("=" * 80)
    print("""
  工程版/早期版本 (BIOS版本号 < 1.00):
    BIOS 0.T3 (N3GET04T)  - 最早的工程测试版，EC 0.26, 板rev 0.2
    BIOS 0.05 (N3GET09W)  - 早期工程版
      ├─ EC 0.07, 板rev 0.3
      ├─ EC 0.08, 板rev 0.3
      └─ EC 0.11, 板rev 0.3
    BIOS 0.06 (EC 0.01A)  - 板rev 0.2 (u2102芯片，不同板子)
    BIOS 0.09              - 过渡版本
      ├─ EC 0.11, 板rev 0.3
      └─ EC 0.11, 板rev 0.4
    BIOS 0.1               - 工程版最后版本
      ├─ EC 0.01, 板rev 0.4
      └─ EC 0.12, 板rev 0.3

  正式版 (BIOS版本号 ≥ 1.00):
    BIOS 1.02 (N3GET21W)  - 第一个正式版
    BIOS 1.64 (N3GET64W)  - 后期正式版 (含TEST版本)
    BIOS 1.65 (N3GET64W)  - 最新正式版 (1.65目录，但BIOS ID似乎同1.64)
    BIOS 1.66 (N3GET66W)  - Z13-0.4-1.66-BIOS.bin (最新)

  板修订版:
    rev 0.2 = 早期原型板
    rev 0.3 = 量产前版本
    rev 0.4 = 量产/最终版本

  特殊目录:
    nm-e161-0.3-不开机 = NM-E161 板rev 0.3 不开机的dump（维修备份）
    3-bios-ec-rev.0.4 = 板rev 0.4 工程版不亮机的备份
    rec-0.4 = recovery（恢复）用固件，板rev 0.4
""")

    # Final summary stats
    print("=" * 80)
    print("八、统计摘要")
    print("=" * 80)
    total_files = len(all_files)
    total_size = sum(s for _, _, s in all_files)
    unique_hashes = set()
    for rel, fpath, size in all_files:
        if size > 10:
            unique_hashes.add(sha256_file(fpath))
    print(f"  总文件数: {total_files}")
    print(f"  总大小: {total_size / (1024*1024):.0f} MB")
    print(f"  唯一文件数 (按SHA256): {len(unique_hashes)}")
    print(f"  重复文件: {total_files - len(unique_hashes) - len([1 for _,_,s in all_files if s <= 10])} 个")


if __name__ == "__main__":
    main()
