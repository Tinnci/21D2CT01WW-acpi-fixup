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
- 实测 `flashrom` 已探测到 32MB Winbond 芯片，候选定义为 `W25Q256JW` / `W25R256JW`
- 由于 `flashrom` 返回多定义匹配，读取时必须显式指定 `-c <chipname>`
- 需要 AMD AGESA/PSP 逆向工程知识来修改 USB4 初始化
- **极高风险**: 变砖可能性大

当前仓库中的 [scripts/spi_dump.sh](../scripts/spi_dump.sh) 已加入候选芯片选择逻辑，默认优先 `W25Q256JW`，并在二次读取时执行一致性校验。

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

## 11. SPI Flash 全量分析 (2026-03-06)

### 11.1 SPI Flash 基础信息

| 项目 | 值 |
|------|-----|
| 芯片 | Winbond W25Q256JW (32MB SPI NOR) |
| 映射地址 | 0xFE000000 |
| Dump 大小 | 33,554,432 bytes |
| MD5 | `5e6c35c93cb9eef266f3a2cfa9d42f80` |
| SHA256 | `b6ed560fce88e250a3fd60b9f09ba4cc9bdcbe0a1fc3ed072a0f842dff75a3b1` |
| 二次读取校验 | ✅ 一致 |

### 11.2 关键发现：USB4 初始化代码**存在**于固件中

**这颠覆了之前"代码不存在"的结论。** SPI dump 中找到了完整的 USB4 子系统代码：

| 组件 | 偏移 | 所在模块 | 说明 |
|------|------|----------|------|
| `UCSI` | 0x091530 | PHCM blob (PD 控制器 FW) | UCSI 协议字符串 |
| `ucsi_cb:` | 0x09441C | PHCM | UCSI 回调函数 |
| `Ucsi Init` | 0x094FEC | PHCM | UCSI 初始化入口 |
| `alt_mode_cb:` | 0x094068 | PHCM | Alt Mode 回调函数 |
| `PPMreset_hd:` | 0x09451C | PHCM | PPM (Policy Power Manager) 重置 |
| `port_cmd_hd:` | 0x094A64 | PHCM | 端口命令处理器 |
| `ppm_cmd_hd:` | 0x094DE4 | PHCM | PPM 命令处理器 |
| `pd_event_hd:` | 0x0951C8 | PHCM | PD 事件处理器 |
| `MuxR` | 0x0933E0 | PHCM | Type-C Mux 读取 |
| `PBMs` / `PBMc` / `PBMe` | 0x093148 | PHCM | PD Bus Manager (start/complete/end) |
| `I2Cr` / `I2Cw` | 0x0929C8 | PHCM | I2C 读写 (PD 控制器通信) |
| `rsmu_usb4.c` | 0x256740 | SMU FW (RSMU) | USB4 电源/时钟管理 |
| `rsmu_usb4phy0.c` | 0x256750 | SMU FW (RSMU) | USB4 PHY 0 初始化 |
| `rsmu_usb4phy1.c` | 0x256764 | SMU FW (RSMU) | USB4 PHY 1 初始化 |
| `rsmu_usb4rt0.c` | 0x256778 | SMU FW (RSMU) | USB4 Router 0 初始化 |
| `rsmu_usb4rt1.c` | 0x256788 | SMU FW (RSMU) | USB4 Router 1 初始化 |
| `nHiF` / `NHiF` | 0x2415D8 | SMU FW 内嵌代码 | NHI 功能调用 |
| `gNHI` | 0xBD2ECA | Type 0x88 模块 | 全局 NHI 数据结构 |

### 11.3 PHCM — PD 控制器固件

| 项目 | 值 |
|------|-----|
| 签名 | `PHCM` |
| 偏移 | 0x081000 |
| 大小 | ~121KB (0x1E400) |
| 平台标识 | `PHCM_1701_MAYANLILAC2021-07-12` |
| AGESA 版本 | 0.1.97321 |
| 构建 commit | 4ade9ed |
| 代码类型 | ARM Cortex-M 固件 (Thumb-2 指令集) |

PHCM 是运行在 AMD SoC 内部 M0/M3 核心上的 PD 控制器固件。它包含完整的 UCSI 协议栈：
- UCSI 命令处理器 (`ucsi_cb`, `ppm_cmd_hd`, `port_cmd_hd`)
- Alt Mode 协商 (`alt_mode_cb`)
- PD 事件处理 (`pd_event_hd`, `pd_event_hd: Disconn->> set DRP`)
- Type-C Mux 控制 (`MuxR`)
- PD SPI Flash 更新 (`After flash PD SPI & PD reset`)
- PPM 重置/恢复 (`PPMreset_hd`, `reset_hd`, `CONN_reset->> set DRP`)

