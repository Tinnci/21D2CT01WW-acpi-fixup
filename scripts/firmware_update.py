#!/usr/bin/env python3
"""
firmware_update.py — 交互式固件更新脚本
用于 ThinkPad Z13 Gen 1 21D2CT01WW（工程样机）

功能：
  1. 显示当前 BIOS / EC 版本与待更新版本
  2. 检查 fwupd 更新队列状态
  3. 可选：使用本地 CAB 文件重新安排更新
  4. 可选：触发重启并应用更新
  5. 重启后验证更新结果（检查 PD 控制器状态）

用法：
  python3 scripts/firmware_update.py           # 交互式菜单
  python3 scripts/firmware_update.py --status  # 只查看状态
  python3 scripts/firmware_update.py --verify  # 重启后验证

注意：
  - 安装更新至 NVRAM 不需要 root（fwupd 已有 polkit 权限）
  - 重启命令需要 root（或用户主动执行）
  - 所有硬件修改操作均有确认提示
"""

import sys
import subprocess
import shutil
import os
from pathlib import Path

# ─── 配置 ─────────────────────────────────────────────────────────────────────

# 项目根目录（脚本位于 scripts/ 下）
PROJECT_ROOT = Path(__file__).parent.parent

# 本地 CAB 文件（可手动覆盖 fwupd 队列）
CAB_DIR = PROJECT_ROOT / "build"

# 已知设备 GUID
DEVICE_BIOS_GUID    = "66d47c53-a746-4495-a444-e6b26a04906d"  # System Firmware
DEVICE_EC_GUID      = "4bea12df-56e3-4cdb-97dd-f133768c9051"  # Embedded Controller
DEVICE_EC_ALT_GUIDS = [
    "88440680-8493-43d8-b1cb-51992223a226",
    "f5536e63-e4c0-4e0d-84d4-e8e152b1ba65",
    "f766f6e6-b43d-4acd-a4bd-80ff2f0af5cc",
]

# 期望的版本（更新成功后）
EXPECTED_BIOS_VER = "0.1.76"
EXPECTED_EC_VER   = "0.1.67"

# Microchip PD DFU 设备（更新成功后应消失）
PD_DFU_VID_PID = "04d8:0039"

# ─── 颜色辅助 ─────────────────────────────────────────────────────────────────

_USE_COLOR = sys.stdout.isatty()

def colored(text: str, code: str) -> str:
    if not _USE_COLOR:
        return text
    return f"\033[{code}m{text}\033[0m"

OK    = lambda s: colored(s, "32")   # 绿
WARN  = lambda s: colored(s, "33")   # 黄
ERR   = lambda s: colored(s, "31")   # 红
BOLD  = lambda s: colored(s, "1")    # 粗体
DIM   = lambda s: colored(s, "2")    # 暗色
INFO  = lambda s: colored(s, "36")   # 青色

def hr(char="─", width=60):
    print(char * width)

# ─── 子命令执行 ───────────────────────────────────────────────────────────────

def run(cmd: list, capture=True, timeout=30) -> tuple[int, str, str]:
    """运行命令，返回 (returncode, stdout, stderr)"""
    try:
        r = subprocess.run(cmd, capture_output=capture, text=True, timeout=timeout)
        return r.returncode, r.stdout.strip(), r.stderr.strip()
    except subprocess.TimeoutExpired:
        return -1, "", "命令超时"
    except FileNotFoundError:
        return -1, "", f"命令未找到: {cmd[0]}"
    except Exception as e:
        return -1, "", str(e)

def check_dep(name: str) -> bool:
    return shutil.which(name) is not None

# ─── 状态检查 ─────────────────────────────────────────────────────────────────

def get_fwupd_devices() -> dict:
    """解析 fwupdmgr get-devices 输出，返回设备信息字典"""
    rc, out, _ = run(["fwupdmgr", "get-devices"])
    if rc != 0:
        return {}
    
    devices = {}
    current_dev = None
    for line in out.splitlines():
        line = line.strip()
        # 设备名行（不含冒号的粗体行）
        if line.endswith(":") and "." not in line and "│" not in line:
            current_dev = line.rstrip(":")
            devices[current_dev] = {}
        elif current_dev and ":" in line and not line.startswith("│") and not line.startswith("└"):
            key, _, val = line.partition(":")
            key = key.strip().strip("│└─├").strip()
            val = val.strip()
            if key and val:
                devices[current_dev][key] = val
    return devices

