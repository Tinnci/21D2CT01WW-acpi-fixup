"""flashrom 子进程封装层。

处理 CH341A 编程器的探测、读取、写入和验证操作。
解决已知问题:
  - 多芯片匹配时自动选择
  - 读取两次验证一致性
  - 详细日志记录
"""

from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class ChipInfo:
    """探测到的 SPI 芯片信息。"""

    name: str
    size_kb: int
    bus: str = "SPI"
    programmer: str = "ch341a_spi"
    jedec_id: Optional[str] = None

    @property
    def size_bytes(self) -> int:
        return self.size_kb * 1024

    @property
    def size_mb(self) -> float:
        return self.size_kb / 1024

    @property
    def size_mbit(self) -> int:
        return self.size_kb * 8 // 1024

    @property
    def is_1v8(self) -> bool:
        """判断芯片是否为 1.8V 型号 (Winbond JW 后缀)。"""
        name_upper = self.name.upper()
        return "JW" in name_upper or "NW" in name_upper


@dataclass
class FlashResult:
    """flashrom 操作结果。"""

    success: bool
    command: list[str]
    stdout: str
    stderr: str
    returncode: int
    output_file: Optional[Path] = None
    sha256: Optional[str] = None


class FlashromError(Exception):
    """flashrom 操作失败。"""

    def __init__(self, message: str, result: Optional[FlashResult] = None):
        super().__init__(message)
        self.result = result


