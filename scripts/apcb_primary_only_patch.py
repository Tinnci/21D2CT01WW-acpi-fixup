#!/usr/bin/env python3
"""
APCB USB4 Enable Patch — Primary Only (方案B: 保留Backup安全网)

仅修改 Primary APCB instance (0x449000)，保持 Backup (0x811000) 和 Small (0x446000) 不变。
如果 ABL 无法处理修改后的 Primary APCB，会 fallback 到原始 Backup APCB。

Target: ThinkPad Z13 Gen 1 (21D2CT01WW) Engineering Sample
        BIOS: N3GET04WE (0.04f), SPI: Winbond W25Q256JW 32MB

Changes (11 bytes in Primary APCB @ 0x449000):
  - Checksum byte @ +0x10: recalculated
  - GNBG Port1 NHI enable @ +0x6E4A: 0x00 → 0x30
  - GNBG Port2 NHI enable @ +0x6E5A: 0x10 → 0x30
  - GNBG Port3 remap byte @ +0x6E68: 0x00 → 0x02
  - GNBG Port3 NHI enable @ +0x6E6A: 0x10 → 0x30
  - GNBG Port3 SS enable  @ +0x6E6B: 0x00 → 0x20
  - GNBG Port4 NHI enable @ +0x6E7A: 0x10 → 0x30
  - Token: APCB_TOKEN_UID_FCH_GPP_CLK2_MAP @ +0x7038: 0x00 → 0x01
  - Token: APCB_TOKEN_UID_USB4_NHI_EN_0   @ +0x7268: 0x00 → 0x01
  - Token: APCB_TOKEN_UID_USB4_NHI_EN_1   @ +0x7318: 0x00 → 0x01
  - Token: APCB_TOKEN_UID_USB4_CM_EN      @ +0x7338: 0x00 → 0x01
"""

import sys
import hashlib
import struct
from datetime import datetime

# === Configuration ===
APCB_PRIMARY_BASE = 0x449000
APCB_PRIMARY_SIZE = 0x75F4  # from APCB header field
CHECKSUM_OFFSET = 0x10       # relative to APCB base

# Patches: (apcb_relative_offset, old_value, new_value, description)
PATCHES = [
    (0x6E4A, 0x00, 0x30, "GNBG Port1: USB4 NHI enable"),
    (0x6E5A, 0x10, 0x30, "GNBG Port2: NHI enable (bit5)"),
    (0x6E68, 0x00, 0x02, "GNBG Port3: NHI device remap"),
    (0x6E6A, 0x10, 0x30, "GNBG Port3: NHI enable (bit5)"),
    (0x6E6B, 0x00, 0x20, "GNBG Port3: SuperSpeed enable"),
    (0x6E7A, 0x10, 0x30, "GNBG Port4: NHI enable (bit5)"),
    (0x7038, 0x00, 0x01, "APCB_TOKEN_UID_FCH_GPP_CLK2_MAP"),
    (0x7268, 0x00, 0x01, "APCB_TOKEN_UID_USB4_NHI_EN_0"),
    (0x7318, 0x00, 0x01, "APCB_TOKEN_UID_USB4_NHI_EN_1"),
    (0x7338, 0x00, 0x01, "APCB_TOKEN_UID_USB4_CM_EN"),
]