def get_fwupd_history() -> list[dict]:
    """解析 fwupdmgr get-history，提取待重启的更新"""
    rc, out, _ = run(["fwupdmgr", "get-history"])
    if rc != 0 or "需要重启" not in out and "pending" not in out.lower():
        return []
    
    pending = []
    lines = out.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].strip().strip("│├└─").strip()
        if "更新状态" in line and "需要重启" in line:
            # 回溯找设备名
            for j in range(i, max(i-20, 0), -1):
                prev = lines[j].strip().strip("│├└─").strip()
                if prev.endswith(":") and "." not in prev:
                    dev_name = prev.rstrip(":")
                    break
            else:
                dev_name = "未知设备"
            
            # 向前找版本信息
            old_ver = new_ver = guid = ""
            for j in range(max(i-5, 0), min(i+15, len(lines))):
                l = lines[j].strip().strip("│├└─").strip()
                if "上个版本" in l:
                    old_ver = l.split(":")[-1].strip()
                if "新版本" in l:
                    new_ver = l.split(":")[-1].strip()
                if "GUID" in l and not guid:
                    guid = l.split(":")[-1].strip()
            
            pending.append({
                "device": dev_name,
                "old_version": old_ver,
                "new_version": new_ver,
                "guid": guid,
            })
        i += 1
    return pending

def check_pd_dfu() -> dict | None:
    """检查 Microchip PD DFU 设备是否存在"""
    rc, out, _ = run(["lsusb"])
    if rc != 0:
        return None
    for line in out.splitlines():
        if PD_DFU_VID_PID in line or "04d8" in line.lower():
            if "0039" in line:
                return {"found": True, "line": line.strip()}
    return {"found": False, "line": ""}

def get_current_versions() -> dict:
    """从 fwupdmgr get-devices 获取当前版本"""
    rc, out, _ = run(["fwupdmgr", "get-devices"])
    versions = {"bios": "未知", "ec": "未知"}
    if rc != 0:
        return versions
    
    lines = out.splitlines()
    in_bios = in_ec = False
    for i, line in enumerate(lines):
        stripped = line.strip().strip("│├└─").strip()
        if "System Firmware" in line:
            in_bios = True; in_ec = False
        elif "Embedded Controller" in line:
            in_ec = True; in_bios = False
        elif stripped.endswith(":") and stripped not in ("", "设备标志:", "Device Requests:"):
            in_bios = in_ec = False
        
        if "当前版本" in stripped:
            ver = stripped.split(":")[-1].strip()
            if in_bios:
                versions["bios"] = ver
            elif in_ec:
                versions["ec"] = ver
    
    return versions

# ─── 显示功能 ─────────────────────────────────────────────────────────────────

def show_banner():
    hr("═")
    print(BOLD("  ThinkPad Z13 Gen 1 21D2CT01WW — 固件更新交互工具"))
    print(DIM("  fwupd + Microchip PD DFU 状态管理"))
    hr("═")
    print()

def show_status():
    """显示完整状态概览"""
    print(BOLD("● 当前固件版本"))
    hr()
    
    versions = get_current_versions()
    bios_ok = versions["bios"] >= EXPECTED_BIOS_VER if versions["bios"] != "未知" else False
    ec_ok   = versions["ec"]   >= EXPECTED_EC_VER   if versions["ec"]   != "未知" else False
    
    bios_icon = OK("✔") if bios_ok else WARN("⚠")
    ec_icon   = OK("✔") if ec_ok   else WARN("⚠")
    
    print(f"  {bios_icon} BIOS (System Firmware)   当前: {BOLD(versions['bios']):20s} 目标: {EXPECTED_BIOS_VER}")
    print(f"  {ec_icon} EC   (Embedded Controller) 当前: {BOLD(versions['ec']):20s} 目标: {EXPECTED_EC_VER}")
    print()
    
    # fwupd 待更新队列
    print(BOLD("● fwupd 更新队列"))
    hr()
    pending = get_fwupd_history()
    if pending:
        for item in pending:
            dev_str = BOLD(item['device'])
            ver_str = f"{WARN(item['old_version'])} → {OK(item['new_version'])}"
            print(f"  ⟳ {dev_str}: {ver_str}")
            if item['guid']:
                print(f"    GUID: {DIM(item['guid'])}")
        print()
        print(WARN("  ⚠ 以上更新已安排，等待重启生效"))
    else:
        print(f"  {OK('✔')} 没有待重启的更新")
    print()
    
    # PD DFU 设备
    print(BOLD("● Microchip PD DFU 设备 (04d8:0039)"))
    hr()
    pd_info = check_pd_dfu()
    if pd_info is None:
        print(f"  {WARN('?')} lsusb 命令失败，无法检查 PD 设备")
    elif pd_info["found"]:
        print(f"  {WARN('⚠')} PD DFU 设备仍然存在（EC 尚未初始化 PD 芯片）")
        print(f"    {DIM(pd_info['line'])}")
        print(f"    → 重启并应用 EC 0.1.67 后，此设备预计消失")
    else:
        print(f"  {OK('✔')} PD DFU 设备未检测到（EC 已正常初始化 PD 芯片）")
    print()
    
    # 本地 CAB 文件
    print(BOLD("● 本地 CAB 文件"))
    hr()
    cabs = list(CAB_DIR.glob("*.cab"))
    if cabs:
        for cab in sorted(cabs):
            size_kb = cab.stat().st_size // 1024
            print(f"  📦 {cab.name} ({size_kb} KB)")
    else:
        print(f"  {DIM('  无本地 CAB 文件')}")
    print()
    
    return versions, pending, pd_info

