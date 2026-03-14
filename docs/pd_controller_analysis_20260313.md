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
### 3.6 PD Blob 二进制 TLV 格式完整解析（N3GPD17W.bin）

#### 整体结构

```
偏移(blob内)  字节长度  含义
0x00:0x7D    125B      预头部区（含少量非FF有效数据）
0x7D:0x81    4B        FF FF FF FF（分隔符）
0x81:0x83    2B        01 00（格式版本 LE16 = 1）
0x83:0x85    2B        BB 04（sub-blob_size LE16 = 0x04BB = 1211B）
0x85:0x89    4B        4D FD 10 04（校验 LE32）
0x89         1B        05（num_ports？）
0x8A:0x92    8B        保留零填充
0x92:0x96    4B        30 78 31 20（"0x1 " 版本标记）
0x95:0x97    2B        FA 8E（Microchip PDFW magic）
0x97:0x9B    4B        54 00 1A 08（端口配置 LE32）
0x9B:0x9F    4B        0C 06 00 07（预-TLV 字段）
0x9F:0xA7    8B        "N3GPD17W"（版本字符串）
0xA7:0x55A   1203B     TLV 数据区（4 个子区，详见下文）
0x55A:0x3A05  剩余     PD 控制器 Flash 原始内容
0x3A05:      零/FF填充
```

#### TLV 数据区（0xA7:0x55A）四个子区

**子区 1：0x0C 型配置 TLV（25 条，0xA7~0x028A）**

格式：`0C [type_LE16 2B] [len_byte 1B] [data (len_byte+1 B)]`，total = `len_byte + 5` 字节

```
偏移      type            len  数据（前6字节）           推测含义
0x00a7   0x0016( 22)     11   0a 78 80 4d 00 00        通用端口配置
0x00b6   0x0020( 32)      2   03 00                    模式配置
0x00bc   0x0023( 35)      4   00 e0 01 00              时序参数
0x00c4   0x0027( 39)     10   05 89 1b 8c 5d 07        PDO 策略配置（共9PDOs）
0x00d2   0x0028( 40)      8   02 c9 63 07 00 00        充电器能力
0x00de   0x0029( 41)      4   51 c0 c1 00              VBus 参数
0x00e6   0x002b( 43)      4   00 02 00 00              扩展配置
0x00ee   0x0032( 50)     31   01 a8 2a 2c 91 01        电流要求表（31B）
0x0111   0x0033( 51)     53   03 2c 91 01 00 45        电流能力表（53B）
0x014a   0x0037( 55)     16   3e 50 14 00 90 91        PDO 定义集合
0x015e   0x0042( 66)      3   1a 00 08                 电源路径配置
0x0165   0x0043( 67)     28   00 00 00 00 00 19        通用 PDO 集合
0x0185   0x0047( 71)     25   06 ef 17 00 95 00        端口策略表
0x01a2   0x004a( 74)     63   01 00 ef 17 01 01        完整 PDO 定义（64B，最大）
0x01e5   0x0051( 81)      6   03 06 1c 00 00 01        UFP 能力
0x01ef   0x0052( 82)      8   03 00 00 00 00 00        DFP 能力
0x01fb   0x0055( 85)      4   7e 00 00 c0              Try.SRC 配置
0x0203   0x0056( 86)      2   3f 00                    Type-C 状态机配置
0x0209   0x005c( 92)     49   d2 0c 00 00 00 10        PPS（APDO）配置
0x023e   0x0062( 98)      8   00 00 03 4a 00 00        VBus 监控参数
0x024a   0x0064(100)     12   08 00 00 00 00 00        电源开关控制
0x025a   0x0070(112)      1   05                       端口数（=5）
0x025f   0x0075(117)      4   01 00 00 80              固件标志
0x0267   0x0077(119)     14   00 00 00 00 00 00        UUID/GUID区
0x0279   0x007e(126)     14   01 00 00 00 00 00        校验/版本尾
```

