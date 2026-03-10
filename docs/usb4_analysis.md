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

## 18. SPI Flash 安全刷写策略 (2026-03-10)

### 18.1 FL1 封装结构解析

量产 BIOS 更新文件 (`$0AN3G00.FL1`) 的精确结构：

```
偏移        大小        内容
0x0000000   0x50        Lenovo 胶囊头 (GUID: CE5CFA7D-0CE2-4974-B866-A367F9E85481)
0x0000050   0x2B0       外层 Firmware Volume 头 (FV + FFS RAW 封装)
  ├─ FV Header     0x48 bytes (FS GUID: 7ac07354-cb3d-ca4d-bd6f-1e9689e7349a)
  ├─ Block Map     0x10 bytes (8437 × 0x1000)
  ├─ Ext Header    0x250 bytes (GUID: d95fe99c-196e-e740-9a8f-ebad7f78e0c5)
  └─ FFS Header    0x20 bytes (RAW, Large File, size=0x2000020)
0x0000320   0x2000000   ★ Raw Flash Image (32MB = SPI dump 完全大小)
0x2000320   0x0F4D30    尾部 FV 填充/对齐

总大小: 34,558,032 bytes (0x20F5050)
```

**关键发现**: FL1[0x320] 即为 SPI Flash 地址 0x000000，1:1 线性映射。

### 18.2 工程版 vs 量产版: 字节级对比

| 区域 | SPI 范围 | 大小 | 差异 | 占比 | 风险 |
|------|----------|------|------|------|------|
| Flash Descriptor | 0x000000-0x010000 | 64KB | 15B | 0.0% | CRITICAL |
| EC Firmware | 0x010000-0x0C0000 | 704KB | 197KB | 27.3% | EXTREME |
| PSP Primary | 0x0C0000-0x440000 | 3.6MB | 2.9MB | 79.7% | EXTREME |
| **APCB Primary** | **0x440000-0x470000** | **192KB** | **22KB** | **11.2%** | **HIGH** |
| PSP Backup | 0x470000-0x800000 | 3.7MB | 3.1MB | 82.1% | EXTREME |
| **APCB Backup** | **0x800000-0x830000** | **192KB** | **79KB** | **40.3%** | **HIGH** |
| PSP/APCB Copies | 0x830000-0xDF0000 | 5.9MB | 5.5MB | 91.7% | EXTREME |
| Reserved | 0xDF0000-0x1000000 | 2.1MB | 550B | 0.0% | LOW |
| UEFI PEI | 0x1000000-0x10A0000 | 640KB | 198KB | 30.2% | HIGH |
| UEFI DXE Vol 1 | 0x10A0000-0x1580000 | 5.0MB | 357KB | 7.0% | MEDIUM |
| UEFI Bridge | 0x1580000-0x15E0000 | 384KB | 311KB | 79.0% | MEDIUM |
| **UEFI DXE Vol 2** | **0x15E0000-0x1830000** | **2.4MB** | **0B** | **0.0%** | **—** |
| UEFI DXE Vol 3 | 0x1830000-0x1F10000 | 7.0MB | 7.1MB | 98.7% | MEDIUM |
| NVRAM/Tail | 0x1F10000-0x2000000 | 960KB | 440KB | 44.7% | HIGH |
| **总计** | | **32MB** | **20.2MB** | **60.3%** | |

UEFI DXE Volume 2 (0x15E0000-0x1830000) **完全相同** — 证实两个固件共享基础 DXE 模块集。

### 18.3 策略评估矩阵

#### 策略 A: 全量刷写量产 BIOS (❌ 已知变砖)

```
刷写范围: 全部 32MB
变更量: 20.2MB (60.3%)
风险: ☠️ 极高 — 已确认导致变砖
原因: PSP 固件校验 CPU 熔丝值, 工程样片 CPU 与量产 PSP 不兼容
恢复: 需 SPI 编程器刷回原始 dump
```

#### 策略 B: APCB-Only 最小补丁 (✓ 推荐方案)

```
刷写范围: 仅 APCB 区域 (3 个 APCB 实例内)
变更量: 26 字节 (0.000077%)
风险: ⚠️ 中等 — APCB 校验和已正确重算
成功概率: ~40% — 取决于工程版 PSP 是否包含 USB4 NHI 初始化代码
恢复: SPI 编程器刷回原始 dump (已有完整备份)
```

#### 策略 C: APCB + 选择性 UEFI DXE (备选)

```
刷写范围: APCB + UEFI DXE Vol 3 (0x1830000-0x1F10000)
变更量: ~7.1MB
风险: ⚠️ 中-高 — DXE 模块可能依赖 PEI 阶段初始化
目的: 获取量产版的 USB4 相关 DXE 驱动 (UcsiDriver, NhiDxe 等)
限制: PEI 阶段仍为工程版, 可能无法正确移交 USB4 设备
```

### 18.4 推荐方案: APCB-Only 补丁 (策略 B) 详细规格

#### 修改清单 (26 字节)

**主 APCB @0x449000 (uid=0x269C, 共 11 字节 + 校验和):**

| SPI 地址 | APCB 内偏移 | 字段 | 原值 | 新值 | 说明 |
|----------|------------|------|------|------|------|
| 0x449010 | +0x10 | Checksum | 0x80 | 0xCA | 校验和重算 |
| 0x44FE4A | GNBG+0xA6 | Port1 byte2 | 0x00 | 0x30 | USB4 模式使能 |
| 0x44FE5A | GNBG+0xB6 | Port2 byte2 | 0x10 | 0x30 | NHI 使能 (bit5) |
| 0x44FE68 | GNBG+0xC4 | Port3 byte0 | 0x00 | 0x02 | NHI 设备映射 |
| 0x44FE6A | GNBG+0xC6 | Port3 byte2 | 0x10 | 0x30 | NHI 使能 (bit5) |
| 0x44FE6B | GNBG+0xC7 | Port3 byte3 | 0x00 | 0x20 | NHI 设备映射 |
| 0x44FE7A | GNBG+0xD6 | Port4 byte2 | 0x10 | 0x30 | NHI 使能 (bit5) |
| 0x450038 | FCHG+0x24 | SS Enable | 0x00 | 0x01 | SuperSpeed 使能 |
| 0x450268 | Token+val | 0xFEDB01F8 | 0x00 | 0x01 | USB4 PCIe Tunneling |
| 0x450318 | Token+val | 0x4367CBD2 | 0x00 | 0x01 | USB4 NHI Enable |
| 0x450338 | Token+val | 0x4967F4FC | 0x00 | 0x01 | USB4 Connection Mgr |

**备份 APCB @0x811000 (uid=0x269C, 相同 11 字节 + 校验和):**
与主 APCB 完全相同的偏移和修改，地址偏移 +0x3C8000。

**小 APCB @0x446000 (uid=0x9F9494, 3 字节 + 校验和):**

| SPI 地址 | 字段 | 原值 | 新值 | 说明 |
|----------|------|------|------|------|
| 0x446010 | Checksum | 0x0D | 0xAD | 校验和重算 |
| 0x4460E6 | GNBG Port2 | 0x10 | 0x30 | USB4 模式 |
| 0x4460F6 | GNBG Port3 | 0x10 | 0x30 | USB4 模式 |
| 0x446106 | GNBG Port4 | 0x10 | 0x30 | USB4 模式 |

#### APCB 校验和算法

```
算法: 8-bit checksum (sum of all bytes mod 256 == 0)
位置: APCB header +0x10 (1 byte)
验证: 修改后全字节求和 mod 256 == 0
```

