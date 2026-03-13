# EC 固件更新 USB 构建记录 — ThinkPad Z13 Gen 1 (21D2CT01WW)

> 构建日期: 2026-03-13
> 目标: 通过 BootX64.efi 仅刷新 EC 固件，不触碰主 SPI (BIOS)
> USB 设备: Realtek RTL9220 Media (disk8, /Volumes/UNTITLED, FAT32, 14.4GB)

---

## 1. 构建背景

### 1.1 目标

将当前工程版 EC (N3GHT**15**W, v0.15) 升级为量产版 EC (N3GHT**69**W, v6.9)，
以恢复 USB-C Type-C 管理、USB3 SuperSpeed 和 DP Alt Mode 功能。

参见 `docs/ec_fl2_analysis.md §6` 对工程 EC 与量产 EC 功能差异的完整分析。

### 1.2 关键架构前提

ThinkPad Z13 Gen 1 主板采用**双 SPI Flash 独立架构**：

| 标号 | 芯片 | 总线 | 用途 |
|------|------|------|------|
| **U2101** | W25Q256JWEIQ (32MB) | AMD SoC SPI | 主 SPI — BIOS/PSP/UEFI |
| **U8505** | W74M25JWZEIQ | EC 独立 SPI | EC SPI — EC 固件 + PD blob |

两颗芯片在物理上完全独立，分属不同总线，操作 U8505 对 U2101 零影响。

BootX64.efi 通过 **EC mailbox 协议 (SMI → IHISI SMM handler → EC 命令接口)**
将 FL2 写入 U8505，全程不操作 U2101。

### 1.3 为何选择 NoDCCheck_BootX64.efi

- **NoDCCheck** 版本已移除 AC 电源和电池电量检查
- 工程机环境下电源状态检测可能不稳定
- 安全验证机制与原版完全一致（仅去除电源检查）
- 两版本均含 `Skip ECFW image check` 能力可绕过签名验证

---

## 2. ISO 来源与验证

### 2.1 来源文件

| 项目 | 值 |
|------|-----|
| ISO 文件 | `n3gur27w.iso` |
| 存储位置 | `/Volumes/UNTITLED/n3gur27w.iso` |
| 文件大小 | 51MB |
| BIOS 版本 | N3GET76W (v7.6) |
| EC 版本 | N3GHT69W (v6.9) |
| ISO 格式 | El Torito 可引导，内嵌 FAT32 (49MB，起始偏移 0x11800) |

### 2.2 FAT32 提取方式 (macOS)

```python
# 从 El Torito ISO 提取内嵌 FAT32 镜像
import struct
with open('/Volumes/UNTITLED/n3gur27w.iso', 'rb') as f:
    f.seek(0x11800)
    fat32 = f.read(52428288)   # 102399 sectors × 512 bytes
with open('/tmp/n3gur27w_fat32.img', 'wb') as f:
    f.write(fat32)

# macOS hdiutil 挂载
# hdiutil attach /tmp/n3gur27w_fat32.img -mountpoint /tmp/n3g_iso_mount -readonly
```

FAT32 内部结构：
```
/EFI/Boot/BootX64.efi               ← 标准 UEFI 启动入口 (= Flash/BootX64.efi)
/Flash/BootX64.efi                   ← 完整更新工具 (含 DC 检查)
/Flash/NoDCCheck_BootX64.efi         ← 无 DC 检查版本
/Flash/SHELLFLASH.EFI                ← EFI Shell 辅助启动器 (23KB)
/Flash/N3GET76W/$0AN3G00.FL1         ← BIOS 固件 33MB  ← 不复制!
/Flash/N3GET76W/$0AN3G00.FL2         ← EC 固件  320KB  ← 复制
```

---

## 3. FL2 固件验证

```
文件名:  $0AN3G00.FL2  (ISO 内部名称)
         N3GHT69W.FL2  (项目内重命名)
大小:    327,968 bytes
SHA256:  011c3027195b7f640df3c9b5b72cf95e3dc09ef8c04413c4417f29c6347b03de
```