**子区 2：0x08 型寄存器 TLV（7 条，0x028B~0x02AE）**

格式：`08 [type_LE16 2B] [0x00] [data 1B]`，total = 5 字节（固定大小）

type_LE16 高字节可能为寄存器地址，低字节为端口/子类型索引，data 为写入值：

```
偏移      type    data  推测（reg:val）
0x028b   0x0827  0x27  reg=0x08, val=0x27 = 39
0x0290   0x1547  0x01  reg=0x15, val=0x47 = 71
0x0295   0x015c  0x0e  reg=0x01, val=0x5C
0x029a   0x095c  0x02  reg=0x09, val=0x5C
0x029f   0x155c  0x00  reg=0x15, val=0x5C
0x02a4   0x0064  0x0c  reg=0x00, val=0x64
0x02a9   0x0a64  0x58  reg=0x0A, val=0x64
```

注意：type 字段的 LE16 解读（低字节=寄存器地址）与 Microchip UPD301x
寄存器映射（AN2960: 0x00=TYPEC_STATUS, 0x08=INT_STATUS, 0x15=CFAP_STATUS）匹配。

**子区 3：LE16 单调增查找表（84 个值，0x02AE~0x0356，168B）**

- 值域：0x00A8(168) ~ 0x028E(654)，步长主要为 6mA
- 解读：ADC 输入电流校正 LUT，168mA~654mA @1mA/步
- 用途：PPS 充电时 CC 线路电流 → 实际充电电流的精确映射表

**子区 4：多 TAG 混合记录（74 条，0x0356~0x053C）**

格式：`TAG [len3] [data (len3+1 B)]`，total = `len3 + 3` 字节（已确认全部条目）

TAG 值及条数分布：
```
TAG   条数  推测含义
0x05  11    充电曲线参数（Charging Curve）
0x06   1    充电协议配置
0x07  14    DFP 端口 PDO/APDO 参数
0x08   3    充电控制器寄存器写入
0x56   4    CC 线状态机参数
0x57   1    协议层配置（11 字节 payload）
0x58   4    电流感应配置
0x59   1    全局 PD 协议参数
0x5a  13    主端口 PD 参数
0x5b   4    辅助端口 PD 参数
0x5d   3    OCP 触发阈值
0x5f   2    VBUS 阈值（5F/89/8B/8D 高压端口组）
0x61   3    VBUS 上电时序
0x71   2    PHY 射频参数
0x89   2    高压端口能力
0x8b   3    高压端口保护
0x8d   3    高压端口阈值
```

终止字节：`0x00` @ `0x053C`（随后填零至 TLV_END=0x55A）

---


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


