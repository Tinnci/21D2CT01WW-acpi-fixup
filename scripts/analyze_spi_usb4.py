#!/usr/bin/env python3
"""Deep APCB + PHCM + USB4 analysis of SPI dump."""

import struct

DUMP = "firmware/spi_dump/bios_dump_20260306_104957.bin"
with open(DUMP, "rb") as f:
    data = f.read()


def u32(off):
    return struct.unpack_from("<I", data, off)[0]


# ── 1. PHCM PD Controller firmware ──────────────────
print("=== PHCM (PD Controller / Type-C Manager) ===")
phcm_off = 0x081000
sig = data[phcm_off : phcm_off + 4]
major = data[phcm_off + 4] | (data[phcm_off + 5] << 8)
minor = data[phcm_off + 6] | (data[phcm_off + 7] << 8)
print(f"  Signature: {sig}")
print(f"  Version: {major}.{minor}")
# Size estimate: find next 0xFF region
i = phcm_off
while i < min(phcm_off + 0x20000, len(data)):
    if data[i : i + 16] == b"\xff" * 16:
        break
    i += 16
phcm_size = i - phcm_off
print(f"  Size: ~0x{phcm_size:X} ({phcm_size // 1024}KB)")
# Show version string area
print(f"  Platform: {data[0x91080:0x910E0].split(b'\\x00')[0].decode(errors='replace')}")

# ── 2. APCB token analysis ──────────────────────────
print("\n=== APCB Instances ===")
apcb_locs = []
pos = 0
while True:
    idx = data.find(b"APCB", pos)
    if idx < 0 or idx >= len(data) - 32:
        break
    # Verify it's a real APCB header
    ver = struct.unpack_from("<H", data, idx + 4)[0]
    hdr_sz = struct.unpack_from("<H", data, idx + 6)[0]
    data_sz = u32(idx + 8)
    if 0x20 <= hdr_sz <= 0x100 and 0 < data_sz < 0x200000:
        uniq = u32(idx + 12)
        board = struct.unpack_from("<H", data, idx + 16)[0]
        print(
            f"  APCB @0x{idx:06X}: ver=0x{ver:04X} hdr=0x{hdr_sz:X} data=0x{data_sz:X} uid=0x{uniq:08X} board=0x{board:X}"
        )
        apcb_locs.append((idx, data_sz))
    pos = idx + 4

# ── 3. Search for USB4 tokens in ALL APCB regions ───
print("\n=== USB4/UCSI Token 全搜 (所有 APCB 区域) ===")
keywords = [
    b"USB4",
    b"Usb4",
    b"usb4",
    b"UCSI",
    b"ucsi",
    b"NHI",
    b"nhi",
    b"TypeC",
    b"typec",
    b"PcieTunnel",
    b"DpTunnel",
    b"UsbTunnel",
    b"Usb4En",
    b"USB4_EN",
    b"NhiEn",
]
for apcb_off, apcb_sz in apcb_locs:
    region = data[apcb_off : apcb_off + apcb_sz + 0x30]
    for kw in keywords:
        idx = 0
        while True:
            found = region.find(kw, idx)
            if found < 0:
                break
            abs_off = apcb_off + found
            ctx = region[max(0, found - 8) : found + len(kw) + 24]
            print(f"  [{kw.decode(errors='replace')}] @0x{abs_off:06X} ctx={ctx.hex()}")
            idx = found + len(kw)

# ── 4. RSMU USB4 module deep analysis ───────────────
print("\n=== RSMU USB4 模块区域上下文 ===")
for label, region_start, region_end in [
    ("RSMU region 1", 0x256000, 0x257000),
    ("RSMU region 2", 0x61E000, 0x61F000),
]:
    print(f"\n  --- {label} ---")
    strs = []
    i = region_start
    while i < region_end:
        # Extract printable strings
        s = b""
        while i < region_end and 0x20 <= data[i] < 0x7F:
            s += bytes([data[i]])
            i += 1
        if len(s) >= 4:
            strs.append((i - len(s), s.decode()))
        i += 1
    for off, s in strs:
        print(f"    0x{off:06X}: {s}")

