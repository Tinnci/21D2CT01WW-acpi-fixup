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

**基本信息：**
```
GUID:   15B985C5-7103-4F35-B59D-2235FC5F3FFE
大小:   2,240 bytes (PE32), .text=881 bytes, .data=584 bytes
构建:   c:\users\qq\desktop\gen1\Build\PM\RELEASE_VS2015x86\X64\
        Phoenix\Modules\Lcfc\000\LcfcPkg\Ucsi\Dxe\UcsiDriver\
来源:   LCFC (联想 ODM) 定制模块, Phoenix UEFI 框架
```

**DXE 依赖 (FFS DEPEX)：**
```
FFE06BDD-6107-46A6-7BB2-5A9C7EC5275C  (gEfiAcpiTableProtocolGuid)
AND
13A3F0F6-264A-3EF0-F2E0-DEC512342F34  (gEfiPciRootBridgeIoProtocolGuid)
```

**引用的 GUID 清单 (.data 区)：**
| 偏移 | GUID | 用途 |
|------|------|------|
| 0x5E0 | `5B1B31A1-9562-11D2-8E3F-00A0C969723B` | gEfiLoadedImageProtocolGuid |
| 0x5F0 | `11B34006-D85B-4D0A-A290-D5A571310EF7` | Phoenix/LCFC PCD 查询协议 |
| 0x600 | `220E73B6-6BDB-4413-8405-B974B108619A` | Phoenix FV ACPI 模板协议 |
| 0x610 | `FFE06BDD-6107-46A6-7BB2-5A9C7EC5275C` | gEfiAcpiTableProtocolGuid |
| 0x620 | `7739F24C-93D7-11D4-9A3A-0090273FC14D` | EFI 配置表搜索 GUID |
| 0x630 | `D1FFD9A6-6107-4E75-BF20-FF8F2FE58287` | UCSI SSDT 模板 A (非 3 端口) |
| 0x640 | `4DB7E114-32E2-4324-9845-2B3FCDAF3AEC` | UCSI SSDT 模板 B (3 端口) |

**完整执行流程 (Capstone x86-64 反汇编)：**

```
UefiMain(ImageHandle, SystemTable)        [0x2E0]
 │
 ├─ 保存全局指针: gBS, gRT, gST, gImageHandle
 │
 ├─ LocateConfigTable()                    [0x4AC]
 │   └─ 遍历 SystemTable->ConfigurationTable[]
 │      搜索 GUID {7739F24C-...}
 │      缓存 VendorTable → gConfigData
 │
 ├─ MainUcsiLogic()                        [0x318]
 │   │
 │   ├─ GetPhoenixProtocol()               [0x470]
 │   │   └─ LocateProtocol({11B34006-...}) → Phoenix PCD 协议
 │   │
 │   ├─ [protocol+8](0x241)               ← PCD token 查询
 │   │   │  检查 USB-C 端口数量配置
 │   │   │
 │   │   ├─ if FALSE: 选择模板 A  → GUID {D1FFD9A6-...}  (UcsiAsl/Ucsi2PortsAsl)
 │   │   └─ if TRUE:  选择模板 B  → GUID {4DB7E114-...}  (Ucsi3PortsAsl)
 │   │
 │   ├─ GetDeviceHandle()                  [0x518]
 │   │   └─ HandleProtocol(gImageHandle, LoadedImageProtocol)
 │   │      → 返回驱动所在 FV 的 DeviceHandle
 │   │
 │   ├─ OpenAcpiTemplate()                 [0x550]
 │   │   └─ HandleProtocol(DeviceHandle, {220E73B6-...})
 │   │      → 从 FV 加载所选 GUID 的 SSDT AML 模板
 │   │      → 返回 (AmlTablePtr, TableSize, AcpiHandle)
 │   │
 │   ├─ AML 模式扫描 #1: OperationRegion(USBC,...)
 │   │   │  逐字节搜索: 80 55 53 42 43 XX 0C DDDDDDDD 0A LL
 │   │   │  即 AML: OpRegionOp "USBC" <Space> DWordPrefix <Offset> BytePrefix <Len>
 │   │   │
 │   │   ├─ AllocatePages(MaxAddress, ACPIMemoryNVS, 1)
 │   │   │   → 分配 1 页 (4KB) ACPI NVS 内存 (< 4GB)
 │   │   │
 │   │   ├─ ZeroMem(buffer, 0x30)
 │   │   │   → 清零 48 字节 = UCSI 数据结构大小
 │   │   │
 │   │   │   ┌─────────── UCSI 邮箱布局 (48 bytes) ───────────┐
 │   │   │   │ +0x00  CCI    (4B)   连接器能力指示符          │
 │   │   │   │ +0x04  CTRL   (8B)   控制寄存器                │
 │   │   │   │ +0x0C  MGI    (16B)  消息输入                  │
 │   │   │   │ +0x1C  MGO    (16B)  消息输出                  │
 │   │   │   │ +0x2C  VER    (2B)   UCSI 版本                 │
 │   │   │   │ +0x2E  RSV    (2B)   保留                      │
 │   │   │   └───────────────────────────────────────────────┘
 │   │   │
 │   │   ├─ 补丁 [rdi+7] = allocated_address   (DWord 偏移)
 │   │   └─ 补丁 [rdi+0xC] = 0x30              (长度 = 48)
 │   │
 │   ├─ AML 模式扫描 #2: Name(RBUF,...)
 │   │   │  搜索: 08 52 42 55 46 ... 55AA55AA
 │   │   │  即 AML: NameOp "RBUF" ... DWordConst 0x55AA55AA
 │   │   │
 │   │   └─ 补丁 0x55AA55AA → allocated_address
 │   │      (ResourceTemplate DWordMemory 基址)
 │   │
 │   └─ LocateProtocol(gEfiAcpiTableProtocolGuid)
 │      └─ InstallAcpiTable(patchedSSDT, tableSize, &tableKey)
 │         → 将补丁后的 SSDT 安装到 ACPI namespace
 │
 └─ return EFI_SUCCESS
```

