#!/usr/bin/env python3
"""Cross-EC base address, vector table, and startup flow analysis.

Scans all EC SPI dumps and standalone FL2 files to determine:
1. _EC header presence and version
2. Base address via LDR literal pool scanning
3. Vector table location and structure
4. Startup flow comparison
"""

import struct
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).resolve().parent.parent

# All SPI dumps
SPI_DIR = ROOT / "firmware" / "ec_spi"
EC_DIR = ROOT / "firmware" / "ec"

def find_ec_regions(data):
    """Find _EC header(s) in a binary blob, return list of (offset, size, ver)."""
    regions = []
    for i in range(0, len(data) - 16, 0x1000):
        if data[i:i+3] == b'_EC':
            ver = data[i+3]
            if ver in (1, 2):
                total = struct.unpack_from("<I", data, i+4)[0]
                dsize = struct.unpack_from("<I", data, i+8)[0]
                # Find end of non-FF data
                end = i + min(total + 0x1000, len(data) - i)
                for j in range(min(i + 0x50000, len(data)), i, -0x100):
                    if any(b != 0xFF for b in data[j-0x100:j]):
                        end = j
                        break
                regions.append((i, end - i, ver, total, dsize))
    return regions

def scan_ldr_t1(ec_blob, test_base):
    """Scan Thumb T1 LDR Rt,[PC,#imm8] and count flash self-references."""
    ec_len = len(ec_blob)
    flash_refs = 0
    sram_refs = 0
    periph_refs = 0
    total = 0

    for off in range(0, ec_len - 1, 2):
        hw = struct.unpack_from("<H", ec_blob, off)[0]
        if (hw & 0xF800) == 0x4800:
            imm8 = hw & 0xFF
            insn_addr = test_base + off
            pool_addr = ((insn_addr + 4) & ~3) + imm8 * 4
            pool_off = pool_addr - test_base
            if 0 <= pool_off <= ec_len - 4:
                val = struct.unpack_from("<I", ec_blob, pool_off)[0]
                total += 1
                if test_base <= val < test_base + ec_len:
                    flash_refs += 1
                elif 0x20000000 <= val < 0x20100000:
                    sram_refs += 1
                elif 0x40000000 <= val < 0x50000000:
                    periph_refs += 1

    return total, flash_refs, sram_refs, periph_refs

def find_best_base(ec_blob):
    """Try candidate bases, return (best_base, flash_refs, total_ldr)."""
    candidates = [
        0x00000000, 0x00001000, 0x00010000,
        0x10000000, 0x10010000, 0x10020000, 0x10030000,
        0x10040000, 0x10050000, 0x10060000, 0x10070000,
        0x10080000, 0x10090000, 0x100A0000, 0x100B0000,
        0x08000000, 0x08010000, 0x08020000,  # STM32 typical
        0x00100000, 0x00200000,
    ]
    best = (0, 0, 0, 0)
    for base in candidates:
        total, flash, sram, periph = scan_ldr_t1(ec_blob, base)
        if flash > best[1]:
            best = (base, flash, sram, total)
    return best

