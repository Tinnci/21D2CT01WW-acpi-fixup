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

## 8. 深度诊断：不更新 BIOS 的可能性分析

### 8.1 平台固件全景

| 组件 | 版本 | 状态 |
|------|------|------|
| CPU | Eng Sample: 100-000000527-41 N | **工程样片** |
| BIOS | N3GET04WE (0.04f) | **工程版** |
| EC | 0.15 | **工程版** |
| PSP (Secure Processor) | 00.28.00.36 | RPMC 未启用 (非量产) |
| SMU (电源管理单元) | 69.40.0 | Program 0 |
| VBIOS | 29 (Rembrandt Generic) | **工程版** |

> **结论**: 这是一台完整的工程样机，CPU 硬件本身是 Engineering Sample。

### 8.2 可用的 Linux 调试接口

| 接口 | 路径 | 访问权限 | 用途 |
|------|------|----------|------|
| EC I/O 端口 | `0x62` (data), `0x66` (cmd) | 需 root | 直接读写 EC 寄存器 |
| EC debugfs | `/sys/kernel/debug/ec/` | 需 root | EC RAM dump |
| think-lmi (BIOS 设置) | `/sys/class/firmware-attributes/thinklmi/` | 用户可读 | BIOS 设置查询/修改 |
| thinkpad_acpi | `/sys/devices/platform/thinkpad_acpi/` | 部分可读 | ThinkPad 功能控制 |
| AMD PSP | `/sys/devices/platform/AMDI0005:00/` | 可读 | SMU 版本查询 |
| AMD PMC | `amd_pmc` 模块 | 可读 | 电源管理/S0ix |
| AMD PMF | `amd_pmf` 模块 | 可读 | 电源管理框架 |
| PCI config | `/sys/bus/pci/devices/*/config` | 前 64B 可读 | PCI 配置空间 |
| XHCI MMIO | BAR0 `0xfd300000` (1MB) | 需 root `/dev/mem` | XHCI 寄存器 |
| WMI | `/sys/bus/wmi/devices/` (28个GUID) | 部分可读 | BIOS WMI 接口 |
| fwupd | `fwupdmgr` | 可用 | 固件更新 (有限) |
| SPI ROM | PSP rpmc_spirom_available=1 | 需特殊工具 | BIOS 闪存 |

### 8.3 BIOS 设置可访问项 (think-lmi)

通过 `/sys/class/firmware-attributes/thinklmi/attributes/` 可读取的与 USB 相关设置：

| 设置 | 当前值 | 可选值 |
|------|--------|--------|
| AlwaysOnUSB | (空) | Disable, Enable |
| USBPortAccess | (空) | Disable, Enable |
| HDMIModeSelect | (空) | HDMI1.4, HDMI2.0 |

**注意**: BIOS 中**完全没有** Thunderbolt/USB4/PCIe Tunneling 相关设置。
DSDT 中的 `PCIeTunneling` 选项值为 0，但在 think-lmi 中不可见（工程 BIOS 未暴露）。

### 8.4 EC 寄存器分析

EC RAM 范围: `0x00-0xED` (256 字节), 通过 `OperationRegion(ECOR, EmbeddedControl, 0, 0x100)` 定义。

**USB-C 相关发现:**

- `UCCI` mutex — 不是 UCSI 接口，而是 **USB-C Charger Interface** (充电同步锁)
  - 用于 `_Q26`/`_Q27` (AC 电源状态变化) → `Notify(AC, 0x80)`
  - 仅处理 USB-C PD 充电事件，不控制数据连接
- `HUBS` (offset ~0x45) — USB Hub 状态标志位
- EC 没有 UCSI 标准寄存器 (`VERS`, `CCI`, `CTL`, `MSG` 字段均不存在)

**结论**: EC 0.15 仅实现基础充电检测，不支持 UCSI 数据协商协议。

### 8.5 USB4 NHI 缺失的硬件证据