**伴随 SSDT 模板 (同 FV 内)：**
```
FFS #291: UcsiDriver          (PE32 DXE 驱动)
FFS #292: Ucsi3PortsAsl       (3 端口 SSDT 模板, GUID {4DB7E114-...})
FFS #293: UcsiAsl             (通用 SSDT 模板)
FFS #294: Ucsi2PortsAsl       (2 端口 SSDT 模板, GUID {D1FFD9A6-...})
```

SSDT 模板包含 (推断):
- `Device(\_SB.UCSI)` 定义, `_HID = "PNP0CA0"`
- `OperationRegion(USBC, SystemMemory, <占位偏移>, <占位长度>)`
- `Field(USBC, ...)` 映射 CCI/CTRL/MGI/MGO/VER 字段
- `Name(RBUF, ResourceTemplate(){ DWordMemory(...0x55AA55AA...) })`
- `Method(_CRS)` 返回 RBUF
- `Method(_DSM)` 实现 UCSI 功能接口

**辅助函数：**
| 地址 | 函数 | 功能 |
|------|------|------|
| 0x260 | CopyMem | 内存拷贝 (支持重叠) |
| 0x2A0 | ZeroMem | 内存清零 |
| 0x2C0 | CompareMem | 内存比较 |
| 0x470 | GetPhoenixProtocol | LocateProtocol 缓存包装 |
| 0x4AC | LocateConfigTable | 搜索 EFI 配置表 |
| 0x518 | GetDeviceHandle | 获取驱动所在 FV 句柄 |
| 0x550 | OpenAcpiTemplate | 从 FV 加载 SSDT 模板 |

**关键技术洞察：**
- 这是一个 **运行时 ACPI 表补丁器**，不是传统意义上的设备驱动
- UCSI 共享内存通过 `AllocatePages(EfiACPIMemoryNVS)` 动态分配
- 使用字节扫描 AML 并原地修补占位符地址 — 标准 Phoenix BIOS 做法
- PCD token 0x241 (577) 决定端口数量模板选择 (ThinkPad Z13 为 2 端口)
- OEM ID 嵌入 "INTEL " — 表明此 SSDT 框架源自 Intel UCSI 参考实现

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

2. **UcsiDriver 是运行时 ACPI 表补丁器** — 经完整逆向工程确认，这个 2.3KB 的驱动
   并非传统设备驱动，而是:
   - 从同 FV 加载预编译 SSDT 模板 (含 PNP0CA0 设备定义)
   - 动态分配 48 字节 ACPI NVS 内存作为 UCSI 邮箱
   - 字节扫描 AML 并补丁 OperationRegion(USBC) 偏移和 Name(RBUF) 地址
   - 通过 EFI_ACPI_TABLE_PROTOCOL 安装补丁后的 SSDT
   - 根据 PCD token 0x241 选择 2 端口或 3 端口 SSDT 模板

