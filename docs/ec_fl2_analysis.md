# EC Firmware (FL2) Analysis — ThinkPad Z13 Gen 1 (21D2CT01WW)

## 1. 概述

本文档分析从 Lenovo BIOS 更新 ISO 中提取的 EC (Embedded Controller) 固件 FL2 文件，
并与机器上运行的工程版 EC 进行对比，评估 EC 更新对启用 USB3/DP 功能的可行性。

### 文件清单

| 文件 | 来源 | EC 版本 | BIOS 版本 | 大小 | SHA256 |
|------|------|---------|-----------|------|--------|
| N3GHT68W.FL2 | n3gur25w.iso | N3GHT68W (v6.8) | N3GET74W | 327,968 B | `a8355b2a...` |
| N3GHT69W.FL2 | n3gur27w.iso | N3GHT69W (v6.9) | N3GET76W | 327,968 B | `011c3027...` |
| (当前机器) | 工程版 | N3GHT15W (v0.15) | N3GET04WE (0.04f) | — | — |

### ISO 提取方法

Lenovo BIOS ISO 是 El Torito 可引导格式，内嵌 FAT32 文件系统（50MB），起始于 ISO offset `0x11800`。
文件目录结构：
```
/EFI/Boot/BootX64.efi
/Flash/N3GETxxW/$0AN3G00.FL1    ← BIOS 固件 (~34.5MB)
/Flash/N3GETxxW/$0AN3G00.FL2    ← EC 固件 (~320KB)
```

---

## 2. FL2 文件结构

### 2.1 双镜像头 (_EC1 / _EC2)

FL2 文件包含两个 EC 镜像，可能用于 A/B 冗余更新：

```
Offset  Field        N3GHT68W         N3GHT69W
------  -----        --------         --------
0x00    Magic        _EC\x01          _EC\x01
0x04    Total size   0x50120 (327968) 0x50120 (327968)
0x08    Data size    0x50000 (327680) 0x50000 (327680)
0x14    Checksum     0x39B08081       0x15B9A478

0x20    Magic        _EC\x02          _EC\x02
0x24    Total size   0x4F140 (323904) 0x4F140 (323904)
0x28    Data size    0x4F000 (323584) 0x4F000 (323584)
0x34    Checksum     0x5E5A78B9       0xA61930FA
```

- **_EC1**: 完整镜像，代码从 offset `0x0120` 开始，大小 327,680 字节
- **_EC2**: 次要镜像，代码从 offset `0x1120` 开始（_EC1 内偏移），大小 323,584 字节
- 签名区域 `0x0080-0x00BF` (64 bytes): 可能是 RSA/ECDSA 数字签名

### 2.2 ARM Cortex-M 向量表

在 FL2 offset `0x0120` 找到向量表（置信度: score=27/32）：

| 向量 | 地址 | 说明 |
|------|------|------|
| SP (栈指针) | `0x200C7C00` | SRAM 区域 |
| Reset | `0x100701F5` (Thumb) | 代码入口 |
| NMI | `0x10070291` | |
| HardFault | `0x1007029D` | |
| MemManage | `0x100702A9` | |
| BusFault | `0x100702B5` | |
| UsageFault | `0x100702C1` | |
| SVCall | `0x100702CD` | |
| PendSV | `0x100702E5` | |
| SysTick | `0x100702F1` | |

**两个版本 (68W / 69W) 的向量表 Reset 入口地址相同** (`0x100701F4`)。

---

## 3. EC 芯片确认：Nuvoton NPCX

### 3.1 外设地址匹配

分析发现大量 Nuvoton NPCX 系列外设寄存器引用：

