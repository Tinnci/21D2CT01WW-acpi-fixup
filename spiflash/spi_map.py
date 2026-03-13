"""SPI dump 分析与 FL2 映射。

将 CH341A 读出的原始 SPI dump 与已知 FL2 文件对比，
确定 FL2 payload 在 SPI flash 中的精确偏移。
"""

from __future__ import annotations

import hashlib
import re
import struct
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from .fl2 import parse_fl2


@dataclass
class VectorTableHit:
    """SPI dump 中找到的 ARM 向量表。"""

    spi_offset: int
    sp: int
    reset: int
    nmi: int
    hardfault: int


@dataclass
class SPIRegion:
    """SPI flash 中的一个数据区域。"""

    start: int
    end: int
    rtype: str  # "DATA", "ERASED" (0xFF), "ZERO"

    @property
    def size(self) -> int:
        return self.end - self.start


@dataclass
class FL2Mapping:
    """FL2 payload 到 SPI 的映射结果。"""

    fl2_version: Optional[str]
    fl2_payload_offset: int  # FL2 文件中 payload 开始的偏移 (通常 0x120)
    spi_offset: int  # SPI dump 中 payload 开始的偏移
    match_bytes: int
    total_bytes: int
    is_exact: bool

    @property
    def match_percent(self) -> float:
        return 100 * self.match_bytes / self.total_bytes if self.total_bytes else 0


@dataclass
class SPIAnalysis:
    """SPI dump 完整分析结果。"""

    path: Path
    size: int
    sha256: str
    ff_percent: float
    data_percent: float
    vector_tables: list[VectorTableHit] = field(default_factory=list)
    boot_config_offset: Optional[int] = None
    ec_headers_found: dict[str, int] = field(default_factory=dict)
    version_strings: dict[str, int] = field(default_factory=dict)
    fl2_mappings: list[FL2Mapping] = field(default_factory=list)
    regions: list[SPIRegion] = field(default_factory=list)


def analyze_spi_dump(
    dump_path: Path | str,
    fl2_paths: Optional[list[Path | str]] = None,
) -> SPIAnalysis:
    """分析 SPI dump 文件，返回完整分析结果。"""
    dump_path = Path(dump_path)
    dump = dump_path.read_bytes()
    sha256 = hashlib.sha256(dump).hexdigest()

    ff_count = dump.count(b"\xff")
    zero_count = dump.count(b"\x00")

    analysis = SPIAnalysis(
        path=dump_path,
        size=len(dump),
        sha256=sha256,
        ff_percent=100 * ff_count / len(dump),
        data_percent=100 * (len(dump) - ff_count - zero_count) / len(dump),
    )

    # 搜索 ARM 向量表
    sp_bytes = struct.pack("<I", 0x200C7C00)
    pos = dump.find(sp_bytes)
    while pos >= 0 and pos + 16 <= len(dump):
        reset = struct.unpack_from("<I", dump, pos + 4)[0]
        if 0x10070000 <= reset <= 0x100FFFFF:
            analysis.vector_tables.append(
                VectorTableHit(
                    spi_offset=pos,
                    sp=struct.unpack_from("<I", dump, pos)[0],
                    reset=reset,
                    nmi=struct.unpack_from("<I", dump, pos + 8)[0],
                    hardfault=struct.unpack_from("<I", dump, pos + 12)[0],
                )
            )
        pos = dump.find(sp_bytes, pos + 1)

    # 搜索引导配置块
    boot_magic = bytes.fromhex("5e4d3b2a1eab0403")
    pos = dump.find(boot_magic)
    if pos >= 0:
        analysis.boot_config_offset = pos

    # 搜索 Insyde _EC 头部
    for tag, name in [(b"_EC\x01", "_EC1"), (b"_EC\x02", "_EC2")]:
        pos = dump.find(tag)
        if pos >= 0:
            analysis.ec_headers_found[name] = pos

    # 搜索版本字符串
    for m in re.finditer(rb"N3G[A-Z]{2}\d{2}W", dump):
        name = m.group().decode()
        if name not in analysis.version_strings:
            analysis.version_strings[name] = m.start()

    # 与 FL2 payload 比较
    if fl2_paths:
        for fl2_path in fl2_paths:
            fl2_path = Path(fl2_path)
            try:
                fl2 = parse_fl2(fl2_path)
            except (ValueError, OSError):
                continue

            payload = fl2.extract_payload()
            needle = payload[:64]
            pos = dump.find(needle)

            if pos >= 0 and pos + len(payload) <= len(dump):
                matched = sum(1 for i in range(len(payload)) if dump[pos + i] == payload[i])
                analysis.fl2_mappings.append(
                    FL2Mapping(
                        fl2_version=fl2.version,
                        fl2_payload_offset=fl2.PAYLOAD_OFFSET,
                        spi_offset=pos,
                        match_bytes=matched,
                        total_bytes=len(payload),
                        is_exact=(matched == len(payload)),
                    )
                )
            else:
                # 尝试通过版本字符串估算偏移
                if fl2.version:
                    ver_bytes = fl2.version.encode()
                    fl2_data = fl2_path.read_bytes()
                    ver_in_fl2 = fl2_data.find(ver_bytes)
                    ver_in_dump = dump.find(ver_bytes)
                    if ver_in_fl2 >= 0 and ver_in_dump >= 0:
                        estimated = ver_in_dump - (ver_in_fl2 - fl2.PAYLOAD_OFFSET)
                        analysis.fl2_mappings.append(
                            FL2Mapping(
                                fl2_version=fl2.version,
                                fl2_payload_offset=fl2.PAYLOAD_OFFSET,
                                spi_offset=estimated,
                                match_bytes=0,
                                total_bytes=len(payload),
                                is_exact=False,
                            )
                        )

    # 区域分割 (256 字节块)
    block_size = 256
    current_type: Optional[str] = None
    region_start = 0

    for i in range(0, len(dump), block_size):
        block = dump[i : i + block_size]
        if all(b == 0xFF for b in block):
            btype = "ERASED"
        elif all(b == 0x00 for b in block):
            btype = "ZERO"
        else:
            btype = "DATA"

        if btype != current_type:
            if current_type is not None:
                analysis.regions.append(SPIRegion(region_start, i, current_type))
            current_type = btype
            region_start = i

    if current_type is not None:
        analysis.regions.append(SPIRegion(region_start, len(dump), current_type))

    return analysis


