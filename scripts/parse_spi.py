#!/usr/bin/env python3
"""Parse AMD SPI BIOS dump — PSP/BIOS directories + USB4/UCSI analysis."""

import struct
import sys

# ── known PSP entry types ──────────────────────────────────────
PSP_TYPES = {
    0x00: "AMD_PUBLIC_KEY",
    0x01: "PSP_BOOTLOADER",
    0x02: "PSP_TOS",
    0x03: "PSP_RECOVERY_BL",
    0x04: "PSP_NV_DATA",
    0x07: "SMU_FW",
    0x08: "SEC_DBG_KEY",
    0x09: "OEM_PSP_KEY",
    0x0A: "ABL0",
    0x0B: "PSP_UNLOCK_DBG",
    0x0C: "ABL1",
    0x0D: "ABL2",
    0x10: "SMU_FN_FW",
    0x12: "SMN_FW2",
    0x13: "ABL3",
    0x20: "ABL4",
    0x21: "ABL5",
    0x22: "ABL6",
    0x24: "PSP_S3_NV",
    0x25: "ABL_SPL",
    0x28: "BOOT_TRUSTLETS",
    0x2D: "PSP_SEV_CODE",
    0x30: "AGESA_PEI",
    0x31: "AGESA_DXE",
    0x40: "PSP_DIR_L2",
    0x47: "SEV_DATA",
    0x48: "BIOS_DIR_L2",
    0x49: "BIOS_RTM_PUBKEY",
    0x4A: "SOFT_FUSE",
    0x55: "RPMC_NVDATA",
    0x5A: "DXIO_PHY_SRAM",
    0x5C: "BOOT_OEM_TRUSTLETS",
}

BIOS_TYPES = {
    0x60: "APCB_DATA",
    0x62: "APCB_DATA2",
    0x63: "APCB_BACKUP",
    0x64: "APOB_DATA",
    0x65: "UNIFIED_MEM",
    0x66: "BIOS_BIN",
    0x68: "APOB_NV",
    0x6A: "OEM_KEY",
    0x70: "BIOS_L2_DIR",
}

ALL_TYPES = {**PSP_TYPES, **BIOS_TYPES}


def u32(data, off):
    return struct.unpack_from("<I", data, off)[0]


def parse_dir(data, offset, label, depth=0):
    """Parse a PSP/PL2/BHD/BL2 directory. Returns list of entries."""
    cookie = data[offset : offset + 4]
    num = u32(data, offset + 8)
    indent = "  " * depth
    # Sanity check
    if num > 200 or num == 0:
        print(f"{indent}--- {label} at 0x{offset:06X} [{cookie}] INVALID entries={num} ---")
        return []
    print(f"\n{indent}--- {label} at 0x{offset:06X} [{cookie}] entries={num} ---")
    results = []
    for i in range(num):
        base = offset + 16 + i * 16
        if base + 16 > len(data):
            break
        etype = data[base]
        esub = data[base + 1]
        struct.unpack_from("<H", data, base + 2)[0]
        esize = u32(data, base + 4)
        raw_loc = struct.unpack_from("<Q", data, base + 8)[0]
        eloc = raw_loc & 0x3FFFFFFF
        if esize == 0 or esize >= 0x10000000:
            continue
        desc = ALL_TYPES.get(etype, "")
        print(f"{indent}  [{i:2d}] 0x{etype:02X} sub={esub} sz=0x{esize:06X} @0x{eloc:08X} {desc}")
        results.append((etype, esub, esize, eloc))
    return results


