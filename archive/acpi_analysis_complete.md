# ThinkPad Z13 Gen 1 — ACPI 完整分析文档

**日期**: 2026-01-06  
**系统**: CachyOS x86_64 (Arch), ThinkPad Z13 Gen 1, AMD Ryzen

> 本文档合并自 `acpi_analysis.md`、`acpi_errors_analysis.md`、`hardware_acpi_mapping.md`。

---

## 一、硬件问题与 ACPI 错误映射

### 1. USB Type-C 接口 USB 3.0 降级为 USB 2.0

**症状**: Type-C 接口只能识别为 USB 2.0，不能达到 USB 3.0 速度

**相关 ACPI 对象**:
- `HS01-HS12` = USB 高速端口（USB 2.0）
- `SS01-SS06` = USB SuperSpeed 端口（USB 3.0）
- 位置: `\_SB.PCI0.GP17.XHC0` 和 `XHC1`

**错误信息**:
```
Could not resolve symbol [\_SB.PC00.XHCI.RHUB.HS01-HS12]
Could not resolve symbol [\_SB.PC00.XHCI.RHUB.SS01-SS06]
```

**根本原因**:
1. 内核寻找 `PC00.XHCI` 命名约定的设备
2. DSDT 定义的是 `PCI0.GP17.XHC0`/`XHC1`（旧命名约定）
3. 命名不匹配导致 SS (SuperSpeed/USB 3.0) 端口配置失败
4. 系统回退到只使用 HS (HighSpeed/USB 2.0) 端口

**DSDT 证据**: XHC0 行 3168-3240, XHC1 行 3358-3430

**修复**: `dsdt_v3_usb_fix.dsl` 中添加 `Alias (PCI0, PC00)` + `Alias (XHC0, XHCI)`

---

### 2. USB Type-C 视频输出不可用

**症状**: USB-C DP/Thunderbolt 输出不工作

**相关 ACPI 对象**:
- `GPP7.DEV0` = PCIe 桥接设备
- `GPP6._CRS` = 资源配置

**错误信息**:
```
Could not resolve symbol [\_SB.PCI0.GPP7.DEV0]
Failure creating named object [\_SB.PCI0.GPP6._CRS]
```

**根本原因**:
1. `GPP7.DEV0` 不存在 — DSDT 中 GPP7 有设备 `L850` 而不是 `DEV0`
2. `GPP6._CRS` 重复定义导致冲突

**修复**: `dsdt_v3_usb_fix.dsl` 中在 GPP7 添加 `Alias (L850, DEV0)`

---

### 3. 盖子 (Lid) 传感器不可用

**症状**: 合盖不能触发待机

**相关 ACPI 对象**:
- `EC0.LHKF` = Lid Hot Key Function
- `EC0.LISD` = Lid State Data

**错误信息**:
```
Failure creating named object [\_SB.PCI0.LPC0.EC0.LHKF]
Failure creating named object [\_SB.PCI0.LPC0.EC0.LISD]
```

**根本原因**: DSDT 与固件 DSDT 重复创建同名对象，AE_ALREADY_EXISTS 冲突

**修复**: `dsdt_v2_lid_fix.dsl` 中添加 `External` 声明避免重复创建

---

## 二、非关键 BIOS 问题（无需修复）

| 问题 | 错误类型 | 影响 | 可修复 |
|------|---------|------|--------|
| EC0.LHKF / EC0.LISD 重复 | AE_ALREADY_EXISTS | 已修复（v2） | ✅ |
| USB Hub 符号解析 | AE_NOT_FOUND | 已修复（v3） | ✅ |
| GPIO.MP2 / GPP7.DEV0 | AE_NOT_FOUND | 已修复（v3） | ✅ |
| WMI1.WQA0 数组越界 | AE_AML_PACKAGE_LIMIT | 轻微，系统稳定 | ❌ BIOS 问题 |
| BIOS _OSI(Linux) 未识别 | — | 无影响 | ❌ BIOS 限制 |
| acpid button/up,down | — | 仅日志，不影响使用 | 可选配 acpid |

---

## 三、错误根因详解

### USB Hub 端口错误 (AE_NOT_FOUND)

- 日志引用: `PC00`（新 AML 命名）
- DSDT 定义: `PCI0`（旧 AML 命名）
- XHC0 设备: 行 3168-3240 (HS01-HS12, SS01-SS06)
- XHC1 设备: 行 3358-3430 (重复的端口定义)

### 重复对象创建错误 (AE_ALREADY_EXISTS)

- `\_SB.PCI0.LPC0.EC0.LHKF` / `EC0.LISD` / `GPP6._CRS`
- 原因: DSDT 覆盖与固件 DSDT 冲突
- 对象在反编译 `dsdt_live.dsl` 中未出现，可能被 SSDT 覆盖

### GPIO/设备引用错误

- `\_SB.PCI0.GP17.MP2` — MP2C 存在(行 3462)但 MP2 不存在
- `\_SB.PCI0.GPP7.DEV0` — GPP7(行 2312)内只有 L850 没有 DEV0

---

## 四、修复优先级与策略

| 优先级 | 问题 | ACPI 对象 | 修复难度 | 状态 |
|--------|------|----------|---------|------|
| 🔴 最高 | Lid 传感器 | EC0.LHKF, EC0.LISD | ⭐ 容易 | ✅ v2 已修复 |
| 🟡 次高 | USB-C 视频 | GPP7.DEV0, GPP6._CRS | ⭐⭐⭐ | ✅ v3 已修复 |
| 🟢 第三 | USB 3.0 降级 | PC00/XHCI 别名 | ⭐⭐ | ✅ v3 已修复 |
| ⚪ 低 | WMI/OSI | BIOS 级别 | 不可修 | ⏭️ 忽略 |

---

## 五、已解决问题

### ✅ 风扇控制
- **方案**: `thinkpad_acpi.fan_control=1` 加入 rEFInd 内核参数
- **结果**: Thinkfan 正常工作

---

## 总结

- **关键问题**: 0 个（全部已修复）
- **用户影响**: 无 — 系统完全可用
- **当前最优版本**: `dsdt_v3_usb_fix.dsl` (v0xF5)
- **回滚版本**: `dsdt_rollback.dsl` (v0xF6)
