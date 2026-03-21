#!/usr/bin/env python3
"""Deep reverse analysis of N3GHT15W EC SPI 0x1C50000 and 0x1D00000 regions.

Hypothesis: these are ARM Thumb-2 code, not NVRAM/logs.
"""

import struct
import hashlib
import re
from pathlib import Path

SPI = Path(__file__).resolve().parent.parent / "firmware" / "ec_spi" / "N3GHT15W_z13_own_20260313.bin"

def detect_thumb_code(data, base_addr, label):
    """Look for ARM Thumb-2 code patterns."""
    print(f"\n  === ARM Thumb-2 代码检测: {label} ===")

    # Count common Thumb instruction patterns
    push_lr = 0  # PUSH {... LR}  = 0xB5xx
    pop_pc = 0   # POP {... PC}   = 0xBDxx
    bl_prefix = 0  # BL prefix     = 0xF7xx or 0xF0xx
    bx_lr = 0    # BX LR          = 0x4770
    nop = 0      # NOP            = 0xBF00
    movs_r0 = 0  # MOVS R0, #imm  = 0x20xx
    ldr_lit = 0  # LDR Rx, [PC, #] = 0x48xx-0x4Fxx

    for i in range(0, len(data) - 1, 2):
        hw = struct.unpack_from('<H', data, i)[0]
        if (hw & 0xFF00) == 0xB500: push_lr += 1
        elif (hw & 0xFF00) == 0xBD00: pop_pc += 1
        elif (hw & 0xF800) == 0xF000: bl_prefix += 1
        elif (hw & 0xF800) == 0xF800: bl_prefix += 1
        elif hw == 0x4770: bx_lr += 1
        elif hw == 0xBF00: nop += 1
        elif (hw & 0xFF00) == 0x2000: movs_r0 += 1
        elif (hw & 0xF800) == 0x4800: ldr_lit += 1

    total_hws = len(data) // 2
    code_score = push_lr + pop_pc + bl_prefix + bx_lr

    print(f"    PUSH {{..LR}}  (0xB5xx): {push_lr}")
    print(f"    POP  {{..PC}}  (0xBDxx): {pop_pc}")
    print(f"    BL prefix   (0xF0/F8): {bl_prefix}")
    print(f"    BX LR       (0x4770):  {bx_lr}")
    print(f"    NOP         (0xBF00):  {nop}")
    print(f"    MOVS R0,#   (0x20xx):  {movs_r0}")
    print(f"    LDR Rx,[PC] (0x48xx):  {ldr_lit}")
    print(f"    代码指标得分: {code_score} / {total_hws} halfwords ({code_score/total_hws*100:.1f}%)")

    is_code = code_score > total_hws * 0.01
    print(f"    判定: {'✓ ARM Thumb-2 代码' if is_code else '✗ 非代码 (数据/NVRAM)'}")
    return is_code


def find_function_prologues(data, base_addr, label, max_show=30):
    """Find function entry points (PUSH {R4-R7, LR} patterns)."""
    print(f"\n  === 函数入口点: {label} ===")
    funcs = []
    for i in range(0, len(data) - 3, 2):
        hw = struct.unpack_from('<H', data, i)[0]
        # PUSH with LR: 0xB5xx where bit 8 set
        if (hw & 0xFF00) == 0xB500:
            regs = hw & 0xFF
            # Also check for wide PUSH: 0xE92D xxxx
            funcs.append((base_addr + i, hw, regs))
        # PUSH.W {R4-R11, LR}: E92D 4xxx or E92D 5xxx
        if i + 2 < len(data):
            w = struct.unpack_from('<I', data, i)[0]
            if (w & 0xFFFF0000) == 0xE92D0000 and (w & 0x4000):  # LR bit
                funcs.append((base_addr + i, w, w & 0xFFFF))

    print(f"    找到 {len(funcs)} 个函数入口")
    if funcs:
        for addr, insn, regs in funcs[:max_show]:
            print(f"    0x{addr:08X}: PUSH 0x{insn:04X}")
    return funcs


