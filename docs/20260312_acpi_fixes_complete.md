# ThinkPad Z13 Gen 1 — ACPI 修复完整文档

> **日期**: 2026-01-06 (创建), 2026-03-15 (整合)  
> **状态**: ✅ 已部署  
> **系统**: CachyOS x86_64 (Arch), ThinkPad Z13 Gen 1, AMD Ryzen  
> **当前版本**: `dsdt_v3_usb_fix.dsl` (v0xF5)  
> **回滚版本**: `dsdt_rollback.dsl` (v0xF6)

> 本文档由 `acpi_analysis_complete.md` 与 `ACPI_FIXES_APPLIED.md` 合并而成。
> 原始文件已归档至 `archive/`。

---

## 一、问题分析与修复

### 1. USB 3.0 降级为 USB 2.0 — ✅ 已修复 (v3)

**症状**: Type-C 接口只识别为 USB 2.0，不能达到 USB 3.0 速度

**根因**: ACPI 命名约定不匹配
- 内核寻找 `\_SB.PC00.XHCI.RHUB.HS01-12` / `SS01-06` (Intel 新命名)
- DSDT 定义的是 `\_SB.PCI0.GP17.XHC0` / `XHC1` (AMD 旧命名)
- SuperSpeed 端口配置失败 → 回退到 USB 2.0

**修复代码** (`dsdt_v3_usb_fix.dsl`):
```asl
Scope (_SB)
{
    Alias (PCI0, PC00)    // 映射 Intel 风格 PC00 → AMD 风格 PCI0
    Alias (XHC0, XHCI)   // XHC0 → 标准 XHCI
}
```

**DSDT 参考**: XHC0 行 3168-3240, XHC1 行 3358-3430

---

### 2. USB-C 视频输出不可用 — ✅ 已修复 (v3)

**症状**: USB-C DP/Thunderbolt 视频输出不工作

**根因**:
- `\_SB.PCI0.GPP7.DEV0` 符号解析失败 — DSDT 中 GPP7 下只有 `L850`，不存在 `DEV0`
- `\_SB.PCI0.GPP6._CRS` 重复定义导致冲突

**修复代码**:
```asl
Device (GPP7)
{
    Alias (L850, DEV0)    // 映射 L850 → 标准 DEV0
    Device (L850) { ... }
}
```

---

### 3. Lid 传感器不可用 — ✅ 已修复 (v2)

**症状**: 合盖不触发待机

**根因**: DSDT 覆盖与固件 DSDT 重复创建 `EC0.LHKF` / `EC0.LISD` → AE_ALREADY_EXISTS

**修复**: 在 `dsdt_v2_lid_fix.dsl` 中添加 `External` 声明避免重复创建

---

### 4. 风扇控制 — ✅ 已配置

**方案**: `thinkpad_acpi.fan_control=1` 加入 rEFInd 内核参数  
**详情**: 见 [thinkfan-setup-notes.md](thinkfan-setup-notes.md)

---

## 二、修复总览

| 优先级 | 问题 | ACPI 对象 | 修复版本 | 状态 |
|--------|------|----------|---------|------|
| 🔴 最高 | Lid 传感器 | EC0.LHKF, EC0.LISD | v2 | ✅ |
| 🟡 次高 | USB-C 视频 | GPP7.DEV0, GPP6._CRS | v3 | ✅ |
| 🟢 第三 | USB 3.0 降级 | PC00/XHCI 别名 | v3 | ✅ |
| ⚪ 低 | WMI/OSI | BIOS 级别 | — | ⏭️ 忽略 (不可修) |

---

## 三、非关键问题（无需修复）

| 问题 | 错误类型 | 影响 |
|------|---------|------|
| WMI1.WQA0 数组越界 | AE_AML_PACKAGE_LIMIT | 轻微，系统稳定 |
| BIOS _OSI(Linux) 未识别 | — | 无影响 |
| acpid button/up,down | — | 仅日志 |

---

## 四、技术背景

三个修复的共同根因：**ACPI 命名约定混淆**

- **PC00 vs PCI0**: Intel 新平台用 PC00，AMD 用 PCI0
- **DEV0 vs L850**: 标准约定用 DEV0，此 BIOS 用 L850
- **EC0 重复**: 固件 DSDT 已定义的对象在覆盖 DSDT 中再次创建

Alias 机制等同于符号链接：告诉 ACPI 解析器两个名字指向同一对象。

---

## 五、编译与部署

### 文件链
```
dsdt/dsdt_v3_usb_fix.dsl  →  build/dsdt_v3_usb_fix.aml  →  build/acpi_override  →  /boot/acpi_override
```

### 编译
```bash
iasl -ve -p dsdt_v3_usb_fix dsdt/dsdt_v3_usb_fix.dsl
# 输出: dsdt_v3_usb_fix.aml (~72KB)

# 打包 CPIO 覆盖
mkdir -p kernel/firmware/acpi
cp dsdt_v3_usb_fix.aml kernel/firmware/acpi/dsdt.aml
find kernel | cpio -o -H newc > build/acpi_override
sudo cp build/acpi_override /boot/acpi_override
```

### 回滚
```bash
sudo cp build/dsdt_rollback.aml /boot/acpi_override
# 或删除覆盖恢复原始 DSDT:
sudo rm /boot/acpi_override
```

---

## 六、验证命令

```bash
# DSDT 加载确认
sudo dmesg | grep -i "DSDT\|acpi_override"

# USB 3.0 端口
lsusb -t

# USB-C 视频
xrandr
dmesg | grep -i "thunderbolt\|usb.*video\|dp"

# Lid 传感器
cat /proc/acpi/button/lid/*/state

# 剩余 ACPI 错误
sudo dmesg | grep "ACPI.*Error\|ACPI.*bug"
```

---

## 七、总结

- **关键问题**: 0 个（全部已修复）
- **用户影响**: 无 — 系统完全可用
- **注意**: USB 3.0/USB-C 视频的 ACPI 修复仅解决命名问题；实际 USB3/USB4/DP 功能受限于 PD 控制器固件空缺（详见 [usb4_analysis.md](usb4_analysis.md) §27-§28）