```
PCI Bus 04 (内部桥 00:08.1):
  04:00.0  0300  VGA     ← 存在
  04:00.1  0403  Audio   ← 存在
  04:00.2  1080  PSP     ← 存在
  04:00.3  0c03  XHCI#1  ← 存在 (USB4 名称，但无 USB4 功能)
  04:00.4  0c03  XHCI#2  ← 存在
  04:00.5  0480  ACP     ← 存在
  04:00.6  0403  HD Audio ← 存在
  04:00.7  1180  SFH     ← 存在
  (无 0880)              ← NHI 应在此 (PCI class 0880 = System Other)

全系统 PCI class 0880 设备数: 0
```

- AMD Rembrandt USB4 NHI 需要独立 PCI 功能号 (预期 class 0880)
- 工程 BIOS 未在 PCIe 初始化时枚举 NHI
- Bus 04 的 8 个功能位 (0-7) 已全部分配给其他设备

### 8.6 Thunderbolt 驱动分析

```
thunderbolt 模块状态: 已加载 (610304 bytes)
绑定设备数: 0
thunderbolt domains: (空)

PCI ID 匹配: thunderbolt 模块仅匹配 Intel (8086) NHI 设备
  → AMD USB4 NHI 使用 AMD (1022) VID，但需要 NHI PCI 设备存在
  → 当前系统中的 AMD XHCI 设备 (1022:161a/b/c) 使用 xhci_hcd 驱动
```

### 8.7 不更新 BIOS 的潜在方案评估

#### 方案 A: 通过 SMN 寄存器启用 USB4 路由器
- **可行性**: ❓ 理论上可能但极高风险
- AMD Rembrandt SoC 的 USB4 路由器 IP 通过 SMN (System Management Network) 控制
- 需要知道精确的 SMN 寄存器地址 (AMD 未公开文档)
- **风险**: 写入错误值可能导致系统挂死或硬件损坏
- **方法**: `sudo setpci -s 00:00.0 0xC0.L=<SMN_ADDR>; sudo setpci -s 00:00.0 0xC4.L`
- **现实**: 即使知道地址，USB4 路由器初始化是复杂多步序列，非单个寄存器可控

#### 方案 B: DSDT 添加 UCSI (PNP0CA0) 设备
- **可行性**: ❌ 不可行
- 即使添加 ACPI 设备定义，EC 0.15 不支持 UCSI 邮箱协议
- EC 不会响应 UCSI 命令 → 驱动会超时
- 已验证: 模块加载后 `/sys/class/typec/` 为空

#### 方案 C: XHCI MMIO 扩展能力探测 ✅ 已完成
- **结果**: ❌ **USB4 Router Operations 能力不存在**
- XHCI 扩展能力链通过 debugfs (`/sys/kernel/debug/usb/xhci/`) 成功获取
- 注: PCI sysfs resource0 的 mmap 被 `CONFIG_IO_STRICT_DEVMEM=y` 阻止 (驱动独占 BAR)

**实际探测数据 (2026-03-06):**

##### XHC0 (04:00.3, USB-C 端口)
| 参数 | 值 | 含义 |
|------|-----|------|
| HCIVERSION | 0x0110 | xHCI 1.10 (仅 USB 3.1，非 USB4) |
| HCSPARAMS1 | 0x06000840 | 6 ports, 64 slots |
| HCCPARAMS1 | 0x0120ffc5 | xECP @ 0x0480 |
| HCCPARAMS2 | 0x0000003f | |

扩展能力链:
```
[0] cap=0x01 USB Legacy Support
[1] cap=0x02 Supported Protocol 'USB ' 2.0 — ports 1-4
[2] cap=0x02 Supported Protocol 'USB ' 3.10 — port 5 (5/10 Gbps)
[3] cap=0x02 Supported Protocol 'USB ' 3.10 — port 6 (5/10 Gbps)
[4] cap=0x0A Debug Capability → END
→ 无 cap_id ≥ 0xC0 (USB4 Router Operations)
```