def main():
    if len(sys.argv) < 2:
        dump = "firmware/spi_dump/bios_dump_20260306_104957.bin"
    else:
        dump = sys.argv[1]
    with open(dump, "rb") as f:
        data = f.read()
    print(f"Loaded {len(data)} bytes from {dump}\n")

    # ── 1. PSP Combo at 0xC1000 ────────────────────────────────
    combo_off = 0xC1000
    num_combo = u32(data, combo_off + 8)
    print(f"PSP Combo at 0x{combo_off:06X}  sub-dirs={num_combo}")
    for i in range(min(num_combo, 10)):
        base = combo_off + 16 + i * 16
        id_val = u32(data, base + 4)
        loc = u32(data, base + 8)
        print(f"  [{i}] id=0x{id_val:08X} → 0x{loc:06X}")

    # ── 2. PL2 directories ─────────────────────────────────────
    for pl2_off in [0x0C5000, 0x48D000]:
        entries = parse_dir(data, pl2_off, "PL2", depth=0)
        for et, es, esz, el in entries:
            if el > 0 and el < len(data) and et in (0x40, 0x48, 0x70):
                parse_dir(data, el, f"  └ L2(0x{et:02X})", depth=1)

    # ── 3. BL2 at known good offsets ───────────────────────────
    for bl2_off in [0x445000, 0x80D000]:
        entries = parse_dir(data, bl2_off, "BL2", depth=0)

    # ── 4. USB4/UCSI/NHI string context ────────────────────────
    print("\n\n=== USB4 / UCSI / NHI 固件代码位置 ===")
    targets = [
        b"rsmu_usb4",
        b"UCSI",
        b"ucsi_cb",
        b"Ucsi Init",
        b"alt_mode_cb",
        b"nHiF",
        b"NHiF",
        b"gNHI",
        b"PBMs",
        b"MuxR",
        b"pd_event_hd",
        b"PPMreset_hd",
        b"port_cmd_hd",
        b"ppm_cmd_hd",
        b"reset_hd",
        b"MAYAN",
        b"N3GET",
    ]
    for t in targets:
        pos = 0
        locs = []
        while len(locs) < 5:
            idx = data.find(t, pos)
            if idx < 0:
                break
            locs.append(idx)
            pos = idx + len(t)
        if locs:
            loc_str = ", ".join(f"0x{loc:06X}" for loc in locs)
            print(f"  {t.decode(errors='replace'):20s}  → {loc_str}")

    # ── 5. APCB config tokens search ──────────────────────────
    print("\n=== APCB USB4/UCSI 令牌搜索 ===")
    # APCB tokens are often 4-byte type + 4-byte value pairs
    # Search for USB4-related strings near APCB structures
    apcb_sigs = []
    pos = 0
    while True:
        idx = data.find(b"APCB", pos)
        if idx < 0:
            break
        apcb_sigs.append(idx)
        pos = idx + 4
    print(f"  APCB signatures found: {len(apcb_sigs)} (first 5: {[f'0x{x:06X}' for x in apcb_sigs[:5]]})")

    # ── 6. Soft fuse analysis ─────────────────────────────────
    print("\n=== Soft Fuse 区域 ===")
    # In PL2, entry type 0x4A = SOFT_FUSE
    for pl2_off in [0x0C5000]:
        num = u32(data, pl2_off + 8)
        for i in range(min(num, 50)):
            base = pl2_off + 16 + i * 16
            if base + 16 > len(data):
                break
            etype = data[base]
            esize = u32(data, base + 4)
            eloc = struct.unpack_from("<Q", data, base + 8)[0] & 0x3FFFFFFF
            if etype == 0x4A and esize > 0 and esize < 0x10000000:
                print(f"  Soft Fuse entry: sz=0x{esize:06X} @0x{eloc:08X}")
                if eloc > 0 and eloc + esize <= len(data):
                    fuse_data = data[eloc : eloc + min(esize, 64)]
                    print(f"  Data: {fuse_data.hex()}")

    # ── 7. Locate PHCM firmware blob ──────────────────────────
    print("\n=== PHCM (PD Controller / Type-C 管理器) 固件 ===")
    phcm_idx = data.find(b"PHCM")
    if phcm_idx >= 0:
        max(0, phcm_idx - 0x1000)
        # Find module header: check for ARM Cortex-M vector table patterns
        # or look for typical fw header structures
        print(f"  PHCM string at 0x{phcm_idx:06X}")
        # Show context around PHCM
        ctx_start = phcm_idx - 16
        ctx = data[ctx_start : ctx_start + 128]
        print(f"  Context: ...{ctx.hex()[:80]}...")

        # Check if there's a recognizable FW header before PHCM
        # ARM Cortex-M: initial SP at offset 0, Reset vector at offset 4
        for probe in range(max(0, phcm_idx - 0x2000), phcm_idx, 0x100):
            sp = u32(data, probe)
            rv = u32(data, probe + 4)
            # Typical SRAM ranges for Cortex-M
            if 0x20000000 <= sp <= 0x20100000 and 0x00000100 <= rv <= 0x00100000:
                phcm_idx - probe + 0x10000  # estimate
                print(f"  Possible FW entry at 0x{probe:06X}: SP=0x{sp:08X} Reset=0x{rv:08X}")
                break

    print("\nDone.")


if __name__ == "__main__":
    main()