内嵌版本字符串：

| 版本串 | 用途 |
|--------|------|
| `N3GHT69W` | EC 主固件版本 (v6.9) |
| `N3GPD17W` | PD 控制器固件 1 |
| `N3GPH20W` | PD 控制器固件 2 |
| `N3GPH70W` | PD 控制器固件 3 |

与项目已存档的 `firmware/ec/N3GHT69W.FL2` SHA256 完全一致。

---

## 4. USB 目录结构

```
/Volumes/UNTITLED/
├── EFI/
│   └── Boot/
│       └── BootX64.efi            ← NoDCCheck_BootX64.efi (UEFI 自动启动入口)
│                                     SHA256: 14b44c53e093cf32...
│
├── Flash/
│   ├── BootX64.efi                ← 原版 (含 DC 检查，备用)
│   │                                 SHA256: 8ff68780369e69a6...
│   ├── NoDCCheck_BootX64.efi      ← 无 DC 检查版本 (手动调用用)
│   │                                 SHA256: 14b44c53e093cf32...
│   ├── SHELLFLASH.EFI             ← EFI Shell 辅助启动器
│   ├── ec_update_only.nsh         ← EC-only 手动调用脚本
│   └── N3GET76W/
│       └── $0AN3G00.FL2           ← N3GHT69W v6.9 EC 固件 320KB
│                                     !! $0AN3G00.FL1 故意缺失 !!
│
├── Tools/
│   ├── ldiag.EFI                  ← Lenovo 硬件诊断
│   ├── LBGRW.efi                  ← BIOS Generic R/W (DMI)
│   ├── LvarEfi64V231.efi          ← UEFI 变量编辑器
│   └── MBD3.efi                   ← Machine Board Data R/W
│
├── startup.nsh                    ← EFI Shell 自动执行脚本
├── README.txt                     ← 操作说明
└── n3gur27w.iso                   ← 原始 ISO 备份 (51MB)
```

### 4.1 关键设计决策

**FL1 故意缺失**：`$0AN3G00.FL1` (BIOS, 33MB) 被刻意排除在外。
- BootX64.efi 找不到 FL1 时无法刷写主 SPI (U2101)
- 即使工具意外尝试全量更新，也只能更新 EC (只有 FL2)
- 这是防止 BIOS 意外被刷的硬性保障

**NoDCCheck 作为 EFI 启动入口**：
- UEFI 固件启动 USB 时自动加载 `/EFI/Boot/BootX64.efi`
- 此文件实际为 NoDCCheck 版本，无需 AC 电源检查
- 减少工程机环境下的电源状态误判

---

## 5. BootX64.efi 工作原理 (EC 更新路径)

根据 `docs/usb4_analysis.md §20` 的逆向分析：

```
NoDCCheck_BootX64.efi 启动
  │
  ├── 扫描引导设备 → 发现 Flash/N3GET76W/$0AN3G00.FL2
  ├── FL1 不存在 → 跳过 BIOS 更新
  ├── FL2 存在   → 进入 EC 更新流程
  │
  ├── 读取 FlashCommand 参数:
  │   "ECFW Update"           → 仅更新 EC
  │   "Skip ECFW image check" → 跳过 EC 固件签名验证
  │   "Skip Battery check"    → 跳过电池检查
  │   "Skip AC Adapter check" → 跳过 AC 检查
  │
  ├── 通过 LenovoVariableSmiCommand → SMI 触发
  ├── BIOS SMM Handler (IHISI) 接收请求
  ├── 通过 EC mailbox 协议发送固件数据
  │   → EC (NPCX997KA0BX) 接收并写入 U8505
  └── 重启
```

### 5.1 关键字符串确认 (来自 NoDCCheck_BootX64.efi strings 分析)