| 外设 | 基址 | 功能 |
|------|------|------|
| GPIO | `0x400C7000` | 通用 IO |
| MIWU0/1/2 | `0x400C1/3/5000` | 多输入唤醒 |
| CDCG | `0x400C9000` | 时钟分配 |
| PM Channel | `0x400CB000` | 电源管理通道 |
| UART | `0x400CD000` | 串口调试 |
| SHI | `0x400CF000` | SPI 主机接口 |
| SHM | `0x400D1000` | 共享内存 |
| KBC | `0x400D3000` | 键盘控制器 |
| ADC | `0x400D5000` | 模数转换 |
| SMBus 0-7 | `0x400D7-DD000` / `0x40080-86000` | I2C/SMBus 总线 |
| TWD | `0x400DF000` | 定时器/看门狗 |
| ITIM | `0x400E1000` | 内部定时器 |
| PWM | `0x400E3000` | PWM 风扇控制 |
| eSPI | `0x400E5000` | 增强 SPI |
| PECI | `0x4000C000` | CPU 温度接口 |
| SPIP | `0x4000E000` | SPI 外设 |

**结论：确认为 Nuvoton NPCX7/NPCX9 系列 EC**（非 ITE）

### 3.2 内存映射

```
地址范围              引用次数   说明
0x10070000-0x1009FFFF  ~6000+   代码 RAM（主固件执行区域）
0x100A0000-0x100BFFFF  ~3952    代码 RAM（扩展区域）
0x200C0000-0x200DFFFF  ~1900    数据 SRAM
0x40000000-0x40FFFFFF  ~1000+   外设寄存器
0xE0000000-0xE00FFFFF  ~1200    Cortex-M 系统寄存器 (NVIC, SCB, SysTick)
```

Ghidra 导入推荐基址：**`0x10070000`**

---

## 4. 内嵌 PD 控制器固件

**关键发现：EC FL2 中嵌入了 3 个 USB PD 控制器固件**：

| PD 固件 ID | FL2 Offset | 大小 | 用途推测 |
|------------|-----------|------|----------|
| N3GPD17W | `0x03AC25` | ~14.5KB | PD 控制器（主 USB-C 端口） |
| N3GPH20W | `0x03E6A6` | ~14.5KB | PD 控制器 H 变体（端口 2 / 高功率） |
| N3GPH70W | `0x042127` | ~16KB | PD 控制器 H 变体（DP Alt Mode?） |

### PD 固件版本索引表

在 offset `0x045B27` 有一个 PD 固件版本索引表：
```
045B27: N3GPD17W\0N3GPH20W\0N3GPH70W\0
045B42: {配置参数表}
```

每个 PD 固件 blob 有相似的头部结构：
```
+0x00: 01 00            (标志?)
+0x02: XX XX            (blob 大小 LE16)
+0x04: XX XX XX XX      (校验和/哈希)
+0x08: XX .. 00 00 00   (保留)
+0x14: "0x1 "           (版本标记?)
+0x18: fa XX            (magic)
+0x1A: 54 00 1a         (PD 配置)
+0x1E: XX 06 00 07      (端口配置)
+0x20: "N3GPxx7xW"      (固件 ID)
```

### PD 版本对比

68W 和 69W 的 PD 固件 ID **完全相同**：N3GPD17W / N3GPH20W / N3GPH70W，
说明两个 EC 版本搭配的 PD 固件没有变化。

---

## 5. 版本差异分析：N3GHT68W vs N3GHT69W

### 5.1 统计

- 文件大小完全相同：327,968 字节
- 不同字节数：**249,127 / 327,968 (75.96%)**
- 差异区域数：17,619 个
- 结构（双镜像头、向量表、PD 固件 ID）完全相同

### 5.2 结论

76% 的字节差异表明这是一次**完全重编译**（可能涉及编译器版本变更、链接顺序调整），
而非简单的 bugfix 补丁。主要特征保持一致（PD 固件不变、向量表入口不变）。

---

## 6. 工程 EC (N3GHT15W) vs 量产 EC 对比

### 6.1 版本号 decode

Lenovo 固件命名规则：`N3G` = Z13 Gen 1 项目
- `HT` = EC 类型，后跟版本号
- `15W` = 工程版 v0.15
- `68W` = 量产版 v6.8（对应 BIOS v7.4）
- `69W` = 量产版 v6.9（对应 BIOS v7.6）