3. **生产版包含 4 个 UCSI FFS 文件** — UcsiDriver + 3 个 SSDT 模板
   (UcsiAsl, Ucsi2PortsAsl, Ucsi3PortsAsl)，工程版零个。

4. **AmdUsb4Dxe 在两个固件中都存在** — 但工程版是 debug build (127KB, 5 sections),
   生产版是 release build (103KB, 4 sections)。两者都依赖相同的 PCI enumeration protocol。

5. **生产版多 51 个 UEFI 模块** — 涵盖 UCSI、WiFi、指纹、安全摄像头、FIDO、TLS 等
   完整的平台功能。工程版是"最小启动"配置。

6. **UCSI 邮箱是标准 48 字节结构** — CCI(4B) + CTRL(8B) + MGI(16B) + MGO(16B) + VER(2B) + RSV(2B)，
   通过 SystemMemory OperationRegion 映射，OS 端由 ucsi_acpi 内核模块通过 ACPI 方法访问。

### 13.10 修复路径 (更新)

| 路径 | 可行性 | 效果预评 |
|------|--------|---------|
| **刷写生产 BIOS + EC** | ✅ 最佳 | USB4 + UCSI + 完整平台功能 |
| **仅提取 UcsiDriver + SSDT 注入** | ⚠️ 极难 | 需同时注入 4 个 FFS 文件到 FV，且 EC 0.15 不支持 UCSI 邮箱 |
| **ACPI 手动添加 PNP0CA0** | ⚠️ 需 EC | 驱动逻辑需 EC 实现 UCSI 邮箱读写 + SCI 中断，EC 0.15 无此功能 |
| **修改 APCB** | ⚠️ 部分可能 | GNBG 组中发现明确的端口 USB4 使能位差异（详见 §14） |

**推荐**: 使用联想 Bootable CD 或 SPI 编程器刷写生产 BIOS (N3GET74W) + EC (N3GHT68W)。
需同时更新 BIOS 和 EC，仅更新一个可能导致不兼容。

> **逆向工程结论**: UcsiDriver 的 48 字节 UCSI 邮箱需要 EC 主动参与 —
> EC 必须监听 CTRL 寄存器写入、执行 UCSI 命令、更新 CCI 状态位、
> 并通过 GPIO/SCI 通知 OS。这不是纯软件可以绕过的限制。

## 14. 实机探测与 AMD SMN 寄存器扫描 (2026-03-06)

> 此章节基于运行中系统的实时寄存器读取，不是固件二进制分析。

### 14.1 EC 固件探测

使用自定义 `ec_probe.py` 工具（通过 /dev/port 直接访问 EC I/O 端口 0x62/0x66）：

| 测试 | 结果 |
|------|------|
| EC 寄存器 dump (256B) | ✅ 成功, 与 ec_sys 一致 |
| EC 固件版本 | `N3GHT15W` (寄存器 0xF0-0xF7) |
| 扩展读取 0xA0-0xAF | ❌ 无响应 (5种协议变体全部超时) |
| 厂商命令 0xCE/0xCF | ❌ 状态 0x08 (CMD set), 无数据返回 |
| **结论** | 工程 EC 不支持扩展命令和厂商命令 |

**EC 寄存器空间关键字段:**
```
A0-AF: 00 00 00 00 FF FF 00 00  00 00 00 00 FF FF 00 00  ← 两端口, 0xFFFF = 未枚举
F0-F7: 4E 33 47 48 54 31 35 57  = "N3GHT15W"
```

### 14.2 USB 设备拓扑（实时）

```
Bus 1 (XHC0 HS):  Hub 5059:5058 @480M → Billboard 5059:5059 + Microchip DFU @12M + Camera @480M
Bus 2 (XHC0 SS):  ← 完全空闲
Bus 3 (XHC1 HS):  Intel L830 WWAN @480M + Synaptics Fingerprint @12M
Bus 4 (XHC1 SS):  ← 完全空闲
Bus 5 (XHC2 HS):  IR Camera @480M
```

**Billboard 设备详情:** wSVID=0xFF01, iAlternateModeSetting="Alt Mode configuration successful", bmConfigured=0x03。  
EC 的 PD 状态机 **正确完成了 DP Alt Mode 协商**，但 PHY mux 未路由 SS 信号。