class Flashrom:
    """flashrom CLI 封装。"""

    # 已知的 1.8V 芯片匹配模式
    KNOWN_1V8_PATTERNS = [
        r"W25Q\d+JW",  # Winbond QPI 1.8V
        r"W25R\d+JW",  # Winbond 1.8V
        r"W25Q\d+.*DTR",  # Winbond DTR (通常 1.8V)
        r"W74M",  # Winbond W74M 系列
        r"W25Q\d+EW",  # Winbond EW 1.8V
    ]

    def __init__(
        self,
        programmer: str = "ch341a_spi",
        chip: Optional[str] = None,
        flashrom_bin: Optional[str] = None,
        use_sudo: bool = True,
        log_dir: Optional[Path] = None,
    ):
        self.programmer = programmer
        self.chip = chip
        self.use_sudo = use_sudo
        self.log_dir = Path(log_dir) if log_dir else None

        if flashrom_bin:
            self.flashrom_bin = flashrom_bin
        else:
            found = shutil.which("flashrom")
            if not found:
                raise FlashromError("flashrom 未找到。请安装: brew install flashrom")
            self.flashrom_bin = found

    def _build_cmd(self, *args: str) -> list[str]:
        cmd = []
        if self.use_sudo and os.geteuid() != 0:
            cmd.append("sudo")
        cmd.append(self.flashrom_bin)
        cmd.extend(["-p", self.programmer])
        if self.chip:
            cmd.extend(["-c", self.chip])
        cmd.extend(args)
        return cmd

    def _run(self, *args: str, timeout: int = 600) -> FlashResult:
        cmd = self._build_cmd(*args)

        try:
            proc = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired as e:
            raise FlashromError(f"flashrom 超时 ({timeout}s): {' '.join(cmd)}") from e
        except FileNotFoundError as e:
            raise FlashromError(f"flashrom 二进制不存在: {self.flashrom_bin}") from e

        result = FlashResult(
            success=proc.returncode == 0,
            command=cmd,
            stdout=proc.stdout,
            stderr=proc.stderr,
            returncode=proc.returncode,
        )

        # 保存日志
        if self.log_dir:
            self.log_dir.mkdir(parents=True, exist_ok=True)
            log_file = self.log_dir / "flashrom_latest.log"
            log_file.write_text(
                f"CMD: {' '.join(cmd)}\n"
                f"RC: {proc.returncode}\n"
                f"--- STDOUT ---\n{proc.stdout}\n"
                f"--- STDERR ---\n{proc.stderr}\n"
            )

        return result

    def probe(self) -> list[ChipInfo]:
        """探测连接的 SPI 芯片，返回所有匹配的芯片定义。"""
        result = self._run()
        combined = result.stdout + result.stderr

        chips: list[ChipInfo] = []
        seen_names: set[str] = set()

        # 解析: Found Winbond flash chip "W25Q256JW" (32768 kB, SPI) on ch341a_spi.
        pattern = re.compile(r'Found\s+\w+\s+flash\s+chip\s+"([^"]+)"\s+\((\d+)\s*kB,\s*(\w+)\)')
        for m in pattern.finditer(combined):
            name = m.group(1)
            if name not in seen_names:
                seen_names.add(name)
                chips.append(
                    ChipInfo(
                        name=name,
                        size_kb=int(m.group(2)),
                        bus=m.group(3),
                        programmer=self.programmer,
                    )
                )

        # 提取 JEDEC ID
        jedec_pattern = re.compile(r"RDID\s+returned\s+0x([0-9a-fA-F\s]+)")
        jedec_match = jedec_pattern.search(combined)
        if jedec_match and chips:
            jedec_id = jedec_match.group(1).strip()
            for chip in chips:
                chip.jedec_id = jedec_id

        return chips

    def read(self, output: Path) -> FlashResult:
        """读取 SPI 闪存到文件。"""
        if not self.chip:
            raise FlashromError("读取需要指定芯片 (-c)。先运行 probe() 确定芯片。")

        output = Path(output)
        output.parent.mkdir(parents=True, exist_ok=True)

        result = self._run("-r", str(output))
        if not result.success:
            raise FlashromError(
                f"读取失败 (rc={result.returncode})",
                result,
            )

        if output.exists():
            sha = hashlib.sha256(output.read_bytes()).hexdigest()
            result.output_file = output
            result.sha256 = sha

        return result

    def read_verified(self, output: Path) -> tuple[FlashResult, FlashResult]:
        """读取两次并验证 SHA256 一致性。返回两次读取结果。"""
        output = Path(output)

        # 第一次读取到临时文件
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False, dir=output.parent) as tmp:
            tmp_path = Path(tmp.name)

        try:
            r1 = self.read(output)
            r2 = self.read(tmp_path)

            if r1.sha256 != r2.sha256:
                # 保存两个文件供调试
                mismatch_path = output.with_suffix(".read2.bin")
                tmp_path.rename(mismatch_path)
                raise FlashromError(
                    f"两次读取 SHA256 不一致！\n"
                    f"  第1次: {r1.sha256}\n"
                    f"  第2次: {r2.sha256}\n"
                    f"SOP 夹接触可能不良，请检查连接后重试。\n"
                    f"两次读取结果已保存:\n"
                    f"  {output}\n"
                    f"  {mismatch_path}"
                )
        finally:
            if tmp_path.exists():
                tmp_path.unlink()

        return r1, r2

    def write(self, image: Path) -> FlashResult:
        """写入镜像到 SPI 闪存 (含自动验证)。"""
        if not self.chip:
            raise FlashromError("写入需要指定芯片 (-c)。")

        image = Path(image)
        if not image.exists():
            raise FlashromError(f"镜像文件不存在: {image}")

        result = self._run("-w", str(image))
        combined = result.stdout + result.stderr

        if "VERIFIED" not in combined:
            raise FlashromError(
                f"写入后验证失败！\n{combined}",
                result,
            )

        result.sha256 = hashlib.sha256(image.read_bytes()).hexdigest()
        return result

    def verify(self, image: Path) -> FlashResult:
        """验证 SPI 闪存内容与镜像一致。"""
        if not self.chip:
            raise FlashromError("验证需要指定芯片 (-c)。")

        image = Path(image)
        if not image.exists():
            raise FlashromError(f"镜像文件不存在: {image}")

        result = self._run("-v", str(image))
        return result

    def check_voltage_warning(self, chip: ChipInfo) -> Optional[str]:
        """检查芯片是否需要 1.8V 适配。返回警告信息或 None。"""
        if chip.is_1v8:
            return (
                f"⚠️  {chip.name} 为 1.8V 芯片！\n"
                f"   CH341A 默认输出 3.3V，过压 ~83%。\n"
                f"   强烈建议使用 1.8V 电平转换适配板。\n"
                f"   上次 3.3V 操作虽然成功，但有损坏风险。"
            )
        return None