def main():
    if len(sys.argv) < 2:
        spi_path = "/home/drie/桌面/acpi-fixup/firmware/spi_dump/bios_dump_20260306_104957.bin"
    else:
        spi_path = sys.argv[1]

    print(f"╔═══════════════════════════════════════════════════════╗")
    print(f"║  APCB USB4 Patch — Primary Only (方案B)              ║")
    print(f"║  保留 Backup APCB 作为 ABL fallback 安全网           ║")
    print(f"╚═══════════════════════════════════════════════════════╝")
    print()

    # Read SPI image
    print(f"[1/5] Reading SPI image: {spi_path}")
    with open(spi_path, 'rb') as f:
        data = bytearray(f.read())

    if len(data) != 32 * 1024 * 1024:
        print(f"  ERROR: Expected 32MB, got {len(data):,} bytes")
        sys.exit(1)

    orig_sha = hashlib.sha256(data).hexdigest()
    print(f"  Size: {len(data):,} bytes")
    print(f"  SHA256: {orig_sha[:32]}...")

    # Verify APCB header
    print(f"\n[2/5] Verifying APCB Primary header @ 0x{APCB_PRIMARY_BASE:X}")
    sig = data[APCB_PRIMARY_BASE:APCB_PRIMARY_BASE + 4]
    if sig != b'APCB':
        print(f"  ERROR: Expected 'APCB' signature, got {sig}")
        sys.exit(1)
    size_field = struct.unpack_from('<H', data, APCB_PRIMARY_BASE + 8)[0]
    if size_field != APCB_PRIMARY_SIZE:
        print(f"  WARNING: Header size 0x{size_field:X} != expected 0x{APCB_PRIMARY_SIZE:X}")
    print(f"  Signature: APCB ✓")
    print(f"  Size: 0x{size_field:X} ({size_field} bytes)")

    # Verify original checksum
    orig_sum = sum(data[APCB_PRIMARY_BASE:APCB_PRIMARY_BASE + APCB_PRIMARY_SIZE]) & 0xFF
    print(f"  Original checksum: 0x{data[APCB_PRIMARY_BASE + CHECKSUM_OFFSET]:02X} (block sum: 0x{orig_sum:02X} {'✓' if orig_sum == 0 else '✗ INVALID'})")

    if orig_sum != 0:
        print(f"  ERROR: Original APCB checksum invalid! Aborting.")
        sys.exit(1)

    # Verify Backup APCB is intact (will NOT be modified)
    print(f"\n[2b/5] Verifying Backup APCB @ 0x811000 (will NOT be modified)")
    backup_sig = data[0x811000:0x811004]
    backup_sum = sum(data[0x811000:0x811000 + APCB_PRIMARY_SIZE]) & 0xFF
    print(f"  Signature: {backup_sig} {'✓' if backup_sig == b'APCB' else '✗'}")
    print(f"  Checksum: sum=0x{backup_sum:02X} {'✓' if backup_sum == 0 else '✗'}")

    # Apply patches to Primary APCB only
    print(f"\n[3/5] Applying {len(PATCHES)} patches to Primary APCB:")
    patch_count = 0
    for apcb_off, old_val, new_val, desc in PATCHES:
        spi_off = APCB_PRIMARY_BASE + apcb_off
        current = data[spi_off]
        if current != old_val:
            print(f"  ✗ 0x{spi_off:08X} (+0x{apcb_off:X}): expected 0x{old_val:02X}, got 0x{current:02X} — {desc}")
            print(f"    ERROR: Unexpected value! Image may not match expected BIOS version.")
            sys.exit(1)
        data[spi_off] = new_val
        patch_count += 1
        print(f"  ✓ 0x{spi_off:08X} (+0x{apcb_off:X}): 0x{old_val:02X} → 0x{new_val:02X}  {desc}")

    # Recalculate Primary APCB checksum
    print(f"\n[4/5] Recalculating Primary APCB checksum:")
    old_cs = data[APCB_PRIMARY_BASE + CHECKSUM_OFFSET]
    # Zero out checksum byte
    data[APCB_PRIMARY_BASE + CHECKSUM_OFFSET] = 0
    # Calculate sum
    block_sum = sum(data[APCB_PRIMARY_BASE:APCB_PRIMARY_BASE + APCB_PRIMARY_SIZE]) & 0xFF
    # New checksum = (256 - sum) mod 256
    new_cs = (256 - block_sum) & 0xFF
    data[APCB_PRIMARY_BASE + CHECKSUM_OFFSET] = new_cs
    # Verify
    verify_sum = sum(data[APCB_PRIMARY_BASE:APCB_PRIMARY_BASE + APCB_PRIMARY_SIZE]) & 0xFF
    print(f"  Old checksum: 0x{old_cs:02X}")
    print(f"  New checksum: 0x{new_cs:02X}")
    print(f"  Verify sum:   0x{verify_sum:02X} {'✓ VALID' if verify_sum == 0 else '✗ INVALID'}")

    if verify_sum != 0:
        print("  ERROR: Checksum verification failed! Aborting.")
        sys.exit(1)

    # Verify Backup APCB is STILL untouched
    print(f"\n[4b/5] Verifying Backup APCB still untouched:")
    backup_sum_after = sum(data[0x811000:0x811000 + APCB_PRIMARY_SIZE]) & 0xFF
    print(f"  Backup checksum: 0x{backup_sum_after:02X} {'✓ unchanged' if backup_sum_after == 0 else '✗'}")

    # Save output
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = f"/home/drie/桌面/acpi-fixup/build/spi_primary_only_patch_{ts}.bin"
    print(f"\n[5/5] Saving patched image:")
    print(f"  Output: {out_path}")

    with open(out_path, 'wb') as f:
        f.write(data)

    new_sha = hashlib.sha256(data).hexdigest()
    diff_count = sum(1 for a, b in zip(open(spi_path, 'rb').read(), data) if a != b)
    print(f"  SHA256: {new_sha[:32]}...")
    print(f"  Total bytes changed: {diff_count}")

    print(f"\n{'='*55}")
    print(f"  方案B 补丁完成!")
    print(f"  修改: {patch_count} data bytes + 1 checksum = {patch_count + 1} bytes")
    print(f"  未修改: Backup APCB, Small APCB")
    print(f"  ABL fallback: 如果 Primary 失败 → 使用原始 Backup")
    print(f"{'='*55}")
    print(f"\n  刷写命令:")
    print(f"  sudo flashrom -p internal -c W25Q256JW -w {out_path}")
    print(f"\n  恢复命令:")
    print(f"  sudo flashrom -p internal -c W25Q256JW -w {spi_path}")


if __name__ == "__main__":
    main()