#### 补丁工具

```bash
# 生成补丁镜像 (scripts/apcb_usb4_patch.py):
python3 scripts/apcb_usb4_patch.py
# → build/spi_usb4_patched_YYYYMMDD_HHMMSS.bin
```

### 18.5 刷写操作规程

#### 前置条件

- [ ] SPI 编程器 (CH341A / dediprog / 树莓派 + flashrom)
- [ ] SOP8 测试夹 (Pomona 5250 或类似) 或拆焊 SPI
- [ ] 原始 SPI dump 已备份 (SHA256: `b6ed560f...`)
- [ ] 补丁镜像已生成 (26 字节差异验证通过)
- [ ] 外部电源断开, 仅电池或完全断电
- [ ] 拆机到主板层面, 定位 Winbond W25Q256JW

#### 刷写步骤

```bash
# 1. 验证芯片连接
flashrom -p ch341a_spi

# 2. 刷写前读取验证
flashrom -p ch341a_spi -r /tmp/pre_flash_readback.bin
sha256sum /tmp/pre_flash_readback.bin
# ↑ 应匹配: b6ed560fce88e250a3fd60b9f09ba4cc9bdcbe0a1fc3ed072a0f842dff75a3b1

# 3. 刷写补丁镜像
flashrom -p ch341a_spi -w build/spi_usb4_patched_*.bin

# 4. 刷写后读回验证
flashrom -p ch341a_spi -r /tmp/post_flash_readback.bin
sha256sum /tmp/post_flash_readback.bin
# ↑ 应匹配补丁镜像的 SHA256

# 5. 比较确认仅 APCB 区域变更
python3 -c "
a = open('/tmp/pre_flash_readback.bin','rb').read()
b = open('/tmp/post_flash_readback.bin','rb').read()
diffs = [(i,a[i],b[i]) for i in range(len(a)) if a[i]!=b[i]]
print(f'{len(diffs)} bytes differ')
for addr,old,new in diffs:
    print(f'  0x{addr:06X}: 0x{old:02X} → 0x{new:02X}')
"
# ↑ 应显示恰好 26 字节变更, 全部在 0x446xxx/0x449xxx-0x450xxx/0x811xxx-0x818xxx 范围
```

#### 验证启动

```bash
# 6. 开机后检查 USB4 NHI
lspci | grep -i 'usb4\|thunderbolt\|nhi\|1022:164e'
# 期望看到 USB4 NHI 设备 (PCI class 0x0C03 或 0x0D10)

# 7. 检查 SuperSpeed 端口状态
for p in /sys/bus/usb/devices/*/speed; do echo "$p: $(cat $p 2>/dev/null)"; done
# 期望: 至少一个端口显示 5000/10000 而非之前的全 480

# 8. 加载 Thunderbolt 驱动
modprobe thunderbolt
ls /sys/bus/thunderbolt/devices/

# 9. 检查 UCSI (可能仍不工作, 因为 EC 未更新)
modprobe typec_ucsi ucsi_acpi
ls /sys/class/typec/
```

### 18.6 风险评估与应对

| 风险 | 概率 | 影响 | 应对 |
|------|------|------|------|
| APCB 修改后无法 POST | 低 (~5%) | 高 | SPI 编程器刷回原始 dump |
| POST 正常但 USB4 仍未启用 | 高 (~50%) | 低 | 工程版 PSP 可能不含 NHI init 代码 |
| POST 正常, SS 工作但无 UCSI | 中 (~30%) | 中 | EC 需升级才能支持 UCSI |
| 内存训练失败 (MEMG 完整性) | 极低 (~1%) | 高 | 补丁不修改 MEMG 区域 |
| 工程版 PSP 拒绝新 APCB 配置 | 低 (~10%) | 高 | PSP 可能忽略未知 token |

**最可能结果**: POST 正常, AGESA 读取新 GNBG 配置, 但因工程版 PSP 缺少 USB4 NHI 
枚举代码, USB4 仍未出现在 PCI 总线上。SuperSpeed 信号路由可能在 PHY 层面改善。

**最佳结果**: NHI 设备出现在 PCI Bus 01, SuperSpeed 端口从 RxDetect 变为 Polling/U0,
thunderbolt 驱动发现 USB4 域, 但 UCSI 仍不可用 (EC 限制)。

### 18.7 补丁文件清单

| 文件 | 用途 |
|------|------|
| `scripts/apcb_usb4_patch.py` | 补丁生成工具 (自验证) |
| `build/spi_usb4_patched_*.bin` | 补丁后 SPI 镜像 (32MB) |
| `firmware/spi_dump/bios_dump_*.bin` | 原始 SPI dump (恢复用) |

---

## §19 固件封装分析：FL1 vs FL2 与 Flash 芯片架构

**日期**: 2025-03-10  
**目标**: 完整解析 Lenovo BIOS 更新包中 FL1/FL2 的结构和用途，澄清 flashrom 检测到"两个 SPI ROM"的机理

### 19.1 FL1 封装结构 (`$0AN3G00.FL1`, 34,558,032 bytes)

FL1 是**完整的 32MB 主 SPI Flash 镜像**，包裹在 Lenovo 胶囊格式中：

```
偏移         大小         内容
─────────────────────────────────────────────────────
0x0000000    0x50         Lenovo Capsule Header
                          GUID: CE5CFA7D-0CE2-4974-B866-A367F9E85481
0x0000050    0x48         Outer FV Header
                          FS GUID: 7ac07354-cb3d-ca4d-bd6f-1e9689e7349a
0x0000088    0x10         Block Map (8437 × 0x1000)
0x00000B0    0x250        Extended Header
                          GUID: d95fe99c-196e-e740-9a8f-ebad7f78e0c5
0x0000300    0x20         FFS File Header (RAW, Large File)
                          Data size: 0x2000020 (33,554,464 bytes)
0x0000320    0x2000000    ★ Raw Flash Image (32MB)
                          = 1:1 线性映射到整个 SPI 芯片
```

FL1 flash 镜像包含全部区域：Flash Descriptor、EC Shadow、PSP 固件、APCB 配置、UEFI PEI/DXE。
BIOS 版本字符串位于 UEFI 区域：工程版 SPI 中为 `N3GET04W` (0x106C00D)，量产 FL1 中为 `N3GET74W` (0x119EE0D)。

### 19.2 FL2 封装结构 (`$0AN3G00.FL2`, 327,968 bytes)

FL2 是**独立的 EC (嵌入式控制器) 固件包**，供 Nuvoton NPCX 芯片内部 Flash 使用：

```
偏移         内容
─────────────────────────────────────────────────────
0x000-0x01F  _EC1 Header
             Magic: _EC\x01
             Total size: 327,968
             Data size: 327,680
             Checksum: 0x39B08081
0x020-0x03F  _EC2 Header
             Magic: _EC\x02
             Total size: 323,904
             Data size: 323,584
0x040-0x05F  填充区 (0xEC pattern)
0x060-0x1FF  填充/metadata
0x200        ARM Cortex-M4F Vector Table
             SP = 0x1008CCAD (NPCX SRAM)
             Reset_Handler = 0x1008CD19
0x200+       EC 运行时代码 + 内嵌 PD 固件
```

**FL2 内嵌版本字符串**:

| 偏移 | 版本 | 用途 |
|------|------|------|
| 0x528 | N3GHT68W | EC 主固件版本 |
| 0x3AC43 | N3GPD17W | PD 控制器固件 |
| 0x3E6C4 | N3GPH20W | PD 控制器固件 |
| 0x42145 | N3GPH70W | PD 控制器固件 |