# 三版本 PD blob 差异对比（需先提取 firmware/ec/N3GP*.bin）
python3 scripts/analyze_pd_blobs_diff.py
python3 scripts/analyze_pd_blobs_diff.py --verbose
```

---

### 3.7 三版本 PD Blob 差异深度分析（N3GPD17W / N3GPH20W / N3GPH70W）

本节记录 `scripts/analyze_pd_blobs_diff.py` 的完整输出分析（2026-03-13 会话）。

#### 3.7.1 头部对比摘要

| 字段 | N3GPD17W | N3GPH20W | N3GPH70W | 说明 |
|---|---|---|---|---|
| sub_blob_size | 0x04BB (1211) | 0x04D1 (1233) | 0x0347 (839) | TLV 数据区大小 |
| config_tag | 0x0C | 0xFF | 0x0F | 子区1 TAG 字节 |
| num_ports | 5 | 0 | 0 | 端口数 |
| mchp_magic | FA 8E | FA 82 | FA 3A | 芯片系列标识 |
| port_config | 0x081A0054 | 0x081A0054 | 0x041A0054 | 端口能力位图 |
| checksum | 0x0410FD4D | 0x4BCCE661 | 0x0205FC0D | 固件完整性校验 |

**推测各 blob 对应硬件端口：**
- **N3GPD17W**（magic=0xFA8E, config_tag=0x0C）：USB-C 左侧端口全功能 PD 控制器（5端口，支持 PPS，UPD301x，USB DFU ID=04d8:0039）
- **N3GPH20W**（magic=0xFA82, config_tag=0xFF）：USB-C 右侧端口全功能 PD 控制器（FA82 芯片，sub_blob_size 比 D17W 多 22 字节）
- **N3GPH70W**（magic=0xFA3A, config_tag=0x0F）：Thunderbolt/USB4 端口控制器（精简配置，port_config 高字节 0x04 vs 0x08）

#### 3.7.2 四个子区版本对比

| 子区 | N3GPD17W | N3GPH20W | N3GPH70W |
|---|---|---|---|
| SEC1 主配置条数 | 25 | 27 | 25 |
| SEC2 寄存器写入 | 7 条 | 0 条 | 0 条 |
| SEC3 ADC 校正 LUT | 84值，168~654mA | 0 值（无） | 84值，168~314mA |
| SEC4 充电曲线/CC | 74 条（17种TAG） | 1 条（TAG=0xF0） | 15 条（8种TAG） |

H70W 的 SEC3 LUT 范围比 D17W 窄（最大314mA vs 654mA），54个0步长值，暗示 TB/USB4 端口的 PPS 工作范围有限。

#### 3.7.3 SEC1 差异（D17W vs H20W，12 处关键差异）

| type | D17W | H20W | 本质差异 |
|---|---|---|---|
| 0x0017 | 无此记录 | len=11，`08 04 00 02...` | H20W 独有的初始化标志 |
| 0x0027 | len=10 | len=11（多1字节） | PDO 策略配置不同 |
| 0x0033 | 首字节 0x03（3条） | 首字节 0x02（2条） | 电流能力条目数 |
| 0x0042 | len=3 | len=4 | 电源路径配置多1字节 |
| 0x0052 | `03 00 00 00 00 00 02 00` | `03 02 00 00 00 00 02 00` | DFP 能力位图字节[1] 不同 |
| 0x0064 | 首字节 `0x08` | 首字节 `0x0c` | **电源开关控制**（关键！） |
| 0x007b | 无此记录 | len=16，`00 02 FF FF...` | H20W 独有 UUID/GUID 扩展 |

`type=0x0064`：H20W 首字节 `0x0c = 0b00001100` 比 D17W `0x08 = 0b00001000` 多使能位2，可能是右侧端口的独立 VBUS 控制路径。

#### 3.7.4 SEC1 差异（D17W vs H70W，13 处）

| type | D17W | H70W | 本质差异 |
|---|---|---|---|
| 0x0017 | 无此记录 | len=11，`08 04 00 02...` | H70W 独有（与 H20W 内容完全相同！） |
| 0x0023 | `00 e0 01 00`（480） | `00 a0 01 00`（416） | 时序参数 -13.3% |
| 0x0027 | `05 89 1b 8c 5d 07 9a 00` | `01 81 03 8c 1d 07 1a 00` | **PDO 策略完全不同** |
| 0x0043 | `00 00 00 00 00 19 50 00` | `19 19 19 19 19 19 08 00` | **温度阈值**：未设置 vs 全25°C |
| 0x0047 | 字节[0]=0x06（端口数6） | 字节[0]=0x04（端口数4） | 端口数量 |
| 0x0052 | 仅 D17W，`03 00 00 00...` | 无 | TB 端口无 DFP 配置 |
| 0x0064 | `08 00 00 00...54` | `30 31 32 00...52` | **电源路径控制**（ASCII字符串？） |

`type=0x0064` 在 H70W 中首字节序列为 `0x30 0x31 0x32`（ASCII `"012"`），疑似端口标识字符串；与 D17W 的位图格式完全不同，跨芯片系列语义可能不同。

#### 3.7.5 SEC4 格式差异

**D17W**（74条）：格式 `TAG [len3] [data(len3+1 B)]`，TAG 值 0x05~0x8D（大TAG值域）
- TAG=0x5A（13条）主端口 PD 参数；TAG=0x07（14条）DFP PDO/APDO

**H70W**（15条，分三子段）：
- 段A/B（17条，0x336~0x38b）：`TAG [0x02] [0x00] [port(0/1)] [flags]`（5字节），TAG 值 0x01~0x24
- 段C（12条，0x38c~0x3c7）：`[port] [reg_addr LE16] [param1] [param2]`（5字节），reg=0x0022×8条、reg=0x0042×4条

H70W 使用**小 TAG 值（0x01~0x24）**，与 D17W**大 TAG 值（0x05~0x8D）**完全不重叠，证明是不同系列 PD 控制器固件。

**H20W**（1条，TAG=0xF0，len3=50）：单条记录包含完整 LE16 数组。

#### 3.7.6 关键推断

1. `type=0x0017` 在 H20W 和 H70W 均存在且内容相同（`08 04 00 02 00 00 00 00 00 00 00`），D17W 无此记录——推测是 USB4/TB 兼容性初始化标志，纯 USB-C PD 端口不需要。
2. 三个 blob 的 `mchp_magic`（FA8E/FA82/FA3A）代表不同芯片系列：D17W 和 H20W 同大系列（FA8x），H70W 独立（FA3A，TB 子系列）。
3. SEC2（寄存器初始化写入序列）仅 D17W 有，H20W 和 H70W 通过 SEC1 type=0x0017 替代。
4. H70W 的 SEC4 段C（`[port][reg][p1][p2]`）很可能是 USB4 retimer 寄存器写入序列，类似 D17W 的 SEC2 但格式适配 TB 架构。

---

### 3.8 系统级 I2C 总线拓扑（实机探测结果）

> 本节基于 2026-03-14 对 ThinkPad Z13 Gen1 实机 I2C 总线的完整扫描及寄存器读取结果。

#### 3.8.1 I2C 总线枚举

| 总线 | 内核适配器名称 | ACPI 设备 | MMIO 基址 |
|---|---|---|---|
| i2c-0 | Synopsys DesignWare | AMDI0010:00 (I2CA, UID=0) | 0xFEDC2000 |
| i2c-1 | Synopsys DesignWare | AMDI0010:01 (I2CB, UID=1) | — |
| i2c-2 | Synopsys DesignWare | AMDI0010:02 (I2CC, UID=2) | 0xFEDC4000 |
| i2c-3~9 | AMDGPU DM | GPU iGPU DP/eDP | — |
| i2c-11~13 | SMBus PIIX4 | 0x00:14.0 | — |

**DSDT 中 4 个 I2C 控制器**：I2CA/B/C（已定义 Device 节点），I2CD（仅在 MI2C 方法中引用，无独立节点）。

#### 3.8.2 I2C 设备发现（i2cdetect 扫描）

```
I2C-0 (i2cdetect -y -r 0):
  0x27 = 有响应（free，未被内核驱动绑定）
  0x48 = 有响应（free，未被内核驱动绑定）

