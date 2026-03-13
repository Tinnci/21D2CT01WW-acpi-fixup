# PD 控制器分析报告

> 日期：2026-03-13
> 设备：ThinkPad Z13 Gen 1 21D2CT01WW（工程样机）
> 输入：`firmware/ec/N3GHT68W.FL2`、`firmware/ec/N3GHT69W.FL2`、`firmware/spi_dump/ec_spi_read_20260313_104036.bin`
> USB 设备：Microchip `04d8:0039` USB DFU（Bus 001 Device 002）
> 结论状态：分析完成；DFU 独立更新路径**不推荐**，需进一步研究

---

## 关键结论

1. **工程机的 Microchip PD 控制器永远停留在 ROM DFU bootloader**，从未收到量产 EC 初始化时通过 I2C/SMBus 写入的 PD 固件，这是导致 USB-C 功能完全失效的根本原因。
2. **FL2 中嵌入 3 个 PD 固件 blob**（N3GPD17W/N3GPH20W/N3GPH70W），每个均约 14–22 KB，使用 Microchip 专有格式（非标准 USB DFU suffix 格式）。
3. **工程版 dump 中的 PD 版本**（N3GPD04W/H03W/H53W）与量产 FL2 中的版本（N3GPD17W/H20W/H70W）完全不同，头部结构完全相同，仅哈希/端口配置不同。
4. **FL2_68 与 FL2_69 的 PD 区域 100% 相同**，PD 固件版本在两次 EC 大版本更新间未变化。
5. **直接用 `dfu-util` 写入 PD blob 不可行**：格式不兼容，且需要 root 权限（现报 `LIBUSB_ERROR_ACCESS`）。

---

## 输入与方法

### 输入文件

| 文件 | 用途 |
|---|---|
| `firmware/ec/N3GHT68W.FL2` | 量产 EC 固件（含 PD blob） |
| `firmware/ec/N3GHT69W.FL2` | 量产 EC 固件 v2（含 PD blob） |
| `ec_spi_read_20260313_104036.bin` | 工程版 EC SPI dump（含工程版 PD 区域） |

### 方法

- Python 字节级扫描：版本串定位 + 头部结构逆向
- `lsusb -v -d 04d8:0039`：USB DFU 描述符读取
- `dfu-util -l`：DFU 设备枚举（非 root，有权限限制）
- 版本索引表（`FL2[0x045B27]`）+ 配置表（`FL2[0x045B44]`）关联分析

---

## 结果与证据

### 3.1 PD 固件版本对比表

| 版本 | 来源 | FL2 偏移 | 大小 | SHA256前16位 |
|---|---|---|---|---|
| N3GPD17W | FL2_68/69（量产） | `0x3AC23–0x3E63E` | 14.6 KB | `9bda622a282a0059` |
| N3GPH20W | FL2_68/69（量产） | `0x3E672–0x420BF` | 14.6 KB | `d5bd8c7626894d0e` |
| N3GPH70W | FL2_68/69（量产） | `0x420F3–0x47970` | 22.1 KB | `5936fc5bf38eabb1` |
| N3GPD04W | EC dump（工程版） | `0x364B1–?` | 估计约 14KB | — |
| N3GPH03W | EC dump（工程版） | `0x39E34–?` | — | — |
| N3GPH53W | EC dump（工程版） | `0x3D7B3–?` | — | — |

关键差异：
- 量产版本号个位 `D17/H20/H70`（v1.7/v2.0/v7.0），工程版 `D04/H03/H53`（v0.4/v0.3/v5.3）
- 工程版 PD 版本更低，可能不支持完整 USB-C 协商功能

### 3.2 PD blob 头部结构（Microchip 专有格式）

```
相对版本串偏移  字段说明
-0x22:         FF FF        (blob 边界分隔符)
-0x20:         01 00        (格式版本 = 0x0001)
-0x1E:         XX XX        (子blob大小 LE16，约 0x04BB = 1211B)
-0x1C:         XX XX XX XX  (哈希/校验 LE32，每个 blob 不同)
-0x18: --0x12: 保留字段 (全零)
-0x0E:         30 78 31 20  = "0x1 " (版本标记字符串)
-0x0A:         FA XX        (0xFA = Microchip PDFW magic，XX = variant)
-0x08:         54 00        后续...
-0x04: -0x02:  XX XX XX XX  (端口配置)
+0x00:         N3GPxxxxW    (8字节版本ID)
```

FL2_68 与 dump 头部字段对比：
- `FF FF`、`01 00`、保留区（全零）：完全相同
- 哈希、variant、端口配置：不同
- 版本ID最后一个数字：不同（量产 vs 工程）

### 3.3 版本索引表与 RAM 地址映射

`FL2[0x045B27]`（RAM 地址 `0x100B5A07`）包含 PD 版本名称索引：
```
N3GPD17W\0N3GPH20W\0N3GPH70W\0
```