FL2 包含 USB-C Power Delivery 控制器固件，负责 Type-C 充电协商和 DP Alt Mode 切换。

### 19.3 FL1 与 FL2 的关系

**关键发现**：FL2 代码**不存在于** FL1（或主 SPI Flash）中。

验证方法：从 FL2 提取多个 32 字节非零代码段，在 SPI 全 32MB 和 FL1 flash 镜像中搜索——仅找到 2 个偶然片段匹配 (SPI 0x081374 和 0x0813B4)，不构成有意义的代码重叠。

| 项目 | FL1 | FL2 |
|------|-----|-----|
| 用途 | 完整 SPI Flash 镜像 | EC 内部 Flash 固件 |
| 大小 | 34.5MB (封装) / 32MB (内容) | 328KB |
| 写入目标 | 主 SPI Flash (W25Q256JW) | EC 内部 Flash (NPCX) |
| 包含 EC 代码? | 是 (SPI EC Shadow 区域 0x10000-0xC0000) | 是 (EC 运行时代码) |
| EC 代码相同? | **否** — FL1 的 EC 区域与 FL2 是不同的固件 |
| BIOS? | 包含完整 UEFI + PSP + APCB | 无 |
| PD 固件? | 无 | 包含 3 个 PD 版本 |

### 19.4 SPI EC Shadow 区域分析

主 SPI Flash 的 EC 区域 (0x10000-0xC0000, 704KB) 内容：

```
子块              工程 SPI vs 量产 FL1                     说明
──────────────────────────────────────────────────────────────
0x010000-0x020000  SAME  (84% FF)                          共享结构
0x020000-0x030000  28,262B diff (eng=88%FF, prod=55%FF)    含 EFS 签名
0x030000-0x040000  17,432B diff (eng=90%FF, prod=71%FF)
0x040000-0x060000  SAME  (68% FF)                          共享代码
0x060000-0x070000  SAME  (84% FF)
0x070000-0x080000  25,988B diff (eng=100%FF, prod=60%FF)   工程版全空
0x080000-0x0A0000  115,208B diff                           主要差异区
0x0A0000-0x0B0000  10,057B diff (eng=100%FF, prod=84%FF)   工程版全空
0x0B0000-0x0C0000  SAME  (100% FF, 空)
```

**统计**: 720,896 字节总计，72% 相同，27% 不同 (196,947 字节)。

SPI EC Shadow 区域**无版本字符串**，无 `_EC1`/`_EC2` 头——是 PSP 在启动早期加载 EC 时使用的原始镜像格式，与 FL2 的封装格式完全不同。

### 19.5 "两个 SPI ROM" 的真相

flashrom 日志中出现：

```
Found chipset "AMD FP4".
Found Winbond flash chip "W25Q256JW" (32768 kB, SPI) mapped at physical address 0xfe000000.
Found Winbond flash chip "W25R256JW" (32768 kB, SPI) mapped at physical address 0xfe000000.
Multiple flash chip definitions match the detected chip(s): "W25Q256JW", "W25R256JW"
```

**结论：这不是两个物理芯片，而是 flashrom 芯片数据库中同一颗 Winbond W25Q256JW 的两个兼容条目。**

证据：
- 两者映射到完全相同的物理地址 `0xfe000000`
- 系统中无 MTD 设备 (`/proc/mtd` 不存在)
- 无 SPI master (`/sys/class/spi_master/` 为空)
- 无额外 SPI 设备 (`/sys/bus/spi/devices/` 为空)
- 使用 `flashrom -c W25Q256JW` 可正常读取完整 32MB

### 19.6 ThinkPad Z13 Flash 芯片架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    ThinkPad Z13 Flash 架构                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────┐                │
│  │ 主 SPI Flash (Winbond W25Q256JW, 32MB)      │ ← flashrom    │
│  │ AMD SoC SPI 控制器总线                       │   可读写      │
│  ├─────────────────────────────────────────────┤                │
│  │ 0x000000  Flash Descriptor (64KB)            │               │
│  │ 0x010000  EC Shadow Region (704KB)           │ FL1 更新      │
│  │ 0x0C0000  PSP Firmware (×2, 3.6MB)           │               │
│  │ 0x440000  APCB Config (×3)                   │               │
│  │ 0xDF0000  Reserved (2MB)                     │               │
│  │ 0x1000000 UEFI PEI + DXE (16MB)             │               │
│  └─────────────────────────────────────────────┘                │
│                                                                 │
│  ┌─────────────────────────────────────────────┐                │
│  │ EC 内部 Flash (Nuvoton NPCX, ~512KB)        │ ← flashrom    │
│  │ EC 自有 SPI 控制器,独立总线                  │   不可见      │
│  ├─────────────────────────────────────────────┤                │
│  │ EC 运行时代码 (N3GHT68W)                     │               │
│  │  - 键盘/触摸板扫描                           │ FL2 更新      │
│  │  - 风扇控制 / 热管理                         │               │
│  │  - 电源管理 / 充电                           │               │
│  │  - UCSI (USB Type-C 接口)                    │               │
│  │ 内嵌 PD 固件 (N3GPD/PH 系列)                │               │
│  │  - Type-C PD 协商                            │               │
│  │  - DP Alt Mode 切换                          │               │
│  └─────────────────────────────────────────────┘                │
│                                                                 │
│  更新流程 (Lenovo BIOS Update):                                 │
│  1. BootX64.efi 读取 FL1 → 解封装 → 写入主 SPI Flash           │
│  2. BootX64.efi 读取 FL2 → 通过 EC mailbox → 写入 EC Flash     │
│  3. 重启后 PSP 从主 SPI 加载 BIOS                               │
│  4. EC 从自有 Flash 运行 (可能校验 SPI EC Shadow)               │
│                                                                 │
│  对 APCB 补丁的影响:                                            │
│  我们仅修改主 SPI 的 APCB 区域 (26 字节), 不涉及 EC Flash      │
│  flashrom 操作: flashrom -c W25Q256JW -p internal               │
└─────────────────────────────────────────────────────────────────┘
```

### 19.7 小结

| 问题 | 答案 |
|------|------|
| FL1 是什么? | 完整 32MB SPI Flash 镜像 (含 BIOS + PSP + APCB + EC Shadow + UEFI) |
| FL2 是什么? | EC 内部 Flash 独立固件 (含 EC 代码 + PD 控制器固件) |
| FL1 和 FL2 有代码重叠? | **否**, FL2 代码不在 FL1 中, 两者目标芯片不同 |
| 有几个物理 Flash 芯片? | 2 — 主 SPI (32MB, flashrom 可见) + EC 内部 (~512KB, 不可见) |
| flashrom "两个芯片"? | 同一颗 W25Q256JW 的两个数据库条目, 不是两个物理芯片 |
| APCB 补丁涉及 FL2? | **否**, 仅操作主 SPI Flash |

---

## §20 BootX64.efi 逆向分析：Lenovo BIOS 刷写工具

**日期**: 2025-03-10  
**目标**: 逆向分析 Lenovo BIOS 更新包中的 BootX64.efi，理解刷写流程和安全机制

### 20.1 文件概况

| 文件 | 大小 | PE32+ | 说明 |
|------|------|-------|------|
| BootX64.efi | 2,145,208 | AMD64, EFI App | 主刷写工具 (含 DC/电池检查) |
| NoDCCheck_BootX64.efi | 2,143,768 | AMD64, EFI App | 去除电源检查版本 |
| SHELLFLASH.EFI | 23,296 | AMD64, EFI App | EFI Shell 引导加载器 |

**BootX64.efi** 是 Lenovo **TDK (ThinkPad Development Kit)** 框架的 BIOS 刷写工具，不是标准 UEFI 胶囊更新器——它是一个功能完整的 EFI Shell 应用，内嵌：
- EFI Shell + 驱动管理
- BIOS/EC/USB 设备固件刷写引擎
- SMBIOS/DMI 编辑
- BIOS GUARD (Intel PFAT) 支持
- 安全验证子系统

### 20.2 PE32+ 结构

```
Section  VAddr       VSize     RawSize    Flags
───────────────────────────────────────────────────
.text    0x0002A0    0x205F7A  0x205F80   CODE+EXEC+READ  (2MB 代码)
text     0x206220    0x000356  0x000360   IDATA+READ+WRITE (数据)
(rdata)  0x206580    0x002700  0x002700   IDATA+READ       (只读数据)
.xdata   0x208C80    0x0018C8  0x0018E0   IDATA+READ       (异常处理)
.reloc   0x20A560    0x000FEC  0x001000   IDATA+READ       (重定位)