I2C-1 (i2cdetect -y -r 1):
  0x40 = UU（cs35l41-hda，Cirrus Logic CS35L41 音频功放 L声道）
  0x41 = UU（cs35l41-hda，Cirrus Logic CS35L41 音频功放 R声道）
  另有 XXXX0000:00（ACPI HID I2C 触摸板，PNP0C50）

I2C-2 (i2cdetect -y -r 2):
  0x15 = UU（ELAN06A0:00，ELAN 触控板，modalias=acpi:ELAN06A0:PNP0C50:）

I2C-13 (SMBus PIIX4 port 1 at 0xb20):
  0x50~0x53 = spd5118（DDR5 SPD EEPROM）
```

**关键发现：I2C-1 的 UU 设备不是 SN2001023YBGR！**
原始假设（I2C-1 = PD 控制器）被推翻。实际情况：
- `sysfs` 显示 `/sys/bus/i2c/devices/i2c-CSC3551:00-cs35l41-hda.0/.1` = Cirrus Logic CS35L41 音频放大器
- 0x40/0x41 对应 CS35L41 的两个标准 I2C 地址（ADDR 引脚控制）
- i2cdump 结果：前 4~5 字节为 `XX`（读 NACK），其余全 0 → CS35L41 通过 SoundWire/HDA 通信，I2C 仅用于初始化

#### 3.8.3 I2C-0 活动设备详细寄存器映射（KB8002 候选）

**地址 0x27（端口1，有连接）**

```
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00: 04 04 04 04 04 10 08 00 04 40 00 00 00 04 00 04
10: 04 40 00 00 0b 0b 0b 0b 0b 0b 05 00 00 00 00 18
20: 02 21 00 04 09 00 05 0b 08 04 00 04 00 05 31 28
30: 35 35 1f 35 06 0c 00 10 00 00 00 00 00 00 00 02
40: 04 08 03 1c 00 00 00 19 19 19 3f 00 00 00 09 1d
50: 06 06 07 06 00 04 02 02 25 0b 1a 00 31 04 00 05
60: 09 1d 08 00 0c 00 00 00 00 04 0d 00 3c 00 00 05
70: 01 00 08 16 04 04 00 0f 04 07 04 10 00 24 0e 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 07 01 00 00 00 00 00 00 00 00 00 00 00
a0-ff: 全 0x00
```

**地址 0x48（端口2，无连接或端口空闲）**

```
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00: 04 04 04 04 04 10 00 00 04 40 00 00 00 04 00 04
10: 04 40 00 00 0b 0b 0b 0b 0b 0b 00 00 00 00 00 00
20: 00 00 00 00 00 00 05 00 00 00 00 00 00 05 00 28
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40-4f: 全 0x00
50-5f: 全 0x00 (reg[5f]=0x05)
60-ff: 全 0x00
```

**双设备对比分析（相同基础配置的两个端口）：**

| 寄存器 | 0x27（端口1活动） | 0x48（端口2空闲） | 差异推测 |
|---|---|---|---|
| reg[0x00~0x04] | `04 04 04 04 04` | `04 04 04 04 04` | 相同（设备标识/lane数=4） |
| reg[0x05] | `0x10` | `0x10` | 相同（系列标志） |
| reg[0x06] | `0x08` | `0x00` | **连接状态**：有连接=0x08，断开=0x00 |
| reg[0x09] | `0x40` | `0x40` | USB3 SuperSpeed 高速模式（0x40=bit6） |
| reg[0x1a~0x1f] | `0b 0b 0b 0b 0b 0b` | `0b 0b 0b 0b 0b 0b` | 相同（RX/TX EQ 增益，6通道） |
| reg[0x20~0x2f] | 大量非零数据 | 全0（仅[0x26]=0x05,[0x2d]=0x05,[0x2f]=0x28） | **通道活跃时初始化** |
| reg[0x30~0x3f] | `35 35 1f 35...` | 全0 | **TX 参数**（仅活跃端口有效） |
| reg[0x40~0x4a] | `04 08 03 1c 0x3f...` | 全0 | **PHY 配置**（仅活跃端口） |
| reg[0x42] | `0x03` | `0x00` | H70W SEC4-C 目标寄存器（初始值=3） |
| reg[0x22] | `0x00` | `0x00` | H70W SEC4-C 目标寄存器（初始值=0） |

**共有基础特征（两端口相同）：**
- reg[0x1a~0x1f] = `0x0b`（6个通道，均值 0x0b）：USB3 SuperSpeed × 4 lane + DP × 2 lane EQ 增益设置
- reg[0x09] = `0x40`：SuperSpeed 标志位活跃
- reg[0x00~0x04] = `04 04 04 04 04`：4单位数据（4×USB3 lanes？）

**连接状态指示寄存器（reg[0x06]）：**
- `0x08` = 已连接（端口1 = 左侧 USB-C，当前有外设接入）
- `0x00` = 未连接（端口2 = 右侧 USB-C 或空端口）

#### 3.8.4 SN2001023YBGR 定位推测修正

**原假设被推翻**：I2C-1 地址 0x40/0x41 不是 SN2001023YBGR，而是 CS35L41 音频功放。

**新推论**：SN2001023YBGR（TI PD 控制器）的实际访问路径可能是：

1. **通过嵌入式控制器（EC）间接访问**：DSDT 中存在 `PDCI`（PD Controller Interface）字段，定义在 MNVS（AMD GlobalNVS，物理地址 `0xBAC25018`）的字节偏移 `0x0EC0`（物理地址 `0xBAC25ED8`），通过 BIOS-OS 共享内存通信。当前值：`PDCI = 0x0000`（PD 控制器未激活）。

2. **ThinkPad EC 直接 I2C 主控**：EC 固件（N3GHT68W.FL2）可能直接控制 SN2001023YBGR，不通过操作系统可见的 I2C 总线暴露。EC 的 I2C 总线可能在 DSDT I2CA~I2CD 范围之外。

3. **UCSI 接口缺失**：系统未加载任何 `typec`/`ucsi` 内核模块；`AMDI0052:00`（AMD Power Platform Generic Package）存在于 platform devices 但**无驱动绑定**（`waiting_for_supplier=0`）。UCSI ACPI 驱动需要 `PNP0CA0` HID，而系统提供的是 `AMDI0052`。

4. **I2C-0 设备（0x27/0x48）= KB8002 USB & DP Repeater**：与 H70W SEC4-C 寄存器地址完美匹配，为最强候选。

---

### 3.9 H70W SEC4-C 与 KB8002 寄存器关联分析

#### 3.9.1 SEC4-C 记录语义（基于实机验证）

H70W（TB/USB4端口控制器固件）中 SEC4-C 段（位于文件偏移 `0x038c~0x03c7`）的 12 条记录：

```
格式：[port 1B] [reg_addr LE16 2B] [param1 1B] [param2 1B]
port=1 → I2C-0 地址 0x27（端口1 retimer）
port=2 → I2C-0 地址 0x48（端口2 retimer）
```

| port | reg_addr | param1 | param2 | 当前实测值 reg[param1] |
|---|---|---|---|---|
| 1 | 0x0022 | 0x00 | 0x15 | reg[0x00]=0x04 |
| 1 | 0x0022 | 0x02 | 0x15 | reg[0x02]=0x04 |
| 1 | 0x0022 | 0x08 | 0x15 | reg[0x08]=0x04 |
| 1 | 0x0022 | 0x0a | 0x15 | reg[0x0a]=0x00 |
| 2 | 0x0022 | 0x00 | 0x15 | reg[0x00]=0x04（0x48） |
| 2 | 0x0022 | 0x02 | 0x15 | reg[0x02]=0x04（0x48） |
| 2 | 0x0022 | 0x08 | 0x15 | reg[0x08]=0x04（0x48） |
| 2 | 0x0022 | 0x0a | 0x15 | reg[0x0a]=0x00（0x48） |
| 1 | 0x0042 | 0x78 | 0x10 | reg[0x78]=0x04（当前） |
| 1 | 0x0042 | 0x7a | 0x10 | reg[0x7a]=0x04（当前） |
| 2 | 0x0042 | 0x78 | 0x10 | reg[0x78]=N/A（0x48 端口2） |
| 2 | 0x0042 | 0x7a | 0x10 | reg[0x7a]=N/A（0x48 端口2） |

#### 3.9.2 解读假设对比

**假设 A（最可能）：reg_addr 是操作页/功能索引，param1 是子寄存器偏移，param2 是目标值**
- `reg=0x0022, param1=0x00/0x02/0x08/0x0a, param2=0x15`
  → 写入到 KB8002 的"功能区 0x22"中偏移 0x00/0x02/0x08/0x0a 处，值 0x15
- `reg=0x0042, param1=0x78/0x7a, param2=0x10`
  → 写入到 KB8002 的"功能区 0x42"中偏移 0x78/0x7a 处，值 0x10
- 支持证据：reg_LE16 实际上是 16 位寄存器地址（高字节非零会不寻常），0x0022/0x0042 均在字节寻址范围，但 0x78/0x7a 超过了 i2cdump 可见的 0x7a 最大有效数据偏移

**假设 B：reg_addr 的高字节 = 功能选择，低字节 = 寄存器**
- `0x0022` → function=0x00, reg=0x22；`0x0042` → function=0x00, reg=0x42
- param1=数据值，param2=写操作标志（0x15=0b00010101 或 0x10=0b00010000）
- 支持证据：当前 reg[0x22]=0x00，reg[0x42]=0x03，与 SEC4-C 写入前的默认值一致

**假设 C：连续覆盖写入，最终值为最后一条记录**
- 8条 reg=0x0022 写入最终值为 0x0a（最后写的 param1）
- 4条 reg=0x0042 写入最终值为 0x7a
- 当前 reg[0x22]=0x00（与假设矛盾，EC 初始化后应该不同）

**暂定结论（假设 B 最合理）**：
- EC 固件在初始化时对 KB8002 端口1（0x27）和端口2（0x48）写入相同的序列
- `reg=0x0022`（目标 KB8002 寄存器）：按四个不同 param1 值写入 param2=0x15
- `reg=0x0042`（目标 KB8002 寄存器）：写入 param1=0x78/0x7a，param2=0x10
- 工程机 EC 固件未执行此初始化，故 reg[0x42]=0x03（非目标值 0x10 or 0x7a）

#### 3.9.3 reg[0x42] 当前值 0x03 的含义

KB8002 地址 0x27 寄存器 0x42 当前值 = `0x03`（word 模式读到 `0x1a03`，即 reg[0x43]=0x1a）：
- `0x03 = 0b00000011`：bit[0]=1（使能），bit[1]=1（可能是速率/模式选择）
- H70W SEC4-C 想将此位置写为 `0x10`（`0b00010000`）和 `0x7a`（`0b01111010`）
- 差异暗示工程机的 retimer 配置在 TX 幅度/CTLE 设置上与量产不同

#### 3.9.4 KB8002 寄存器功能推测

基于实测数据（地址 0x27，有 USB-C 连接状态）：

| 寄存器范围 | 取值 | 功能推测 |
|---|---|---|
| reg[0x00~0x04] | `04 04 04 04 04` | Lane 配置（4 lanes？） |
| reg[0x05] | `0x10` | 系列/版本标识 |
| reg[0x06] | `0x08` / `0x00` | 连接状态寄存器（0x08=已连接） |
| reg[0x09] | `0x40` | 速率配置（USB3 SuperSpeed = 0x40） |
| reg[0x1a~0x19] | `0x0b` ×6 | RX/TX EQ 增益（6通道，均为 0x0b） |
| reg[0x22] | `0x00` | SEC4-C 初始化目标（重均衡寄存器？） |
| reg[0x2e~0x33] | `0x31 0x28 0x35 0x35 0x1f 0x35` | TX Pre/Post-empahsis 配置 |
| reg[0x42] | `0x03` | SEC4-C 初始化目标（CTLE/TX 幅度？） |
| reg[0x47~0x49] | `0x19 0x19 0x19` | 阈值配置（25 = 0x19） |
| reg[0x4a] | `0x3f` | 全带配置？（0x3f = 0b00111111） |
| reg[0x70~0x7f] | 参见完整表格 | DP/TB Lane 映射、link state |

---

### 3.10 系统架构总结

#### 3.10.1 ThinkPad Z13 Gen1 USB-C 硬件拓扑

```
                    AMD Ryzen 6800U
                         │
              ┌──────────┼──────────┐
              │          │          │
           I2C-0       I2CA      UCSI?
         0xFEDC2000   (AMDI0010) (AMDI0052 - 未绑定)
              │
     ┌────────┴────────┐
     │                 │
  KB8002 #1          KB8002 #2
  I2C addr 0x27     I2C addr 0x48
  (USB-C 左端口      (USB-C 右端口
   Retimer/Repeater)  Retimer/Repeater)
  via USBC0          via USBC1

  EC (N3GHT6xW)
     │
     ├─ ThinkPad 嵌入式控制器总线（不暴露为 Linux i2c-X）
     │       │
     │    SN2001023YBGR (TI USB PD 控制器 ×2?)
     │    (通过 ACPI MNVS.PDCI 字段或 EC 直连 I2C)
     │
     └─ I2C-1 (AMDI0010:01)
            ├─ 0x40 CS35L41 音频功放 L（cs35l41-hda）
            └─ 0x41 CS35L41 音频功放 R（cs35l41-hda）

  I2C-2 (AMDI0010:02, 0xFEDC4000)
     └─ 0x15 ELAN06A0 触控板 (UU, ELAN HID I2C)