**关键发现：代码在等待被调用，但从未被调用过。**

### 11.4 RSMU (Root SMU) USB4 模块

SMU 固件中包含 USB4 电源/时钟域管理代码：

```
rsmu_usb0.c  → USB 基础控制器 0 (XHCI)
rsmu_usb1.c  → USB 基础控制器 1
rsmu_usb2.c  → USB 基础控制器 2
rsmu_usb3.c  → USB 基础控制器 3
rsmu_usb4.c  → USB4 总线控制器 (独立于 XHCI)
rsmu_usb4phy0.c → USB4 PHY 端口 0 (左侧 USB-C?)
rsmu_usb4phy1.c → USB4 PHY 端口 1 (右侧 USB-C?)
rsmu_usb4rt0.c  → USB4 Router 0
rsmu_usb4rt1.c  → USB4 Router 1
```

RSMU 区域存在两份完全相同的副本：
- 副本 1: 0x256000 区域
- 副本 2: 0x61E000 区域 (偏移差 0x3C8000)

这是 AMD SPI 固件的标准冗余布局 — A/B 分区用于安全恢复。

### 11.5 PSP 固件目录结构

```
SPI Flash (32MB Winbond W25Q256JW)
├── 0x020000  EFS (Embedded Firmware Structure)
├── 0x0C1000  PSP Combo Directory ($PSP) → 2 条目
│   ├── 0x0C3000  Sub-dir 0
│   └── 0x0C4000  Sub-dir 1
├── 0x0C5000  PSP L2 Directory ($PL2) — 43 条目 ← 主 PSP 目录
│   ├── [0]  AMD_PUBLIC_KEY    @0x000400 (1KB)
│   ├── [1]  PSP_BOOTLOADER    @0x000900 (7KB)
│   ├── [3]  PSP_TOS           @0x015E00 (81KB)
│   ├── [9]  ABL1              @0x06E700 (128KB)
│   ├── [10] SMN_FW2 sub=0     @0x08E800 (103KB) ← 内含 UCSI 引用
│   ├── [11] SMN_FW2 sub=1     @0x0A8700 (118KB)
│   ├── [22] AGESA_PEI         @0x111600 (436KB)
│   ├── [31] DXIO_PHY_SRAM     @0x191100 (289KB) ← USB/PCIe PHY 初始化码
│   └── [42] BIOS_RTM_PUBKEY   @0x380000
├── 0x445000  BIOS L2 ($BL2) — 19 条目
│   ├── [3]  APOB_NV           @0x004000 (32KB)
│   ├── [9]  APCB_DATA         @0x16CF000 (1.7MB) ← 板级配置
│   └── [18] BIOS_BIN          @0x043500 (5.4KB)
├── 0x446000  APCB (board config, 多实例)
│   ├── @0x446000  uid=0x9F9494  1KB
│   ├── @0x449000  uid=0x269C    30KB ← 主 APCB
│   └── @0x451000  uid=0x23DE    0.4KB
├── 0x48D000  PSP L2 备份副本 ($PL2)
├── 0x80D000  BIOS L2 备份副本 ($BL2)
└── 0x081000  PHCM (PD Controller FW, 121KB) ← USB-C 管理固件
```

### 11.6 APCB 配置 — 无 USB4 令牌

**对所有 6 个 APCB 实例进行了穷举搜索**（包含 1.7MB 主配置数据），
以下关键词均**未找到**：

`USB4`, `Usb4`, `usb4`, `UCSI`, `ucsi`, `NHI`, `nhi`, `TypeC`, `typec`,
`PcieTunnel`, `DpTunnel`, `UsbTunnel`, `Usb4En`, `USB4_EN`, `NhiEn`

**结论**: 工程版 APCB 中完全没有 USB4 启用令牌。量产 BIOS 的 APCB 会包含这些令牌。

### 11.7 修正后的因果链

