# 项目文件时间线与结构清单

> 生成日期：2026-03-06  
> 统计范围：工作区业务文件（不含 `.git/`）

## 1. 时间线概览

### 2026-01-06：第一轮集中产出

这一天完成了绝大多数核心资产，说明项目主体是在一次连续的 ACPI 修复会话中建立的。

| 时间段 | 文件 | 说明 |
|---|---|---|
| 01:58 | `archive/copilot-session-92820eca-*.md` | 早期调试记录 |
| 14:56 | `docs/thinkfan-setup-notes.md` | 风扇控制补充笔记 |
| 16:58–17:47 | `dsdt/*.dsl`、`build/*.aml`、`build/acpi_override`、`firmware/acpi/dsdt.aml` | DSDT 修改、编译与部署主链 |
| 16:59–17:00 | `docs/ACPI_FIXES_APPLIED.md`、`docs/QUICK_REFERENCE.txt` | 部署记录与速查 |
| 17:49 | `archive/Fixing ACPI Lid and USB.md` | 大型过程记录归档 |

### 2026-03-06：第二轮整理与深度诊断

这一轮主要在做文档收敛、USB4 根因分析与 SPI dump 辅助脚本。

| 时间 | 文件 | 说明 |
|---|---|---|
| 00:48 | `docs/acpi_analysis_complete.md` | 汇总版分析文档 |
| 01:34 | `README.md` | 项目入口说明 |
| 02:02 | `docs/usb4_analysis.md` | USB4/USB-C 深度诊断报告 |
| 02:09 | `scripts/spi_dump.sh` | SPI 只读 dump 脚本 |

## 2. 当前结构评估

### 目录职责

| 目录 | 职责 | 现状 |
|---|---|---|
| `docs/` | 结论型文档、操作说明 | 结构清晰，适合作为主文档区 |
| `dsdt/` | DSL 源码历史版本 | 命名连续，版本脉络清楚 |
| `build/` | 可部署产物 | 保留最新版与回滚版是合理的 |
| `firmware/acpi/` | 中间固件产物 | 可保留，便于追溯 |
| `firmware/spi_dump/` | SPI dump 输出目录 | 应视为临时/证据目录，不建议纳入版本控制 |
| `scripts/` | 自动化脚本 | 目前仅 1 个脚本，适合继续扩展 |
| `archive/` | 历史记录与旧产物 | 已承担归档职责，合理 |

## 3. 主要文件清单

### 核心源码与产物

| 文件 | 修改时间 | 大小 | 角色 |
|---|---:|---:|---|
| `dsdt/dsdt_safe_audio_base.dsl` | 2026-01-06 17:21 | 626232 B | 基准 DSDT |
| `dsdt/dsdt_safe.dsl` | 2026-01-06 17:16 | 630006 B | 音频修复分支 |
| `dsdt/dsdt_v2_lid_fix.dsl` | 2026-01-06 17:27 | 626331 B | Lid 修复版本 |
| `dsdt/dsdt_v3_usb_fix.dsl` | 2026-01-06 17:36 | 626549 B | 当前主线 |
| `dsdt/dsdt_rollback.dsl` | 2026-01-06 17:47 | 626232 B | 回滚版本 |
| `build/dsdt_v3_usb_fix.aml` | 2026-01-06 17:37 | 72464 B | 当前部署产物 |
| `build/dsdt_rollback.aml` | 2026-01-06 17:47 | 72317 B | 回滚产物 |
| `build/acpi_override` | 2026-01-06 17:47 | 73216 B | 引导覆盖包 |

### 文档区

| 文件 | 修改时间 | 大小 | 角色 |
|---|---:|---:|---|
| `README.md` | 2026-03-06 01:34 | 3862 B | 入口说明 |
| `docs/acpi_analysis_complete.md` | 2026-03-06 00:48 | 4217 B | 总体分析汇总 |
| `docs/usb4_analysis.md` | 2026-03-15 | ~120 KB | USB4 深度诊断 (含 §1-§27) |
| `docs/ACPI_FIXES_APPLIED.md` | 2026-01-06 16:59 | 4234 B | 修复落地记录 |
| `docs/QUICK_REFERENCE.txt` | 2026-01-06 17:00 | 4120 B | 快速命令参考 |
| `docs/thinkfan-setup-notes.md` | 2026-01-06 14:56 | 3069 B | 风扇补充笔记 |
| `docs/ec_fl2_analysis.md` | 2026-03-13 | — | EC FL2 固件深度分析 |

### 固件分析脚本

| 文件 | 说明 |
|---|---|
| `scripts/analyze_ec_fl2.py` | EC FL2 固件包解析 |
| `scripts/analyze_spi_usb4.py` | SPI flash USB4 模块分析 |
| `scripts/dfu_trace3.py` | Microchip PD DFU 状态机追踪 (pyusb) |
| `scripts/ec_probe.py` | EC 端口探测 |
| `scripts/parse_spi.py` | SPI 镜像解析 |

### EC/PD 固件文件

| 文件 | 大小 | 说明 |
|---|---:|---|
| `firmware/ec/N3GHT68W.FL2` | 327,968 B | EC 固件 (BIOS N3GET74W 配套) |
| `firmware/ec/N3GHT69W.FL2` | 327,968 B | EC 固件 (BIOS N3GET76W 配套) |

## 4. 优化建议与已处理项

### 已处理

- 补充了项目入口 `README.md`
- 补充了 `scripts/spi_dump.sh`
- 增加 `.gitignore`，避免 SPI dump 二进制和日志污染版本库

### 建议继续保持

1. `archive/` 只放历史记录，不再放当前使用中的文件。  
2. `build/` 只保留“当前部署版 + 回滚版”。  
3. `firmware/spi_dump/` 仅保存必要证据，二进制 dump 建议离线备份。  
4. 新文档优先放到 `docs/`，避免根目录继续膨胀。  

## 5. 结论

当前项目已经从“实验目录”转成了“可维护目录”：

- 根目录文件数量较少
- 版本链清楚
- 归档区与工作区已基本分离
- 仍需重点避免把 SPI dump 结果纳入版本控制
