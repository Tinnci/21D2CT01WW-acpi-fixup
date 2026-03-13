"""spiflash CLI — ThinkPad Z13 SPI Flash 管理工具."""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path
from typing import Callable


def cmd_check(args: argparse.Namespace) -> int:
    from .macos import check_prerequisites, find_ch341a, is_macos
    import shutil

    print("=== 环境检查 ===")
    print(f"平台: {'macOS' if is_macos() else sys.platform}")

    if is_macos():
        device = find_ch341a()
        if device:
            print(f"CH341A: 已连接 ({device.name})")
        else:
            print("CH341A: 未检测到")

    fr = shutil.which("flashrom")
    print(f"flashrom: {fr}" if fr else "flashrom: 未安装 (brew install flashrom)")

    issues = check_prerequisites() if is_macos() else []
    if issues:
        print(f"\n发现 {len(issues)} 个问题:")
        for i, issue in enumerate(issues, 1):
            print(f"  {i}. {issue}")
        return 1

    print("\n所有检查通过")
    return 0


def cmd_probe(args: argparse.Namespace) -> int:
    from .flashrom import Flashrom

    fr = Flashrom(use_sudo=not args.no_sudo)
    print("探测 SPI 芯片...\n")

    chips = fr.probe()
    if not chips:
        print("未检测到 SPI 芯片。检查 SOP 夹连接和 CH341A USB 状态。")
        return 1

    for i, chip in enumerate(chips, 1):
        print(f"  [{i}] {chip.name}")
        print(f"      容量: {chip.size_kb} KB ({chip.size_mb:.0f} MB, {chip.size_mbit} Mbit)")
        if chip.jedec_id:
            print(f"      JEDEC: {chip.jedec_id}")
        warning = fr.check_voltage_warning(chip)
        if warning:
            print(f"\n{warning}")

    if len(chips) > 1:
        print(f"\n提示: 探测到 {len(chips)} 个匹配。使用 --chip 指定。")
    return 0


def cmd_read(args: argparse.Namespace) -> int:
    from .backup import BackupRegistry
    from .flashrom import ChipInfo, Flashrom, FlashromError

    output = Path(args.output)
    chip = args.chip
    target = args.target or "unknown"

    if not chip:
        print("错误: 读取需要 --chip 参数。先运行 probe 确定芯片。")
        return 1

    fr = Flashrom(chip=chip, use_sudo=not args.no_sudo)
    info = ChipInfo(name=chip, size_kb=0)
    warning = fr.check_voltage_warning(info)
    if warning:
        print(warning)
        if not args.force:
            resp = input("\n继续? (y/N) ").strip().lower()
            if resp != "y":
                return 1

    print(f"读取 SPI (芯片: {chip})...\n")
    try:
        r1, r2 = fr.read_verified(output)
    except FlashromError as e:
        print(f"读取失败: {e}")
        return 1

    print("读取完成")
    print(f"  文件: {output}")
    print(f"  大小: {output.stat().st_size} bytes")
    print(f"  SHA256: {r1.sha256}")
    print("  验证: 两次读取一致")

    registry = BackupRegistry.load(output.parent)
    registry.add(output, chip=chip, target=target)
    registry.save(output.parent)
    print("  已注册到备份历史")
    return 0


def cmd_write(args: argparse.Namespace) -> int:
    from .backup import BackupRegistry
    from .flashrom import ChipInfo, Flashrom, FlashromError

    image = Path(args.image)
    chip = args.chip

    if not chip:
        print("错误: 写入需要 --chip 参数。")
        return 1
    if not image.exists():
        print(f"错误: 镜像文件不存在: {image}")
        return 1

    fr = Flashrom(chip=chip, use_sudo=not args.no_sudo)

    print("=== 写入安全检查 ===\n")
    warning = fr.check_voltage_warning(ChipInfo(name=chip, size_kb=0))
    if warning:
        print(f"{warning}\n")

    image_data = image.read_bytes()
    sha = hashlib.sha256(image_data).hexdigest()
    print(f"镜像: {image}")
    print(f"  大小: {len(image_data)} bytes")
    print(f"  SHA256: {sha}")

    registry = BackupRegistry.load(Path("firmware/spi_dump"))
    latest = registry.latest()
    if latest:
        print(f"\n最近的备份: {latest.filename} ({latest.timestamp})")
    elif not args.force:
        print("\n未找到备份记录！强烈建议先备份。")
        if input("确认继续? (输入 YES) ").strip() != "YES":
            return 1

    if not args.force:
        print(f"\n即将写入 {len(image_data)} bytes! 芯片: {chip}")
        if input("确认写入? (输入 WRITE) ").strip() != "WRITE":
            return 1

    print("\n写入中...")
    try:
        fr.write(image)
    except FlashromError as e:
        print(f"\n写入失败: {e}")
        return 1

    print("写入完成并已验证 (VERIFIED)")
    return 0