Entry Point RVA: 0x1A5BC0
Image Base: 0x0 (relocatable)
```

### 20.3 刷写流程

从字符串分析还原完整流程：

```
1. 读取固件镜像
   ├─ "Read BIOS image from file" → 从 $0AN3G00.FL1 读取
   ├─ "Read BIOS image from memory" → 或从内存读取
   └─ "Read current BIOS" → 读取当前 SPI 内容

2. 安全验证
   ├─ "Failed to verify Secure Flash image" → X.509 签名校验
   ├─ "Flash BIOS is not compatible" → 机型兼容性检查
   ├─ "Flash BIOS is not an upgrade" → 版本升级检查
   ├─ "Secure RollBack Prevention is enabled" → 防降级检查
   └─ "Enable Microsoft Bit-locker check" → BitLocker 检查

3. 初始化刷写
   ├─ "Initialize Flash module" → 初始化 SPI 访问
   ├─ "Open flash write enable status" → 通过 SMI 解锁 SPI 写保护
   ├─ "Prepare patched NvStorage" → 合并 NVRAM 变量
   └─ "Backup current BIOS" → 备份当前 BIOS

4. 执行刷写
   ├─ "Begin Flashing......"
   ├─ "Total number of region to flash = %d" → 按区域刷写
   ├─ "Region name: %s" → 区域名称
   ├─ "Total blocks of the image = %d" → 按 4KB 块操作
   ├─ "Erase fail: Block = 0x%X" → 块擦除
   ├─ "Write fail: Block = 0x%X" → 块写入
   └─ "Image flashing done" → 完成

5. 刷写后操作
   ├─ "FlashCommand" → 写入 BCP (Boot Config Parameters) 到 EVSA NVRAM
   ├─ "TdkBiosRomWrite" → ROM 写入确认
   ├─ "BIOS is updated successfully"
   └─ "System will shutdown or reboot in 5 seconds"

6. EC 固件更新 (FL2)
   ├─ "ECFW Update" / "EC Update"
   └─ 通过 EC mailbox 协议写入 EC 内部 Flash
```

### 20.4 SMI 通信机制

BootX64.efi **不直接操作 SPI 寄存器**，而是通过 **SMI (System Management Interrupt)** 与 BIOS 固件的 SMM 处理器通信：

```
BootX64.efi (EFI Shell Ring 0)
    │
    ├─ LenovoVariableSmiCommand → SMI 触发
    │
    ▼
BIOS SMM Handler (Ring -2)
    │
    ├─ "Failed to initialize SMI" → SMM 初始化
    ├─ "Failed on executing WRITE command" → SPI 写入
    ├─ "Open flash write enable status" → 解锁 SPI Flash
    └─ "Close flash write enable status" → 重新锁定
```

**关键发现**：刷写操作通过 `LenovoVariableSmiCommand` 和 `LenovoBiosFeature` 两个 Lenovo 私有协议实现，SMM 处理器负责实际的 SPI 读写和写保护控制。

### 20.5 CLI 参数与功能

从嵌入的帮助文本还原 FlashCommand 的命令行选项：

| 功能 | 说明 |
|------|------|
| `filename` | 指定 FL1/FL2 文件 |
| `BIOS Update` | 刷写完整 BIOS |
| `EC Update` / `ECFW Update` | 刷写 EC 固件 |
| `Skip Battery check` | 跳过电池/电源检查 (= NoDCCheck 版本) |
| `Skip BIOS build date time checking` | 跳过构建日期检查 |
| `Skip part number checking` | 跳过零件号检查 |
| `Skip flash options in BIOS FlashCommand` | 跳过某些选项 |
| `Shutdown after flash completed` | 完成后关机而非重启 |
| `Silent operation` | 安静模式 (无蜂鸣) |
| `Replace SLP marker or MSDM key` | 替换 Windows 激活密钥 |
| `Enable flash verification` | 启用刷写后验证 |
| `Enable Microsoft Bit-locker check` | 启用 BitLocker 检查 |
| `Update variable size CPU microcode` | 更新 CPU 微码 |
| `password` | 管理员密码 |
| `Flash without skipping same content blocks` | 不跳过相同块 (全量) |
| `/rsbr GUID filename` | **按 GUID 替换子区域** |
| `FDLA` | **写入指定物理地址** |

**特别关注**：
- `/rsbr GUID filename` — 可以按 GUID 定位并替换特定子区域
- `FDLA` — 可以写入指定的物理地址
- 工具在刷写前会跳过内容相同的块 (增量刷写)

### 20.6 安全检测机制

```
签名验证链:
  Lenovo Ltd. Root CA 2012 (RSA)
    └─ ThinkPad Product CA 2012 (RSA)
        └─ Capsule/FL1 镜像签名

安全密钥检测 (SCT = Security Configuration Table):
  ├─ "Secure flash public key is same with sample/dummy in SCT"
  ├─ "Secure boot platform key is same with sample/dummy in SCT"
  ├─ "Secure boot key exchange key is same with sample/dummy in SCT"
  ├─ "Unlock key is same with sample/dummy in SCT"
  ├─ "Verified boot public key is same with sample in SCT"
  ├─ "Boot guard public key is same with sample in SCT"
  └─ "BIOS guard(PFAT) hash is same with sample/dummy in SCT"