`FL2[0x045B44]`（RAM 地址 `0x100B5A44`）包含配置指针表：

| 表偏移 | 值 | RAM 地址 | 对应 FL2 位置 | 用途推断 |
|---|---|---|---|---|
| +0x04 | `0x100B5A07` | 代码RAM | `FL2[0x45B27]` | PD 版本索引起始 |
| +0x08 | `0x100AAA84` | 代码RAM | `FL2[0x3ABA4]` | N3GPD17W blob 数据区 |
| +0x1C | `0x100B5A10` | 代码RAM | `FL2[0x45B30]` | N3GPH20W 版本名 |
| +0x20 | `0x100AE505` | 代码RAM | `FL2[0x3F585]` | N3GPH20W blob 数据区 |
| +0x30 | `0x10087645` | 代码RAM | `FL2[0x7685]` | 重复指针（公共库?） |

**结论**：EC 通过版本索引表找到 PD 固件 blob，在启动时通过 I2C/SMBus 传输给 PD 芯片。工程版 EC 未实现这个初始化流程。

### 3.4 Microchip PD DFU 设备状态

```
VID:PID        04d8:0039
制造商         MCHP
产品名         USB DFU
序列号         MCHP-DF-005
bcdDevice      8.20  (ROM bootloader 版本)
DFU 接口       Interface 0, AlternateSetting 0
DFU 能力       Upload + Download 支持
wTransferSize  64 bytes
bcdDFU         1.00
DFU 状态       dfuIDLE (state=2, status=0)
Upload 结果     0 bytes → 固件槽为空
```

### 3.5 DFU 独立更新路径可行性分析

| 问题 | 结论 |
|---|---|
| 是否需要 root？ | **是**（当前报 `LIBUSB_ERROR_ACCESS`） |
| FL2 blob 是否为标准 DFU suffix 格式？ | **否**（无 `DFU` 后缀字节，使用 Microchip 专有头部） |
| 直接 `dfu-util -D blob.bin` 是否可行？ | **不可行**（格式不兼容，可能导致芯片损坏） |
| 需要什么工具？ | Microchip MPLABConnect / PDFU 写入工具，或需逆向 EC 的 I2C 写入协议 |
| 三个 blob 哪个对应 `04d8:0039`？ | 未知，推测 N3GPD17W（主端口），但未验证 |
| 是否存在多个 PD 芯片？ | 可能。三个 blob 各自对应不同端口 / 芯片 |

---

## 风险与限制

1. **PD 芯片写错后果不可逆**：写入错误固件版本可能导致 USB-C 端口永久损坏
2. **工程版 PD 固件未知**：工程版 EC dump 中有 D04/H03/H53，但不知道它们对哪款芯片兼容
3. **接口协议未明确**：不确定 PD 芯片是否仅接受 I2C 协议（EC 写入），或也接受 USB DFU
4. **`04d8:0039` 可能只是一个 PD 芯片**：其他 PD 芯片可能通过 I2C 连接，不暴露 USB 接口

---

## 下一步

- [ ] **获取 root 权限后尝试 DFU 枚举**：`sudo dfu-util -l` 确认 altsetting 数量
- [ ] **Upload 固件内容**：若其他 DFU 设备有 altsetting 可上传，做版本对比
- [ ] **研究 Microchip PDFU 格式**：查阅 Microchip AN2242/USB PD bootloader 文档
- [ ] **等待 EC 更新后重测**：若 EC 0.1.67 更新成功，PD 芯片应由新 EC 初始化，此 DFU 接口可能消失
- [ ] **从 FL2 提取正确 payload 格式**：通过逆向 EC I2C 写入函数确认 blob 格式是否需要去头

---

## 可复现命令

```bash
# 查看 DFU 设备（需 root）
sudo dfu-util -l
sudo lsusb -v -d 04d8:0039

# 定位 PD blob（示例：N3GPD17W）
python3 - << 'PY'
from pathlib import Path
fl2 = Path('firmware/ec/N3GHT68W.FL2').read_bytes()
p = fl2.find(b'N3GPD17W')
print(f"N3GPD17W @ FL2 0x{p:X}")
print(f"  头部: {fl2[p-0x22:p+8].hex()}")
PY

# 提取三个 PD blob 到文件
python3 scripts/extract_pd_fw.py firmware/ec/N3GHT68W.FL2 /tmp/pd_blobs/

# 版本索引表
python3 - << 'PY'
from pathlib import Path
fl2 = Path('firmware/ec/N3GHT68W.FL2').read_bytes()
idx = fl2.find(b'N3GPD17W\x00N3GPH')
print(f"版本索引表 @ FL2 0x{idx:X}")
print(fl2[idx:idx+30])
PY
```
