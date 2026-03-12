# 项目文件结构清单

> 最后更新：2026-03-15  
> 设备：ThinkPad Z13 Gen 1 (21D2CT01WW)

## 1. 时间线概览

| 阶段 | 日期 | 主要工作 |
|------|------|----------|
| ACPI 修复 | 2026-01-06 | DSDT 修改、编译、部署（USB3/Lid/DP 命名修复） |
| 文档整理 | 2026-03-06 | USB4 根因分析、SPI dump 脚本、README |
| EC/PD 分析 | 2026-03-12~13 | FL2 逆向、PD blob 提取、DFU 设备发现 |
| DFU/硬件分析 | 2026-03-15 | DFU 状态机追踪 (死胡同)、双 SPI 架构确认、I2C 拓扑 |
| 文档整合 | 2026-03-15 | ACPI 文档合并、project_inventory 更新 |

## 2. 目录结构

| 目录 | 职责 |
|------|------|
| `docs/` | 结论型文档、分析报告 |
| `dsdt/` | DSL 源码历史版本 (v1→v3 + rollback) |
| `build/` | 可部署产物 (AML + CPIO) |
| `firmware/acpi/` | ACPI 中间产物 |
| `firmware/ec/` | EC FL2 固件 (Lenovo ISO 提取) |
| `firmware/spi_dump/` | SPI dump 输出 (不纳入版本控制) |
| `scripts/` | 分析/调试脚本 |
| `spi-tool/` | Rust SPI 镜像分析工具 |
| `archive/` | 归档：旧文档、会话记录、旧产物 |
| `thinkpadOEM/` | Lenovo OEM 工具 (U 盘备份) |

## 3. 主要文件清单

### 核心源码与产物

| 文件 | 角色 |
|------|------|
| `dsdt/dsdt_v3_usb_fix.dsl` | **当前主线** DSDT (USB3 + DP + Lid 修复) |
| `dsdt/dsdt_rollback.dsl` | 回滚版本 (原始 DSDT) |
| `build/dsdt_v3_usb_fix.aml` | 编译产物 (~72KB) |
| `build/acpi_override` | 引导覆盖 CPIO 包 |

### 文档

| 文件 | 内容 |
|------|------|
| `docs/acpi_fixes_complete.md` | ACPI 修复完整文档 (分析+代码+验证) |
| `docs/usb4_analysis.md` | USB4/EC/SPI/PD 终极诊断报告 (§1-§28, ~140KB) |
| `docs/ec_fl2_analysis.md` | EC FL2 固件逆向分析 |
| `docs/spi_recovery_log.md` | CH341A SPI Flash 恢复日志 |
| `docs/thinkfan-setup-notes.md` | 风扇控制配置 |
| `docs/QUICK_REFERENCE.txt` | ACPI 修复速查参考卡 |
| `docs/project_inventory.md` | 本文件 — 项目结构导航 |

### 固件

| 文件 | 说明 |
|------|------|
| `firmware/ec/N3GHT68W.FL2` | EC 固件 (配套 BIOS N3GET74W) |
| `firmware/ec/N3GHT69W.FL2` | EC 固件 (配套 BIOS N3GET76W) |

### 脚本

| 文件 | 说明 |
|------|------|
| `scripts/analyze_ec_fl2.py` | EC FL2 固件包解析 |
| `scripts/analyze_spi_usb4.py` | SPI flash USB4 模块分析 |
| `scripts/dfu_trace3.py` | Microchip PD DFU 状态机追踪 |
| `scripts/ec_probe.py` | EC 端口探测 |
| `scripts/parse_spi.py` | SPI 镜像解析 |
| `scripts/spi_dump.sh` | SPI 只读 dump 脚本 |

### 归档 (archive/)

| 文件 | 说明 |
|------|------|
| `acpi_analysis_complete.md` | 已合并入 `acpi_fixes_complete.md` |
| `ACPI_FIXES_APPLIED.md` | 已合并入 `acpi_fixes_complete.md` |
| `project_inventory_old.md` | 旧版项目清单 |
| `copilot-session-*.md` ×2 | 早期调试会话记录 |
| `Fixing ACPI Lid and USB.md` | 大型过程记录 |
| `dsdt_v2_lid_fix.aml` | 旧版 AML |
| `acpi_override_new` | 旧版覆盖包 |

## 4. 关键硬件信息速查

| 项目 | 值 |
|------|-----|
| BIOS | N3GET04WE (工程版 v0.04f) |
| EC | N3GHT15W (工程版 v0.15) |
| EC 芯片 | Nuvoton NPCX997KA0BX (ARM Cortex-M4, flashless) |
| 主 SPI (U2101) | W25Q256JWEIQ (32MB, 1.8V) — BIOS 固件 |
| EC SPI (U8505) | W74M25JWZEIQ — EC 固件 |
| PD 控制器 | Microchip, VID 04d8:0039, DFU bootloader v8.20 |
| VPD EEPROM (U5402) | 24256E (32KB I2C, EC 私有总线) |
| SSH | drie@192.168.1.10 |