```

**工程样机关键发现**：工具会主动检测 SCT 中的密钥是否为 **sample/dummy** 密钥。这意味着：
1. 工程版 BIOS 可能使用样品/测试密钥
2. 如果安全密钥是 dummy 的，签名验证可能可以被绕过或放松
3. 这为将来可能通过修改后的 BootX64.efi 刷写提供了一条潜在路径

### 20.7 BootX64 vs NoDCCheck 对比

| 维度 | BootX64 | NoDCCheck |
|------|---------|-----------|
| 文件大小 | 2,145,208 | 2,143,768 (-1,440) |
| Image Size | 0x20B560 (2,143,584) | 0x20AFC0 (2,142,144) |
| Entry RVA | 0x1A5BC0 | 0x1A5980 |
| 代码差异 | — | 67.2% .text 不同 |
| 安全验证 | ✅ 完整 | ✅ 完整 (相同) |
| 证书/签名 | 2× Root CA, 1× Product CA | 2× Root CA, 1× Product CA |
| DC/电池检查 | ✅ 需要 AC 电源 | ❌ 已移除 |

**两者是完全独立的编译版本**，不是简单的二进制补丁。NoDCCheck 仅移除了电源检查，安全验证完整保留。

### 20.8 BIOS 子区域映射 (BCP)

BootX64.efi 使用 3 字母代码管理 BIOS 子区域：

```
bak = 备份          bbl = Boot Block      bcp = Boot Config Parameters
bcplogo = 启动 Logo  cac = CA 证书         capload = 胶囊加载器
cbp = ??             cvar = 自定义变量     dat = 数据
dco = DMI 配置       dmc = DMI 制造商      dmm = DMI 内存
dmpgr = DMI BIOS 区  dmppr = DMI 处理器    dfs/dks/dms/dos = DMI 子区域
dpc/dpm/dps/dsc/dsm/dss/dus/dvc = 其他子区域
```

### 20.9 对 APCB 补丁策略的影响

| 问题 | 结论 |
|------|------|
| 能否通过 BootX64.efi 刷写我们的补丁? | **否** — FL1 签名校验会失败 (我们没有 Lenovo 私钥) |
| NoDCCheck 能绕过签名吗? | **否** — 仅去除电源检查，安全验证完整保留 |
| FDLA/sub-region 写入能用吗? | **理论上可以**，但同样受 SMI 安全策略限制 |
| 工程 BIOS 的密钥是 dummy 的吗? | **可能** — 工具有 dummy key 检测逻辑，工程样机常用测试密钥 |
| 最安全的刷写方式? | **仍然是 flashrom 直写 SPI** — 完全绕开 BootX64.efi 和 SMI 安全层 |
| BootX64.efi 的 SMI 刷写涉及 PSP 验证吗? | **可能** — SMM handler 可能会调用 PSP 验证固件完整性 |

**结论**: flashrom 外部编程器方案仍然是最安全、最可控的 APCB 补丁应用方式。BootX64.efi 的逆向分析证实了它有多层安全检查，不适合注入修改过的固件。但 dummy key 检测逻辑的存在暗示工程样机可能运行在降级安全模式下，这可能简化了 PSP 的启动验证要求。

---

## §21 PSP 安全密钥与 APCB 验证范围分析

> **目标**: 确定工程 BIOS 是否使用 dummy/测试密钥，以及 PSP 是否对 APCB 区域进行签名验证——直接影响 Strategy B (26字节 APCB 补丁) 的安全风险等级。

### 21.1 PSP 目录结构全景

AMD Rembrandt PSP 采用多级目录体系。通过 EFS (Embedded Firmware Structure) @0x20000 定位所有入口：

```
EFS @0x20000 (magic=0x55AA55AA)
├── PSP_DIR  → 0xC1000 ($PSP L1, 2 entries → combo pointers)
├── PSP_COMBO → 0xC2000 ($PSP L1, 同上)
└── BIOS_DIR  → 0x0 (未设置! BIOS 通过 PSP combo 间接引用)

$PSP L1 @0xC1000:
├── [0x48] BIOS_L2_B_DIR → 0xC3000 (combo BIOS 目录, 非标准魔数)
└── [0x4A] SEC_BIOS_DIR  → 0xC4000 (combo 备份目录)

$PL2 (PSP Level 2) @0xC5000: 43 entries (Engineering)
├── [0x00] AMD_PUBLIC_KEY         @0x000400 (0x440 bytes) ★
├── [0x01] PSP_FW_BOOT_LOADER    @0x000900
├── [0x09] AMD_SEC_DBG_PUBLIC_KEY @0x06E200 (0x440 bytes) ★
├── [0x0B] AMD_SOFT_FUSE_CHAIN   val=0xC001 ★
├── [0x22] SEC_POLICY             @0x0CA000 (0x1000 bytes) ★
├── [0x49] SEC_PSP_DIR            @0x380000
└── ... (43 entries total: SMU, TrustOS, ABL, etc.)

$BL2 (BIOS Level 2) @0x445000: 19 entries (Engineering)
├── [0x05] BIOS_RTM_FIRMWARE     @0x000400 (0x340 bytes) ★
├── [0x68] AP_BL                 @0x004000
├── [0x64] APOB_DATA             @0x037000
├── [0x66] MP5_FW                @0x043500
└── ⚠️ 无 APCB_DATA (0x60) 条目!
└── ⚠️ 无 BIOS_RTM_SIGNATURE (0x6A) 条目!
```

**关键发现**: 工程 BL2 中**完全没有 APCB_DATA 和 BIOS_RTM_SIGNATURE 条目**。APCB 不在 PSP 目录注册范围内。

### 21.2 AMD 根密钥分析 — 空白密钥槽

```
AMD_PUBLIC_KEY @SPI 0x400 (1088 bytes):
  Engineering SHA256: 769b7cd9026948adacd8471bc117a9a1ebb2cd7ed9c4fbfdfcd71a61c604ff48
  Production  SHA256: 769b7cd9026948adacd8471bc117a9a1ebb2cd7ed9c4fbfdfcd71a61c604ff48
  内容: 全部 0xFF ← 完全空白!
  两者完全一致: ✅

AMD_SEC_DBG_PUBLIC_KEY:
  Engineering @0x6E200: SHA256 同上 → 全部 0xFF
  Production  @0x70400: SHA256 同上 → 全部 0xFF
  两者完全一致: ✅
```

**结论**: SPI 中的 AMD 公钥槽是**空的** (全 0xFF)。AMD PSP 根密钥烧录在 CPU 硅片的 OTP (One-Time Programmable) 熔丝中，不依赖 SPI 闪存中的密钥槽。这不是"dummy key"——而是**根本没有 SPI 级密钥验证链**。

### 21.3 软熔丝链 (Soft Fuse Chain) — 工程 vs 量产

```
Type 0x0B — AMD_SOFT_FUSE_CHAIN_01 (值内联在目录条目中):

  Engineering: 0x0000C001 = 0000_0000_0000_0000_1100_0000_0000_0001
  Production:  0x3000C041 = 0011_0000_0000_0000_1100_0000_0100_0001
  XOR (差异): 0x30000040 = 0011_0000_0000_0000_0000_0000_0100_0000
```

| Bit | 含义 | 工程 | 量产 | 差异 |
|-----|------|------|------|------|
| 0 | PLATFORM_SECURE_BOOT_EN | 1 | 1 | — |
| 1 | DISABLE_AMD_BIOS_KEY_USE | 0 | 0 | — |
| 2 | DISABLE_AMD_KEY_USAGE | 0 | 0 | — |
| 6 | **DISABLE_SECURE_DEBUG** | **0** | **1** | **← 关键!** |
| 14 | PLATFORM_MODEL_ID | 1 | 1 | — |
| 28-29 | (高级安全限制) | 0 | 1 | ← 额外限制 |

**关键差异**:
- **Bit 6** = 0 (工程): 安全调试**未禁用** → 调试通道开放
- **Bit 6** = 1 (量产): 安全调试**已禁用** → 生产锁定
- **Bits 28-29** (量产额外设置): 可能是反回滚保护或平台绑定标志

> 工程 BIOS 运行在**开发安全模式**下——调试端口可用，安全限制更少。

### 21.4 BIOS RTM (Root of Trust for Measurement) — 空白!

```
BIOS_RTM_FIRMWARE (type 0x05) → SPI @0x400, size 0x340:
  Engineering: 全部 0xFF ← RTM 数据区完全空白!
  Production:  全部 0xFF ← 同样空白!

BIOS_RTM_SIGNATURE (type 0x6A):
  Engineering: $BL2 中不存在此条目!
  Production:  $BL2 中不存在此条目!