### 6.2 当前工程 EC 的问题

| 功能 | 工程 EC (0.15) | 量产 EC (6.8/6.9) |
|------|---------------|-------------------|
| 基本键盘/触控板 | ✅ | ✅ |
| 电池管理 | ✅（电池 5B10W51883 不在 FRU 表中） | ✅ |
| 风扇控制 | ✅（thinkfan 可用） | ✅ |
| USB-C Type-C 管理 | ❌（无 /sys/class/typec/ 设备） | ✅（推测） |
| USB PD 控制器 | ❌/部分（无 UCSI 接口） | ✅（嵌入 PD 固件） |
| USB3 SuperSpeed | ❌（仅 USB2 工作） | ✅（推测） |
| DP Alt Mode | ❌ | ✅（推测） |

### 6.3 关键证据

1. **无 typec class 设备** — `ls /sys/class/typec/` 返回空
2. **USB 拓扑** — 5 个总线运行（xhci_hcd），但无 Type-C 端口管理
3. **Microchip USB DFU** — `04d8:0039` 设备存在（可能是 PD 控制器处于 DFU 模式）
4. **PD 固件嵌入** — 量产 FL2 携带 3 个 PD 控制器固件（N3GPD17W/N3GPH20W/N3GPH70W）

**`04d8:0039 Microchip Technology USB DFU` 可能是关键线索**：
这是一个 PD 控制器（可能是 Microchip/MCHP USB-C PD 芯片）停留在 DFU（固件更新）模式，
说明工程 EC 从未给 PD 控制器写入过生产固件。

---

## 7. EC 更新可行性评估

### 7.1 更新路径

| 方案 | 风险 | 可行性 |
|------|------|--------|
| **A: 通过 BIOS 更新 ISO 刷入** | 低 | ⚠️ 可能不兼容工程 BIOS |
| **B: 直接写入 EC SPI Flash** | 极高 | ❌ 需要拆机+找到 EC SPI 芯片 |
| **C: 通过 fwupd capsule** | 中 | ⚠️ fwupd 未检测到 EC |
| **D: 先刷量产 BIOS + EC 联合更新** | 中高 | ⚠️ 需要完整量产 SPI 镜像 |

### 7.2 风险分析

**⚠️ EC 刷坏后果极其严重：**
- EC 控制电源开关 — 刷坏后机器**完全无法开机**
- EC SPI Flash 是独立芯片，**不在主 SPI 中**（已通过 CH341A 恢复验证）
- 不同于主 SPI，EC SPI 可能没有外部编程接口（SOP clip 无法触及）
- 即使有接口，需要精确定位 EC SPI 芯片位置

### 7.3 FL2 签名验证

`0x0080-0x00BF` 区域的 64 字节数据可能是数字签名。
如果 EC 启动时验证签名，则：
- 工程 EC 和量产 EC 可能使用**不同的签名密钥**
- 直接用量产 FL2 覆盖工程 EC Flash 可能导致签名校验失败 → 变砖

### 7.4 建议

1. **不要贸然更新 EC** — 砖的风险太高，且恢复手段有限
2. **先尝试方案 A** — 用 Lenovo BIOS 更新 ISO 启动，看是否自动刷 EC
   - 注意：ISO 中的 BIOS 是量产版 (N3GET74W/76W)，可能不兼容工程硬件
3. **关注 Microchip DFU 设备** — `04d8:0039` 可能可以通过 USB DFU 协议单独更新 PD 固件
4. **研究 PD 控制器独立更新** — 如果 PD 芯片在 DFU 模式，也许可以用 `dfu-util` 刷入 PD 固件

---

## 8. Microchip PD 控制器 DFU 调查

### 8.1 设备详情