def compare_with_main_ec(data, base_addr, spi_data, label):
    """Compare this region with the main EC firmware at 0x1000."""
    print(f"\n  === 与主 EC 镜像对比: {label} ===")

    # Main EC at 0x1000, size ~276KB
    main_ec = spi_data[0x1000:0x45000]
    print(f"    主 EC: 0x001000-0x045000 ({len(main_ec)/1024:.0f}KB)")
    print(f"    本区域: 0x{base_addr:08X} ({len(data)/1024:.0f}KB)")

    # Try to find main EC code snippets in this region
    # Use first 64 bytes of main EC (after _EC header)
    ec_header = main_ec[:64]
    idx = data.find(ec_header)
    if idx >= 0:
        print(f"    ★ 主 EC 头部在本区域偏移 0x{idx:X} (SPI 0x{base_addr+idx:08X}) 找到!")
        # Count match length
        match_len = 0
        for j in range(min(len(main_ec), len(data) - idx)):
            if main_ec[j] == data[idx + j]:
                match_len += 1
            else:
                break
        print(f"    连续匹配: {match_len} bytes ({match_len/1024:.1f}KB)")
    else:
        print(f"    主 EC 头部未在本区域找到")

    # Try code snippets from various offsets
    print(f"\n    代码片段搜索 (主EC中随机采样):")
    for sample_off in [0x100, 0x1000, 0x5000, 0xA000, 0x10000, 0x20000, 0x30000]:
        if sample_off + 32 > len(main_ec):
            continue
        snippet = main_ec[sample_off:sample_off+32]
        idx = data.find(snippet)
        if idx >= 0:
            print(f"    主EC[0x{sample_off:05X}] → 本区域[0x{idx:05X}] 匹配 (SPI 0x{base_addr+idx:08X})")
        else:
            print(f"    主EC[0x{sample_off:05X}] → 未找到")


def check_repeating_copies(data, base_addr, label):
    """Check if the region contains multiple copies of the same code block."""
    print(f"\n  === 重复拷贝检测: {label} ===")

    block_size = len(data)
    if block_size < 0x10000:
        return

    # Try various copy sizes
    for copy_size in [0x10000, 0xFF00, 0x8000, 0x4000, 0x20000, 0x40000]:
        if copy_size >= block_size // 2:
            continue
        first_copy = data[:copy_size]
        copies_found = 0
        offsets = []
        pos = 0
        while pos + copy_size <= block_size:
            candidate = data[pos:pos+copy_size]
            if candidate == first_copy:
                copies_found += 1
                offsets.append(pos)
                pos += copy_size
            else:
                pos += 0x1000  # step by 4KB

        if copies_found > 1:
            print(f"    ★ 0x{copy_size:X} ({copy_size/1024:.0f}KB) 块重复 {copies_found}x:")
            for off in offsets[:10]:
                print(f"      0x{base_addr+off:08X}")

    # Check if there's a repeating pattern at fixed interval
    # Count exact 64KB block matches
    block_64k = data[:0x10000]
    hash_first = hashlib.sha256(block_64k).hexdigest()
    matches = 0
    for off in range(0, block_size, 0x10000):
        h = hashlib.sha256(data[off:off+0x10000]).hexdigest()
        if h == hash_first:
            matches += 1

    if matches > 1:
        print(f"    64KB 块匹配: {matches}x (首块 hash)")

    # Compare consecutive 64KB blocks for similarity
    print(f"\n    相邻 64KB 块相似度:")
    prev_hash = None
    for off in range(0, min(block_size, 0x200000), 0x10000):
        blk = data[off:off+0x10000]
        h = hashlib.sha256(blk).hexdigest()[:8]
        if prev_hash:
            prev_blk = data[off-0x10000:off]
            diff_count = sum(1 for a, b in zip(blk, prev_blk) if a != b)
            sim = 1 - diff_count / len(blk)
            print(f"    0x{base_addr+off:08X}: hash={h}  vs前块: {sim*100:.1f}% 相同 ({diff_count} diff)")
        else:
            print(f"    0x{base_addr+off:08X}: hash={h}  (首块)")
        prev_hash = h


def search_ec_identifiers(data, base_addr, label):
    """Search for EC-relevant identifiers."""
    print(f"\n  === EC 标识搜索: {label} ===")

    # _EC magic
    idx = 0
    ec_headers = []
    while True:
        idx = data.find(b'\x5f\x45\x43', idx)
        if idx < 0:
            break
        if idx + 16 <= len(data):
            ver = data[idx+3]
            if ver in (1, 2):
                ec_headers.append((base_addr + idx, ver))
        idx += 1
    print(f"  _EC 头部: {len(ec_headers)}")
    for addr, ver in ec_headers[:10]:
        print(f"    0x{addr:08X}: ver={ver}")

    # Version strings
    for m in re.finditer(rb'N3G[A-Z]{2}\d{2}W', data):
        print(f"  版本串 @ 0x{base_addr+m.start():08X}: {m.group().decode()}")

    # Copyright
    idx = data.find(b'Copyright')
    if idx >= 0:
        snippet = data[idx:idx+80]
        print(f"  版权 @ 0x{base_addr+idx:08X}: {snippet.decode('ascii', errors='replace')[:60]}")

    # SMFI / EC names
    for pat in [b'SMFI', b'ACPI', b'PMC', b'KBC', b'BRAM', b'eSPI', b'SPI', b'GPIO',
                b'PWM', b'ADC', b'I2C', b'UART', b'WDT', b'PECI', b'SMBUS',
                b'FAN', b'TEMP', b'BAT', b'battery', b'thermal', b'keyboard',
                b'Insyde', b'LENOVO', b'ThinkPad']:
        idx = data.find(pat)
        if idx >= 0:
            print(f"  '{pat.decode()}' @ 0x{base_addr+idx:08X}")