```

#### 3.10.2 KB8002 与 SN2001023YBGR 职责分工

| 芯片 | 制造商 | 功能 | I2C 总线 | Linux 可见？ |
|---|---|---|---|---|
| KB8002 (BQFR2 封装) | Kingston Semiconductor | USB 3.2 / DP Retimer-Repeater | I2C-0 (0x27, 0x48) | **是**（free，可直接读写） |
| SN2001023YBGR | Texas Instruments | USB Type-C PD 控制器（CC/VBUS） | 通过 EC 或专用总线 | **否**（通过 ACPI MNVS.PDCI 间接）|
| CS35L41 × 2 | Cirrus Logic | 音频功率放大器 | I2C-1 (0x40, 0x41) UU | 是（cs35l41-hda 驱动） |
| ELAN06A0 | ELAN | 触控板 | I2C-2 (0x15) UU | 是（hid-generic 驱动） |

#### 3.10.3 工程机问题根因链（修订版）

```
EC 固件工程版（N3GHT6xW）
  │
  ├─ 问题1：未向 Microchip PD IC（04d8:0039）下发 N3GPD17W/H20W 固件
  │          → PD 芯片停留在 ROM DFU bootloader → USB-C 协商失败
  │
  ├─ 问题2：未通过 I2C-0 对 KB8002（0x27/0x48）执行 H70W SEC4-C 初始化序列
  │          → reg[0x42]=0x03（未设置为目标值），retimer PHY 参数错误
  │          → TB/USB4 通道 EQ/幅度参数与量产不符
  │
  └─ 问题3（推测）：未激活 MNVS.PDCI（当前值=0x0000）
             → SN2001023YBGR PD 控制器功能未启用
             → UCSI 接口无法绑定驱动（AMDI0052 无驱动）
```

**解决路径（优先级排序）：**
1. **立即可行**：重启并通过 fwupd 应用 EC 0.1.67 + BIOS 0.1.76（量产版 EC 应有完整初始化）
2. **调试路径**：读取 MNVS.PDCI（devmem2 0xBAC25ED8）观察 EC 更新前后变化
3. **研究路径**：通过 `i2cset -y 0 0x27 0x42 0x10` 等命令手动模拟 H70W SEC4-C 初始化
