#!/usr/bin/env python3
"""Compare IRQ handlers across EC firmware versions.

For each version, extract the vector table and disassemble the first N 
instructions of each unique handler. Then compare handler signatures
across versions to identify functional changes.
"""

import struct, os, sys, hashlib
from pathlib import Path
from collections import defaultdict

try:
    from capstone import Cs, CS_ARCH_ARM, CS_MODE_THUMB
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False

BASE = 0x10070000
EC_SPI_DIR = Path("firmware/ec_spi")
EC_DIR = Path("firmware/ec")

VECTOR_NAMES = [
    "SP", "Reset", "NMI", "HardFault",
    "MemManage", "BusFault", "UsageFault", "Rsv7", "Rsv8", "Rsv9", "Rsv10",
    "SVCall", "DebugMon", "Rsv13", "PendSV", "SysTick",
] + ["IRQ%d" % i for i in range(64)]


def find_ec_blobs(path):
    """Find all _EC blobs in file."""
    data = path.read_bytes()
    results = []
    for off in range(0, min(len(data), 0x200000), 0x1000):
        if data[off:off+3] == b'_EC':
            ver = data[off+3]
            total = struct.unpack_from("<I", data, off+8)[0]
            if 0x1000 < total < 0x100000:
                blob = data[off:off+total]
                # version string
                version = "unknown"
                for s in range(0, min(len(blob), 0x2000)):
                    if blob[s:s+5] == b'N3GHT':
                        version = blob[s:s+8].decode('ascii', errors='replace')
                        break
                vt_off = 0x0120 if ver == 1 else 0x0100
                results.append((version, ver, blob, vt_off))
    # Also check if file is standalone EC
    if not results and len(data) < 0x100000 and data[:3] == b'_EC':
        ver = data[3]
        total = struct.unpack_from("<I", data, 8)[0]
        blob = data[:total] if total <= len(data) else data
        version = "unknown"
        for s in range(0, min(len(blob), 0x2000)):
            if blob[s:s+5] == b'N3GHT':
                version = blob[s:s+8].decode('ascii', errors='replace')
                break
        vt_off = 0x0120 if ver == 1 else 0x0100
        results.append((version, ver, blob, vt_off))
    return results


def extract_vectors(blob, vt_off):
    """Extract vector table entries. Return list of (name, addr, ec_offset)."""
    vectors = []
    for i in range(80):
        off = vt_off + i * 4
        if off + 4 > len(blob):
            break
        val = struct.unpack_from("<I", blob, off)[0]
        name = VECTOR_NAMES[i] if i < len(VECTOR_NAMES) else "IRQ%d" % (i-16)
        if i == 0:
            vectors.append((name, val, None))  # SP
        else:
            ec_off = (val & ~1) - BASE
            if 0 <= ec_off < len(blob):
                vectors.append((name, val, ec_off))
            else:
                vectors.append((name, val, None))
    return vectors


def get_handler_signature(blob, ec_off, n_bytes=64):
    """Get handler byte signature (first n_bytes of code)."""
    if ec_off is None or ec_off < 0 or ec_off + n_bytes > len(blob):
        return None
    return blob[ec_off:ec_off+n_bytes]


def disasm_handler(md, blob, ec_off, n_insn=10):
    """Disassemble first n instructions of a handler."""
    if ec_off is None or ec_off < 0 or ec_off >= len(blob):
        return []
    chunk = blob[ec_off:ec_off + n_insn * 4]
    result = []
    for insn in md.disasm(chunk, BASE + ec_off):
        result.append(f"  0x{insn.address:08X}: {insn.mnemonic:8s} {insn.op_str}")
        if len(result) >= n_insn:
            break
        # Stop at branch/return
        if insn.mnemonic in ('b', 'bx', 'pop') and 'pc' in insn.op_str.lower():
            break
    return result