### 14.3 USB4 XHCI PORTSC 寄存器

通过 /dev/mem 直接读取 XHCI 内存映射寄存器：

| 控制器 | 端口 | 地址偏移 | PORTSC | 解码 |
|--------|------|----------|--------|------|
| XHC0 | HS01 | +0x480 | 0x0A0002A0 | RxDetect, 无设备 |
| XHC0 | HS02 | +0x490 | 0x0C000E63 | U3, HS, 已连接 |
| XHC0 | HS03 | +0x4A0 | 0x0C000663 | U3, FS, 已连接 |
| XHC0 | HS04 | +0x4B0 | 0x0C000E63 | U3, HS, 已连接 |
| XHC0 | **SS01** | +0x4C0 | **0x0A0002A0** | **RxDetect, 无SS信号** |
| XHC0 | **SS02** | +0x4D0 | **0x0A0002A0** | **RxDetect, 无SS信号** |
| XHC1 | SS03-SS04 | | 0x0A0002A0 | 同样 RxDetect |

### 14.4 AMD SMN 寄存器深度扫描

通过 PCI Root Complex (0000:00:00.0) SMN_INDEX/SMN_DATA (offset 0x60/0x64) 访问：

#### USB4 PHY (3个实例，配置相同)

| SMN 地址 | 值 | 含义 |
|----------|-----|------|
| 0x16C00000 | 0x01100020 | PHY #0 存在, 已上电 |
| 0x16C10000 | 0x01100020 | PHY #1 存在, 已上电 |
| 0x16C20000 | 0x01100020 | PHY #2 存在, 已上电 |
| 0x16C00420 | 0x0A0002A0 | **Port 0: RxDetect** (与 XHCI SS01 一致) |
| 0x16C00430 | 0x0C000E63 | Port 1: U3, HS, Connected |
| 0x16C00460 | 0x0A0002A0 | **Port 4: RxDetect** |
| 0x16C00470 | 0x0A0002A0 | **Port 5: RxDetect** |
| 0x16C00494 | 0x20425355 | "USB " — USB 能力标识符 |
| 0x16C004A4 | 0x20425355 | "USB " — SS端口#1 能力 |
| 0x16C004C4 | 0x20425355 | "USB " — SS端口#2 能力 |
| 0x16C00500 | 0x000F0000 | PHY 配置 (非零 = 已初始化) |

PHY SERDES 初始化表 (0xB000-0xB55C) 完整存在，校准数据 (0xC100-0xC700) 正常。

#### USB IP Discovery

| SMN 地址 | 值 | 含义 |
|----------|-----|------|
| 0x16600000 | 0xFFFFFFFF | **USB IP Discovery 完全禁用/不可访问** |

#### USB4 Router

| SMN 地址 | 值 | 含义 |
|----------|-----|------|
| 0x16D20000 | 0x000054CD | Router 存在, 部分初始化 |
| 0x16D20008 | 0x00000070 | 配置大小 |
| 0x16D20080 | 0x00004000 | 路由表 |
| 0x16D20090-0xF0 | 非零 | 链路参数 (等化, CDR 等) |
| 0x16D20100 | 0x00000080 | 端口 A 配置 |
| 0x16D20104 | 0x00000080 | 端口 B 配置 |

#### FCH USB 控制器 (3个实例)

| SMN 地址 | 值 | 含义 |
|----------|-----|------|
| 0x16ED0000 | 0x01100020 | FCH USB #0 存在 |
| 0x16EE0000 | 0x01100020 | FCH USB #1 存在 |
| 0x16EF0000 | 0x01100020 | FCH USB #2 存在 |

#### SMU 邮箱

| SMN 地址 | 值 | 含义 |
|----------|-----|------|
| 0x03B10528 | 0x0000001C | MP1_SMN_C2PMSG_40 (SMU 响应寄存器) |
| 0x03B10570 | 0x00000001 | MP1_SMN_C2PMSG_58 (SMU 就绪标志) |

**关键结论: USB4 PHY 硬件存在且上电, 但 USB IP Discovery 禁用 → AGESA/APCB 级配置缺失。**

### 14.5 PCI 拓扑

