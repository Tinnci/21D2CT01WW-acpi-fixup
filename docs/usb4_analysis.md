# USB4/USB-C 降级根因分析报告

> 分析日期: 2026-03-06  
> 设备: ThinkPad Z13 Gen 1 (21D2CT01WW)  
> 内核: 6.19.5-3-cachyos  

## 1. 固件信息

| 项目 | 当前值 | 备注 |
|------|--------|------|
| BIOS 版本 | `N3GET04WE (0.04f)` | `E` 后缀 = **工程版 (EVT)** |
| BIOS 日期 | 2021-09-09 | Z13 Gen 1 发布前 ~5 个月 |
| EC 固件 | 0.15 | 极早期工程版 (量产版通常 ≥1.xx) |
| 平台 | AMD Rembrandt (Ryzen 6000) | USB4 集成于 SoC |

## 2. 问题现象

- **Xiaomi Type-C 5-in-1 Hub** 仅以 USB 2.0 (480Mbps) 连接
- Bus 002 (SuperSpeed 10Gbps) 完全空闲，无任何设备
- USB Billboard 设备出现（表示 Alt Mode 协商失败）
- `/sys/class/typec/` 目录**存在但为空**——模块已加载但无设备注册

## 3. 根本原因：工程 BIOS 三层缺失

### 3.1 缺失一：UCSI ACPI 设备 (PNP0CA0)

UCSI (USB Type-C Connector System Interface) 是操作系统管理 USB-C 端口的标准接口。

- **DSDT** 和全部 **23 个 SSDT** 中均无 `PNP0CA0` 设备定义
- `ucsi_acpi` 内核模块可以加载，但找不到任何匹配的 ACPI 设备
- 后果：操作系统无法:
  - 查询 USB-C 连接状态
  - 控制 Type-C mux (USB/DP 信号切换)
  - 协商 Alternate Mode
  - 管理 Power Delivery 角色

**验证命令:**
```bash
# UCSI 模块已加载但无设备
lsmod | grep ucsi
# ucsi_acpi              12288  0
# typec_ucsi             77824  1 ucsi_acpi

# typec 目录存在但为空
ls /sys/class/typec/
# (空)
```

### 3.2 缺失二：USB4 NHI (Native Host Interface) PCI 设备

USB4 NHI 是 Thunderbolt/USB4 路由器的软件接口，负责 USB4 隧道管理。

- PCI 总线中无 USB4 NHI 设备 (预期 PCI ID: `1022:161d/e/f`)
- Bus 04 功能号 04:00.0 ~ 04:00.7 全部占满，无 NHI 预留位
- `thunderbolt` 内核模块加载成功但无设备绑定

**PCI 总线布局 (Bus 04):**
```
04:00.0  GPU (Rembrandt)
04:00.1  HDMI Audio
04:00.2  PSP/CCP (加密)
04:00.3  USB4 XHCI #1 ← USB-C 外部端口
04:00.4  USB4 XHCI #2 ← 内部设备 (指纹/WWAN)
04:00.5  Audio Coprocessor
04:00.6  HD Audio
04:00.7  Sensor Fusion Hub
```

**验证命令:**
```bash
# Thunderbolt 域为空
ls /sys/bus/thunderbolt/devices/
# (空)

# 无 NHI PCI 设备
lspci -nn | grep "1022:161[def]"
# (无输出)
```

### 3.3 缺失三：EC UCSI 邮箱支持

UCSI 协议要求 EC 固件实现标准化的邮箱接口 (Mailbox) 用于 OS ↔ EC 通信。

- EC 固件版本 0.15（工程版）极大概率不实现 UCSI 邮箱
- 即使通过 DSDT Override 手动添加 `PNP0CA0` ACPI 设备，EC 也不会响应命令
- EC 路径: `\_SB_.PCI0.LPC0.EC0`

### 3.4 因果链

```
工程 BIOS (0.04f, 2021-09)
    │
    ├─→ 不初始化 USB4 NHI 硬件
    │       └─→ XHCI 控制器存在但无 USB4 路由功能
    │               └─→ SuperSpeed 信号无法通过 Type-C mux 路由
    │                       └─→ USB-C 只能走 USB 2.0 通路
    │
    ├─→ ACPI 表不包含 UCSI 设备
    │       └─→ OS 无法管理 USB-C 端口
    │               └─→ Alt Mode 协商失败 → Billboard 出现
    │
    └─→ EC 固件 (0.15) 不支持 UCSI 协议
            └─→ DSDT Override 无法绕过此限制
```

## 4. USB 拓扑对照