def main():
    if HAS_CAPSTONE:
        md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
        md.detail = False
    else:
        md = None
        print("Warning: Capstone not available, no disassembly")

    # Collect all EC blobs
    all_versions = {}  # version -> (blob, vt_off, vectors)

    for spi_file in sorted(EC_SPI_DIR.glob("*.bin")):
        for version, hdr_ver, blob, vt_off in find_ec_blobs(spi_file):
            if version not in all_versions:
                vectors = extract_vectors(blob, vt_off)
                all_versions[version] = (blob, vt_off, vectors, spi_file.name)

    for ec_file in sorted(EC_DIR.iterdir()):
        if ec_file.suffix in ('.bin', '.FL2'):
            for version, hdr_ver, blob, vt_off in find_ec_blobs(ec_file):
                if version not in all_versions:
                    vectors = extract_vectors(blob, vt_off)
                    all_versions[version] = (blob, vt_off, vectors, ec_file.name)

    versions = sorted(all_versions.keys())
    print("=" * 80)
    print(f"IRQ Handler Comparison across {len(versions)} EC versions")
    print("=" * 80)
    print("Versions:", ", ".join(versions))

    # Build handler signature table: handler_name -> {version: signature_hash}
    handler_sigs = defaultdict(dict)  # name -> {version: hash}
    handler_addrs = defaultdict(dict)  # name -> {version: ec_offset}

    for version in versions:
        blob, vt_off, vectors, fname = all_versions[version]
        for name, addr_val, ec_off in vectors:
            if name == "SP":
                continue
            sig = get_handler_signature(blob, ec_off, 64)
            if sig:
                handler_sigs[name][version] = hashlib.md5(sig).hexdigest()[:8]
                handler_addrs[name][version] = ec_off

    # Find which handlers changed between versions
    print("\n" + "=" * 80)
    print("Handler Signature Comparison (MD5 of first 64 bytes)")
    print("=" * 80)

    # Print header
    short_ver = [v.replace("N3GHT", "") for v in versions]
    print(f"\n{'Handler':<14s}", end="")
    for sv in short_ver:
        print(f" {sv:>8s}", end="")
    print("  Changes?")
    print("-" * (14 + 9 * len(versions) + 10))

    changed_handlers = []
    for i in range(1, 80):
        name = VECTOR_NAMES[i] if i < len(VECTOR_NAMES) else "IRQ%d" % (i-16)
        sigs = handler_sigs.get(name, {})
        if not sigs:
            continue

        unique_sigs = set(sigs.values())
        changed = len(unique_sigs) > 1

        print(f"{name:<14s}", end="")
        for v in versions:
            sig = sigs.get(v, "   ---  ")
            print(f" {sig:>8s}", end="")
        
        if changed:
            print(f"  ← CHANGED ({len(unique_sigs)} variants)")
            changed_handlers.append(name)
        else:
            print()

    # Summary
    print(f"\n{'='*80}")
    print(f"Summary: {len(changed_handlers)} handlers changed out of {len(handler_sigs)}")
    print(f"{'='*80}")

    if changed_handlers:
        print(f"\nChanged handlers: {', '.join(changed_handlers)}")

    # Group versions by handler signature profile
    print(f"\n{'='*80}")
    print("Version Grouping by Handler Profile")
    print(f"{'='*80}")

    # For each version, create a combined signature of all handlers
    version_profiles = {}
    for version in versions:
        profile_parts = []
        for i in range(1, 80):
            name = VECTOR_NAMES[i] if i < len(VECTOR_NAMES) else f"IRQ{i-16}"
            sig = handler_sigs.get(name, {}).get(version, "none")
            profile_parts.append(sig)
        version_profiles[version] = hashlib.md5("|".join(profile_parts).encode()).hexdigest()[:12]

    # Group by profile
    profile_groups = defaultdict(list)
    for v, p in version_profiles.items():
        profile_groups[p].append(v)

    for profile, vers in sorted(profile_groups.items(), key=lambda x: x[1][0]):
        print(f"  Profile {profile}: {', '.join(vers)}")

    # Detailed disassembly of changed handlers
    if HAS_CAPSTONE and changed_handlers:
        print(f"\n{'='*80}")
        print("Detailed Disassembly of Changed Handlers")
        print(f"{'='*80}")

        for name in changed_handlers[:10]:  # Limit to first 10 changed
            print(f"\n--- {name} ---")
            # Group versions by signature
            sig_groups = defaultdict(list)
            for v in versions:
                sig = handler_sigs.get(name, {}).get(v, "none")
                sig_groups[sig].append(v)

            for sig, vers in sorted(sig_groups.items(), key=lambda x: x[1][0]):
                # Disassemble from the first version in this group
                rep_ver = vers[0]
                blob, vt_off, vectors, fname = all_versions[rep_ver]
                ec_off = handler_addrs.get(name, {}).get(rep_ver)
                if ec_off is None:
                    continue

                print(f"\n  Variant [{sig}] in: {', '.join(vers)}")
                print(f"  EC+0x{ec_off:05X} (0x{BASE+ec_off:08X}):")
                lines = disasm_handler(md, blob, ec_off, 15)
                for line in lines:
                    print(f"    {line}")


if __name__ == "__main__":
    main()