```
Bus 001 Device 002: ID 04d8:0039 Microchip Technology, Inc. USB DFU
  iManufacturer: MCHP
  iProduct:      USB DFU
  iSerial:       MCHP-DF-005
  bcdDevice:     8.20 (bootloader version)
  DFU capabilities: Upload + Download supported
  wTransferSize: 64 bytes
  bcdDFUVersion: 1.00
```

### 8.2 DFU 状态

- `dfu-util -l` → `DFU state(2) = dfuIDLE, status(0) = No error condition is present`
- `dfu-util -U` → Upload 返回 **0 字节** — **固件为空**
- PD 控制器处于 ROM DFU bootloader 中，从未被 EC 写入过生产固件

### 8.3 重大发现

**Microchip PD 控制器的固件正常情况下由 EC 在启动时通过 I2C/SMBus 写入**。
工程 EC (v0.15) 缺少这个初始化流程，导致：
1. PD 控制器永远停留在 DFU bootloader
2. 无 USB-C Type-C 端口管理 → `/sys/class/typec/` 为空
3. 无 USB PD 协商 → USB3 SuperSpeed / DP Alt Mode 不可用
4. PD 控制器暴露 USB DFU 接口 (`04d8:0039`)

### 8.4 潜在独立更新路径

PD 控制器同时暴露了 USB DFU 接口，理论上可以绕过 EC 直接写入固件：

```bash
# ⚠️ 高风险操作 — 未经验证，可能导致 PD 芯片变砖
# 需要先从 FL2 中正确提取 PD 固件 blob 并转换为 DFU 格式
sudo dfu-util -d 04d8:0039 -D pd_firmware.bin
```

**但需要解决：**
- FL2 中的 PD 固件 blob 可能不是标准 DFU 格式（需要解析头部）
- 三个 PD 固件（N3GPD17W/N3GPH20W/N3GPH70W）不确定哪个对应这个 DFU 设备
- 可能还有其他 PD 控制器不在 USB 总线上（通过 I2C 连接）
- 即使 PD 固件写入成功，EC 侧的 UCSI 驱动也需要配合

---

## 9. BootX64.efi 更新工具分析

### 9.1 工具概况

| 文件 | 大小 | 说明 |
|------|------|------|
| BootX64.efi | 2,145,208 B | 主更新工具（含 DC/电池检查） |
| NoDCCheck_BootX64.efi | 2,143,768 B | 工厂/服务版（跳过 DC 检查） |
| SHELLFLASH.EFI | 23,296 B | EFI Shell 辅助工具（仅引导） |

**BootX64.efi = Lenovo SecureFlash (基于 Insyde H2O IHISI)**

### 9.2 命令行参数

从字符串分析提取的 `FlashCommand` 参数：

| 参数 | 说明 |
|------|------|
| **EC Update** | 仅更新 EC 固件 |
| **BIOS Update** | 仅更新 BIOS 固件 |
| **ECFW Update** | 更新 EC 固件（可能与 "EC Update" 不同流程） |
| **Skip Battery check** | 跳过电池电量检查 |
| **Skip ECFW image check** | ⚠️ **跳过 EC 固件镜像验证** |
| **Skip AC Adapter check** | 跳过 AC 适配器检查 |
| **Clear BIOS Configuration** | 清除 BIOS 配置 |
| **Force update backup area** | 强制更新 BIOS Self-healing 备份区 |
| **Set ECFW** | 设置 EC 固件（配合密码?） |
| **Reboot automatically** | 自动重启 |

### 9.3 安全机制

1. **LenovoSecureFlash** — 使用 Insyde SecureFlash 签名验证
2. **Intel BIOS Guard (PFAT)** — PUP (Protected Update Package) 格式
3. **PUP 组件**: PUPHEAD.BIN, PUPSCRP.BIN, PUPCERT.BIN, PUPSIGN.BIN
4. **Capsule Update** — 通过 `FlashCapsuleUpdate.c` 实现

### 9.4 更新流程推断