def format_analysis(analysis: SPIAnalysis) -> str:
    """格式化分析结果为可读文本。"""
    lines: list[str] = []
    sep = "=" * 60

    lines.append(sep)
    lines.append(f"EC SPI Dump 分析: {analysis.path.name}")
    lines.append(sep)
    lines.append(f"  大小: {analysis.size} bytes ({analysis.size // 1024}KB, {analysis.size * 8 // 1024 // 1024}Mbit)")
    lines.append(f"  SHA256: {analysis.sha256}")
    lines.append(f"  0xFF: {analysis.ff_percent:.1f}%  数据: {analysis.data_percent:.1f}%")

    lines.append("\n--- ARM 向量表 ---")
    if analysis.vector_tables:
        for vt in analysis.vector_tables:
            lines.append(f"  ★ SPI 偏移 0x{vt.spi_offset:06X}")
            lines.append(f"    SP=0x{vt.sp:08X}  Reset=0x{vt.reset:08X}")
            lines.append(f"    NMI=0x{vt.nmi:08X}  HardFault=0x{vt.hardfault:08X}")
    else:
        lines.append("  未找到 (dump 可能为空或加密)")

    lines.append("\n--- 引导配置块 ---")
    if analysis.boot_config_offset is not None:
        lines.append(f"  ★ 找到: SPI 偏移 0x{analysis.boot_config_offset:06X}")
    else:
        lines.append("  未找到")

    lines.append("\n--- Insyde _EC 头部 ---")
    if analysis.ec_headers_found:
        for name, off in analysis.ec_headers_found.items():
            lines.append(f"  {name}: SPI 偏移 0x{off:06X}")
    else:
        lines.append("  未找到 (FL2 头部不在 SPI 中)")

    lines.append("\n--- 版本字符串 ---")
    for name, off in analysis.version_strings.items():
        lines.append(f"  '{name}' @ SPI 0x{off:06X}")

    lines.append("\n--- FL2 映射 ---")
    for mapping in analysis.fl2_mappings:
        status = "★ 完全匹配" if mapping.is_exact else "≈ 部分匹配"
        lines.append(f"  {status}: {mapping.fl2_version}")
        lines.append(f"    FL2[0x{mapping.fl2_payload_offset:X}:] → SPI[0x{mapping.spi_offset:06X}:]")
        lines.append(f"    匹配: {mapping.match_bytes}/{mapping.total_bytes} ({mapping.match_percent:.1f}%)")

    lines.append("\n--- SPI 区域 ---")
    for region in analysis.regions:
        if region.size >= 4096 or region.rtype == "DATA":
            label = {"ERASED": "已擦除", "ZERO": "全零", "DATA": "固件数据"}[region.rtype]
            lines.append(f"  0x{region.start:06X}-0x{region.end - 1:06X}  {region.size:>8} bytes  [{label}]")

    # 结论
    lines.append(f"\n{sep}")
    lines.append("映射结论:")
    if analysis.vector_tables:
        vt = analysis.vector_tables[0]
        if vt.spi_offset == 0:
            lines.append("  SPI[0x0] = ARM 向量表")
            lines.append("  → FL2[0x120:] 直接映射到 SPI[0x0:]")
            lines.append("  → 写入镜像 = FL2 payload (去掉前 0x120 字节)")
        else:
            lines.append(f"  SPI[0x{vt.spi_offset:06X}] = ARM 向量表")
            lines.append(f"  → SPI 前 {vt.spi_offset} 字节为 boot header")
            lines.append(f"  → 写入时需保留 SPI[0x0:0x{vt.spi_offset:X}] 原始内容")
    else:
        lines.append("  未找到 ARM 向量表 — 需要进一步分析")
    lines.append(sep)

    return "\n".join(lines)
