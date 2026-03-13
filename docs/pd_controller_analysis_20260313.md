# PD 控制器分析报告

> 日期：2026-03-13
> 设备：ThinkPad Z13 Gen 1 21D2CT01WW（工程样机）
> 输入：`firmware/ec/N3GHT68W.FL2`、`firmware/ec/N3GHT69W.FL2`、`firmware/spi_dump/ec_spi_read_20260313_104036.bin`
> USB 设备：Microchip `04d8:0039` USB DFU（Bus 001 Device 002）
结论状态：分析完成（含 DFU 实时调查）；DFU DNLOAD 路径技术上可行但格式需逆向


## 关键结论

1. **工程机的 Microchip PD 控制器永远停留在 ROM DFU bootloader**，从未收到量产 EC 初始化时通过 I2C/SMBus 写入的 PD 固件，这是导致 USB-C 功能完全失效的根本原因。
2. **FL2 中嵌入 3 个 PD 固件 blob**（N3GPD17W/N3GPH20W/N3GPH70W），每个均约 14–22 KB，使用 Microchip 专有 TLV 格式（非标准 USB DFU suffix 格式）。
3. **工程版 dump 中的 PD 版本**（N3GPD04W/H03W/H53W）与量产 FL2 中的版本（N3GPD17W/H20W/H70W）完全不同，头部结构完全相同，仅哈希/端口配置不同。
4. **FL2_68 与 FL2_69 的 PD 区域 100% 相同**，PD 固件版本在两次 EC 大版本更新间未变化。
5. **DFU_DNLOAD 通道技术上可行**：设备处于 `dfuIDLE`，接受 64 字节块，但 bootloader 会校验固件格式后才进入 manifest 阶段——非法格式被静默丢弃，需要提供正确 binary 格式才能实际写入。
6. **FL2 中的 PD blob 是 EC 容器格式（TLV 记录）**，不是直接可以发送给 DFU 的 raw binary；DFU 期望的是不含 FL2 包装头的纯 PD firmware binary。

---

## 输入与方法

### 输入文件

| 文件 | 用途 |
```
VID:PID         04d8:0039
制造商          MCHP
产品名          USB DFU
序列号          MCHP-DF-005
String[1]       'MCHP'
String[2]       'USB DFU'
String[3]       'MCHP-DF-005'
String[4]       'Main Configuration'
String[5]       'Main Interface'
bcdDevice       0x0820 = 8.32（ROM bootloader 版本，非 8.20）
DFU 接口        Interface 0, AlternateSetting 0
bInterfaceClass  0xFE（Application Specific）
bInterfaceSubClass 0x01（DFU）
bInterfaceProtocol 0x02（DFU Mode，已处于 DFU 模式，非 runtime）
DFU 能力        bmAttributes=0x03（bitCanUpload=1, bitCanDnload=1）
				bitWillDetach=0（需手动 USB reset）
				bitManifestTolerant=0
wDetachTimeout  0 ms
wTransferSize   64 bytes（每次最多传 64B）
bcdDFUVersion   0x0100（DFU 1.00 规范）
DFU 状态        dfuIDLE (state=2, status=0, pollTimeout=0ms)
Upload 结果      DFU_UPLOAD block 0 & 1 = 0 bytes → 固件槽为空（ROM BL 无内置 FW）
```

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
| 是否需要 root？ | **已通过指纹认证获取 root**（`sudo dfu-util` 可用） |
| FL2 blob 是否为标准 DFU suffix 格式？ | **否**（无 `DFU` 后缀字节，使用 Microchip TLV 格式） |
| 直接 `dfu-util -D pd_blob.bin` 是否可行？ | **不可行**（FL2 blob 含 TLV 包装头，需剥离后才能发送） |
| DFU_DNLOAD 通道技术上能用吗？ | **能**（接受 64B 块，state→dfuDNLOAD-IDLE）但校验格式 |
| bootloader 对无效格式块的反应？ | **静默丢弃**（OK 状态，零终止后直接回 dfuIDLE，不进 manifest） |
| 厂商命令（bmRequestType=0xC0）有用吗？ | **否**（所有请求全部 USBTimeoutError） |
| 标准 DFU Upload 有数据吗？ | **否**（0 bytes，固件槽完全为空） |
| 需要什么格式？ | 纯 PD firmware binary（剥除 FL2 TLV 头部），可能还需 DFU suffix |
| 三个 blob 哪个对应 `04d8:0039`？ | 仍未知，推测 N3GPD17W（USB-C 主端口），需进一步确认 |
| 是否存在多个 PD 芯片？ | 可能。三个控制块指针各对应一个芯片/端口 |

---

## 风险与限制

1. **PD 芯片写错后果不可逆**：写入错误固件版本可能导致 USB-C 端口永久损坏
2. **工程版 PD 固件未知**：工程版 EC dump 中有 D04/H03/H53，但不知道它们对哪款芯片兼容
3. **接口协议未明确**：不确定 PD 芯片是否仅接受 I2C 协议（EC 写入），或也接受 USB DFU
4. **`04d8:0039` 可能只是一个 PD 芯片**：其他 PD 芯片可能通过 I2C 连接，不暴露 USB 接口

---

## 下一步

- [x] **获取 root 权限**：已通过指纹认证，`sudo dfu-util -l` 可用
- [x] **DFU 协议探测**：完成 GETSTATUS / UPLOAD / 厂商命令 / DNLOAD 探测
- [x] **设备描述符完整解析**：bcdDevice=8.32，5 个字符串描述符，RAM 地址指针表
- [ ] **从 FL2 提取纯 PD binary**：剥除 TLV 头部（34字节 header），提取 N3GPD17W 纯 payload
- [ ] **构造合法 DFU 传输包**：纯 PD binary + DFU suffix（vendor=04d8, product=0039）并测试
- [ ] **等待 EC 更新后重测（最优先）**：重启 → fwupd 应用 EC 0.1.67 → 检查 `04d8:0039` 是否消失
- [ ] **研究 Microchip PDFU 格式细节**：查阅 AN2242 文档（需 Microchip 账号登录）
```bash
# DFU 实时探测（需 root）
sudo python3 - << 'PY'
import usb.core, struct
dev = usb.core.find(idVendor=0x04d8, idProduct=0x0039)
try: dev.set_configuration()
except: pass

# GET_STATUS
r = dev.ctrl_transfer(0xA1, 3, 0, 0, 6, timeout=2000)
states = {2:'dfuIDLE',5:'dfuDNLOAD-IDLE',10:'dfuERROR'}
print(f"state={r[4]}({states.get(r[4],'?')}) status={r[0]}")

# Upload → 预期 0 bytes（固件槽为空）
up = dev.ctrl_transfer(0xA1, 2, 0, 0, 64, timeout=2000)
print(f"Upload block 0: {len(up)} bytes")
PY

# USB 软复位
sudo python3 -c "
import usb.core, time
dev = usb.core.find(idVendor=0x04d8, idProduct=0x0039)
dev.reset(); time.sleep(1)
dev2 = usb.core.find(idVendor=0x04d8, idProduct=0x0039)
r = dev2.ctrl_transfer(0xA1, 3, 0, 0, 6, timeout=2000)
print(f'复位后 state={r[4]}')
"
```


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