# ─── 操作功能 ─────────────────────────────────────────────────────────────────

def install_cab(cab_path: Path, target_guid: str) -> bool:
    """使用 fwupdmgr install 安装本地 CAB"""
    print(f"\n正在安装: {cab_path.name}")
    print(f"目标 GUID: {target_guid}")
    print(WARN("\n⚠ 此操作将修改 NVRAM/EC 固件更新队列"))
    
    confirm = input("确认安装？(y/N) > ").strip().lower()
    if confirm != "y":
        print(DIM("已取消"))
        return False
    
    cmd = ["fwupdmgr", "install", "--allow-reinstall", "--allow-older",
           str(cab_path), target_guid]
    print(f"\n执行: {' '.join(cmd)}")
    rc, out, err = run(cmd, capture=False, timeout=120)
    
    if rc == 0:
        print(OK("\n✔ 安装命令成功"))
        return True
    else:
        print(ERR(f"\n✘ 安装失败 (rc={rc})"))
        if err:
            print(DIM(f"  错误: {err[:200]}"))
        return False

def schedule_reboot():
    """询问是否立即重启"""
    print()
    hr()
    print(BOLD("重启确认"))
    hr()
    print(WARN("⚠ 重启后 fwupd 将自动应用以下更新："))
    print(f"  • BIOS: → {EXPECTED_BIOS_VER}")
    print(f"  • EC  : → {EXPECTED_EC_VER}")
    print()
    print("建议：确保已保存所有工作，连接电源适配器")
    print()
    choice = input("现在重启？[y=立即重启 / n=取消 / s=30秒后重启] > ").strip().lower()
    
    if choice == "y":
        print(WARN("\n3 秒后重启..."))
        import time; time.sleep(3)
        rc, _, err = run(["sudo", "reboot"], capture=False, timeout=10)
        if rc != 0:
            print(ERR(f"重启失败: {err}"))
            print(DIM("手动执行: sudo reboot"))
    elif choice == "s":
        print(WARN("\n30 秒后重启... (Ctrl+C 取消)"))
        rc, _, _ = run(["sudo", "shutdown", "-r", "+0", "固件更新"], capture=False, timeout=10)
        if rc != 0:
            print(ERR("重启命令失败，请手动执行: sudo reboot"))
    else:
        print(DIM("已取消重启。请稍后手动执行 sudo reboot 以应用更新"))

def post_reboot_verify():
    """重启后验证更新结果"""
    print(BOLD("\n● 重启后验证"))
    hr()
    
    versions = get_current_versions()
    
    bios_ok = versions["bios"] == EXPECTED_BIOS_VER
    ec_ok   = versions["ec"]   == EXPECTED_EC_VER
    
    bios_icon = OK("✔ 成功") if bios_ok else ERR("✘ 失败")
    ec_icon   = OK("✔ 成功") if ec_ok   else ERR("✘ 失败")
    
    print(f"  BIOS: {versions['bios']:10s} (期望 {EXPECTED_BIOS_VER}) — {bios_icon}")
    print(f"  EC  : {versions['ec']:10s} (期望 {EXPECTED_EC_VER})  — {ec_icon}")
    print()
    
    # PD DFU 验证
    pd_info = check_pd_dfu()
    if pd_info and not pd_info["found"]:
        print(OK("  ✔ PD DFU 设备 (04d8:0039) 已消失 → EC 成功初始化 PD 芯片！"))
        print(BOLD("    USB-C 功能预计已恢复"))
    elif pd_info and pd_info["found"]:
        print(WARN("  ⚠ PD DFU 设备仍然存在"))
        print("    可能原因:")
        print("    1. EC 更新未成功应用（检查 fwupdmgr get-history）")
        print("    2. 工程版 EC 硬件与量产 EC 初始化流程不兼容")
        print("    3. 需要通过 DFU 手动写入 PD 固件（参见 docs/pd_controller_analysis_20260313.md）")
    
    print()
    
    # fwupd 历史
    rc, out, _ = run(["fwupdmgr", "get-history"])
    if "success" in out.lower() or "成功" in out:
        print(OK("  ✔ fwupdmgr get-history 显示更新成功"))
    else:
        print(DIM("  → 运行 fwupdmgr get-history 查看详细历史"))
    
    print()
    # 汇总
    all_ok = bios_ok and ec_ok and pd_info is not None and not pd_info.get("found", True)
    if all_ok:
        print(OK("  ✔✔✔ 所有检查通过！固件更新完全成功"))
    else:
        print(WARN("  部分检查未通过，请查看上方详情"))
    
    return bios_ok and ec_ok

