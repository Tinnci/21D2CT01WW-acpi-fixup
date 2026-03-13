#!/usr/bin/env python3
"""
reverse_efi.py — EFI PE32+ 深度逆向分析
ThinkPad Z13 Gen 1 (21D2CT01WW) — NoDCCheck_BootX64.efi

功能:
  1. PE32+ 结构解析 (节表、导入/导出、入口点)
  2. UTF-16LE 字符串全量提取 (EFI 内部真实字符串)
  3. CLI 参数表重建 (从字符串上下文推断真实开关语法)
  4. 关键函数定位 (ArgumentParser / FlashCommand / ECFW / PartNumber)
  5. x86-64 反汇编关键片段 (需要 capstone)
  6. 与 BootX64.efi 原版 diff (定位 NoDCCheck 去掉了什么)

Usage:
  python3 scripts/reverse_efi.py [EFI_PATH] [--diff ORIG_EFI] [--disasm] [--strings] [--all]

Examples:
  python3 scripts/reverse_efi.py /tmp/NoDCCheck_BootX64.efi --all
  python3 scripts/reverse_efi.py /tmp/NoDCCheck_BootX64.efi --diff /tmp/BootX64_orig.efi
  python3 scripts/reverse_efi.py /tmp/NoDCCheck_BootX64.efi --strings --disasm
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# ── 可选依赖 ──────────────────────────────────────────────────
try:
    import pefile
    HAS_PEFILE = True
except ImportError:
    HAS_PEFILE = False

try:
    import capstone
    HAS_CAPSTONE = True
except ImportError:
    HAS_CAPSTONE = False

# ─────────────────────────────────────────────────────────────
# 常量
# ─────────────────────────────────────────────────────────────
SEP   = "=" * 72
SEP2  = "-" * 72
SEP3  = "·" * 72

# 关键字符串 (ASCII / UTF-16LE 两种形式都要搜)
KEY_STRINGS = [
    # CLI 参数相关
    "FlashCommand",
    "TdkFlashCommandLine",
    "Skip part number checking",
    "Skip ECFW image check",
    "Skip Battery check",
    "Skip AC Adapter check",
    "ECFW Update",
    "EC Update",
    "BIOS Update",
    "Reboot automatically",
    "Shutdown after flash completed",
    "Silent operation",
    "Skip flash options in BIOS FlashCommand",
    "Skip BIOS build date time checking",
    "Flash without skipping same content blocks",
    "Enable flash verification",
    "Enable Microsoft Bit-locker check",
    "Update variable size CPU microcode",
    "Specify admin",
    "OEM command line",
    "filename",
    "password",
    "rsbr",
    "FDLA",
    "force",
    "output",
    "verify",
    "reboot",
    "Show command list",
    "hidden commands",
    # 机型/兼容检查
    "Model Part Number",
    "ModelPartNumber",
    "Part Number",
    "BIOS part numbers do not match",
    "does not recognize",
    "Incompatible Version",
    "not compatible",
    "not an upgrade",
    "Secure RollBack",
    # EC/ECFW
    "ECFW",
    "LenovoEcfwUpdate",
    "Set ECFW Interface",
    "ECFW image file is invalid",
    "Failed to load ECFW image",
    "signed ECFW image only",
    "unsigned ECFW image only",
    # SMI/IHISI
    "LenovoVariableSmiCommand",
    "LenovoBiosFeature",
    "Failed to initialize SMI",
    "Open flash write enable",
    "Close flash write enable",
    "Failed on executing WRITE",
    "BIOS doesn't support SMI",
    "BIOS doesn't support SMM TDK",
    # 安全
    "Secure flash public key",
    "sample/dummy",
    "Verified boot",
    "Boot guard",
    "BIOS guard",
    # 刷写流程
    "Begin Flashing",
    "Image flashing done",
    "BIOS is updated successfully",
    "System will shutdown or reboot",
    "Total number of region",
    "Total blocks",
    "Erase fail",
    "Write fail",
    "Verify fail",
    # 变量/NVRAM
    "TdkBcpReadAscii",
    "TdkBcpWriteAscii",
    "TdkBcpDeleteAscii",
    "TdkVariableSet",
    "TdkVariableGet",
    "TdkBiosService",
    "Argument",
    "ArgCommand",
    # 错误
    "Command line error",
    "ERROR 105",
    "utility process has not completed",
    "process does not recognize",
    "BIOS was locked",
]

# CLI 开关候选 (在帮助文本中通常紧跟说明行)
HELP_DESC_PATTERNS = [
    r"Skip .+",
    r"Specify .+",
    r"Enable .+",
    r"Disable .+",
    r"Update .+",
    r"Replace .+",
    r"Reserve .+",
    r"Flash .+",
    r"Show .+",
    r"Write .+",
    r"Do not .+",
    r"No .+",
    r"Production mode.*",
    r"Patch mode.*",
    r"Silent operation.*",
    r"Shutdown after.*",
    r"Reboot .*",
    r"Output .+",
    r"GUID .+",
    r"filename .+",
    r"password",
    r"port value",
    r"start size",
]


# ─────────────────────────────────────────────────────────────
# PE32+ 解析
# ─────────────────────────────────────────────────────────────
@dataclass
class PESection:
    name: str
    vaddr: int
    vsize: int
    raw_offset: int
    raw_size: int
    characteristics: int

    @property
    def is_executable(self) -> bool:
        return bool(self.characteristics & 0x20000000)

    @property
    def is_writable(self) -> bool:
        return bool(self.characteristics & 0x80000000)

    @property
    def is_readable(self) -> bool:
        return bool(self.characteristics & 0x40000000)


@dataclass
class PEInfo:
    path: Path
    size: int
    sha256: str
    machine: int
    image_base: int
    entry_rva: int
    entry_va: int
    image_size: int
    subsystem: int
    sections: list[PESection] = field(default_factory=list)
    text_section: Optional[PESection] = None
    rdata_section: Optional[PESection] = None


def parse_pe_headers(data: bytes, path: Path) -> PEInfo:
    """手动解析 PE32+ 头部，不依赖 pefile。"""
    sha256 = hashlib.sha256(data).hexdigest()

    # MZ 魔数
    if data[:2] != b'MZ':
        raise ValueError("不是有效的 MZ / PE 文件")

    # PE 头偏移
    pe_offset = struct.unpack_from('<I', data, 0x3C)[0]
    if data[pe_offset:pe_offset+4] != b'PE\x00\x00':
        raise ValueError(f"PE 签名错误 at 0x{pe_offset:X}")

    # COFF 头
    machine          = struct.unpack_from('<H', data, pe_offset + 4)[0]
    num_sections     = struct.unpack_from('<H', data, pe_offset + 6)[0]
    opt_header_size  = struct.unpack_from('<H', data, pe_offset + 20)[0]
    characteristics  = struct.unpack_from('<H', data, pe_offset + 22)[0]

    # Optional Header (PE32+)
    opt_base = pe_offset + 24
    magic    = struct.unpack_from('<H', data, opt_base)[0]
    if magic != 0x20B:
        raise ValueError(f"不是 PE32+ (magic=0x{magic:04X})")

    image_base  = struct.unpack_from('<Q', data, opt_base + 24)[0]
    entry_rva   = struct.unpack_from('<I', data, opt_base + 16)[0]
    image_size  = struct.unpack_from('<I', data, opt_base + 56)[0]
    subsystem   = struct.unpack_from('<H', data, opt_base + 68)[0]

    info = PEInfo(
        path       = path,
        size       = len(data),
        sha256     = sha256,
        machine    = machine,
        image_base = image_base,
        entry_rva  = entry_rva,
        entry_va   = image_base + entry_rva,
        image_size = image_size,
        subsystem  = subsystem,
    )

    # 节表
    sect_base = pe_offset + 24 + opt_header_size
    for i in range(num_sections):
        off = sect_base + i * 40
        raw_name = data[off:off+8]
        name = raw_name.rstrip(b'\x00').decode('ascii', errors='replace')
        vsize      = struct.unpack_from('<I', data, off + 8)[0]
        vaddr      = struct.unpack_from('<I', data, off + 12)[0]
        raw_size   = struct.unpack_from('<I', data, off + 16)[0]
        raw_offset = struct.unpack_from('<I', data, off + 20)[0]
        chars      = struct.unpack_from('<I', data, off + 36)[0]

        sec = PESection(
            name           = name,
            vaddr          = vaddr,
            vsize          = vsize,
            raw_offset     = raw_offset,
            raw_size       = raw_size,
            characteristics = chars,
        )
        info.sections.append(sec)
        if name in ('.text', 'text'):
            info.text_section = sec
        if name in ('.rdata', 'rdata', '.rodata'):
            info.rdata_section = sec

    return info


def print_pe_info(info: PEInfo):
    machine_names = {0x8664: 'AMD64 (x86-64)', 0x014C: 'i386', 0xAA64: 'ARM64'}
    subsys_names  = {10: 'EFI Application', 11: 'EFI Boot Service Driver',
                     12: 'EFI Runtime Driver', 13: 'EFI ROM'}

    print(SEP)
    print("PE32+ 结构分析")
    print(SEP)
    print(f"  文件:        {info.path}")
    print(f"  大小:        {info.size:,} bytes ({info.size // 1024}KB)")
    print(f"  SHA256:      {info.sha256}")
    print(f"  架构:        {machine_names.get(info.machine, f'0x{info.machine:04X}')}")
    print(f"  Image Base:  0x{info.image_base:016X}")
    print(f"  Entry RVA:   0x{info.entry_rva:08X}")
    print(f"  Entry VA:    0x{info.entry_va:016X}")
    print(f"  Image Size:  0x{info.image_size:08X} ({info.image_size // 1024}KB)")
    print(f"  Subsystem:   {subsys_names.get(info.subsystem, f'0x{info.subsystem:04X}')}")
    print()
    print(f"  {'节名':<12} {'VAddr':>12} {'VSize':>10} {'RawOff':>10} {'RawSize':>10}  {'属性'}")
    print(f"  {'-'*12} {'-'*12} {'-'*10} {'-'*10} {'-'*10}  {'------'}")
    for sec in info.sections:
        flags = []
        if sec.is_executable: flags.append('X')
        if sec.is_readable:   flags.append('R')
        if sec.is_writable:   flags.append('W')
        print(f"  {sec.name:<12} 0x{sec.vaddr:010X} 0x{sec.vsize:08X} 0x{sec.raw_offset:08X} 0x{sec.raw_size:08X}  {''.join(flags)}")
    print()


# ─────────────────────────────────────────────────────────────
# UTF-16LE 字符串提取 (EFI 真正的字符串格式)
# ─────────────────────────────────────────────────────────────
@dataclass
class U16String:
    offset: int
    text: str
    section: str = ""

    def __len__(self):
        return len(self.text)


def extract_utf16le_strings(data: bytes, min_len: int = 5) -> list[U16String]:
    """提取所有 UTF-16LE 字符串（4字节对齐或非对齐均扫）。"""
    results = []
    i = 0
    while i < len(data) - 2:
        # 尝试在此位置开始一段 UTF-16LE 可打印字符串
        j = i
        chars = []
        while j + 1 < len(data):
            w = struct.unpack_from('<H', data, j)[0]
            if 0x0020 <= w <= 0x007E or w in (0x000A, 0x000D, 0x0009):
                chars.append(chr(w))
                j += 2
            else:
                break
        if len(chars) >= min_len:
            text = ''.join(chars).strip()
            if len(text) >= min_len:
                results.append(U16String(offset=i, text=text))
            i = j
        else:
            i += 2
    return results


def label_section(offset: int, info: PEInfo) -> str:
    for sec in info.sections:
        if sec.raw_offset <= offset < sec.raw_offset + sec.raw_size:
            return sec.name
    return "?"


def extract_ascii_strings(data: bytes, min_len: int = 6) -> list[tuple[int, str]]:
    """提取 ASCII 字符串。"""
    results = []
    pattern = re.compile(rb'[\x20-\x7E]{' + str(min_len).encode() + rb',}')
    for m in pattern.finditer(data):
        results.append((m.start(), m.group().decode('ascii')))
    return results


# ─────────────────────────────────────────────────────────────
# 关键字符串搜索
# ─────────────────────────────────────────────────────────────
@dataclass
class StringHit:
    offset: int
    encoding: str   # "ascii" | "utf16"
    text: str
    keyword: str
    section: str = ""
    context_before: list[str] = field(default_factory=list)
    context_after: list[str] = field(default_factory=list)


def search_key_strings(
    data: bytes,
    info: PEInfo,
    ascii_strings: list[tuple[int, str]],
    utf16_strings: list[U16String],
    context: int = 4,
) -> list[StringHit]:
    hits: list[StringHit] = []

    for kw in KEY_STRINGS:
        kw_lower = kw.lower()

        # ASCII 搜索
        for idx, (off, text) in enumerate(ascii_strings):
            if kw_lower in text.lower():
                before = [s for _, s in ascii_strings[max(0, idx-context):idx]]
                after  = [s for _, s in ascii_strings[idx+1:idx+1+context]]
                hits.append(StringHit(
                    offset=off, encoding="ascii", text=text, keyword=kw,
                    section=label_section(off, info),
                    context_before=before, context_after=after,
                ))

        # UTF-16LE 搜索
        for idx, s in enumerate(utf16_strings):
            if kw_lower in s.text.lower():
                before = [u.text for u in utf16_strings[max(0, idx-context):idx]]
                after  = [u.text for u in utf16_strings[idx+1:idx+1+context]]
                hits.append(StringHit(
                    offset=s.offset, encoding="utf16", text=s.text, keyword=kw,
                    section=label_section(s.offset, info),
                    context_before=before, context_after=after,
                ))

    return hits


# ─────────────────────────────────────────────────────────────
# CLI 参数表重建
# ─────────────────────────────────────────────────────────────
@dataclass
class CLIEntry:
    switch: str          # 可能的开关名 (e.g., /w, /skip_pn, ...)
    description: str     # 说明文本
    offset: int
    encoding: str
    argument: str = ""   # 可能跟的参数 (e.g., "filename", "GUID")


def reconstruct_cli_table(
    ascii_strings: list[tuple[int, str]],
    utf16_strings: list[U16String],
) -> list[CLIEntry]:
    """
    尝试从帮助文本字符串重建真实 CLI 参数表。
    策略：找到所有符合帮助说明模式的字符串，
    然后查看它在字符串数组中的前几行，
    推断对应的开关名。
    """
    entries: list[CLIEntry] = []
    desc_re = re.compile('|'.join(HELP_DESC_PATTERNS), re.IGNORECASE)

    # 先在 ASCII 字符串序列里找
    ascii_list = [(off, text) for off, text in ascii_strings]
    for idx, (off, text) in enumerate(ascii_list):
        if desc_re.match(text.strip()):
            # 前 1-3 个字符串可能是开关名或参数格式
            prev_items = ascii_list[max(0, idx-3):idx]
            switch_guess = ""
            arg_guess    = ""
            for poff, ptext in reversed(prev_items):
                ptext = ptext.strip()
                # 短字符串 (1-20 字符) 很可能是开关或格式
                if 1 <= len(ptext) <= 30:
                    if ptext.startswith('/') or ptext.startswith('-'):
                        switch_guess = ptext
                        break
                    elif re.match(r'^[A-Za-z0-9_.]{1,20}$', ptext):
                        if not switch_guess:
                            arg_guess = ptext
            entries.append(CLIEntry(
                switch      = switch_guess or "(unknown)",
                description = text.strip(),
                offset      = off,
                encoding    = "ascii",
                argument    = arg_guess,
            ))

    # 再在 UTF-16LE 序列里找
    u16_list = utf16_strings
    for idx, u16 in enumerate(u16_list):
        text = u16.text.strip()
        if desc_re.match(text):
            prev_items = u16_list[max(0, idx-3):idx]
            switch_guess = ""
            arg_guess    = ""
            for pu in reversed(prev_items):
                pt = pu.text.strip()
                if 1 <= len(pt) <= 30:
                    if pt.startswith('/') or pt.startswith('-'):
                        switch_guess = pt
                        break
                    elif re.match(r'^[A-Za-z0-9_.]{1,20}$', pt):
                        if not switch_guess:
                            arg_guess = pt
            entries.append(CLIEntry(
                switch      = switch_guess or "(unknown)",
                description = text,
                offset      = u16.offset,
                encoding    = "utf16",
                argument    = arg_guess,
            ))

    # 去重 (同一说明文本)
    seen = set()
    unique: list[CLIEntry] = []
    for e in entries:
        key = e.description.lower()
        if key not in seen:
            seen.add(key)
            unique.append(e)

    return unique


# ─────────────────────────────────────────────────────────────
# 二进制 Diff (NoDCCheck vs 原版)
# ─────────────────────────────────────────────────────────────
def diff_binaries(data_a: bytes, data_b: bytes,
                  name_a: str = "NoDCCheck",
                  name_b: str = "BootX64_orig") -> dict:
    """逐字节比较，找出差异区间。"""
    min_len = min(len(data_a), len(data_b))
    diff_offsets = [i for i in range(min_len) if data_a[i] != data_b[i]]

    # 合并连续差异区间
    regions: list[tuple[int, int]] = []
    if diff_offsets:
        start = diff_offsets[0]
        prev  = diff_offsets[0]
        for off in diff_offsets[1:]:
            if off - prev > 64:   # 超过 64 字节空白 → 新区间
                regions.append((start, prev + 1))
                start = off
            prev = off
        regions.append((start, prev + 1))

    return {
        "name_a":       name_a,
        "name_b":       name_b,
        "size_a":       len(data_a),
        "size_b":       len(data_b),
        "diff_bytes":   len(diff_offsets),
        "diff_percent": 100 * len(diff_offsets) / min_len if min_len else 0,
        "diff_regions": regions,
    }


def print_diff(result: dict, data_a: bytes, data_b: bytes, context_bytes: int = 64):
    print(SEP)
    print(f"Binary Diff: {result['name_a']} vs {result['name_b']}")
    print(SEP)
    print(f"  {result['name_a']}: {result['size_a']:,} bytes")
    print(f"  {result['name_b']}: {result['size_b']:,} bytes")
    print(f"  差异字节: {result['diff_bytes']:,} ({result['diff_percent']:.1f}%)")
    print(f"  差异区间: {len(result['diff_regions'])} 个")
    print()

    for i, (start, end) in enumerate(result['diff_regions'][:30]):
        size = end - start
        print(f"  [{i+1:3d}] 0x{start:08X} – 0x{end-1:08X}  ({size} bytes)")

        # 显示每个区间的十六进制上下文
        ctx_start = max(0, start - 16)
        ctx_end   = min(min(len(data_a), len(data_b)), end + 16)

        chunk_a = data_a[ctx_start:ctx_end]
        chunk_b = data_b[ctx_start:ctx_end]

        def hexline(d: bytes, off: int) -> str:
            return ' '.join(f'{b:02X}' for b in d[:32]) + (f'  ... (+{len(d)-32})' if len(d)>32 else '')

        print(f"       A: {hexline(chunk_a, ctx_start)}")
        print(f"       B: {hexline(chunk_b, ctx_start)}")

        # 尝试找这个区间对应的字符串
        for off in range(start, min(end, start + 256)):
            # 检查 ASCII
            if 0x20 <= data_a[off] <= 0x7E:
                j = off
                while j < len(data_a) and 0x20 <= data_a[j] <= 0x7E:
                    j += 1
                if j - off >= 4:
                    print(f"       A-str: '{data_a[off:j].decode('ascii', errors='replace')}'")
            if 0x20 <= data_b[off] <= 0x7E:
                j = off
                while j < len(data_b) and 0x20 <= data_b[j] <= 0x7E:
                    j += 1
                if j - off >= 4:
                    print(f"       B-str: '{data_b[off:j].decode('ascii', errors='replace')}'")
            break
        print()

    if len(result['diff_regions']) > 30:
        print(f"  ... (共 {len(result['diff_regions'])} 个区间，仅显示前 30)")
    print()


# ─────────────────────────────────────────────────────────────
# 反汇编 (capstone)
# ─────────────────────────────────────────────────────────────
def disasm_region(data: bytes, offset: int, size: int,
                  base_va: int, label: str = "") -> list[str]:
    """反汇编指定 raw offset 处的代码。"""
    if not HAS_CAPSTONE:
        return ["[capstone 未安装，跳过反汇编]"]
    cs = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    cs.detail = True
    lines = []
    if label:
        lines.append(f"  ;; {label}")
    code_va = base_va + offset   # 近似 (忽略节偏移差)
    for insn in cs.disasm(data[offset:offset+size], code_va):
        lines.append(f"  0x{insn.address:016X}:  {insn.bytes.hex():<24}  {insn.mnemonic} {insn.op_str}")
    return lines


def find_and_disasm_key_patterns(
    data: bytes,
    info: PEInfo,
    utf16_strings: list[U16String],
    ascii_strings: list[tuple[int, str]],
) -> list[tuple[str, list[str]]]:
    """
    找到关键函数附近并反汇编：
    - ArgumentParser / ArgCommand 相关代码
    - FlashCommand 写入逻辑
    - ECFW 更新触发点
    - PartNumber 检查逻辑
    """
    if not HAS_CAPSTONE:
        return []

    results: list[tuple[str, list[str]]] = []

    targets = [
        ("ECFW Update",              0x100),
        ("Skip part number checking", 0x100),
        ("FlashCommand",              0x100),
        ("TdkFlashCommandLine",       0x100),
        ("LenovoVariableSmiCommand",  0x100),
        ("BIOS doesn't support SMI",  0x80),
        ("LenovoEcfwUpdate",          0x100),
        ("Begin Flashing",            0x100),
        ("BIOS is updated successfully", 0x80),
    ]

    for keyword, disasm_size in targets:
        kw_bytes_utf16 = keyword.encode('utf-16-le')
        kw_bytes_ascii = keyword.encode('ascii')

        offsets: list[tuple[int, str]] = []
        pos = data.find(kw_bytes_utf16)
        while pos >= 0:
            offsets.append((pos, 'utf16'))
            pos = data.find(kw_bytes_utf16, pos + 1)
        pos = data.find(kw_bytes_ascii)
        while pos >= 0:
            offsets.append((pos, 'ascii'))
            pos = data.find(kw_bytes_ascii, pos + 1)

        for str_off, enc in offsets[:3]:
            # 找 .text 节
            text_sec = info.text_section
            if text_sec is None:
                continue

            # 找字符串引用: 在 .text 里搜索把这个 VA 作为立即数的指令
            str_va  = info.image_base + str_off   # 近似
            va_bytes = struct.pack('<Q', str_va)
            ref_off  = data.find(va_bytes, text_sec.raw_offset,
                                 text_sec.raw_offset + text_sec.raw_size)
            if ref_off < 0:
                # 也试 RVA (相对)
                ref_off = text_sec.raw_offset
            else:
                # 往前找函数序言 (push rbp / sub rsp / ...)
                scan = ref_off
                for _ in range(512):
                    if scan <= text_sec.raw_offset:
                        break
                    if data[scan:scan+2] in (b'\x55\x48', b'\x40\x55'):
                        break
                    scan -= 1
                ref_off = max(scan, ref_off - 64)

            code = disasm_region(
                data, ref_off, min(disasm_size, text_sec.raw_size),
                info.image_base + text_sec.vaddr - text_sec.raw_offset,
                label=f"keyword='{keyword}' str@0x{str_off:08X} ({enc})"
            )
            results.append((keyword, code))
            break   # 只取第一个引用

    return results


# ─────────────────────────────────────────────────────────────
# UEFI 协议 GUID 搜索
# ─────────────────────────────────────────────────────────────
KNOWN_GUIDS = {
    "8BE4DF61-93CA-11D2-AA0D-00E098032B8C": "gEfiGlobalVariableGuid",
    "EE4E5898-3914-4259-9D6E-DC7BD79403CF": "gEf