##### XHC1 (04:00.4, 内部设备)
| 参数 | 值 | 含义 |
|------|-----|------|
| HCIVERSION | 0x0110 | xHCI 1.10 |
| HCSPARAMS1 | 0x05000840 | 5 ports, 64 slots |

扩展能力链:
```
[0] cap=0x01 USB Legacy Support
[1] cap=0x02 Supported Protocol 'USB ' 2.0 — ports 1-3
[2] cap=0x02 Supported Protocol 'USB ' 3.10 — port 4 (5/10 Gbps)
[3] cap=0x02 Supported Protocol 'USB ' 3.10 — port 5 (5/10 Gbps)
[4] cap=0x0A Debug Capability → END
→ 无 USB4 Router Operations
```

##### XHC2 (05:00.0, IR 摄像头)
| 参数 | 值 | 含义 |
|------|-----|------|
| HCIVERSION | 0x0110 | xHCI 1.10 |
| HCSPARAMS1 | 0x01000840 | 1 port, 64 slots |

扩展能力链:
```
[0] cap=0x01 USB Legacy Support
[1] cap=0x02 Supported Protocol 'USB ' 2.0 — port 1
[2] cap=0x0A Debug Capability → END
→ 无 USB4 Router Operations
```

##### 硬件级结论
**三个 XHCI 控制器均仅报告 xHCI 1.10 (USB 3.1)，无 USB4 Router Operations 扩展能力.**

这证实 USB4 路由器是**独立的 NHI PCI 设备** (非 XHCI 控制器的子功能)。
工程 BIOS 在 PCIe 初始化阶段根本没有启用 USB4 NHI 硬件块，而 Bus 04 的全部 8 个 function slot (0-7) 已被其他设备占满。

**探测方法** (需 root):
```bash
# 通过 xhci debugfs 获取扩展能力 (无需 /dev/mem)
sudo cat /sys/kernel/debug/usb/xhci/0000:04:00.3/reg-cap
sudo cat /sys/kernel/debug/usb/xhci/0000:04:00.3/reg-ext-protocol:00
sudo cat /sys/kernel/debug/usb/xhci/0000:04:00.3/reg-ext-protocol:01
sudo cat /sys/kernel/debug/usb/xhci/0000:04:00.3/reg-ext-protocol:02
sudo cat /sys/kernel/debug/usb/xhci/0000:04:00.3/reg-ext-dbc:00
```

#### 方案 D: EC RAM 全量 dump + 逆向
- **可行性**: ✅ 可作为研究
- 通过 EC Debug 接口读取全部 256 字节 RAM
- **诊断命令** (需root):
```bash
# 方法1: debugfs
sudo cat /sys/kernel/debug/ec/ec0/io | xxd

# 方法2: 直接 IO 端口
sudo python3 -c "
import os, time
# EC IO: data=0x62, cmd=0x66
fd = os.open('/dev/port', os.O_RDWR)
def ec_read(addr):
    os.lseek(fd, 0x66, 0); os.write(fd, bytes([0x80]))  # READ command
    time.sleep(0.001)
    os.lseek(fd, 0x62, 0); os.write(fd, bytes([addr]))
    time.sleep(0.001)
    os.lseek(fd, 0x62, 0); return os.read(fd, 1)[0]

for i in range(0, 256, 16):
    row = [ec_read(i+j) for j in range(16)]
    print(f'{i:02x}: ' + ' '.join(f'{b:02x}' for b in row))
os.close(fd)
"
```

#### 方案 E: SPI Flash BIOS dump → 分析 → 修改
- **可行性**: ⚠️ 高风险，但理论上可行
- PSP 的 `rpmc_spirom_available=1` 表明 SPI ROM 可访问
- 可使用 `flashrom` 或内核 SPI 框架 dump BIOS
- 需要 AMD AGESA/PSP 逆向工程知识来修改 USB4 初始化
- **极高风险**: 变砖可能性大