def check_data_tables(data, base_addr, label):
    """Look for data tables (pointers, jump tables, etc.)."""
    print(f"\n  === 数据表检测: {label} ===")

    # Look for pointer tables (values in SRAM range 0x200xxxxx or flash range 0x100xxxxx)
    sram_ptrs = 0
    flash_ptrs = 0
    for i in range(0, len(data) - 3, 4):
        val = struct.unpack_from('<I', data, i)[0]
        if 0x20000000 <= val <= 0x200FFFFF:
            sram_ptrs += 1
        elif 0x10000000 <= val <= 0x101FFFFF:
            flash_ptrs += 1

    print(f"    SRAM 指针 (0x200xxxxx): {sram_ptrs}")
    print(f"    Flash 指针 (0x100xxxxx): {flash_ptrs}")

    # Vector table check at offset 0
    sp = struct.unpack_from('<I', data, 0)[0]
    reset = struct.unpack_from('<I', data, 4)[0]
    print(f"    首 8 字节: SP=0x{sp:08X}  Reset=0x{reset:08X}")
    if 0x20000000 <= sp <= 0x200FFFFF and 0x10000000 <= reset <= 0x100FFFFF:
        print(f"    ★ 看起来像 ARM 向量表!")

    # Scan for consecutive pointer values (jump/function table)
    tables = []
    for i in range(0, len(data) - 32, 4):
        ptrs = [struct.unpack_from('<I', data, i + j * 4)[0] for j in range(8)]
        if all(0x10000000 <= p <= 0x101FFFFF and (p & 1) for p in ptrs):
            tables.append(base_addr + i)
        elif all(0x20000000 <= p <= 0x200FFFFF for p in ptrs):
            tables.append(base_addr + i)

    if tables:
        print(f"    连续指针表 ({len(tables)}处):")
        for addr in tables[:10]:
            off = addr - base_addr
            ptrs = [struct.unpack_from('<I', data, off + j * 4)[0] for j in range(4)]
            print(f"      0x{addr:08X}: {' '.join(f'0x{p:08X}' for p in ptrs)}")


def main():
    data = SPI.read_bytes()
    print("=" * 70)
    print("N3GHT15W EC SPI — 运行时数据区域深度逆向")
    print("=" * 70)

    regions = [
        (0x1C50000, 0x1CB7000, "Region 1 (0x1C50000, 412KB)"),
        (0x1D00000, 0x2000000, "Region 2 (0x1D00000, 3MB)"),
    ]

    # Also include sub-regions from the deep_ec_analysis
    # 0x1C8F000-0x1CA2000 (76KB) and 0x1CA5000-0x1CB7000 (72KB) mentioned in prior analysis

    for start, end, label in regions:
        region = data[start:end]
        detect_thumb_code(region, start, label)
        find_function_prologues(region, start, label, max_show=15)
        search_ec_identifiers(region, start, label)
        check_data_tables(region, start, label)
        compare_with_main_ec(region, start, data, label)
        check_repeating_copies(region, start, label)

    # Now do a finer analysis of Region 2: is it multiple copies of the main EC?
    print(f"\n{'='*70}")
    print("  Region 2 细分分析")
    print(f"{'='*70}")

    r2 = data[0x1D00000:0x2000000]
    main_ec = data[0x1000:0x45000]  # 276KB

    # Try matching main_ec code at various offsets in Region 2
    print(f"\n  主 EC (276KB) 在 Region 2 中的匹配:")
    for probe_off in range(0, len(r2) - 32, 0x1000):
        snippet = r2[probe_off:probe_off+32]
        idx = main_ec.find(snippet)
        if idx >= 0:
            # Count extended match
            match_len = 0
            for j in range(min(256, len(main_ec) - idx, len(r2) - probe_off)):
                if main_ec[idx + j] == r2[probe_off + j]:
                    match_len += 1
                else:
                    break
            if match_len > 64:
                print(f"    R2[0x{probe_off:06X}] → EC[0x{idx:05X}] 匹配 {match_len}B")

    # And vice versa: try main_ec fragments in R2
    print(f"\n  主 EC 64B 采样 → Region 2:")
    for ec_off in range(0, len(main_ec), 0x4000):
        snippet = main_ec[ec_off:ec_off+64]
        idx = r2.find(snippet)
        if idx >= 0:
            print(f"    EC[0x{ec_off:05X}] → R2[0x{idx:06X}] (SPI 0x{0x1D00000+idx:08X})")
        else:
            print(f"    EC[0x{ec_off:05X}] → 未找到")


if __name__ == "__main__":
    main()