def find_vector_table(ec_blob, base):
    """Scan for Cortex-M vector table pattern in EC blob."""
    ec_len = len(ec_blob)
    results = []
    for i in range(0, min(ec_len - 16, 0x2000), 4):
        sp = struct.unpack_from("<I", ec_blob, i)[0]
        if not (0x20000000 <= sp <= 0x20100000):
            continue
        v1 = struct.unpack_from("<I", ec_blob, i + 4)[0]
        v2 = struct.unpack_from("<I", ec_blob, i + 8)[0]
        v3 = struct.unpack_from("<I", ec_blob, i + 12)[0]
        if all((v & 1) and base <= (v & ~1) < base + ec_len for v in [v1, v2, v3]):
            # Count how many consecutive valid vectors
            n_valid = 0
            for j in range(1, min(256, (ec_len - i) // 4)):
                v = struct.unpack_from("<I", ec_blob, i + j * 4)[0]
                if v == 0 or ((v & 1) and base <= (v & ~1) < base + ec_len):
                    n_valid += 1
                else:
                    break
            results.append((i, sp, v1, v2, v3, n_valid))
    return results

def analyze_startup(ec_blob, base, reset_off):
    """Check startup code pattern: what does Reset handler reference?"""
    # Look for literal pool near reset handler
    info = {}
    # Scan 512 bytes of code from reset handler
    for off in range(reset_off, min(reset_off + 512, len(ec_blob) - 3), 2):
        hw = struct.unpack_from("<H", ec_blob, off)[0]
        # Check for VTOR register reference (0xE000ED08)
        if off + 4 <= len(ec_blob):
            val = struct.unpack_from("<I", ec_blob, off)[0]
            if val == 0xE000ED08:
                info["vtor_ref"] = off
            if val == base:
                info["base_ref"] = off

    # Check for LDR.W SP, [PC, #imm] (setting up stack)
    for off in range(reset_off, min(reset_off + 256, len(ec_blob) - 3), 2):
        hw1 = struct.unpack_from("<H", ec_blob, off)[0]
        if hw1 == 0xF8DF:
            hw2 = struct.unpack_from("<H", ec_blob, off + 2)[0]
            rt = (hw2 >> 12) & 0xF
            if rt == 13:  # SP
                info["sp_load"] = off

    return info

def get_version_string(ec_blob):
    """Find N3GHT??W or other version string."""
    for i in range(0, min(len(ec_blob), 0x2000)):
        if ec_blob[i:i+4] == b'N3GH' and i + 8 <= len(ec_blob):
            end = i + 8
            while end < min(i + 20, len(ec_blob)) and ec_blob[end] >= 32:
                end += 1
            return ec_blob[i:end].decode("ascii", "replace")
    return None

def get_copyright(ec_blob):
    """Find copyright string offset."""
    for i in range(0, len(ec_blob) - 20):
        if ec_blob[i:i+9] == b'Copyright':
            return i
    return None

# ============================================================
# Main analysis
# ============================================================

print("=" * 80)
print("Cross-EC Firmware Base Address & Vector Table Analysis")
print("=" * 80)

files = []
# SPI dumps
for f in sorted(SPI_DIR.glob("*.bin")):
    files.append(("SPI", f))
# Standalone EC
for f in sorted(EC_DIR.glob("*")):
    files.append(("EC", f))

results = []

for ftype, fpath in files:
    fname = fpath.name
    with open(fpath, "rb") as f:
        raw = f.read()

    print(f"\n{'─'*80}")
    print(f"[{ftype}] {fname} ({len(raw):,} bytes)")

    # Find _EC headers
    regions = find_ec_regions(raw)
    if not regions:
        print("  ⚠ No _EC header found")
        # For EC0.11 etc, try scanning from offset 0
        continue

    for idx, (ec_off, ec_size, ver, total, dsize) in enumerate(regions):
        print(f"  _EC[{idx}] @ SPI 0x{ec_off:06X}, ver={ver}, total=0x{total:X}, data=0x{dsize:X}")

        # Extract EC blob
        # Use data_size or total to determine actual firmware extent
        blob_end = ec_off + min(total, len(raw) - ec_off)
        # But also check non-FF extent
        actual_end = ec_off
        for j in range(blob_end, ec_off, -0x100):
            if any(b != 0xFF for b in raw[max(ec_off, j-0x100):j]):
                actual_end = j
                break
        if actual_end <= ec_off:
            actual_end = ec_off + 0x100
        ec_blob = raw[ec_off:actual_end]
        ec_len = len(ec_blob)
        print(f"  Blob size: {ec_len:,} bytes ({ec_len/1024:.0f} KB)")

        # Version string
        ver_str = get_version_string(ec_blob)
        if ver_str:
            print(f"  Version: {ver_str}")

        # Copyright
        cr_off = get_copyright(ec_blob)
        if cr_off is not None:
            print(f"  Copyright @ EC+0x{cr_off:05X}")

        # Find best base
        best_base, best_flash, best_sram, best_total = find_best_base(ec_blob)
        print(f"  Best base: 0x{best_base:08X} (flash_refs={best_flash}, sram={best_sram}, total_ldr={best_total})")

        # Also try a finer sweep around the best base
        if best_base > 0:
            fine_best = (best_base, best_flash)
            for delta in range(-0x10000, 0x10001, 0x1000):
                candidate = best_base + delta
                if candidate < 0:
                    continue
                _, flash, _, _ = scan_ldr_t1(ec_blob, candidate)
                if flash > fine_best[1]:
                    fine_best = (candidate, flash)
            if fine_best[0] != best_base:
                best_base, best_flash = fine_best
                print(f"  Refined base: 0x{best_base:08X} (flash_refs={best_flash})")

        # Vector table
        vts = find_vector_table(ec_blob, best_base)
        if vts:
            for vt_off, sp, reset, nmi, hf, n_valid in vts:
                print(f"  Vector Table @ EC+0x{vt_off:04X}:")
                print(f"    SP    = 0x{sp:08X}")
                print(f"    Reset = 0x{reset:08X} -> EC+0x{(reset&~1)-best_base:05X}")
                print(f"    NMI   = 0x{nmi:08X} -> EC+0x{(nmi&~1)-best_base:05X}")
                print(f"    HF    = 0x{hf:08X} -> EC+0x{(hf&~1)-best_base:05X}")
                print(f"    Consecutive valid vectors: {n_valid}")

                # Startup analysis
                reset_off = (reset & ~1) - best_base
                if 0 <= reset_off < ec_len:
                    si = analyze_startup(ec_blob, best_base, reset_off)
                    if si:
                        for k, v in si.items():
                            print(f"    Startup: {k} @ EC+0x{v:05X}")
        else:
            print("  ⚠ No vector table found")

        # Check for LADD descriptor
        for check_off in [0x100000 - ec_off, 0xFF000 - ec_off]:
            if 0 < check_off < len(raw) - ec_off - 8:
                maybe_ladd = raw[ec_off + check_off:ec_off + check_off + 4]
                if maybe_ladd == b'LADD':
                    print(f"  LADD descriptor @ SPI 0x{ec_off + check_off:06X}")

        results.append({
            "file": fname,
            "type": ftype,
            "ec_off": ec_off,
            "ver": ver,
            "version_str": ver_str,
            "blob_size": ec_len,
            "base": best_base,
            "flash_refs": best_flash,
            "vt_offset": vts[0][0] if vts else None,
            "sp": vts[0][1] if vts else None,
            "reset": vts[0][2] if vts else None,
            "n_vectors": vts[0][5] if vts else 0,
        })

# Also scan the large regions in N3GHT25W and N3GHT64W
print(f"\n{'='*80}")
print("Large ARM regions in N3GHT25W/64W (above SPI 0x100000)")
print("=" * 80)

for fname in ["N3GHT25W_v1.02.bin", "N3GHT64W_v1.64.bin"]:
    fpath = SPI_DIR / fname
    if not fpath.exists():
        continue
    with open(fpath, "rb") as f:
        raw = f.read()

    print(f"\n[{fname}]")

    # Collect contiguous non-empty regions above 0x100000
    regions_found = []
    pos = 0x100000
    while pos < min(len(raw), 0x2000000):
        page = raw[pos:pos + 0x1000]
        if all(b == 0xFF for b in page) or all(b == 0x00 for b in page):
            pos += 0x1000
            continue
        # Found non-empty start - find end
        rstart = pos
        pos += 0x1000
        while pos < len(raw):
            page = raw[pos:pos + 0x1000]
            if all(b == 0xFF for b in page) or all(b == 0x00 for b in page):
                break
            pos += 0x1000
        regions_found.append((rstart, pos))

    for rstart, rend in regions_found:
        rsize = rend - rstart
        if rsize < 0x4000:
            continue
        region = raw[rstart:rend]
        print(f"\n  Region SPI 0x{rstart:07X}-0x{rend:07X} ({rsize/1024:.0f} KB)")

        if region[:3] == b'_EC':
            print(f"    _EC header: ver={region[3]}, total=0x{struct.unpack_from('<I', region, 4)[0]:X}")
        if region[:4] == b'LADD':
            print(f"    LADD descriptor table")

        if rsize > 0x4000:
            bb, bf, bs, bt = find_best_base(region)
            if bf > 10:
                print(f"    Best base: 0x{bb:08X} (flash={bf}, sram={bs})")
                vts = find_vector_table(region, bb)
                if vts:
                    for vt_off, sp, reset, nmi, hf, nv in vts[:2]:
                        print(f"    VT @ +0x{vt_off:04X}: SP=0x{sp:08X} Reset=0x{reset:08X} ({nv} vectors)")
            else:
                print(f"    No clear base (best flash_refs={bf})")

# Summary table
print(f"\n{'='*80}")
print("SUMMARY TABLE")
print("=" * 80)
print(f"{'File':<42s} {'Base':>12s} {'Flash':>6s} {'VT Off':>8s} {'SP':>12s} {'#Vec':>5s} {'Version':<12s}")
print("-" * 100)
for r in results:
    vt = f"0x{r['vt_offset']:04X}" if r['vt_offset'] is not None else "N/A"
    sp = f"0x{r['sp']:08X}" if r['sp'] else "N/A"
    ver = r['version_str'] or "?"
    print(f"{r['file']:<42s} 0x{r['base']:08X} {r['flash_refs']:>6d} {vt:>8s} {sp:>12s} {r['n_vectors']:>5d} {ver:<12s}")