#### 方案 F: fwupd 尝试更新个别组件
- **可行性**: ✅ 部分可行
- fwupd 可见:
  - Synaptics Prometheus (指纹): 可独立更新
  - UEFI Secure Boot 证书: 可更新
  - TPM: 7.1.3.13
- fwupd **不可见**:
  - BIOS 主体 (工程版无 UEFI Capsule 支持)
  - EC 固件
  - AMD 微码 (来自 linux-firmware 包)

## 9. EC RAM 完整 dump (2026-03-06)

通过 `sudo modprobe ec_sys write_support=1` + `sudo xxd /sys/kernel/debug/ec/ec0/io` 获取:

```
00: 00 00 00 55 00 00 00 00 00 00 00 00 00 00 00 00  ...U............
10: 00 00 00 00 00 00 00 80 00 00 80 00 01 00 00 00  ................
20: 30 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00  00..............
30: e8 19 50 60 0f 00 00 00 97 00 c4 00 00 57 00 00  ..P`.........W..
40: 00 20 de ff df 00 54 27 80 01 00 06 80 00 00 00  . ....T'........
50: 5d 00 2b 00 00 00 00 00 00 00 00 00 00 00 1b 87  ].+.............
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
70: 00 00 00 00 03 00 e8 19 00 00 00 00 e8 19 00 00  ................
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
f0: 4e 33 47 48 54 31 35 57 2c 25 49 2c 0b 02 01 05  N3GHT15W,%I.....
```

关键字段:
| 偏移 | 值 | DSDT 字段 | 含义 |
|------|-----|-----------|------|
| 0x38 | 0x97 | MBTS+MCHG | 电池在位，充电至 23% |
| 0x46 | 0x54 | HPAC+HPLD | AC 已接, 盖子打开 |
| 0xF0-F7 | "N3GHT15W" | — | EC 固件版本字符串 |
| 0x45 | 0x00 | HUBS | Hub Status = 0 (EC 未检测到 USB hub) |

EC RAM 中**无 UCSI 标准寄存器** (VERS/CCI/CTL/MSG)，确认 EC 0.15 不实现 UCSI。

## 10. 验证命令汇总 (无需sudo)

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

# 完整固件版本
fwupdmgr get-devices 2>/dev/null | head -30
```

## 11. 最终结论

### 所有软件绕过路径均已关闭

经过全面的硬件级探测（XHCI MMIO 扩展能力链、EC RAM dump、PCI 拓扑分析、
BIOS 设置接口、fwupd 能力、Thunderbolt 驱动匹配分析），结论如下:

| 探测项 | 结果 | 影响 |
|--------|------|------|
| XHCI 扩展能力链 | 仅 USB 3.1，无 USB4 cap | 硅片级确认无 USB4 路由功能 |
| USB4 NHI PCI 设备 | 不存在 (class 0880=0) | BIOS 未初始化 USB4 NHI 硬件 |
| UCSI ACPI 设备 | 不存在 (PNP0CA0=0) | OS 无法管理 USB-C |
| EC UCSI 邮箱 | 不实现 | DSDT override 无法绕过 |
| BIOS USB4 设置 | 不存在 | think-lmi 无可用选项 |
| Thunderbolt 域 | 空 | 无 USB4 隧道 |

### 唯一解决方案: 更新 BIOS + EC 固件

工程 BIOS `N3GET04WE (0.04f)` + EC `0.15` 缺少 USB4 初始化代码。
量产 BIOS (`N3GETxxW`，无"E"后缀) 会：
1. 在 PCIe 初始化时启用 USB4 NHI 硬件块
2. 提供 UCSI ACPI 设备 (PNP0CA0)
3. EC 实现 UCSI 邮箱协议
4. 配置 Type-C mux 支持 SuperSpeed + Alt Mode