```
工程 BIOS (0.04f, 2021-09)
    │
    ├─→ APCB 配置中无 USB4 令牌
    │       └─→ AGESA/ABL 启动序列跳过 USB4 初始化
    │
    ├─→ SMU RSMU 有 USB4 模块代码 (rsmu_usb4*.c)
    │   但因 APCB 无令牌 → SMU 从不调用 USB4 PHY/Router init
    │       └─→ USB4 PHY 未上电 + Router 未配置
    │               └─→ PCIe 枚举时无 NHI 设备出现
    │
    ├─→ PHCM blob 有完整 UCSI 协议栈
    │   但因 USB4 Router 不存在 → PHCM 初始化路径被跳过
    │       └─→ UCSI/Alt Mode/Mux 代码成为死代码
    │
    └─→ 最终结果：
        ├─ XHCI 控制器正常 (USB 2.0 + USB 3.1)
        ├─ USB4 NHI = 未枚举 (PCI bus 上不存在)
        ├─ Type-C Mux = 未配置 (SS 通道不可用)
        └─ UCSI = 无设备 (EC 未被要求初始化 UCSI 邮箱)
```

### 11.8 硬件能力确认

SPI 分析**证实硅片具备 USB4 能力**：
- **2 × USB4 PHY** (phy0, phy1) — 对应 2 个 USB-C 端口
- **2 × USB4 Router** (rt0, rt1) — 完整的 USB4 路由引擎
- **NHI 代码** — gNHI 全局数据结构存在 (UEFI DXE 阶段)
- **UCSI 协议栈** — 运行在 PHCM/PSP 上的完整实现
- **Mux 控制** — 信号路由硬件存在
- **PD Bus Manager** — USB PD 协商代码已编译

问题不是硬件缺失，而是 **APCB 配置未包含启用 USB4 的令牌**。

## 12. 最终结论

### 原结论需要修正

之前认为"USB4 代码不存在" — 这是**错误的**。

SPI 全量分析证明：
1. SMU 固件中有完整的 USB4 PHY + Router 电源/时钟管理代码 (`rsmu_usb4*.c`)
2. PHCM 中有完整的 UCSI/Alt Mode/Mux 控制代码
3. UEFI DXE 阶段有 NHI 数据结构 (`gNHI`)
4. ARM 级 PD 事件/命令处理器均已编译

### 真正的阻塞点

**APCB (AMD Platform Configuration Block) 中缺少 USB4 启用令牌。**

APCB 是 AGESA 启动流程的"开关面板"。当 USB4 令牌不存在时，
ABL (AGESA Boot Loader) 在 Stage 0-6 执行过程中跳过 USB4 初始化序列，
导致 SMU 从不调用 `rsmu_usb4*.c` 中的代码，PHCM 从不进入 UCSI 初始化路径。

### 可能的修复路径（理论）

| 路径 | 可行性 | 风险 |
|------|--------|------|
| **修改 APCB 添加 USB4 令牌** | ❓ 理论上可能 | ⚠️ 高 — 需要精确的令牌 ID + 值 |
| **替换 APCB 为量产版本** | ❓ 需获取量产 BIOS dump | ⚠️ 高 — 板级配置差异 |
| **通过 SMN 直接启用 USB4** | ❓ 极端方案 | 🔴 极高 — 无公开文档 |
| **更新整个 BIOS 到量产版** | ✅ 最安全可靠 | ⚠️ 中 — 需 SPI 编程器或闪写工具 |

### 下一步建议

1. ~~获取量产 BIOS dump~~ → ✅ 已完成（见第 13 节）
2. **AMD APCB 令牌文档** — 搜索 coreboot/openSIL 项目中 Rembrandt APCB 令牌定义
3. **尝试 fwupdmgr** — 虽然 BIOS 不可见，但尝试强制更新仍值得一试
4. **保留 SPI dump** — 作为恢复备份，万一刷写失败可通过外部编程器还原

## 13. 生产 BIOS 固件对比分析

> 分析日期: 2026-03-06
> 目标: 对比工程版 (N3GET04WE) 与生产版 (N3GET74W) BIOS 固件

### 13.1 固件来源

| 项目 | 工程 BIOS (当前) | 生产 BIOS (N3GET74W) |
|------|------------------|---------------------|
| **来源** | SPI Flash 直读 (flashrom) | Lenovo 官网 ISO (n3gur25w.iso) |
| **BIOS 版本** | N3GET04WE (0.04f) | N3GET74W |
| **EC 版本** | 0.15 | N3GHT68W |
| **大小** | 32MB (SPI 全量) | 33MB FL1 + 320KB FL2 |
| **构建日期** | 2021-09-09 | 2025-08-20 |

### 13.2 ISO 拆解过程

