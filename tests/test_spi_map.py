from __future__ import annotations

import struct
from pathlib import Path

from spiflash.spi_map import analyze_spi_dump, format_analysis


def test_analyze_spi_dump_detects_vector_and_versions(tmp_path: Path) -> None:
    dump = bytearray(b"\xff" * 4096)

    # ARM vector table @ offset 0
    struct.pack_into("<I", dump, 0x00, 0x200C7C00)
    struct.pack_into("<I", dump, 0x04, 0x100701F5)
    struct.pack_into("<I", dump, 0x08, 0x10070291)
    struct.pack_into("<I", dump, 0x0C, 0x1007029D)

    # version string
    dump[0x200:0x208] = b"N3GHT68W"

    path = tmp_path / "ec_spi.bin"
    path.write_bytes(dump)

    analysis = analyze_spi_dump(path)

    assert analysis.size == 4096
    assert len(analysis.vector_tables) == 1
    assert "N3GHT68W" in analysis.version_strings
    assert analysis.regions

    text = format_analysis(analysis)
    assert "EC SPI Dump 分析" in text
    assert "ARM 向量表" in text