def menu_install_local_cab():
    """子菜单：安装本地 CAB"""
    cabs = sorted(CAB_DIR.glob("*.cab"))
    if not cabs:
        print(ERR("  build/ 目录下没有 CAB 文件"))
        return
    
    print(BOLD("\n选择要安装的 CAB 文件："))
    hr()
    for i, cab in enumerate(cabs, 1):
        size_kb = cab.stat().st_size // 1024
        print(f"  {i}. {cab.name} ({size_kb} KB)")
    print(f"  0. 返回")
    
    try:
        choice = int(input("\n选择 > ").strip())
    except ValueError:
        print(DIM("无效输入"))
        return
    
    if choice == 0:
        return
    if not (1 <= choice <= len(cabs)):
        print(DIM("超出范围"))
        return
    
    cab = cabs[choice - 1]
    
    # 根据 CAB 名推断 GUID
    guids = [DEVICE_EC_GUID] + DEVICE_EC_ALT_GUIDS
    if "N3GET76W" in cab.name or "EC" not in cab.name.upper():
        # BIOS CAB
        guids = [DEVICE_BIOS_GUID]
    
    print(f"\n可用 GUID：")
    for i, g in enumerate(guids, 1):
        tag = " ← 推荐" if i == 1 else ""
        print(f"  {i}. {g}{tag}")
    
    try:
        gchoice = int(input("\n选择 GUID (默认 1) > ").strip() or "1")
        if 1 <= gchoice <= len(guids):
            target_guid = guids[gchoice - 1]
        else:
            target_guid = guids[0]
    except ValueError:
        target_guid = guids[0]
    
    install_cab(cab, target_guid)

# ─── 主菜单 ───────────────────────────────────────────────────────────────────

def main_menu():
    while True:
        show_banner()
        versions, pending, pd_info = show_status()
        
        hr("─")
        print(BOLD("操作菜单"))
        hr("─")
        print("  1. 刷新并查看状态")
        print("  2. 安装本地 CAB 文件（重新安排更新）")
        print()
        if pending:
            print(WARN("  3. 重启并应用已排队的更新 ← 推荐"))
        else:
            print(DIM("  3. 重启（无待更新项）"))
        print()
        print("  4. 重启后验证（更新完成后运行）")
        print("  5. 查看 fwupd 完整历史")
        print("  0. 退出")
        hr("─")
        
        try:
            choice = input("选择 > ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\n" + DIM("退出"))
            break
        
        if choice == "0":
            break
        elif choice == "1":
            continue  # 循环会自动刷新
        elif choice == "2":
            menu_install_local_cab()
            input("\n按 Enter 继续...")
        elif choice == "3":
            schedule_reboot()
            input("\n按 Enter 继续...")
        elif choice == "4":
            post_reboot_verify()
            input("\n按 Enter 继续...")
        elif choice == "5":
            rc, out, _ = run(["fwupdmgr", "get-history"], capture=True)
            print(out)
            input("\n按 Enter 继续...")
        else:
            print(DIM("无效选项"))
        
        print()

# ─── 入口 ─────────────────────────────────────────────────────────────────────

def main():
    # 检查依赖
    if not check_dep("fwupdmgr"):
        print(ERR("错误：未找到 fwupdmgr，请安装 fwupd"))
        sys.exit(1)
    
    # 解析命令行参数
    args = sys.argv[1:]
    
    if "--status" in args:
        show_banner()
        show_status()
    elif "--verify" in args:
        show_banner()
        post_reboot_verify()
    elif "--no-menu" in args:
        # 非交互模式：只输出状态 JSON
        import json
        versions = get_current_versions()
        pd_info = check_pd_dfu()
        pending = get_fwupd_history()
        data = {
            "versions": versions,
            "pending_updates": pending,
            "pd_dfu_present": pd_info.get("found", None) if pd_info else None,
            "update_needed": versions["bios"] < EXPECTED_BIOS_VER or versions["ec"] < EXPECTED_EC_VER,
        }
        print(json.dumps(data, ensure_ascii=False, indent=2))
    else:
        main_menu()

if __name__ == "__main__":
    main()