```
-[0000:00]-+-00.0  Root Complex (SMN Access)
           +-01.1  → Bus 01 (空! NHI 应在此)  ← 有 I/O 和 Memory 分配但无设备
           +-01.2  → Bus 02 (WiFi: QCNFA765)
           +-02.4  → Bus 03 (NVMe: YMTC)
           +-08.1  → Bus 04 (内部)
           |  04:00.3  XHC0 [1022:161a] "Rembrandt USB4 XHCI controller #1"
           |  04:00.4  XHC1 [1022:161b] "Rembrandt USB4 XHCI controller #2"
           +-08.3  → Bus 05
           |  05:00.0  XHC2 [1022:161c] "Rembrandt USB4 XHCI controller #7"
```

**Bus 01 分配了资源但为空** — 这是 USB4 NHI 设备应该出现的位置。
Root port 00:01.1 → secondary bus 01, 有 I/O (2000-2fff) 和 Memory (d0200000-d03fffff) 分配。

### 14.6 Thunderbolt 和 TypeC 驱动状态

手动加载后：

```
thunderbolt           610304  1 typec        ← 模块加载成功
typec_ucsi             77824  1 ucsi_acpi    ← UCSI 驱动加载
ucsi_acpi              12288  0              ← ACPI 绑定无设备
```

- `/sys/bus/thunderbolt/devices/` — 空 (无 NHI → 无法发现域)
- `/sys/class/typec/` — 空 (无 UCSI 设备 → 无端口注册)
- dmesg: `ACPI: bus type thunderbolt registered` — 仅此一行

## 15. APCB 深度对比分析

### 15.1 APCB 提取

| 来源 | SPI dump 偏移 | 大小 | Unique ID |
|------|-------------|------|-----------|
| 工程版主 APCB | 0x449000 | 0x75F4 (30,196B) | 0x269C |
| 量产版主 APCB | 0x449320 | 0xBA24 (47,652B) | 0x2249 |

量产 APCB 比工程版大 **17,456 字节 (+58%)**，主要差异在 MEMG 组。

### 15.2 APCB 内部结构

```
Offset  Engineering        Production         含义
0x0000  APCB header        APCB header        相同版本 0x0080
0x0020  ECB2 header        ECB2 header        完全相同
0x007C  "BCBA"             "BCPA"             Board Config 标识不同
0x0080  PSPG (0x4C)        PSPG (0x4C)        PSP组: 相同
0x00CC  MEMG (0x6CD8)      MEMG (0xB0A8)      内存组: 量产多 0x43D0 字节
0x6DA4  GNBG (0x270)       GNBG (0x270)       北桥组: ★ 关键差异
0x7014  FCHG (0x80)        FCHG (0x90)        FCH组: 量产多 0x10 字节
0x7094  TOKN (0x560)       TOKN (0x5B0)       Token组: 量产多 0x50 字节
```

### 15.3 GNBG (北桥组) 关键差异 ★★★

GNBG 包含 PCIe/USB4 端口配置。两者大小相同 (0x270) 但有 **4处端口级差异**:

```
偏移    工程版           量产版           差异
+0xA4   00 00 00 00     00 00 30 00     端口1: +0x3000 → USB4 模式使能?
+0xB4   00 01 10 00     00 01 30 00     端口2: 0x10→0x30 (bit5=1 → NHI 使能)
+0xC4   00 01 10 00     02 01 30 20     端口3: 0x10→0x30 + byte0=0x02, byte3=0x20
+0xD4   00 01 10 00     00 01 30 00     端口4: 0x10→0x30
```

**模式: 量产版在每个端口配置的 byte14 中一致性地将 bit5 (0x20) 置1。**
- 工程版: `0x10` = 仅 XHCI 模式
- 量产版: `0x30` = XHCI + USB4/NHI 模式

端口3 额外设置 byte12=0x02 和 byte15=0x20，可能指定 NHI 设备映射。

### 15.4 FCHG (FCH组) 差异

| 偏移 | 字段 | 工程 | 量产 | 含义 |
|------|------|------|------|------|
| +0x24 | byte4 | 0x00 | 0x01 | **USB SuperSpeed 使能** (0→1) |
| +0x2C | byte2-3 | 0x80 0x10 | 0x7F 0x0F | 端口使能掩码调整 |
| +0x58 | word | 0x0010 | 0x02FF | USB 控制器配置 |
| +0x64 | dword | 0xFE00D000 | 0xFEEC2000 | MMIO 基地址不同 |
| +0x7C | word | 0x1002 | 0x0000 | 调试/保留字段 |
| +0x80-8F | | (不存在) | FE C2 02 00..01 | **额外 USB4 MMIO 映射** |

### 15.5 TOKN (Token组) 差异

