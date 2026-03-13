"""Lenovo EC 固件 FL2 文件解析。

支持:
  - _EC1/_EC2 双头部解码
  - 签名提取
  - 引导配置块解码
  - 版本字符串提取
  - PD 固件 blob 定位
  - Payload 提取 (用于 SPI 写入)
"""

from __future__ import annotations

import hashlib
import re
import struct
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


@dataclass
class ECHeader:
    """_EC1 或 _EC2 头部。"""

    index: int  # 1 或 2
    magic: bytes
    total_size: int
    data_size: int
    field_0c: int
    field_10: int
    checksum: int
    offset: int  # 在 FL2 中的偏移

    @property
    def is_valid(self) -> bool:
        return self.magic in (b"_EC\x01", b"_EC\x02")


@dataclass
class BootConfig:
    """引导配置块 (FL2 偏移 0xE0-0x11F)。"""

    magic: int  # 0xE0: 0x2A3B4D5E
    config_word1: int  # 0xE4
    config_word2: int  # 0xE8
    entry_word: int  # 0xEC: 包含 Reset 入口点信息
    load_base_hint: int  # 0xF0
    code_size_minus1: int  # 0xF4
    code_size: int  # 0xF8
    flags: int  # 0xFC
    crc_fixed: int  # 0x118: 两版本相同
    crc_version: int  # 0x11C: 每版本不同
    raw: bytes  # 完整 64 字节

    @property
    def estimated_code_kb(self) -> int:
        return self.code_size // 1024


@dataclass
class PDFirmware:
    """嵌入的 PD 控制器固件。"""

    name: str
    offset: int  # FL2 中的偏移
    size: int
    payload_offset: int  # payload (SPI) 中的偏移

    @property
    def spi_offset(self) -> int:
        """假设 FL2[0x120:] → SPI[0:] 时的偏移。"""
        return self.payload_offset


@dataclass
class FL2Info:
    """FL2 文件完整解析结果。"""

    path: Path
    size: int
    sha256: str
    ec1: ECHeader
    ec2: ECHeader
    signature: bytes  # 64 字节
    boot_config: BootConfig
    version: Optional[str]  # e.g., "N3GHT68W"
    pd_firmwares: list[PDFirmware] = field(default_factory=list)
    vector_sp: int = 0
    vector_reset: int = 0
    vector_nmi: int = 0
    vector_hardfault: int = 0

    HEADER_SIZE = 0x120
    PAYLOAD_OFFSET = 0x120

    @property
    def payload_size(self) -> int:
        return self.ec1.data_size

    def extract_payload(self) -> bytes:
        """提取固件 payload (用于 SPI 写入)。"""
        data = self.path.read_bytes()
        return data[self.PAYLOAD_OFFSET : self.PAYLOAD_OFFSET + self.payload_size]


