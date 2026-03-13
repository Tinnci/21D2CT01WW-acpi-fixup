# ThinkPad Z13 Gen 1 — ACPI 修复项目

**设备**: Lenovo ThinkPad Z13 Gen 1 (AMD Ryzen)  
**系统**: CachyOS x86_64 (Arch Linux), KDE Plasma  
**创建日期**: 2026-01-06  
**当前部署版本**: DSDT v0xF5 (`dsdt_v3_usb_fix`)

---

## 已修复的问题

| # | 问题 | 修复版本 | 状态 |
|---|------|---------|------|
| 1 | 风扇控制 (`thinkpad_acpi.fan_control=1`) | 内核参数 | ✅ |
| 2 | Lid 盖子传感器不工作 | v0xF4 (v2) | ✅ |
| 3 | USB 3.0 降级为 USB 2.0 | v0xF5 (v3) | ✅ |
| 4 | USB-C 视频输出不可用 | v0xF5 (v3) | ✅ |

## 已知限制（工程 BIOS）

| # | 问题 | 原因 | 修复方案 |
|---|------|------|---------|
| 5 | USB-C Hub 降级为 USB 2.0 | BIOS 缺少 UcsiDriver + USB4 NHI 未枚举 | 需升级量产 BIOS |
| 6 | USB4/Thunderbolt 完全不可用 | 工程 BIOS AGESA 未初始化 USB4 | 需升级量产 BIOS |
| 7 | 指纹读取器频繁重置 | USB autosuspend 相关 | 待排查 |

> 详细分析见 [docs/usb4_analysis.md](docs/usb4_analysis.md)（含第 13 节：生产 BIOS 对比）
>
> 文件时间线与结构清单见 [docs/project_inventory.md](docs/project_inventory.md)
>
> EC SPI 实操前请先阅读 [docs/ec_spi_operation_guide.md](docs/ec_spi_operation_guide.md)

---

## 项目结构

```
acpi-fixup/
├── README.md                 ← 本文件
├── pyproject.toml            ← Python 打包与 Ruff 配置
├── pixi.toml                 ← pixi 环境与任务定义
├── docs/                     ← 文档
│   ├── acpi_fixes_complete.md      修复报告（整合版）
│   ├── file_date_audit_20260313.md 文件日期审计与结构整理
│   ├── project_inventory.md        文件时间线与结构清单
│   ├── usb4_analysis.md            USB4/USB-C 降级根因分析
│   ├── QUICK_REFERENCE.txt         快速参考卡（验证命令）
│   ├── ec_spi_operation_guide.md   EC/SPI 操作指南
│   └── thinkfan-setup-notes.md     ThinkFan 风扇配置
├── dsdt/                     ← DSDT 源码（按版本演进）
│   ├── dsdt_safe_audio_base.dsl    v0xF3 — 基准版本
│   ├── dsdt_safe.dsl               v0xF4 — CS35L41 音频修复（独立分支）
│   ├── dsdt_v2_lid_fix.dsl         v0xF4 — Lid 传感器修复
│   ├── dsdt_v3_usb_fix.dsl         v0xF5 — USB 3.0 + USB-C 视频修复 ★当前
│   └── dsdt_rollback.dsl           v0xF6 — 回滚版本
├── build/                    ← 编译产物
│   ├── dsdt_v3_usb_fix.aml         最新版编译结果
│   ├── dsdt_rollback.aml           回滚版编译结果
│   └── acpi_override               /boot 引导覆盖文件（CPIO 格式）
├── firmware/                 ← 固件相关
│   ├── acpi/
│   │   └── dsdt.aml                中间构建产物
│   ├── packages/                   原始固件包（ISO/CAB）
│   ├── spi_dump/                   SPI 只读 dump 输出目录（已忽略）
│   └── bios_update/                生产 BIOS 提取
│       └── extracted/Flash/N3GET74W/
│           ├── $0AN3G00.FL1        主 BIOS (33 MB)
│           └── $0AN3G00.FL2        EC 固件 (320 KB)
├── scripts/                  ← 自动化脚本
│   ├── spi_dump.sh                SPI 只读 dump 脚本
│   ├── parse_spi.py               AMD PSP 目录解析
│   └── analyze_spi_usb4.py        USB4/UCSI SPI 深度分析
├── spiflash/                 ← 统一 SPI 工具包 (Python)
│   ├── __main__.py                `python -m spiflash` 入口
│   ├── cli.py                     CLI 子命令 (check/probe/read/write/...)
│   ├── flashrom.py                flashrom 封装
│   ├── macos.py                   macOS 权限与 CH341A 检查
│   ├── fl2.py                     FL2 解析/比较
│   ├── spi_map.py                 SPI dump 布局分析
│   └── backup.py                  备份注册与 SHA256 记录
└── archive/                  ← 归档（可安全删除）
    ├── copilot-session-*.md        Copilot 调试对话记录
    ├── Fixing ACPI Lid and USB.md  聊天对话导出
    ├── dsdt_v2_lid_fix.aml         旧版编译产物
    └── acpi_override_new           旧版 CPIO 包
```

---

## DSDT 版本演进

```
dsdt_safe_audio_base.dsl (v0xF3) ─── 基准
    │
    ├── dsdt_safe.dsl (v0xF4) ─── 音频修复分支（CS35L41 放大器）
    │
    ├── dsdt_v2_lid_fix.dsl (v0xF4) ─── Lid 传感器修复
    │       │
    │       └── dsdt_v3_usb_fix.dsl (v0xF5) ─── USB + 视频修复 ★ 当前部署
    │
    └── dsdt_rollback.dsl (v0xF6) ─── 安全回滚（与基准内容相同）
```

---

## 快速操作

### SPI 工具链（新增）
```bash
# 查看所有子命令
python3 -m spiflash --help

# 环境检查（macOS/CH341A/flashrom）
python3 -m spiflash check

# 探测芯片
python3 -m spiflash probe

# 对比 FL2
python3 -m spiflash fl2 firmware/ec/N3GHT68W.FL2 firmware/ec/N3GHT69W.FL2

# 分析 dump
python3 -m spiflash analyze /path/to/ec_spi_dump.bin
```

### pixi 任务（spi-flash feature）
```bash
# 进入 spi-flash 环境执行任务
pixi run -e spi-flash spi-check
pixi run -e spi-flash spi-probe
pixi run -e spi-flash spi-fl2
pixi run -e spi-flash spi-lint
pixi run -e spi-flash spi-fmt
```

### 验证当前状态
```bash
sudo dmesg | grep "DSDT\|ACPI" | grep -i "error\|bug"
lsusb -t                                    # USB 速度
cat /proc/acpi/button/lid/*/state           # Lid 状态
```

### 只读导出 SPI Flash
```bash
sudo bash scripts/spi_dump.sh
```

> 脚本会自动处理 `flashrom` 的多芯片匹配提示，并在读取前要求再次确认。

### 修改 DSDT 流程
```bash
cd dsdt/
# 1. 编辑 .dsl 文件，升级版本号
# 2. 编译
iasl -oa -tc dsdt_v3_usb_fix.dsl
# 3. 打包
mkdir -p /tmp/build/kernel/firmware/acpi
cp dsdt_v3_usb_fix.aml /tmp/build/kernel/firmware/acpi/dsdt.aml
cd /tmp/build && find kernel | cpio -H newc --create > acpi_override
# 4. 部署
sudo cp acpi_override /boot/acpi_override
# 5. 重启验证
```

### 回滚
rEFInd 启动时按 `a` 键跳过 acpi_override。
