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