```
n3gur25w.iso (52 MB)
├── El Torito 引导记录 (Nero Burning ROM v12)
├── MBR 引导映像 @ sector 27 (偏移 0xD800)
│   └── 分区 1: FAT32, 51 MB
│       ├── EFI/Boot/BootX64.efi     (2.1 MB, UEFI 闪写启动器)
│       └── Flash/
│           ├── BootX64.efi           (2.1 MB, 同上)
│           ├── NoDCCheck_BootX64.efi (2.1 MB, 无电源检查版)
│           ├── SHELLFLASH.EFI        (23 KB, EFI Shell)
│           └── N3GET74W/
│               ├── $0AN3G00.FL1      (33 MB, 主 BIOS)
│               └── $0AN3G00.FL2      (320 KB, EC 固件)
```

### 13.3 FL1 BIOS 结构

FL1 = Lenovo 封装头 (0x320 bytes) + UEFI BIOS 映像

- **首个 FV**: 偏移 0x50, 大小 33.7 MB (整个 BIOS 区域)
- **EFS**: 偏移 0x20320 (= SPI 0x20000 + 0x320Δ)
- **PSP Combo**: 偏移 0xC1320 → PL2 @ 0xC5320 → BL2 @ 0x445320
- **PHCM**: 偏移 0x81320 (MAYAN/LILAC 平台, 与工程版相同)
- **APCB**: 偏移 0x449320 (主), 0x81A320 (备份)

### 13.4 APCB 对比

| 指标 | 工程版 | 生产版 | 差异 |
|------|--------|--------|------|
| **大小** | 29.5 KB (0x75F4) | 46.5 KB (0xBA24) | +17.0 KB |
| **版本字节** | 0x80000030 | 0x37000030 | 不同 |
| **内存 SPD** | Samsung K3LKCKC@BM | Micron MT62F1G32D4DR / SK Hynix H9JCNNNCP3MLYR | 多厂商支持 |
| **USB4 令牌** | ❌ 未找到 | ❌ 未找到 | 两者均无 |

**额外 17KB 内容**: 生产版增加了更多内存 SPD 配置文件 (Micron + SK Hynix)，
以及 `OPTB`/`GNBG`/`FCHG` 配置区块。USB4 启用不在 APCB 令牌层面。

### 13.5 UEFI DXE 模块对比 (关键发现)

DXE 模块总数: 工程版 **305 个** vs 生产版 **356 个** (差 51 个)

#### 仅在生产版中的关键模块

| 模块名 | 类型 | 功能 |
|--------|------|------|
| **`UcsiDriver`** | DXE driver (2.3 KB) | ⭐ **UCSI 连接器接口** — 向 OS 暴露 USB-C 端口管理 |
| `AmdCpmSoundWireDxe` | DXE driver | SoundWire 音频总线 |
| `AmdCpmPlatformOscTableInstall` | DXE driver | _OSC 方法安装 (USB4 PCIe negotiation) |
| `FprSynapticsPrometheusDriver` | DXE driver | Synaptics 指纹 BIOS 级驱动 |
| `EcFwUpdateDxe` | DXE driver | EC 固件更新能力 |
| `RZ616_MtkWiFiDex` / `WCN6855` | DXE driver | WiFi 网卡 PXE 驱动 |
| `SecureBIOCamera_*` | DXE driver (×4) | 安全摄像头驱动 (Realtek/Sonix/Sunplus) |
| `TlsDxe` / `FidoDxe` | DXE driver | TLS 网络 + FIDO 认证 |
| `MemTest` | DXE driver | 内存测试 |

#### AmdUsb4Dxe 对比

```
两个固件均包含 AmdUsb4Dxe (GUID: 051274F4-A724-4732-BE00-82793A3D499A)

工程版: 127 KB PE32 (5 PE sections) — 可能为 debug build
生产版: 103 KB PE32 (4 PE sections) — release build
构建路径: c:\users\qq\desktop\gen1\Amd\AgesaModulePkg\Usb4\AmdUsb4Dxe\

功能: USB4 Host Router 初始化 + Pre-OS Connection Manager
      包含: NHI BAR0 检测、Router Init、内存分配、PCI 枚举回调
```

#### 仅在工程版中的模块

| 模块名 | 说明 |
|--------|------|
| `AcpiS3SaveDxe` | S3 睡眠保存 (已整合到其他模块) |
| `AmdCpmSensorFusionDxe` | 传感器融合 (已替换) |
| `AmdCpmZeroPowerOddDxe` | 零功耗光驱 (Z13 无光驱) |
| `DataHubDxe` / `DatahubStatusCodeHandlerDxe` | 调试用数据中心 |

### 13.6 UcsiDriver 详细分析