```
EC Update                           ← EC 更新命令
ECFW Update                         ← EC 固件更新命令 (推荐)
Skip ECFW image check               ← 跳过签名验证
Skip Battery check                  ← 跳过电池检查
Skip AC Adapter check               ← 跳过 AC 检查
LenovoEcfwUpdate                    ← UEFI 协议名
ECFW image file is invalid          ← 签名验证失败提示
This system BIOS supports signed ECFW image only.    ← 可能触发
This system BIOS supports unsigned ECFW image only.  ← 工程 BIOS 可能命中
Error: Failed to write FlashCommand to BCP.          ← BCP NVRAM 写入失败
.ecfw                               ← 可能的 CLI shorthand 参数
```

---

## 6. 操作流程

### 6.1 方法 A: 直接 UEFI 启动 (最简单)

```
1. 接上 AC 电源 (保险起见)
2. ThinkPad F12 → 选择 USB 设备启动
3. NoDCCheck_BootX64.efi 自动加载
4. 工具扫描 Flash/N3GET76W/ → 发现 $0AN3G00.FL2
5. 执行 EC 更新
6. 自动重启
```

预期输出：
```
Begin Flashing......
ECFW Update
Image flashing done
BIOS is updated successfully.
System will shutdown or reboot in 5 seconds!
```

### 6.2 方法 B: EFI Shell + 手动参数 (推荐，可控)

如果进入了 EFI Shell 环境：

```nsh
Shell> fs0:
Shell> NoDCCheck_BootX64.efi "ECFW Update" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
```

或直接运行内置脚本：
```nsh
Shell> startup.nsh
```

### 6.3 方法 C: startup.nsh 自动流程 (备选)

如果 EFI Shell 自动读取了 `startup.nsh`，脚本会：
1. 确认 FL2 文件存在
2. 10 秒倒计时（可中止）
3. 先尝试 `ECFW Update` + 跳过所有检查
4. 若失败，备选 `EC Update` 语法

---

## 7. 校验和汇总

| 文件 | SHA256 (前32字符) | 大小 |
|------|-------------------|------|
| `EFI/Boot/BootX64.efi` (NoDCCheck) | `14b44c53e093cf322d0c263c52fe2ac9` | 2,143,768 B |
| `Flash/BootX64.efi` (原版)          | `8ff68780369e69a6e00e9a77a03a864b` | 2,145,208 B |
| `Flash/NoDCCheck_BootX64.efi`       | `14b44c53e093cf322d0c263c52fe2ac9` | 2,143,768 B |
| `Flash/N3GET76W/$0AN3G00.FL2`       | `011c3027195b7f640df3c9b5b72cf95e` | 327,968 B   |

> 注：`EFI/Boot/BootX64.efi` 与 `Flash/NoDCCheck_BootX64.efi` SHA256 完全相同，
> 确认两者为同一文件。

---

## 8. 实测结果 (2026-03-13)

> **状态: ❌ 失败 — Part Number 不匹配, 跳过参数未生效**

### 8.1 执行记录

在 EFI Shell 中执行:
```nsh
NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
```

工具报告**机型不兼容**, 拒绝继续 EC 更新。`"Skip part number checking"` 参数未能绕过检查。

### 8.2 失败原因分析

1. **参数系统双层冲突** — NoDCCheck_BootX64.efi 内部有两套参数体系
   (FlashCommand 长句 + dot-token 短命令), 如何正确传递 "Skip part number"
   的映射关系尚未完全锁定
2. **OEM 兼容检查硬编码** — 可能在 FlashCommand 参数处理之前就已执行
3. **工程 BIOS BCP 缺失** — 工程版 BIOS (N3GET04WE) 的 NVRAM 中可能没有
   标准 BCP 变量, 导致 `Failed to get partnumber from ROM BCP!`

### 8.3 结论

**EFI 工具路径 (方案 A) 暂时不可用。** 后续需要:
- 更深层 EFI 逆向, 找到正确的参数调用方式
- 或者直接走 CH341A 物理编程 (方案 B)

---