# ── 5. Locate the UCSI/PD fw blob boundaries ────────
print("\n=== UCSI/PD 固件区域边界 ===")
# The UCSI code is in the PHCM blob (0x081000 - ~0x09xxxx)
ucsi_strs = [
    (0x091530, "UCSI"),
    (0x09441C, "ucsi_cb:"),
    (0x094FEC, "Ucsi Init"),
    (0x094068, "alt_mode_cb:"),
    (0x093E0C, "COLDUEXP"),
    (0x0951C8, "pd_event_hd:"),
    (0x09451C, "PPMreset_hd:"),
    (0x094A64, "port_cmd_hd:"),
    (0x094DE4, "ppm_cmd_hd:"),
]
min_off = min(x[0] for x in ucsi_strs)
max_off = max(x[0] for x in ucsi_strs)
print(f"  UCSI/PD handler 代码范围: 0x{min_off:06X} - 0x{max_off:06X}")
print(f"  PHCM blob: 0x{phcm_off:06X} - 0x{phcm_off + phcm_size:06X}")
print(f"  → UCSI 代码在 PHCM 内部偏移 0x{min_off - phcm_off:04X} - 0x{max_off - phcm_off:04X}")

# ── 6. Check SMU firmware for USB4 references ───────
print("\n=== SMU 固件中的 USB4 引用 ===")
# SMU FW is in PL2 entry type 0x07
# From parse_spi.py: SMN_FW2 at 0x8E800 (sz 0x19E60) and 0xA8700 (sz 0x1D8D0)
for label, fw_off, fw_sz in [
    ("SMN_FW2 sub=0", 0x08E800, 0x019E60),
    ("SMN_FW2 sub=1", 0x0A8700, 0x01D8D0),
    ("DXIO_PHY_SRAM", 0x191100, 0x048480),
    ("ABL SPL", 0x0D4A00, 0x0191F0),
]:
    region = data[fw_off : fw_off + fw_sz]
    hits = []
    for kw in [b"usb4", b"USB4", b"nhi", b"NHI", b"ucsi", b"UCSI"]:
        idx = region.find(kw)
        if idx >= 0:
            hits.append(f"{kw.decode()}@+0x{idx:X}")
    if hits:
        print(f"  {label}: {', '.join(hits)}")
    else:
        print(f"  {label}: 无 USB4 引用")

# ── 7. AGESA PEI analysis ───────────────────────────
print("\n=== AGESA PEI (0x111600, 436KB) - USB4 引用 ===")
agesa_pei = data[0x111600 : 0x111600 + 0x06A940]
for kw in [
    b"USB4",
    b"usb4",
    b"Usb4",
    b"UCSI",
    b"NHI",
    b"nhi",
    b"XHCI",
    b"xhci",
    b"TypeC",
    b"Mux",
    b"PD ",
    b"PdController",
]:
    hits = []
    idx = 0
    while len(hits) < 5:
        found = agesa_pei.find(kw, idx)
        if found < 0:
            break
        hits.append(found)
        idx = found + len(kw)
    if hits:
        locs = [f"0x{0x111600 + h:06X}" for h in hits[:3]]
        more = f" (+{len(hits) - 3} more)" if len(hits) > 3 else ""
        print(f"  {kw.decode(errors='replace'):16s} → {', '.join(locs)}{more}")

# ── 8. NHI data structure analysis ──────────────────
print("\n=== NHI 结构分析 ===")
# nHiF at 0x2415D8 is inside the SMN_FW2 region
# These are ARM Cortex-M function calls (BL instruction patterns)
# Let's check what module contains 0x241xxx
for label, fw_off, fw_sz in [
    ("SMN_FW2 sub=0", 0x08E800, 0x019E60),
    ("SMN_FW2 sub=1", 0x0A8700, 0x01D8D0),
    ("AGESA_PEI", 0x111600, 0x06A940),
    ("Type 0x73", 0x002600, 0x013740),
    ("Type 0x71 sub=0", 0x1DA200, 0x018C90),
    ("Type 0x71 sub=1", 0x1F2F00, 0x026110),
    ("Type 0x86", 0x8B9000, 0x234000),
    ("Type 0x88", 0xAED000, 0x1B4000),
]:
    if fw_off <= 0x2415D8 < fw_off + fw_sz:
        inner = 0x2415D8 - fw_off
        print(f"  nHiF (0x2415D8) 在 {label} 内部, 偏移 +0x{inner:X}")
    if fw_off <= 0x256740 < fw_off + fw_sz:
        inner = 0x256740 - fw_off
        print(f"  rsmu_usb4 (0x256740) 在 {label} 内部, 偏移 +0x{inner:X}")
    if fw_off <= 0x091530 < fw_off + fw_sz:
        inner = 0x091530 - fw_off
        print(f"  UCSI (0x091530) 在 {label} 内部, 偏移 +0x{inner:X}")
    if fw_off <= 0xBD2ECA < fw_off + fw_sz:
        inner = 0xBD2ECA - fw_off
        print(f"  gNHI (0xBD2ECA) 在 {label} 内部, 偏移 +0x{inner:X}")

print("\nDone.")