def cmd_analyze(args: argparse.Namespace) -> int:
    from .spi_map import analyze_spi_dump, format_analysis

    dump_path = Path(args.dump)
    if not dump_path.exists():
        print(f"错误: 文件不存在: {dump_path}")
        return 1

    fl2_dir = Path(args.fl2_dir) if args.fl2_dir else Path("firmware/ec")
    fl2_files: list[Path | str] = sorted(fl2_dir.glob("*.FL2")) if fl2_dir.is_dir() else []
    print(format_analysis(analyze_spi_dump(dump_path, fl2_files or None)))
    return 0


def cmd_fl2(args: argparse.Namespace) -> int:
    from .fl2 import compare_fl2, parse_fl2

    paths = [Path(p) for p in args.files]
    infos = []
    for path in paths:
        if not path.exists():
            print(f"错误: 不存在: {path}")
            return 1
        info = parse_fl2(path)
        infos.append(info)
        nz = sum(1 for b in info.signature if b)
        print(f"=== {path.name} ===")
        print(f"  大小: {info.size} bytes  SHA256: {info.sha256}")
        ver = info.version or "未知"
        print(f"  版本: {ver}")
        print(f"  _EC1: total={info.ec1.total_size}, data={info.ec1.data_size}")
        print(f"  _EC2: total={info.ec2.total_size}, data={info.ec2.data_size}")
        print(f"  签名: {nz}/64 non-zero  向量表: SP=0x{info.vector_sp:08X} Reset=0x{info.vector_reset:08X}")
        print(f"  Boot Config: code_size={info.boot_config.code_size} ({info.boot_config.estimated_code_kb}KB)")
        for pd in info.pd_firmwares:
            print(f"  PD: {pd.name} @ 0x{pd.offset:06X}")
        print()

    if len(infos) >= 2:
        diff = compare_fl2(infos[0], infos[1])
        v0 = infos[0].version
        v1 = infos[1].version
        print(f"=== 比较 {v0} vs {v1} ===")
        db = diff["diff_bytes"]
        sa = diff["payload_size_a"]
        dp = diff["diff_percent"]
        print(f"  差异: {db}/{sa} ({dp:.1f}%)")
        print(f"  签名匹配: {diff['signature_match']}")
        print(f"  Boot Config 匹配: {diff['boot_config_match']}")
        print(f"  向量表匹配: {diff['vectors_match']}")
    return 0


def cmd_extract(args: argparse.Namespace) -> int:
    from .fl2 import parse_fl2

    fl2_path = Path(args.fl2)
    output = Path(args.output) if args.output else fl2_path.with_suffix(".payload.bin")
    if not fl2_path.exists():
        print(f"错误: 不存在: {fl2_path}")
        return 1

    info = parse_fl2(fl2_path)
    payload = info.extract_payload()
    output.write_bytes(payload)
    sha = hashlib.sha256(payload).hexdigest()
    print(f"Payload 已提取: {fl2_path.name} ({info.version})")
    print(f"  输出: {output}  大小: {len(payload)} bytes  SHA256: {sha}")
    print("提示: 假设 FL2[0x120:] -> SPI[0x0:]，请先用 analyze 验证。")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="spiflash",
        description="ThinkPad Z13 SPI Flash 管理工具",
    )
    parser.add_argument("--no-sudo", action="store_true", help="不使用 sudo")
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("check", help="检查环境")
    sub.add_parser("probe", help="探测 SPI 芯片")

    p = sub.add_parser("read", help="读取 SPI flash (双重验证)")
    p.add_argument("output")
    p.add_argument("--chip", "-c")
    p.add_argument("--target", "-t", choices=["main_spi", "ec_spi"])
    p.add_argument("--force", "-f", action="store_true")

    p = sub.add_parser("write", help="写入 SPI flash")
    p.add_argument("image")
    p.add_argument("--chip", "-c")
    p.add_argument("--force", "-f", action="store_true")

    p = sub.add_parser("analyze", help="分析 SPI dump")
    p.add_argument("dump")
    p.add_argument("--fl2-dir")

    p = sub.add_parser("fl2", help="解析 FL2 文件")
    p.add_argument("files", nargs="+")

    p = sub.add_parser("extract", help="从 FL2 提取 SPI payload")
    p.add_argument("fl2")
    p.add_argument("-o", "--output")

    args = parser.parse_args(argv)
    if not args.command:
        parser.print_help()
        return 0

    cmds: dict[str, Callable[[argparse.Namespace], int]] = {
        "check": cmd_check,
        "probe": cmd_probe,
        "read": cmd_read,
        "write": cmd_write,
        "analyze": cmd_analyze,
        "fl2": cmd_fl2,
        "extract": cmd_extract,
    }
    return cmds[args.command](args)