## 9. 风险评估 (事前)

| 风险 | 级别 | 缓解措施 |
|------|------|---------|
| EC 签名验证失败 (工程 BIOS 拒绝量产 EC) | 中 | `Skip ECFW image check` 参数；或切换 CH341A 物理方案 |
| EC 固件写入失败导致 EC 变砖 | 中 | U8505 已有完整备份 (`ec_spi_read_20260313_104036.bin`)，可 CH341A 恢复 |
| 工程 BIOS (N3GET04WE) IHISI handler 不支持 EC 更新 | 中 | 如果 SMI 接口不存在，工具会报 "BIOS doesn't support SMI" |
| BIOS 被意外刷写 | **无** | FL1 物理缺失，技术上不可能 |
| 量产 EC + 工程 BIOS 不兼容 | 中 | 最坏情况：键盘/电源失效，用 CH341A 恢复 EC 备份 |

### 9.1 工程 BIOS 签名密钥分析

根据 `docs/usb4_analysis.md §20.6`，工具包含以下检测逻辑：
```
"Secure flash public key is same with sample/dummy in SCT"
"This system BIOS supports unsigned ECFW image only."
```

工程 BIOS (N3GET04WE) **可能**使用 dummy/sample 签名密钥，这意味着：
- 签名验证可能在宽松模式下运行
- `Skip ECFW image check` 可有效绕过剩余检查
- `unsigned ECFW image only` 分支可能被工程 BIOS 命中（反而有利）

---

## 10. 后备方案 (CH341A)

如果 BootX64.efi 方法失败，唯一可靠替代方案是 **CH341A 物理编程**：

```
目标芯片:  U8505 (W74M25JWZEIQ, 主板背面, 1.8V)
备份文件:  firmware/spi_dump/ec_spi_read_20260313_104036.bin
操作文档:  docs/ec_spi_operation_guide.md

写入策略:
  [SPI[0x0000:0x1000] 原始头部] + [FL2[0x20:] EC2 container 开始]
  禁止全片盲写，必须保留前 0x1000 字节头部区域

注意: 需要 1.8V 电平转换适配板，CH341A 默认 3.3V 不可直接使用
```

---

## 11. 验证步骤 (成功更新后)

重启进入 Linux 后执行：

```bash
# 确认 EC 版本已更新
cat /sys/class/dmi/id/ec_firmware_release
# 期望: N3GHT69W 或类似

# 确认 USB-C 端口管理出现
ls /sys/class/typec/
# 期望: port0/ port1/ (非空)

# 确认 PD 控制器不再停留在 DFU bootloader
lsusb | grep "04d8:0039"
# 期望: 消失 (PD 控制器已被 EC 写入生产固件)

# 确认 UCSI 驱动加载
dmesg | grep -i "ucsi\|typec"

# 确认 USB3 SS 速度
lsusb -t | grep "5000M\|10000M"
```

---

## 参考文档

| 文档 | 内容 |
|------|------|
| `docs/ec_fl2_analysis.md` | FL2 逆向分析、BootX64.efi 参数清单、DFU 状态 |
| `docs/ec_spi_fl2_mapping.md` | SPI ↔ FL2 偏移映射、版本对比、写入策略 |
| `docs/ec_spi_operation_guide.md` | CH341A 物理操作清单 (后备方案) |
| `docs/ec_spi_read_20260313_analysis.md` | EC SPI 实读结构分析 |
| `docs/usb4_analysis.md §19` | FL1/FL2 架构、双 SPI 芯片布局 |
| `docs/usb4_analysis.md §20` | BootX64.efi 完整逆向分析 |
| `docs/usb4_analysis.md §28` | EC SPI U8505 物理识别与备份方案 |
| `firmware/ec/N3GHT69W.FL2` | EC 固件存档 (与 ISO 内 FL2 SHA256 一致) |
| `firmware/spi_dump/ec_spi_read_20260313_104036.bin` | EC SPI 备份 (恢复用) |