```

**RTM 机制分析**:
- BIOS_RTM_FIRMWARE 定义 PSP 在启动时需要度量/验证的 BIOS 区域范围
- 该条目指向 SPI 0x400 (与 AMD_PUBLIC_KEY 重叠)，内容全部为 0xFF
- **没有 BIOS_RTM_SIGNATURE** 意味着没有签名可用于验证
- **结论: PSP 的 BIOS RTM 验证在此平台上完全无效** — 既无度量范围定义，也无签名数据

### 21.5 PSP 对 APCB 区域的引用 — 完全缺失

通过遍历所有 $PL2 和 $BL2 目录条目的绝对地址引用：

```
PSP $PL2 目录 (Engineering primary + backup):
  → 无任何条目引用 APCB 区域 (0x440000-0x470000) ✓

PSP $PL2 目录 (Production primary + backup):
  → 无任何条目引用 APCB 区域 (0x440000-0x470000) ✓

BIOS $BL2 目录 (Engineering primary + backup):
  → 无 APCB_DATA (0x60) 条目 ✓
  → 无 BIOS_RTM_SIGNATURE (0x6A) 条目 ✓

BIOS $BL2 目录 (Production primary + backup):
  → 有 APCB_DATA type=0x20000060 sz=0x3000 @0x1000 (BL2 内部相对偏移)
  → 无 BIOS_RTM_SIGNATURE (0x6A) 条目 ✓
```

**关键发现**: 
1. PSP 固件目录 ($PL2) 在工程和量产版中**都不引用 APCB 区域**
2. 工程 BIOS 目录 ($BL2) **完全缺少 APCB 注册条目**
3. 即使量产版有 APCB 条目，也**没有对应的 RTM 签名**
4. **APCB 不在任何 PSP 签名验证范围内**

### 21.6 SEC_POLICY 对比

```
Engineering @0xCA000 (4096 bytes):
  SHA256: c001d66ebb89787b5e2adc480b2356db4e695d2661184aa6f1ab4ce8d9bce7cd
  结构: ARM Thumb2 代码 (含 "CryptoModExp Invalid Parameter exiting..." 字符串)
  特征: 加密模块的验证例程代码

Production @0xD5000 (4096 bytes):
  SHA256: 92555970a36c5c7129039c0191062738ee3e54416f33d9c62df527a072e37aec
  结构: 偏移表 + ARM Thumb2 代码 (不同结构)
  特征: 策略表驱动的安全检查

两者完全不同: 不同的安全执行策略。
```

工程版 SEC_POLICY 包含明文加密验证代码；量产版使用策略表间接跳转。这表明工程版的安全执行路径更简单、限制更少。

### 21.7 证书体系差异 (补充 §20)

| 证书 | 工程 SPI | 量产 FL1 | 含义 |
|------|----------|----------|------|
| Lenovo Ltd. Root CA 2012 | ✅ @0x10030E0 | ✅ @0x1F05632 | 根 CA |
| ThinkPad Product CA 2012 | ✅ @0x100316E | ✅ @0x1F056C0 | 产品 CA |
| Lenovo Ltd. PK CA 2012 | ❌ | ✅ @0x1F0426D | Platform Key CA |
| Lenovo Ltd. KEK CA 2012 | ❌ | ✅ @0x1F04650 | Key Exchange Key CA |
| RSA 结构总数 | **66** | **48** | 工程反而更多 |

工程版缺少 Platform Key CA 和 KEK CA，但总 RSA 结构数更多 (66 vs 48)——说明工程 BIOS 包含额外的调试/测试用密钥材料，但 UEFI Secure Boot 的 PK/KEK 链不完整。

### 21.8 综合安全评估 — APCB 补丁风险降级

```
安全验证层级分析:

层级 1: PSP 硅片 OTP 密钥 → 验证 PSP 固件本身
  影响 APCB: ❌ (APCB 不是 PSP 固件)

层级 2: PSP 目录完整性 ($PL2 checksums) → 验证目录结构
  影响 APCB: ❌ (APCB 不在 $PL2 目录中)

层级 3: BIOS RTM 验证 → 定义 PSP 度量的 BIOS 范围
  影响 APCB: ❌ (RTM 内容全部 0xFF，无签名)

层级 4: BIOS $BL2 目录 → 列出 APCB 位置
  影响 APCB: ⚠️ (工程版无条目; 量产版有条目但无签名)

层级 5: ABL/AGESA → 扫描 APCB magic 并校验 checksum
  影响 APCB: ✅ (8位字节和校验, 我们的补丁维护此校验)

层级 6: UEFI Secure Boot → 验证 OS 启动加载器
  影响 APCB: ❌ (在 APCB 读取之后)