| 类别 | 数量 | 详情 |
|------|------|------|
| 仅量产 | 12 | 包含可能的 USB4 功能使能 token |
| 仅工程 | 2 | 0x190305DF=0, 0x5B10198C=0 |
| 值不同 | 11 | 重要: 0x4367CBD2 (0→1), 0x4967F4FC (0→1), 0xFEDB01F8 (0→1) |
| 值相同 | 151 | 核心平台配置一致 |

关键 token 变化:
- **0x4367CBD2**: 0→1 (可能: USB4 NHI Enable)
- **0x4967F4FC**: 0→1 (可能: USB4 Connection Manager)
- **0xFEDB01F8**: 0→1 (可能: USB4 PCIe Tunneling)
- **0x596663AC**: 0xFFFFFFFF→0x0002001B (USB 控制器端口映射)
- **0x4DBEA2A3**: 2→0 (PCIe 根端口模式)

## 16. 综合诊断结论

### 16.1 根因确认

工程版 BIOS (N3GET04WE) 的 APCB 配置中：

1. **GNBG 端口配置缺少 USB4 模式位** — bit5 未设置, 端口仅配置为 XHCI-only
2. **FCHG 缺少 SuperSpeed 使能** — byte +0x24 = 0x00 (量产 = 0x01)
3. **缺少 USB4 NHI 使能 Token** — 至少 3 个关键 token 为 0 (量产为 1)
4. **EC N3GHT15W 不支持 UCSI** — 即使 PHY 启用也无法做 Alt Mode
5. **Bus 01 无 NHI 设备** — AGESA 未枚举 USB4 NHI PCI function

### 16.2 硬件状态图

```
                      ┌─────────────────────────────────────────┐
                      │        AMD Rembrandt SoC                │
                      │                                         │
  USB-C Port 1 ───→  │  USB4 PHY #0 ✅存在 ✅上电              │
  USB-C Port 2 ───→  │  USB4 PHY #1 ✅存在 ✅上电              │
                      │  USB4 PHY #2 ✅存在 ✅上电              │
                      │                                         │
                      │  USB4 Router ⚠️部分初始化               │
                      │  USB IP Discovery ❌ 0xFFFFFFFF          │
                      │  USB4 NHI ❌ PCI设备未枚举 (Bus 01空)   │
                      │                                         │
                      │  XHC0 ✅工作 (仅HS)   XHC1 ✅工作 (仅HS)│
                      │  SS端口 ❌全部 RxDetect                  │
                      │                                         │
                      │  PHY SERDES ✅初始化表存在               │
                      │  PHY 校准数据 ✅存在                     │
                      │  PHY Mux ❌ 未配置SS路由                 │
                      └─────────────────────────────────────────┘
                                        │
                      EC (N3GHT15W): PD ✅ (电源/DP协商正常)
                                    UCSI ❌ (命令不支持)
                                    扩展读 ❌ (0xA0-0xAF超时)
```

### 16.3 修复路径重新评估

| 路径 | 可行性 | 风险 | 效果 |
|------|--------|------|------|
| **A: SPI 刷写量产 BIOS+EC** | ✅ 最佳 | ⚠️ 已知变砖风险 | 完整 USB4 |
| **B: 仅修改 APCB GNBG 位** | ⚠️ 理论可行 | 中等 | SS 可能工作, 无 UCSI |
| **C: 运行时 SMN 写入 USB4 位** | ❌ 不可行 | PHY mux 需 AGESA 初始化序列 | — |
| **D: SMU 邮箱命令启用 USB4** | ❌ 不可行 | 导致系统冻结 | 详见 §17 |

#### 路径 B 详解: 仅修改 APCB

理论上可以通过 SPI 编程器仅修改 APCB 区域：

1. 将 GNBG 端口配置的 byte14 从 `0x10` 改为 `0x30` (4处)
2. 将 FCHG +0x24 从 `0x00` 改为 `0x01`
3. 添加缺失的 token (0x4367CBD2=1, 0x4967F4FC=1, 0xFEDB01F8=1)

**潜在收益**: AGESA 可能在下次启动时枚举 NHI、配置 PHY mux、启用 SS 信号。

**限制**: 
- EC 仍为 N3GHT15W, 不支持 UCSI → 无 Alt Mode/Power Role 管理
- 可能需要同步修改 DSDT (添加 NHI 设备下的子设备)
- Token ID 是哈希值, 无法确认具体功能
- APCB 有校验和, 需重新计算

