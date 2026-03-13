"""macOS 平台特定处理。

解决已知问题:
  - CH341A 被 macOS USB 串口驱动抢占
  - sudo 权限提升
  - libusb "no capture entitlements" 警告
"""

from __future__ import annotations

import os
import platform
import re
import subprocess
from dataclasses import dataclass
from typing import Optional


@dataclass
class USBDevice:
    """USB 设备信息。"""

    vendor_id: str
    product_id: str
    name: str
    serial: Optional[str] = None
    location: Optional[str] = None


# CH341A USB 标识
CH341A_VID = "0x1a86"
CH341A_PID = "0x5512"


def is_macos() -> bool:
    return platform.system() == "Darwin"


def is_root() -> bool:
    return os.geteuid() == 0


def find_ch341a() -> Optional[USBDevice]:
    """检测 CH341A 编程器是否连接。仅 macOS。"""
    if not is_macos():
        return None

    try:
        output = subprocess.run(
            ["system_profiler", "SPUSBDataType"],
            capture_output=True,
            text=True,
            timeout=10,
        ).stdout
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None

    # 查找 CH341A (VID 1a86, PID 5512)
    # system_profiler 格式:
    #   USB UART-LPT:
    #     Product ID: 0x5512
    #     Vendor ID: 0x1a86
    blocks = output.split("\n\n")
    for block in blocks:
        if "1a86" in block.lower() and "5512" in block.lower():
            name_match = re.search(r"^\s+(.+?):", block, re.MULTILINE)
            name = name_match.group(1).strip() if name_match else "CH341A"

            vid_match = re.search(r"Vendor ID:\s*(0x[0-9a-fA-F]+)", block)
            pid_match = re.search(r"Product ID:\s*(0x[0-9a-fA-F]+)", block)
            serial_match = re.search(r"Serial Number:\s*(.+)", block)
            location_match = re.search(r"Location ID:\s*(0x[0-9a-fA-F]+)", block)

            return USBDevice(
                vendor_id=vid_match.group(1) if vid_match else CH341A_VID,
                product_id=pid_match.group(1) if pid_match else CH341A_PID,
                name=name,
                serial=serial_match.group(1).strip() if serial_match else None,
                location=location_match.group(1) if location_match else None,
            )

    return None


def check_usb_serial_conflict() -> Optional[str]:
    """检查 macOS USB 串口驱动是否可能抢占 CH341A。

    返回警告信息或 None。
    """
    if not is_macos():
        return None

    try:
        output = subprocess.run(
            ["kextstat"],
            capture_output=True,
            text=True,
            timeout=10,
        ).stdout
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None

    # 检查是否加载了 USB 串口驱动
    serial_drivers = [
        "com.apple.driver.usb.serial",
        "com.apple.driver.AppleUSBCHCOM",
        "com.wch.usbserial",
    ]

    loaded = [d for d in serial_drivers if d in output]
    if loaded:
        return (
            f"⚠️  检测到已加载的 USB 串口驱动: {', '.join(loaded)}\n"
            f"   这些驱动可能抢占 CH341A 的 USB 接口。\n"
            f"   如果 flashrom 无法连接 CH341A:\n"
            f"   1. 拔出 CH341A\n"
            f"   2. 等待 5 秒\n"
            f"   3. 重新插入 CH341A\n"
            f"   4. 立即运行 flashrom (在驱动再次抢占之前)"
        )
    return None


def check_prerequisites() -> list[str]:
    """检查 macOS 上运行 flashrom 的所有前置条件。返回问题列表。"""
    issues: list[str] = []

    if not is_macos():
        return issues

    # 1. 检查 flashrom 安装
    import shutil

    if not shutil.which("flashrom"):
        issues.append("flashrom 未安装。运行: brew install flashrom")

    # 2. 检查 CH341A 连接
    device = find_ch341a()
    if not device:
        issues.append("CH341A 编程器未检测到。请检查 USB 连接。")

    # 3. 检查 USB 串口驱动冲突
    conflict = check_usb_serial_conflict()
    if conflict:
        issues.append(conflict)

    # 4. 检查 sudo 权限
    if not is_root():
        issues.append("需要 root 权限。flashrom 操作会自动调用 sudo。\n   确保当前用户在 sudoers 中。")

    return issues


def request_sudo_password() -> bool:
    """预先请求 sudo 权限以避免后续操作中断。

    返回 True 如果获得权限。
    """
    if is_root():
        return True

    try:
        result = subprocess.run(
            ["sudo", "-v"],
            timeout=60,
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False