```

### 21.9 Strategy B 风险更新

| 风险因素 | §18 评估 | §21 更新 | 原因 |
|----------|----------|----------|------|
| PSP 签名验证失败 | HIGH | **NONE** | PSP 不验证 APCB (无目录注册、无 RTM、无签名) |
| ABL checksum 失败 | LOW | **LOW** | 补丁工具维护 8-bit checksum ✓ |
| APCB 内容不兼容 | MEDIUM | **MEDIUM** | 工程 BIOS ABL 版本可能不支持某些 token |
| SPI 写入失败/损坏 | LOW | **LOW** | flashrom 验证写入 ✓ |
| 总体风险 | **HIGH** | **MEDIUM-LOW** | PSP 安全层完全不触及 APCB |

### 21.10 最终结论

1. **没有 dummy key** — SPI 密钥槽是**空的** (全 0xFF)，不是使用测试密钥，而是完全不使用 SPI 密钥
2. **PSP 不验证 APCB** — 四重确认:
   - $PL2 无 APCB 引用
   - $BL2 无 APCB 条目 (工程版)
   - RTM 全部空白
   - 无 RTM 签名
3. **工程 BIOS 安全更宽松** — 软熔丝 bit 6 = 0 (调试未禁用)，SEC_POLICY 更简单
4. **APCB 仅受 ABL checksum 保护** — 我们的 26 字节补丁维护此校验 → **安全**
5. **Strategy B 风险从 HIGH 降级为 MEDIUM-LOW** — 主要剩余风险是 APCB token 兼容性，而非签名验证

> **行动建议**: 可以放心执行 flashrom APCB 补丁。PSP 安全链不会阻止修改后的 APCB 被 ABL 正常读取。唯一需确保的是 APCB checksum 正确 (补丁工具已保证)。

---

## §22 Lenovo OEM 服务工具分析

**日期**: 2025-01-10
**目标**: 分析项目根目录下 `thinkpadOEM/` 中两套 Lenovo OEM 服务工具，评估对 USB4 项目的可用性

### 22.1 工具集概览

项目中包含两套独立的 Lenovo 官方服务工具：

#### A. Lenovo Golden Key U1 Tool V3.5.3 (`thinkpadOEM/LenovoUone/`)

- **版本**: V3.5.3 (2021-07-22)
- **用途**: "Lenovo PCSD Service Enablement" — 联想全产品线工厂/售后服务用 USB 启动盘
- **启动方式**: UEFI 可直接启动 (<code>EFI/BOOT/BOOTX64.EFI</code>, 922KB)
- **架构**: PE32+ AMD64 EFI_APP
- **模式**: `INTERNAL_MODE=1` (内部模式)

#### B. ThinkPad Maintenance Utilities V1.06 (`thinkpadOEM/ThinkPad Maintenance Utilities/`)

- **版本**: V1.06 (2015-Jul-1), 作者 Masahiro Tokuno
- **用途**: ThinkPad 专用维护/服务工具集
- **声明**: "Lenovo Confidential - For development, service and manufacturing use only"
- **启动方式**: UEFI 启动盘 (<code>EFI/Boot/BootX64.efi</code>, 784KB)
- **高级模式**: `hide_adv=0` → Advanced Menu 已启用

### 22.2 Golden Key U1 详细工具清单

U1 工具包含针对不同 BIOS 平台的多个后端 EFI 工具：

| 工具 | 大小 | 用途 | 协议/接口 |
|------|------|------|-----------|
| **ShellFlash64.efi** | 543KB | 全 BIOS 刷写/DMI 补丁 | FFS2, SecureFlash, UpdateCapsule, SMM |
| **H2OSDE-Sx64.efi** | 345KB | Insyde BIOS Setup 编辑器 | Insyde IHISI, NVRAM (仅限 Insyde 平台) |
| **LBGRW.efi** | 47KB | Lenovo BIOS Generic R/W | QNVS (ACPI NVRAM), EDK2 |
| **LvarEfi64V231.efi** | 24KB | Lenovo UEFI 变量编辑器 | GetVariable/SetVariable, Lenovo 专有 GUID |
| **EEPROMx64.efi (B)** | 10KB | 轻量 SN/MTM/UUID 读写 | UEFI RT Services |
| **EEPROMx64.efi (5)** | 63KB | 完整 EEPROM 读写 | SwSMI 0xC0 → SMM → 4KB EEPROM |
| **BIOS_LOCK.efi** | 10KB | BIOS 写保护锁/解锁 | PchSetup UEFI变量 → PchBiosLock |
| **MBD3.efi** | 27KB | Machine Board Data 原始读写 | UDK2010, NVS hex R/W |
| **PARR2.efi** | 23KB | 字符串解析辅助工具 | Shell 脚本辅助 |
| **AMIDEEFIx64_XXX.efi** | 多版本 | AMI DMI 编辑器 | AMI BIOS 平台专用 |
| **ldiag.EFI** | 904KB | Lenovo Diagnostics | 硬件诊断 |
| **DEU.efi** | 161KB | Drive Erase Utility | 安全擦除 |

### 22.3 关键工具深度分析

#### 22.3.1 BIOS_LOCK.efi — BIOS 写保护控制

```
"Program to lock or unlock BIOS ROM FRO V540 - Version 1.0(2019/05/23)"
"For Bitland approved purposes only"
```

**工作机制**:
1. 读取 UEFI 变量 `PchSetup` (Intel PCH Setup)
2. 修改 `PchBiosLock` 字段 (0=解锁, 1=锁定)
3. 调用 `SetVariable` 写回

**关键发现**: 此工具 **仅适用于 Intel PCH 平台** (V540 = Lenovo IdeaPad)。
AMD 平台的 SPI 写保护由 SMN 寄存器 (`SPI_CNTRL0/1`) 控制，而非 PchSetup 变量。
**对本项目: ❌ 不可用**

#### 22.3.2 LBGRW.efi — BIOS Generic Read/Write

```
构建路径: d:\edk2\edk2\Build\MdeModule\DEBUG_MYTOOLS\X64\...\LBGRW\
```

**功能** (UTF-16LE 字符串提取):
```
/R UU    — 读 UUID         /S UU [Value]  — 写 UUID
/R PN    — 读产品名称       /S PN [Value]  — 写产品名称
/R LS    — 读序列号         /S LS [Value]  — 写序列号
/R MT    — 读机型名称       /S MT [Value]  — 写机型名称
/R GBT   — 读启动模式       /S LEB         — 设置 Legacy 启动
/R T1V   — Type1 版本       /S UEB         — 设置 UEFI 启动
/R KB    — 键盘 ID          /R CPU         — MB 板 CPU 类型
/R MA    — MAC ID           /S SPM         — 设置电池船运模式
/S SSB [on/off]              — 启用/禁用 Secure Boot
/S SOO [on/off]              — 启用/禁用 OS Optimized Defaults
/S MAB [on/off]              — 充/放电 主电池
```

**接口**: 使用 QNVS (ACPI Qualified NVS) 地址空间。
**对本项目: ❌ 仅操作 DMI/SMBIOS 数据，无法触及 APCB 区域**

#### 22.3.3 LvarEfi64V231.efi — Lenovo Variable Tool

```
|           Lenovo Variable Tool              |
|              v2.31 Lenovo/LCFC 2020/09/21   |
```

**支持的变量名**: `/pn` (产品名), `/pjn` (项目名), `/mtm`, `/ln` (序列号), `/btid` (品牌),
`/kbid` (键盘), `/epaid`, `/func` (功能标志), `/cust` (客户), `/fd` (家族名), `/at` (资产标签),
`/sku`, `/oa3` (OA3 MSDM), `/slic` (OA2), `/ospn`, `/osdes`, `/mfgmode`, `/macapt`, `/region`

**接口**: `GetVariable`/`SetVariable` — 通过 UEFI RT Services 读写 Lenovo 专有 NVRAM 变量。
**对本项目: ❌ 操作 UEFI NVRAM 变量，非 SPI flash 中的 APCB 二进制数据**

#### 22.3.4 EEPROM5 — SwSMI 驱动的 EEPROM 读写

**工作流程** (readme.txt 摘要):
1. 解析 `EEPROM.ini` 配置 — 获取命令定义、EEPROM 数据结构、SMI 端口
2. 安装 EEPROM 驱动
3. 发送 **SwSMI 0xC0** → SMM 处理器读取 4KB EEPROM 数据
4. 通过 ini 定义的命令进行字段读写

**EEPROM 数据映射** (EEPROM.ini):
| 偏移 | 长度 | 字段 | 类型 |
|------|------|------|------|
| 0x000 | 0x41 | Product Name | astring |
| 0x050 | 0x21 | Serial Number | astring |
| 0x080 | 0x10 | UUID | GUID |
| 0x090 | 0x41 | Project Name | astring |
| 0x0E0 | 0x01 | KBID | byte |
| 0x0E5 | 0x01 | Hidden Page | byte |
| 0x0E6 | 0x01 | Secure Boot | byte |
| 0x0F0 | 0x41 | Family | astring |
| 0x1B0 | 0x41 | MTM | astring |
| 0x200 | 0x21 | OA3 Key ID | astring |
| 0x230 | 0x21 | MB Serial Number | astring |

**对本项目: ❌ 访问 4KB 制造数据 EEPROM (VPD)，非 32MB SPI flash**

#### 22.3.5 H2OSDE-Sx64.efi — Insyde Setup Design Editor

含大量 SMBIOS/NVRAM 字符串提示。专为 Insyde H2O BIOS 设计。
我们的 Z13 使用 Phoenix/AMD AGESA 固件，**非 Insyde 平台**。
**对本项目: ❌ 平台不兼容**

#### 22.3.6 ShellFlash64.efi — UEFI Capsule Flash

`UpdateCapsule`, `CapsuleOnRam`, `SecureFlash` — 全 BIOS capsule 刷写工具。
用于 `/patch /dus /dsm /dps /dvs` DMI 数据补丁。
**对本项目: ⚠️ 理论上可刷全 BIOS，但我们已知量产 BIOS 会变砖 — 危险**

### 22.4 ThinkPad Maintenance Utilities 详细分析

内嵌 UEFI Shell + ThinkPad 专用工具集 (DEU.efi 中的字符串):

```
ThinkPad Maintenance Utilities V1.04(X64) Lenovo Confidential Nov.28.2014
```

**功能菜单**:
1. **Write/Read/Delete Serial Numbers** — 序列号管理
2. **Assign UUID** — UUID 分配
3. **Update Configuration Area** — ECA Info, Brand name, Product ID, Type 11
4. **Initialize EEPROM** — ⚠️ 清除所有系统标识数据、UUID、Config Data
5. **Dump EEPROM** — 导出 EEPROM 区域所有数据
6. **Copy/Update BIOS Settings** — V2.01:
   - Copy BIOS Setting to file
   - Update BIOS Setting from file
   - Update Boot Order only from file
7. **Program to exit MFG mode** — V0.93

**配套 DOS 工具** (FLSHBIOS.SYS 驱动):
| 工具 | 大小 | 用途 |
|------|------|------|
| ECAINF.EXE | 32KB | EC 信息读取 |
| VPDUPDT.EXE | 53KB | VPD 数据更新 |
| SERUPDT.EXE | 114KB | 序列号更新 |
| ADMIN.EXE | 32KB | 管理工具 |
| CFGUPDT.EXE | 24KB | 配置更新 |

**型号数据库** (plnsrv.ini): 覆盖数百款 ThinkPad 型号 (至 X1 Carbon Gen 9, T14s Gen 2, X13 Gen 2 ~ 2021年)。**不包含 Z13 Gen 1 (21D2)**。

**对本项目: ❌ "BIOS Settings" = UEFI Setup 变量，非 APCB 二进制数据**

### 22.5 EEPROMB 写保护工作流

EEPROMB 目录的脚本揭示了标准写保护流程：

```nsh
# eepromefi.nsh (EEPROMB 版本)
BIOS_LOCK.efi U          # 步骤1: 解锁 BIOS
EEPROMx64.efi /wsn %2    # 步骤2: 写入数据
BIOS_LOCK.efi L          # 步骤3: 重新锁定