> **警告**: 修改 SPI Flash 需要 SPI 编程器和完整备份。操作失误会变砖。

## 17. SMU 邮箱探测 (2026-03-10)

### 17.1 SMU 固件信息

```
SMU Version:  69.40.0  (sysfs: /sys/devices/platform/AMDI0005:00/smu_fw_version)
SMU Program:  0
SMU IP Block: smu_v13_0_0 (Yellow Carp / Rembrandt)
ryzen_smu:    不可用 (内核模块不存在)
```

### 17.2 SMU 寄存器布局

系统中存在 **两套** SMU 邮箱，共享同一 SMU 固件核心：

| 邮箱 | 用途 | MSG 寄存器 | RESP 寄存器 | ARG 寄存器 |
|------|------|-----------|------------|-----------|
| **MP1 (amdgpu)** | GPU 电源管理 | C2PMSG_66 (+0x608) | C2PMSG_82 (+0x648) | C2PMSG_83+ |
| **RSMU (平台)** | AGESA/平台功能 | C2PMSG_10 (+0x528) | C2PMSG_28 (+0x570) | +0x998 |

SMN 非零寄存器快照：

```
MP1 Area:
  C2PMSG_10 [0x03B10528] = 0x0000001C  (RSMU 最后消息 ID)
  C2PMSG_28 [0x03B10570] = 0x00000001  (RSMU 响应: OK)
  C2PMSG_30 [0x03B10578] = 0x00000001  (doorbell)

RSMU Area:
  [0x03B10A00] = 0x00000002
  [0x03B10A08] = 0x0000000F
  [0x03B10A0C] = 0x00000006
  [0x03B10A10] = 0x00000003
```

### 17.3 RSMU GetSmuVersion 测试

通过 RSMU 邮箱发送 `GetSmuVersion` (MSG=0x02):

```
Protocol: clear RESP → write ARG(0) → write MSG(0x02) → poll RESP
Result:   ARG_BASE [0x03B10998] = 0x00452800
Decoded:  69.40.0 — 完全匹配 sysfs 版本 ✓

Side effects:
  +0x9FC [0x03B109FC]: 0x00000001 → 0x00000000
  +0xA00 [0x03B10A00]: 0x00000010 → 0x00000002
```

消息本身**成功执行**，但有严重副作用（见下节）。

### 17.4 致命副作用：SMU 状态机阻塞 → 系统冻结

RSMU 消息发送后约 22 秒（T+390s → T+412s），amdgpu 驱动报告：

```
[412s] amdgpu: SMU: I'm not done with your previous command:
       SMN_C2PMSG_66:0x0000001A  SMN_C2PMSG_82:0x00000000
[412s] amdgpu: Failed to disable gfxoff!
[418s] amdgpu: Failed to export SMU metrics table!
... (每 ~6 秒循环, 共 11 次)
→ 系统最终完全冻结, 需要硬重启
```

**冻结因果链：**

1. `smu_find_resp.py` 清零了 RESP 寄存器 (C2PMSG_28 = 0) 以发送 RSMU 消息
2. RSMU 和 MP1 共享同一 SMU 核心 — RSMU 消息占用 SMU 处理队列
3. 清零操作可能破坏了 SMU 内部状态机的同步标志
4. amdgpu 的 MP1 命令 (0x1A = GfxOff 相关) 无法获得 SMU 响应
5. C2PMSG_82 (MP1 RESP) 停留在 0x00000000 → amdgpu 无限等待
6. GfxOff 禁用失败 → GPU 意外进入低功耗 → 显示冻结 → 系统不可用

### 17.5 结论：路径 D 判定

| 项目 | 结论 |
|------|------|
| SMU 可通信 | ✓ RSMU 邮箱可以发送消息并获得正确响应 |
| 安全性 | ❌ **不安全** — 与 amdgpu MP1 邮箱冲突，导致 GPU 电源管理崩溃 |
| USB4 相关消息 | 未测试 — 连 GetSmuVersion 都会冻结系统 |
| 可修复性 | ❌ 无法安全地在运行时使用 RSMU 邮箱 |

**路径 D 已关闭。** 剩余可行路径：

- **路径 A**: SPI 刷写量产 BIOS + EC（最佳，但已知变砖风险）
- **路径 B**: 仅修改 APCB 的 GNBG/FCHG/Token（中等风险，可能启用 SS）