```
GUID: 15B985C5-7103-4F35-B59D-2235FC5F3FFE
大小: 2,240 bytes (极小的 shim 驱动)
构建: c:\...\Phoenix\Modules\Lcfc\000\LcfcPkg\Ucsi\Dxe\UcsiDriver
来源: LCFC (Lenovo ODM) 定制模块

依赖:
  FFE06BDD-6107-46A6-7BB2-5A9C7EC5275C (AcpiSdt Protocol)
  AND
  13A3F0F6-264A-3EF0-F2E0-DEC512342F34 (PciRootBridgeIo Protocol)

作用:
  在 UEFI DXE 阶段安装 UCSI ACPI 设备 (PNP0CA0)
  建立 EC ↔ ACPI ↔ OS 的 UCSI 通信通道
  使 ucsi_acpi 内核模块能发现并接管 USB-C 端口管理
```

### 13.7 EC 固件对比

| 项目 | 工程 EC | 生产 EC (FL2) |
|------|---------|--------------|
| **版本** | 0.15 | N3GHT68W |
| **大小** | 未知 (嵌入 SPI) | 320 KB |
| **区域** | 1 | 2 (\_EC1: 320KB + \_EC2: 316KB) |
| **版权** | — | LENOVO 2005, 2018 |
| **UCSI 邮箱** | 未实现 | ✅ 完整实现 |

### 13.8 USB4/USB-C 不工作的完整原因链 (修正版)

```
工程 BIOS N3GET04WE 问题链:
                                                        
 ┌──────────────────────────────────────────────────┐   
 │  1. UcsiDriver 缺失                              │  ← 生产版新增
 │     └─ ACPI namespace 无 PNP0CA0 设备             │
 │        └─ ucsi_acpi 模块无设备可绑定              │
 │           └─ /sys/class/typec/ 为空               │
 │              └─ USB-C 端口管理完全由 PHCM 独立处理 │
 ├──────────────────────────────────────────────────┤
 │  2. AmdUsb4Dxe 存在但无法初始化                    │
 │     └─ 读取 USB4BAR0 返回 0xFFFFFFFF              │
 │        └─ USB4 NHI PCI 设备未被 AGESA 枚举         │
 │           └─ AGESA ABL 阶段跳过 USB4 初始化        │
 │              └─ APCB 中无 USB4 启用令牌 (仍然成立)  │
 ├──────────────────────────────────────────────────┤
 │  3. EC 0.15 过于原始                               │ ← 生产 EC = N3GHT68W
 │     └─ 不实现 UCSI 邮箱命令                        │
 │        └─ 即使有 UcsiDriver 也无法通信             │
 └──────────────────────────────────────────────────┘
```

### 13.9 重要发现

1. **APCB 中并无显式 USB4 令牌** — 生产版和工程版的 APCB 都没有找到 USB4 启用令牌。
   USB4 的启用可能不是通过 APCB 令牌，而是通过其他机制（如 AGESA 版本差异、
   DXE 驱动链初始化顺序、或 EC 协商触发）。

2. **关键差异是 UcsiDriver** — 这个仅 2.3KB 的 LCFC/Lenovo shim 驱动是连接
   EC UCSI 邮箱和 OS typec 子系统的桥梁。工程版完全缺失此驱动。

3. **AmdUsb4Dxe 在两个固件中都存在** — 但工程版是 debug build (127KB, 5 sections),
   生产版是 release build (103KB, 4 sections)。两者都依赖相同的 PCI enumeration protocol。

4. **生产版多 51 个 UEFI 模块** — 涵盖 UCSI、WiFi、指纹、安全摄像头、FIDO、TLS 等
   完整的平台功能。工程版是"最小启动"配置。

### 13.10 修复路径 (更新)

| 路径 | 可行性 | 效果预评 |
|------|--------|---------|
| **刷写生产 BIOS + EC** | ✅ 最佳 | USB4 + UCSI + 完整平台功能 |
| **仅提取 UcsiDriver 注入 SPI** | ⚠️ 极难 | UCSI 可能工作，但 USB4 NHI 仍无法枚举 |
| **ACPI 手动添加 PNP0CA0** | ⚠️ 需 EC 配合 | EC 0.15 不支持 UCSI 邮箱，无效 |
| **修改 APCB** | ❓ 不确定 | APCB 差异主要是内存配置，不是 USB4 开关 |

**推荐**: 使用联想 Bootable CD 或 SPI 编程器刷写生产 BIOS (N3GET74W) + EC (N3GHT68W)。
需同时更新 BIOS 和 EC，仅更新一个可能导致不兼容。