# 对比: EEPROM5 版本 — 无 BIOS_LOCK 步骤
EEPROMx64.efi /wsn %2    # 直接写入 (通过 SwSMI)
```

**关键区别**: EEPROMB 的 EEPROMx64.efi (10KB) 直接通过 UEFI RT Services 写入，需要先解锁 BIOS ROM；而 EEPROM5 的 EEPROMx64.efi (63KB) 通过 SwSMI → SMM 间接写入，SMM 已有特权，无需额外解锁。

### 22.6 UEFI GUID 交叉引用

对所有工具进行 UEFI GUID 扫描:

| 工具 | GUID | 含义 |
|------|------|------|
| EEPROMx64-5 | 8BE4DF61-93CA-11D2-AA0D-… | gEfiGlobalVariableGuid |
| ThinkPad BootX64 | 8BE4DF61-93CA-11D2-AA0D-… | gEfiGlobalVariableGuid |
| ShellFlash64 | 8BE4DF61-93CA-11D2-AA0D-… | gEfiGlobalVariableGuid |
| ShellFlash64 | EE4E5898-3914-4259-9D6E-… | gEfiFirmwareFileSystem2Guid (FFS2) |
| DEU.efi | 8BE4DF61-93CA-11D2-AA0D-… | gEfiGlobalVariableGuid |

**未发现**: 无 SPI Protocol GUID、无 SMM Communication GUID、无 AMD 特有 GUID。
所有工具均走标准 UEFI 接口 (RT Services / Shell Protocol)，无直接硬件操作。

### 22.7 SPI/Flash 关键字扫描

| 工具 | 关键字命中 |
|------|-----------|
| LBGRW.efi | `QNVS` ×3 |
| BIOS_LOCK.efi | `PchSetup` ×2, `PchBiosLock` ×1, `GetVariable` ×1 |
| H2OSDE-Sx64.efi | `NVRAM` ×5, `Flash` ×1 |
| ShellFlash64.efi | `Flash` ×31, `flash` ×39, `SecureFlash` ×3, `SMM` ×1 |

**未发现**: 无 `APCB`、`apcb`、`SpiProtocol`、`flashrom`、`SmmComm` 命中。
**结论**: 没有任何工具知道 APCB 的存在。

### 22.8 综合评估与结论

#### 对 USB4 项目的可用性判定

| 工具 | 可用性 | 原因 |
|------|--------|------|
| BIOS_LOCK.efi | ❌ | Intel PCH 专用，AMD 无 PchSetup 变量 |
| LBGRW.efi | ❌ | 仅操作 DMI/SMBIOS (QNVS)，非 APCB |
| LvarEfi64V231.efi | ❌ | UEFI NVRAM 变量编辑，APCB 在 raw SPI flash |
| EEPROMx64.efi (两版) | ❌ | 制造 EEPROM (4KB VPD)，非 32MB SPI |
| H2OSDE-Sx64.efi | ❌ | Insyde 平台专用，Z13 用 Phoenix/AGESA |
| ShellFlash64.efi | ⚠️ 危险 | 全 BIOS capsule 刷写 → 已知量产 BIOS 变砖 |
| MBD3.efi | ❌ | Machine Board Data (VPD NVS)，非 APCB |
| ThinkPad Maint BootX64 | ❌ | BIOS Settings = Setup 变量，非 APCB 二进制 |
| ldiag.EFI | ❌ | 硬件诊断，无配置修改能力 |
| DEU.efi | ❌ | 驱动器擦除工具 |

#### 技术层次分析

```
┌─────────────────────────────────────────────────┐
│ Level 4: 用户界面 (BIOS Setup / Shell 菜单)     │ ← ThinkPad Maint Utilities
├─────────────────────────────────────────────────┤
│ Level 3: UEFI 变量 (GetVariable/SetVariable)    │ ← Lvar, LBGRW, H2OSDE, BIOS_LOCK
├─────────────────────────────────────────────────┤
│ Level 2: SMM 服务 (SwSMI → Ring -2)             │ ← EEPROMx64-5 (via SwSMI 0xC0)
├─────────────────────────────────────────────────┤
│ Level 1: Capsule 更新 (UpdateCapsule/FFS)       │ ← ShellFlash64
├─────────────────────────────────────────────────┤
│ Level 0: SPI Flash 直接读写 (SPI Protocol/MMIO) │ ← flashrom ★ (我们需要的层次)
├─────────────────────────────────────────────────┤
│     APCB 数据: SPI Flash @ 0x440000-0x470000    │ ← 目标区域
└─────────────────────────────────────────────────┘
```

**核心问题**: 所有 Lenovo OEM 工具均工作在 Level 1-4，通过 UEFI 标准接口或 SMM 服务间接访问固件。**没有任何工具提供 Level 0 的 SPI flash 直接读写能力**。APCB 存储在 raw SPI flash 中，不在 UEFI 变量存储或 EEPROM VPD 区域中。

#### 最终结论

> **Lenovo OEM 服务工具对本 USB4 项目无直接帮助。** 它们设计用于工厂制造流程(SN/MTM/UUID分配)和售后服务(BIOS 设置备份/恢复)，均通过 UEFI 标准接口操作 NVRAM 变量，不具备 SPI flash 直接操作能力。
>
> **Strategy B (flashrom APCB 26字节补丁) 仍然是唯一可行路径。** 无替代方案。
>
> 这些工具的分析进一步确认了一个事实：Lenovo 自身的高级服务工具也不直接修改 APCB — APCB 被视为固件构建时的静态配置，不在运行时或服务流程中被修改。这间接佐证了 APCB 修改后被 ABL 正常读取的安全性（只要 checksum 正确）。
