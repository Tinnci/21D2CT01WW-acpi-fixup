#!/usr/bin/env python3
"""CH341A SPI Flash helper — read, verify, write via flashrom on macOS."""

import subprocess
import sys
import hashlib
from pathlib import Path
from datetime import datetime

CHIP = "W25Q256JW"
PROGRAMMER = "ch341a_spi"
BUILD_DIR = Path(__file__).resolve().parent.parent / "build"
BACKUP_FILE = BUILD_DIR / "fresh_backup_preflash_20260310.bin"
EXPECTED_SIZE = 32 * 1024 * 1024  # 32 MB for W25Q256JW


def sha256(filepath: Path) -> str:
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def run_flashrom(*args: str) -> subprocess.CompletedProcess:
    cmd = ["flashrom", "-p", PROGRAMMER, "-c", CHIP, *args]
    print(f">>> {' '.join(cmd)}")
    return subprocess.run(cmd, capture_output=True, text=True)


def probe():
    """Probe the SPI chip to verify CH341A connection."""
    print("=== 探测 SPI 芯片 ===")
    r = run_flashrom()
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
        sys.exit(1)
    print("芯片探测成功！")


def read_flash(output: str | None = None):
    """Read full SPI flash contents."""
    if output is None:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        output = str(BUILD_DIR / f"spi_ch341a_read_{ts}.bin")
    out_path = Path(output)
    print(f"=== 读取 SPI 闪存 → {out_path.name} ===")
    r = run_flashrom("-r", str(out_path))
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
        sys.exit(1)
    size = out_path.stat().st_size
    print(f"读取完成: {size} bytes ({size // 1024 // 1024} MB)")
    print(f"SHA256: {sha256(out_path)}")
    if size != EXPECTED_SIZE:
        print(f"警告: 预期 {EXPECTED_SIZE} bytes, 实际 {size} bytes!")
    return out_path


def verify(image: str | None = None):
    """Verify SPI flash against an image file."""
    img = Path(image) if image else BACKUP_FILE
    if not img.exists():
        print(f"错误: 文件不存在: {img}")
        sys.exit(1)
    print(f"=== 验证 SPI 闪存 vs {img.name} ===")
    r = run_flashrom("-v", str(img))
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
        print("验证失败!")
        return False
    print("验证通过!")
    return True


def write_flash(image: str | None = None):
    """Write an image to SPI flash with safety checks."""
    img = Path(image) if image else BACKUP_FILE
    if not img.exists():
        print(f"错误: 文件不存在: {img}")
        sys.exit(1)
    size = img.stat().st_size
    if size != EXPECTED_SIZE:
        print(f"错误: 固件大小 {size} bytes 不等于预期 {EXPECTED_SIZE} bytes!")
        sys.exit(1)

    print(f"=== 即将写入 SPI 闪存 ===")
    print(f"  固件文件: {img.name}")
    print(f"  大小: {size // 1024 // 1024} MB")
    print(f"  SHA256: {sha256(img)}")
    print()

    confirm = input("确认写入? 这将覆盖SPI闪存全部内容! (输入 YES 确认): ")
    if confirm != "YES":
        print("已取消。")
        return

    # Step 1: 先做一次当前内容的备份读取
    print("\n--- 步骤 1/3: 写入前备份当前SPI内容 ---")
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    pre_backup = BUILD_DIR / f"spi_pre_write_backup_{ts}.bin"
    r = run_flashrom("-r", str(pre_backup))
    if r.returncode != 0:
        print("备份读取失败，中止写入。")
        print(r.stderr)
        sys.exit(1)
    print(f"备份已保存: {pre_backup.name}")

    # Step 2: 写入
    print("\n--- 步骤 2/3: 写入固件 ---")
    r = run_flashrom("-w", str(img))
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
        print("写入可能失败! 请检查输出。")
        sys.exit(1)

    # Step 3: 验证
    print("\n--- 步骤 3/3: 验证写入 ---")
    r = run_flashrom("-v", str(img))
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
        print("验证失败! SPI内容可能不正确。")
        sys.exit(1)
    print("写入并验证成功!")


def info():
    """Show available firmware images and their hashes."""
    print("=== 可用固件文件 ===")
    for f in sorted(BUILD_DIR.glob("*.bin")):
        size = f.stat().st_size
        h = sha256(f)
        marker = " <-- 原始备份" if "fresh_backup" in f.name else ""
        print(f"  {f.name}  ({size // 1024 // 1024} MB)  {h[:16]}...{marker}")


if __name__ == "__main__":
    cmds = {
        "probe": probe,
        "read": read_flash,
        "verify": verify,
        "write": write_flash,
        "info": info,
    }
    if len(sys.argv) < 2 or sys.argv[1] not in cmds:
        print(f"用法: {sys.argv[0]} <{'|'.join(cmds.keys())}> [image.bin]")
        print()
        print("  probe  — 探测CH341A连接的SPI芯片")
        print("  read   — 读取SPI闪存内容（保存到 build/）")
        print("  verify — 验证SPI内容与镜像文件一致")
        print("  write  — 写入固件到SPI闪存（带安全检查）")
        print("  info   — 显示可用固件文件信息")
        sys.exit(1)

    cmd = sys.argv[1]
    arg = sys.argv[2] if len(sys.argv) > 2 else None
    if arg:
        cmds[cmd](arg)
    else:
        cmds[cmd]()