```
BootX64.efi 启动
  ├── 读取 $0AN3G00.FL1 (BIOS) 和 $0AN3G00.FL2 (EC)
  ├── 检查 AC 适配器 / 电池电量
  ├── 验证 SecureFlash 签名
  ├── 通过 IHISI SMM 接口发送固件数据
  │   ├── BIOS: PFAT/BIOS Guard 写入 SPI Flash
  │   └── EC: 通过 EC 命令接口写入 EC Flash
  └── 自动重启
```

### 9.5 对工程机的可行性评估

**关键问题：**
1. **IHISI 接口依赖 SMM** — 工程 BIOS (N3GET04WE) 是否包含 SecureFlash SMM handler？
2. **BIOS Guard/PFAT** — 工程 BIOS 是否启用了 BIOS Guard？（可能未启用）
3. **签名密钥** — 量产固件签名能否通过工程 BIOS 的验证？

**`Skip ECFW image check` 参数可能允许绕过签名验证！**

### 9.6 建议操作

**低风险测试（不写入任何数据）：**
```bash
# 1. 从 USB 启动 BIOS ISO，进入 EFI Shell
# 2. 手动运行 BootX64.efi 查看帮助/错误信息
# 3. 观察是否能识别 IHISI 接口
```

**中风险操作（仅更新 EC）：**
```bash
# 使用 NoDCCheck 版本 + 跳过检查参数
# ⚠️ 如果 EC 更新失败，机器可能无法开机
NoDCCheck_BootX64.efi /ecfu "Skip ECFW image check" "Skip Battery check"
```

> **警告：以上命令格式是推测的，实际参数语法需要进一步验证。
> 建议先在 EFI Shell 中运行 `BootX64.efi /?` 查看帮助。**

---

## 10. 下一步

- [ ] 从 FL2 提取 N3GPD17W blob 的纯固件数据（去掉 Lenovo 头部）并分析 Microchip 固件格式
- [ ] 研究 Microchip USB-C PD 控制器固件更新协议（可能需要 MCHP 专有工具 MPLABConnect）
- [ ] 分析 LADDR 配置表（offset `0x0469B8`）中的 EC 寄存器映射
- [ ] 对比工程 SPI dump 中 EC 相关的 ACPI 表（ECDT、EC OpRegion）
- [ ] 在 Ghidra 中加载 FL2（基址 `0x10070000`，ARM Cortex-M4，Thumb-2）进行逆向
- [ ] 考虑：是否可以用量产 BIOS ISO 直接引导更新（包含 FL1+FL2，EC 更新程序可能在 SHELLFLASH.EFI 中）

---

## 附录 A: EC FL2 内嵌字符串（关键项）

```
0x000528: "N3GHT68W"                    ← EC 版本 ID
0x0015A0: "(C) Copyright IBM Corp..."   ← Lenovo/IBM 版权
0x0317C8: "SB10F4646000HW022"           ← 电池 FRU 表 (30 条目)
0x03AC43: "N3GPD17W"                    ← PD 控制器固件 1
0x03E6C4: "N3GPH20W"                    ← PD 控制器固件 2
0x042145: "N3GPH70W"                    ← PD 控制器固件 3
0x0469B8: "0.1500.160LADDR"             ← 版本/地址配置
```

## 附录 B: 提取命令记录

```bash
# 1. 从 ISO 提取 FAT32 文件系统
python3 -c "
import struct
data = open('n3gur25w.iso', 'rb').read()
bpb = data[0x11800:0x11C00]
total = struct.unpack_from('<I', bpb, 32)[0]
open('/tmp/fat32.img', 'wb').write(data[0x11800:0x11800 + total * 512])
"

# 2. 挂载并提取
sudo mount -o loop,ro /tmp/fat32.img /tmp/fat_mount
cp /tmp/fat_mount/Flash/N3GET74W/\$0AN3G00.FL2 ./N3GHT68W.FL2

# 3. 分析
python3 scripts/analyze_ec_fl2.py ./N3GHT68W.FL2
```