### 当前 (工程 BIOS)
```
Bus 001 (XHC0 USB 2.0, 480M):
  ├─ Port 002: Xiaomi Hub (USB 2.1 Hub, 480M) ← 应为 SuperSpeed
  │    └─ Port 005: Billboard [无驱动]         ← Alt Mode 失败标志
  ├─ Port 003: USB DFU (12M)
  └─ Port 004: Integrated Camera (480M)

Bus 002 (XHC0 SuperSpeed, 10G):
  └─ (完全空闲)                                ← 应有 Xiaomi Hub

Bus 003 (XHC1 USB 2.0):
  ├─ Port 001: Intel L830-EA WWAN (480M)
  └─ Port 003: Synaptics Fingerprint (12M)

Bus 004 (XHC1 SuperSpeed, 10G):
  └─ (空)

Bus 005 (XHC2 USB 2.0):
  └─ Port 001: IR Camera (480M)
```

### 预期 (量产 BIOS)
```
Bus 001 (XHC0 USB 2.0, 480M):
  └─ (USB 2.0 companion 设备)

Bus 002 (XHC0 SuperSpeed, 10G):
  └─ Port: Xiaomi Hub (SuperSpeed, 5G/10G)  ← 通过 USB4 路由器

Thunderbolt 域:
  └─ domain0: USB4 路由器
       ├─ USB tunnel → XHCI
       └─ DP tunnel → DisplayPort Alt Mode
```

## 5. DSDT 相关信息

### XHC 控制器 ACPI 路径
| ACPI 路径 | PCI 地址 | 用途 |
|-----------|----------|------|
| `\_SB_.PCI0.GP17.XHC0` | 04:00.3 | USB-C 外部端口 (Bus 1/2) |
| `\_SB_.PCI0.GP17.XHC1` | 04:00.4 | 内部设备 (Bus 3/4) |
| `\_SB_.PCI0.GP19.XHC2` | 05:00.0 | IR 摄像头 (Bus 5) |

### XHC0 端口布局 (USB-C 端口)
| 端口 | 地址 | _UPC Type | 说明 |
|------|------|-----------|------|
| HS01 | 0x01 | 0x00 (Type-A) | USB-C 端口 1 (USB 2.0 侧) |
| HS02 | 0x02 | 0x00 (Type-A) | USB-C 端口 2 (USB 2.0 侧) |
| HS03 | 0x03 | Not Connectable | 内部/未使用 |
| HS04 | 0x04 | Not Connectable | 内部/未使用 |
| SS01 | 0x05 | 0x09 (Type-C USB2) | USB-C 端口 1 (SS 侧) |
| SS02 | 0x06 | 0x03 (Type-A SS) | USB-C 端口 2 (SS 侧) |

> 注: SS01 的 UPC type=0x09 已在之前的 DSDT 修复中处理

### BIOS 设置中的相关项
- `PCIeTunneling` — 值为 0 (禁用/未实现)
- `USBTypeC` — 仅为设置菜单字符串，非设备定义

## 6. 修复方案评估

| 方案 | 可行性 | 说明 |
|------|--------|------|
| DSDT Override 添加 UCSI | ❌ 不可行 | EC 0.15 不支持 UCSI 邮箱协议 |
| 手动添加 NHI PCI 设备 | ❌ 不可行 | PCI 设备由 SoC 固件枚举，非 ACPI 控制 |
| 强制 XHCI SuperSpeed | ❌ 不可行 | 需要 USB4 路由器控制 Type-C mux |
| **升级量产 BIOS** | ✅ 唯一方案 | N3GETxxW 系列 (去掉 E 后缀) |

### 升级 BIOS 注意事项
- ThinkPad Z13 Gen 1 量产 BIOS 前缀: `N3GET`
- Lenovo 官方下载: https://pcsupport.lenovo.com → 搜索 21D2
- **风险**: 从工程版升级到量产版可能需要特殊工具 (非标准 BIOS 刷写流程)
- 建议先确认是否可以通过 `fwupdmgr` 或 Lenovo BIOS Update Utility 升级

## 7. 其他已发现问题

| 问题 | 严重程度 | 状态 |
|------|----------|------|
| 指纹读取器 (06cb:0123) 每次会话重置 15 次 | 中 | 未修复 — 可能与 USB autosuspend 相关 |
| Intel L830-EA 报告 sim-missing | 低 | 信息性 — 无 SIM 卡插入 |
| Billboard 设备无驱动 | 低 | 正常 — 仅为协商失败标志 |

## 8. 验证命令汇总

```bash
# 检查 BIOS/EC 版本
cat /sys/class/dmi/id/bios_version
cat /sys/class/dmi/id/ec_firmware_release

# 检查 UCSI 设备状态
ls /sys/class/typec/
lsmod | grep ucsi

# 检查 USB4 NHI
lspci -nn | grep -i "thunderbolt\|NHI\|1022:161[def]"
ls /sys/bus/thunderbolt/devices/

# 检查 USB-C 连接速度
lsusb -t

# 检查 ACPI 中是否存在 PNP0CA0
grep -r "PNP0CA0" /sys/bus/acpi/devices/*/hid 2>/dev/null
```
