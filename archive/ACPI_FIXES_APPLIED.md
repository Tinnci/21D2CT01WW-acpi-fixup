# ThinkPad Z13 Gen 1 ACPI 修复报告

**日期**: 2026-01-06  
**状态**: ✅ 已部署  
**版本**: DSDT v0xF2 (242)  

---

## 已应用的修复

### 1. ✅ 版本号升级
- **原**: 0x000000F1 (241)
- **新**: 0x000000F2 (242)
- **目的**: 确保内核识别新的DSDT覆盖

### 2. ✅ USB 3.0/4.0 兼容性 (PC00 别名)
**修复代码**:
```asl
Scope (_SB)
{
    // Alias for USB 3.0/4.0 compatibility - maps Intel-style PC00 to AMD-style PCI0
    Alias (PCI0, PC00)
    ...
}
```

**解决的问题**:
- ❌ `Could not resolve symbol [\_SB.PC00.XHCI.RHUB.HS01-12]`
- ❌ `Could not resolve symbol [\_SB.PC00.XHCI.RHUB.SS01-06]`
- ✅ USB Type-C SuperSpeed (3.0/3.1) 应该恢复
- ✅ SS (SuperSpeed) 端口配置应正确加载

**预期改进**:
- USB Type-C接口能识别为USB 3.0而不是2.0
- USB转接器和设备会获得全速性能

---

### 3. ✅ USB-C 视频输出兼容性 (L850→DEV0 别名)
**修复代码**:
```asl
Device (GPP7)
{
    ...
    // Alias for USB-C video compatibility - maps L850 to standard DEV0
    Alias (L850, DEV0)
    
    Device (L850)
    ...
}
```

**解决的问题**:
- ❌ `Could not resolve symbol [\_SB.PCI0.GPP7.DEV0]`
- ✅ PCIe桥接设备正确识别
- ✅ USB-C DP/Thunderbolt 协商应工作

**预期改进**:
- USB-C 视频输出（DP、HDMI Alt Mode）应可用
- 支持外接显示器和扩展坞

---

### 4. ⏳ Lid 传感器修复 (EC0 重复对象)
**状态**: 部分修复（需要下一步验证）

**原始问题**:
- ❌ `Failure creating named object [\_SB.PCI0.LPC0.EC0.LHKF]`
- ❌ `Failure creating named object [\_SB.PCI0.LPC0.EC0.LISD]`

**当前行动**:
- 新DSDT已升级（v0xF2）
- 多个EC0 Scope块可能导致冲突
- 下一步：启动后验证是否仍然有重复对象错误

**预期改进**:
- 合盖能正确触发休眠
- Lid传感器状态被系统识别

---

## 技术细节

### 改修的文件
- **源**: `/home/drie/下载/dsdt_live.dsl`
- **备份**: `/home/drie/下载/dsdt_live.dsl.backup`
- **编译产物**: `/home/drie/下载/dsdt_live.aml`
- **部署**: `/boot/acpi_override` (新版本)

### 编译信息
```
Intel ACPI Component Architecture
ASL+ Compiler version 20250404

Input file: /home/drie/下载/dsdt_live.dsl
Output file: /home/drie/下载/dsdt_live.aml
Length: 71KB (72566 bytes)

编译结果: ✅ 成功 (仅有风格警告，无错误)
```

---

## 验证步骤

### 重启后验证 (必需)
```bash
# 1. 检查DSDT是否被加载
sudo dmesg | grep -i "DSDT\|acpi_override"

# 2. 验证USB 3.0端口
lsusb -t  # 查看USB端口，应显示速度而不仅是型号

# 3. 检查USB-C视频
xrandr  # 应该显示连接的显示器
dmesg | grep -i "thunderbolt\|usb.*video\|dp"

# 4. 验证合盖传感器
cat /proc/acpi/button/lid/*/state  # 应显示 open 或 closed

# 5. 检查剩余的ACPI错误
sudo dmesg | grep "ACPI.*Error\|ACPI.*bug"
```

### 性能测试
```bash
# USB 3.0速度测试 (需要USB 3.0设备)
lsusb -v | grep -i speed

# 查看Lid事件日志
sudo journalctl -b | grep -i "lid\|suspend"
```

---

## 预期效果总结

| 功能 | 修复前 | 修复后 | 确定性 |
|-----|------|------|------|
| USB Type-C 3.0速度 | ❌ 降级到2.0 | ✅ 3.0/3.1 | 高 |
| USB-C 视频输出 | ❌ 不可用 | ✅ 应可用 | 中 |
| 合盖休眠 | ❌ 不工作 | ⏳ 需验证 | 低* |

*Lid传感器修复需要取决于是否还有其他EC0冲突

---

## 下一步建议

1. **立即重启** - 让新DSDT生效
2. **运行验证脚本** - 检查上述所有功能
3. **收集dmesg日志** - 看是否仍有ACPI错误
4. **如果Lid仍未修复** - 可能需要深入编辑EC0 Scope块

---

## 技术背景

这三个修复都基于同一个根本问题：**ACPI 命名约定混淆**

- **PC00 vs PCI0**: Intel新平台用PC00，AMD用PCI0。中间件（内核或固件）期望PC00但DSDT定义PCI0
- **DEV0 vs L850**: 标准ACPI约定使用DEV0引用标准设备，但这个BIOS用L850
- **EC0重复**: 固件DSDT已定义，你的覆盖DSDT也定义，导致冲突

这些别名（Alias）就像"符号链接"，指示ACPI解析器："这两个名字指向同一个对象"。

---

## 回滚步骤 (如需要)

```bash
sudo cp /home/drie/下载/acpi_override /boot/acpi_override
```