def parse_fl2(path: Path | str) -> FL2Info:
    """解析 FL2 文件。"""
    path = Path(path)
    data = path.read_bytes()
    sha256 = hashlib.sha256(data).hexdigest()

    if len(data) < 0x120:
        raise ValueError(f"文件太小 ({len(data)} bytes), 不是有效的 FL2")

    # _EC1 header (0x00-0x1F)
    ec1 = ECHeader(
        index=1,
        magic=data[0:4],
        total_size=struct.unpack_from("<I", data, 4)[0],
        data_size=struct.unpack_from("<I", data, 8)[0],
        field_0c=struct.unpack_from("<I", data, 0x0C)[0],
        field_10=struct.unpack_from("<I", data, 0x10)[0],
        checksum=struct.unpack_from("<I", data, 0x14)[0],
        offset=0,
    )
    if not ec1.is_valid:
        raise ValueError(f"无效的 _EC1 magic: {ec1.magic!r}")

    # _EC2 header (0x20-0x3F)
    ec2 = ECHeader(
        index=2,
        magic=data[0x20:0x24],
        total_size=struct.unpack_from("<I", data, 0x24)[0],
        data_size=struct.unpack_from("<I", data, 0x28)[0],
        field_0c=struct.unpack_from("<I", data, 0x2C)[0],
        field_10=struct.unpack_from("<I", data, 0x30)[0],
        checksum=struct.unpack_from("<I", data, 0x34)[0],
        offset=0x20,
    )

    # Signature (0x80-0xBF)
    signature = data[0x80:0xC0]

    # Boot Config (0xE0-0x11F)
    bc_raw = data[0xE0:0x120]
    boot_config = BootConfig(
        magic=struct.unpack_from("<I", bc_raw, 0)[0],
        config_word1=struct.unpack_from("<I", bc_raw, 4)[0],
        config_word2=struct.unpack_from("<I", bc_raw, 8)[0],
        entry_word=struct.unpack_from("<I", bc_raw, 0x0C)[0],
        load_base_hint=struct.unpack_from("<I", bc_raw, 0x10)[0],
        code_size_minus1=struct.unpack_from("<I", bc_raw, 0x14)[0],
        code_size=struct.unpack_from("<I", bc_raw, 0x18)[0],
        flags=struct.unpack_from("<I", bc_raw, 0x1C)[0],
        crc_fixed=struct.unpack_from("<I", bc_raw, 0x38)[0],
        crc_version=struct.unpack_from("<I", bc_raw, 0x3C)[0],
        raw=bc_raw,
    )

    # ARM Vector Table @ 0x0120
    sp = struct.unpack_from("<I", data, 0x120)[0]
    reset = struct.unpack_from("<I", data, 0x124)[0]
    nmi = struct.unpack_from("<I", data, 0x128)[0]
    hf = struct.unpack_from("<I", data, 0x12C)[0]

    # Version string (N3Gxx##W pattern)
    version = None
    for m in re.finditer(rb"N3GHT\d{2}W", data):
        version = m.group().decode()
        break

    # PD firmware blobs
    pd_fws: list[PDFirmware] = []
    for m in re.finditer(rb"(N3GP[A-Z]\d{2}W)", data):
        name = m.group().decode()
        fl2_offset = m.start()
        # PD blobs 在名字之前有固定结构; 这里只记录名字位置
        payload_off = fl2_offset - 0x120
        # 避免重复 (索引表中会再次出现)
        if not any(p.name == name and abs(p.offset - fl2_offset) < 0x100 for p in pd_fws):
            pd_fws.append(
                PDFirmware(
                    name=name,
                    offset=fl2_offset,
                    size=14977,  # 从之前分析得知的固定大小
                    payload_offset=payload_off,
                )
            )

    return FL2Info(
        path=path,
        size=len(data),
        sha256=sha256,
        ec1=ec1,
        ec2=ec2,
        signature=signature,
        boot_config=boot_config,
        version=version,
        pd_firmwares=pd_fws,
        vector_sp=sp,
        vector_reset=reset,
        vector_nmi=nmi,
        vector_hardfault=hf,
    )


def compare_fl2(a: FL2Info, b: FL2Info) -> dict[str, object]:
    """比较两个 FL2 文件的差异。"""
    pa = a.extract_payload()
    pb = b.extract_payload()
    min_len = min(len(pa), len(pb))
    diff_bytes = sum(1 for i in range(min_len) if pa[i] != pb[i])

    return {
        "version_a": a.version,
        "version_b": b.version,
        "payload_size_a": len(pa),
        "payload_size_b": len(pb),
        "diff_bytes": diff_bytes,
        "diff_percent": 100 * diff_bytes / min_len if min_len else 0,
        "signature_match": a.signature == b.signature,
        "boot_config_match": a.boot_config.raw == b.boot_config.raw,
        "vectors_match": (a.vector_sp == b.vector_sp and a.vector_reset == b.vector_reset),
    }
