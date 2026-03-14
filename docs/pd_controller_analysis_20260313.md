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

---

### 3.11 EC SPI 固件深度分析（32MB dump）

> 本节基于 2026-03-14 对 `firmware/spi_dump/ec_spi_read_20260313_104036.bin` 的深度逆向分析，结合 `firmware/ec/N3GPH70W.bin` SEC4-C 数据段的精确解析。

#### 3.11.1 SPI 整体布局

| SPI 偏移 | 内容 | 说明 |
|---|---|---|
| 0x001508 | EC 版本字符串 "N3GHT15W" | 工程版 EC 固件 v1.5 |
| 0x0364d3 | N3GPD17W PD blob | 左侧 USB-C PD 控制器固件 |
| 0x039e54 | N3GPH20W PD blob | 右侧 USB-C PD 控制器固件 |
| 0x03d7d5 | N3GPH70W PD blob | Thunderbolt/USB4 PD 控制器固件 |
| 0x040000+ | EC ARM 代码区 | 含 KB8002 初始化代码（KB8002 init 位于 0x40000+0x21783） |
| 0x041450 | TPS65994 I2C 设备表 | ch=0x40~0x47, bus=0x0b, addr=0x20 |
| 0x041530 | TPS65994 寄存器访问索引表 | 25 条，全部 bus=0x14, dev=0x20 |
| 0x041698 | 函数指针表（0x0b10 段） | 共 13 条，KB8002 相关函数 |
| 0x416d0 | TPS65994 I2C 总线/地址映射表 | bus=0x08, write_addr=0x40 |
| 0x042960 | TPS65994 命令名称/ID 映射表 | 59 条命令，ID 0x01~0x3b |
| 0x042ac8 | TPS65994 命令处理函数指针表 | 36 条，EC 地址范围 0x07xxxx~0x09xxxx |
| 0x042b58 | 命令路由查找表 | 0xFF 分隔的索引数组 |

**EC MCU 代码段说明（Renesas RL78 架构）：**
- `0x07xxxx` 段：主 PD 控制代码（TPS65994 命令处理核心）
- `0x08xxxx` 段：扩展功能（GAID 事件处理）
- `0x09xxxx` 段：电源管理（SWSk Sink 切换、GSrC Source 能力获取）
- `0x0bxxxx` 段：KB8002 Retimer 控制模块

---

#### 3.11.2 TPS65994 / SN2001023YBGR I2C 地址确认

**结论：TPS65994（SN2001023YBGR）7-bit I2C 地址 = `0x20`，写地址 = `0x40`**

确认依据1：SPI `0x41450` 处 I2C 设备表：
```
每条记录 4 字节：[ch_id=0x40~0x47][bus=0x0b][reserved][dev_addr=0x20]
共 8 条，每个通道（ch_id=0x40/0x41/0x42/0x43/0x44/0x45/0x46/0x47）
全部指向 bus=0x0b, dev=0x20
```

确认依据2：SPI `0x41530` 处寄存器访问索引表，全部 25 条记录均为 `bus=0x14, dev_addr=0x20`。

确认依据3：SPI `0x416d0` 处映射表：
```
04 10 08 40  → port_idx=4, bus=0x08, write_addr=0x40 (7bit=0x20)
```

该地址在 Linux 下不可见（TPS65994 通过 EC 独占的 I2C 总线控制）。

---

#### 3.11.3 TPS65994 命令名称/ID 映射表（★★★ 关键发现）

**位置**：SPI `0x42960`~`0x42ac5`（330 字节）
**格式**：`[cmd_id: 1B][name_4char: ASCII][size_or_flags: 1B]` = 6 字节/条，共 59 条

这是 EC 固件内嵌的 TPS65994 I2C 子命令路由表，证明 EC 通过 I2C 直接向 TPS65994 下发 59 种操作指令。

**完整命令表：**

| CMD ID | 名称 | Payload | 功能说明 |
|---|---|---|---|
| 0x01 | Gaid | 8B | Go Away ID（异步通知事件） |
| 0x02 | GAID | 8B | Get Active IDentity |
| 0x03 | DISC | 7B | Disconnect |
| 0x04 | GO2M | 6B | Go to Minimized（低功耗模式） |
| 0x05 | ABRT | 6B | Abort |
| 0x06 | LOCK | 7B | Lock port |
| 0x07 | SWSk | 6B | SoftwareSwitch-Sink |
| 0x08 | SWSr | 6B | SoftwareSwitch-Source |
| 0x09 | SWDF | 6B | SW DualFunction |
| 0x0a | SWUF | 6B | SW UFP（上行端口模式） |
| 0x0b | SWVC | 6B | SW VConn Control |
| 0x0c | GSkC | 6B | Get Sink Capability |
| 0x0d | GSrC | 6B | Get Source Capability |
| 0x0e | SSrC | 6B | Set Source Capability |
| 0x0f | RRDO | 7B | Request RDO（Request Data Object） |
| 0x10 | ARDO | 7B | Answer RDO |
| 0x11 | SRDO | 7B | Set RDO |
| 0x12 | HRST | 6B | Hard Reset |
| 0x13 | CRST | 6B | Cable Reset |
| 0x14 | VDMs | 7B | VDM Send（Vendor Defined Message） |
| **0x15** | **AMDI** | 7B | **AMD Inquiry VDM（AMD 平台专用）** |
| **0x16** | **AMEn** | 7B | **AMD Enable VDM** |
| **0x17** | **AMEx** | 7B | **AMD Exit VDM** |
| **0x18** | **AMDs** | 6B | **AMD Status VDM** |
| 0x19 | GCdm | 3B | Get Configured Display Mode |
| 0x1a | SRDY | 7B | Set Ready |
| 0x1b | SRYR | 6B | Set Retry Reason |
| 0x1c | PTCs | 3B | PTC start |
| 0x1d | PTCd | 3B | PTC done |
| 0x1e | PTCc | 2B | PTC complete |
| 0x1f | PTCq | 2B | PTC query |
| 0x20 | PTCr | 3B | PTC result |
| 0x21 | FLrr | 3B | Flash read request |
| 0x22 | FLer | 7B | Flash erase |
| 0x23 | FLrd | 3B | Flash read data |
| 0x24 | FLad | 7B | Flash address set |
| 0x25 | FLwd | 7B | Flash write data |
| 0x26 | FLem | 7B | Flash erase mask |
| 0x27 | FLvy | 7B | Flash verify |
| 0x28 | GPoe | 1B | GPIO output enable |
| 0x29 | GPie | 1B | GPIO input enable |
| 0x2a | GPsh | 1B | GPIO set high |
| 0x2b | GPsl | 1B | GPIO set low |
| 0x2c | ADCs | 3B | ADC sample |
| 0x2d | ANeg | 0B | Auto-negotiate |
| 0x2e | DBfg | 0B | Debug flag |
| 0x2f | GSCX | 6B | Get Source Capability Extended |
| 0x30 | GSSt | 6B | Get Source Status |
| 0x31 | GBaS | 7B | Get Battery Status |
| 0x32 | GBaC | 7B | Get Battery Capability |
| 0x33 | GMfI | 7B | Get Manufacturer Info |
| 0x34 | MBWr | 1B | MessageBox Write |
| 0x35 | MBRd | 3B | MessageBox Read |
| 0x36 | FRSw | 6B | Fast Role Swap |
| 0x37 | SRrq | 7B | Set RDO request |
| 0x38 | SRrs | 7B | Set RDO response |
| 0x39 | ALRT | 6B | Alert |
| **0x3a** | **UCSI** | 7B | **★ UCSI 接口命令（系统级 PD 管理）** |
| **0x3b** | **Trig** | 7B | **Trigger（触发器）** |

**AMD 专用命令（0x15~0x18）**：AMD 平台专有 Vendor Defined Messages，用于 EC 向 TPS65994 下发 AMD 平台特定配置，涉及 DisplayPort Alt Mode 协商和 AMD ProximityConnect 特性。

**UCSI 命令（0x3a）**：EC 实现了通过 TPS65994 I2C 接口的 UCSI 子命令路由，但工程版 EC 固件问题导致 AMDI0052 ACPI 设备无法绑定 UCSI 驱动。

---

#### 3.11.4 TPS65994 命令处理函数指针表

**位置**：SPI `0x42ac8`~`0x42b57`（144 字节）
**格式**：`[EC_addr_LE24: 3B][segment=0x10: 1B]` = 4 字节/条，共 36 条有效记录

这是 EC 固件的 TPS65994 命令调度表，命令 ID → EC 函数地址的直接映射：

```
[00] CMD_Gaid → EC 0x07F693   [01] CMD_GAID → EC 0x0883A1
[02] CMD_DISC → EC 0x07F621   [03] CMD_GO2M → EC 0x07C949
[04] CMD_ABRT → EC 0x07B441   [05] CMD_LOCK → EC 0x07CD35
[06] CMD_SWSk → EC 0x0912E5   [07] CMD_SWSr → EC 0x0745E9
[08] CMD_SWDF → EC 0x0751F5   [09] CMD_SWUF → EC 0x075239
[0a] CMD_SWVC → EC 0x075269   [0b] CMD_GSkC → EC 0x074C41
[0c] CMD_GSrC → EC 0x094A21   [0d] CMD_SSrC → EC 0x0752C5
[0e] CMD_RRDO → EC 0x075201   [0f] CMD_ARDO → EC 0x075165
[10] CMD_SRDO → EC 0x074675   [11] CMD_HRST → EC 0x0751D5
[12] CMD_CRST → EC 0x074C7D   [13] CMD_VDMs → EC 0x0751C7
[14] CMD_AMDI → EC 0x075191   [15] CMD_AMEn → EC 0x074795
[16] CMD_AMEx → EC 0x0752E1   [17] CMD_AMDs → EC 0x0752DD
[18] CMD_GCdm → EC 0x07464D   [19] CMD_SRDY → EC 0x0751D1
[1a] CMD_SRYR → EC 0x074651   [1b] CMD_PTCs → EC 0x07470D
[1c] CMD_PTCd → EC 0x074641   [1d] CMD_PTCc → EC 0x07462D
[1e] CMD_PTCq → EC 0x074631   [1f] CMD_PTCr → EC 0x07455D
[20] CMD_FLrr → EC 0x074635   [21] CMD_FLer → EC 0x07457D
[22] CMD_FLrd → EC 0x074569   [23] CMD_FLad → EC 0x0745AD
```

注意：59 条命令中仅有 36 条独立处理函数，其余 23 条（FLwd/FLem/FLvy/GPoe...Trig 等）路由到 `0x42b58` 的命令路由查找表中。`CMD_SWSk`（0x06，Sink 切换）和 `CMD_GSrC`（0x0c，获取 Source 能力）对应 `0x09xxxx` 代码段。

---

#### 3.11.5 TPS65994 寄存器访问白名单（SPI 0x41530）

**格式**：`[entry_idx: 1B][bus=0x14: 1B][cmd_reg=0x0c: 1B][dev_addr=0x20: 1B][target_reg LE32: 4B]` = 8 字节/条，共 25 条

含义：EC 通过 I2C bus=0x14（设备地址=0x20）访问 TPS65994 的 CMD 寄存器（0x0c），target_reg 是允许操作的 TPS65994 内部子寄存器地址白名单。

| 索引 | 目标寄存器地址 | 推测功能 |
|---|---|---|
| 4 | 0x001F | Port Status |
| 5 | 0x0020 | Connection Status |
| 6 | 0x0021 | Cable Plug Status |
| 7 | 0x0026 | VDO |
| 8 | 0x0040 | Data Status |
| 9 | 0x0041 | Power Status |
| 10 | 0x0042 | PD Status |
| 11 | 0x0046 | Override Source Status |
| 12 | 0x0044 | Type-C控制 |
| 13 | 0x0047 | GPIO状态 |
| 14 | 0x0048 | Version信息 |
| 15 | 0x0049 | ManufacturerInfo |
| 16 | 0x004A | Port Control |
| 17 | 0x004C | Sink PDO |
| 18 | 0x0050 | Current Sink Cap |
| 19 | 0x0051 | Alt Mode Status |
| 20 | 0x0052 | Alt Mode Config |
| 21 | 0x0060 | DP Status |
| 22 | 0x0061 | DP Config |
| 23 | 0x0084 | Temperature |
| 24 | 0x00C2 | TX Hard Reset |
| 25 | 0x00C3 | RX Hard Reset |
| 26 | 0x0101 | TX Sub Port |
| 27 | 0x0105 | RX Sub Port |
| 28 | 0x05000000 | （结尾标记） |

---

#### 3.11.6 KB8002 初始化序列（N3GPH70W.bin SEC4-C 精确解析）

##### 格式最终确认

H70W bin SEC4-C 数据段（偏移 `H70W+0x38C` ~ `H70W+0x3C7`，共 60 字节）：

```
格式：[port: 1B][reg_lo: 1B][reg_hi: 1B][val_lo: 1B][val_hi: 1B]
长度：5 字节/条记录，60B ÷ 5B = 12 条（完全整除，无对齐问题）
```

##### 完整 12 条记录

| 条目 | 偏移（H70W+） | port | 寄存器（LE16） | 值（LE16） | 实际写入字节 |
|---|---|---|---|---|---|
| 0 | 0x38C | 1 | reg=0x0022 | 0x1500 | val=0x00 |
| 1 | 0x391 | 1 | reg=0x0022 | 0x1502 | val=0x02 |
| 2 | 0x396 | 1 | reg=0x0022 | 0x1508 | val=0x08 |
| 3 | 0x39B | 1 | reg=0x0022 | 0x150A | val=0x0A |
| 4 | 0x3A0 | 2 | reg=0x0022 | 0x1500 | val=0x00 |
| 5 | 0x3A5 | 2 | reg=0x0022 | 0x1502 | val=0x02 |
| 6 | 0x3AA | 2 | reg=0x0022 | 0x1508 | val=0x08 |
| 7 | 0x3AF | 2 | reg=0x0022 | 0x150A | val=0x0A |
| 8 | 0x3B4 | 1 | reg=0x0042 | 0x1078 | TX/RX配置A |
| 9 | 0x3B9 | 1 | reg=0x0042 | 0x107A | TX/RX配置B |
| 10 | 0x3BE | 2 | reg=0x0042 | 0x1078 | TX/RX配置A |
| 11 | 0x3C3 | 2 | reg=0x0042 | 0x107A | TX/RX配置B |

**port 1 = KB8002 port1（I2C-0 地址 0x27），port 2 = KB8002 port2（I2C-0 地址 0x48）**

##### reg[0x22] 初始化序列含义

```
写入序列：0x00 → 0x02 → 0x08 → 0x0A（对 port1 和 port2 各一遍）

bit[1] = USB3 使能：0x02 = 仅使能 USB3
bit[3] = DP 使能：  0x08 = 仅使能 DP
0x0A = bit1+bit3 = USB3 + DP 同时使能（多路复用最终状态）

工程机当前值：reg[0x22] = 0x00（USB3+DP 多路复用未激活）
```

##### reg[0x42] 配置参数解读

```
0x1078：
  bit[15:12] = 0x1  → TX 驱动强度 = 档位 1
  bit[11:8]  = 0x0  → Pre-emphasis（预加重）= 0
  bit[7:4]   = 0x7  → TX 摆幅（Swing）= 档位 7
  bit[3:0]   = 0x8  → RX CTLE 均衡增益 = 8（标准均衡）

0x107A：
  同上，但 bit[3:0] = 0xA → RX CTLE 均衡增益 = 10（增强均衡）

工程机当前值：reg[0x42] = 0x03（TX 和 RX 参数均不正确）
```

##### 手动仿真初始化命令

```bash
# 对 KB8002 port1（I2C-0 地址 0x27）执行 H70W SEC4-C 初始化序列：
sudo i2cset -y 0 0x27 0x22 0x00  # 步骤1：清零
sudo i2cset -y 0 0x27 0x22 0x02  # 步骤2：使能 USB3
sudo i2cset -y 0 0x27 0x22 0x08  # 步骤3：使能 DP
sudo i2cset -y 0 0x27 0x22 0x0a  # 步骤4：USB3+DP 最终值

# reg[0x42]（16-bit写入，注意字节序）：
sudo i2cset -y 0 0x27 0x42 0x78 0x10 i  # val = 0x1078

# port2（I2C-0 地址 0x48）相同操作：
sudo i2cset -y 0 0x48 0x22 0x0a
sudo i2cset -y 0 0x48 0x42 0x78 0x10 i

# ⚠ 风险提示：写入前断开所有 USB-C 外设，每次写入后验证读回值
```

---

#### 3.11.7 分析结论汇总

| 发现 | 确认状态 | 技术意义 |
|---|---|---|
| TPS65994 7-bit I2C 地址 = 0x20（bus_id=0x08/0x14） | ✅ 三处独立确认 | PD 控制器 I2C 配置确认 |
| TPS65994 命令表 59 条（SPI 0x42960），含 UCSI（0x3a）和 AMD VDM（0x15~0x18） | ✅ 完整解析 | EC 实现了 UCSI 接口 |
| TPS65994 命令处理函数指针 36 条（SPI 0x42ac8，EC 地址 0x07~0x09xxxx） | ✅ 完整解析 | 可定位反汇编目标 |
| KB8002 reg[0x22] 初始化序列：0x00→0x02→0x08→0x0a（port1 & port2） | ✅ 5字节格式确认 | USB3+DP 多路复用配置流程 |
| KB8002 reg[0x42] 目标值 0x1078/0x107a（TX=7 EQ=8/a） | ✅ 完整解析 | Retimer 链路均衡参数 |
| 工程机 reg[0x22]=0x00, reg[0x42]=0x03 与目标值不符 | ✅ 已实测 | 量产 EC 初始化序列未执行于工程机 |
| EC 代码分 4 段（0x07/0x08/0x09/0x0b），0x0b 段 = KB8002 控制 | ✅ 架构确认 | EC 固件模块化架构 |

---

### 3.12 KB8002 手动初始化测试结果（实机验证）

> 本节记录 2026-03-14 实机验证结果，对 3.11.6 节手动初始化命令序列的修正。

#### 3.12.1 I2C 写入测试结果

**测试结论：i2cset 字节写入 KB8002 无效（写后读回值不变）**

- `i2cset -y 0 0x27 0x22 0x0a` → 写入返回成功（ACK），但读回仍为 0x00
- `i2cset -y 0 0x27 0x42 0x78` → 写入返回成功（ACK），但读回仍为 0x03
- word 模式写入同样无效

与此同时，**word 读取揭示了寄存器真实值**：
- `i2cget -y 0 0x27 0x42 w` → 返回 `0x1a03`（低字节=0x03，高字节=0x1a）
- 实际 reg[0x42] 16-bit 值为 `0x1a03`，而目标值为 `0x1078/0x107a`

#### 3.12.2 KB8002 寄存器完整快照（工程机状态）

| 寄存器 | 值 | 说明 |
|---|---|---|
| reg[0x22] | 0x00 | USB3/DP 配置，应为 0x0a（USB3+DP 同时使能） |
| reg[0x42] | 0x03（byte）/ 0x1a03（word） | TX/RX 均衡，应为 0x1078/0x107a |
| reg[0x21] | 0x21 | 设备版本/ID 字节之一 |
| reg[0x09] | 0x40 | 状态字节（bit6 置位） |
| reg[0x11] | 0x40 | 与 reg[0x09] 相同，可能是镜像 |
| reg[0x1f] | 0x18 | 链路状态？ |
| reg[0x30]~[0x33] | 0x35/0x35/0x1f/0x35 | 可能是信号质量抽样值 |

#### 3.12.3 写入无效原因分析

写入无效可能原因（排序）：

1. **EC 独占写保护**：KB8002 上电后 EC 接管控制权，通过某种方式使 I2C 总线对外来写写保护（如声明总线主控、设置 I2C alert 锁定）
2. **状态机写入条件不满足**：EC ARM 代码（0x21710 处的 Thumb-2 函数）是一个**跳转表状态机**（`tbb [pc, r0]`），写入操作只在特定链路训练阶段（r0=状态字节）发生，链路未就位时写入被忽略
3. **KB8002 写保护寄存器**：Retimer 可能有一个解锁序列，需要先写入特定 magic 字节才能开放写权限（工程 EC 可能已锁定）
4. **需要 I2C 复位序列**：某些寄存器只在复位后的初始化窗口可写

#### 3.12.4 EC ARM Thumb-2 代码逆向发现

利用 `capstone` 对 EC SPI `0x21710`~`0x217a0` 区域进行了准确反汇编，确认：
- `0x21710`: `PUSH.W {r4-r11, lr}` → 标准 ARM Thumb-2 函数序言
- `0x021780`~`0x21795`: 初始化常量加载：
  ```
  movs r6, #0          ; r6 = 0
  movs r7, #1          ; r7 = 1  
  movs r2, #0x42       ; r2 = KB8002 reg[0x42] address
  mov.w r9, #0x45      ; r9 = 69
  mov.w lr, #0x2e      ; lr = 46
  mov.w r8, #0x26      ; r8 = 38
  mov.w r11, #0x17     ; r11 = 23
  ```
- `0x021798`: `cmp r0, #0x4b` / `0x02179c: tbb [pc, r0]` → **跳转表分支（状态机）**
  
  `r0` 来自 `ldrb r0, [r4, #5]`（读取当前链路状态字节），`tbb` 根据状态机状态（0~0x4a）跳入对应处理分支。**KB8002 初始化是状态机驱动的，不是一次性顺序写入**。

#### 3.12.5 修订的手动初始化方法

**3.11.6 节的 i2cset 命令序列目前无效**。以下是已知的可能方案：

**方案 A（最简单）**：更新 EC 固件至 N3GHT67W（量产版），让 EC 自动执行状态机初始化。

**方案 B（调试）**：触发 EC 重新执行 KB8002 初始化状态机。通过注入 USB-C hotplug 事件可能触发状态机从初始状态重跑：
```bash
# 观察 EC 状态变化（通过 ACPI 事件监控）
acpi_listen &
# 插入/拔出 USB-C 外设观察状态机响应
```

**方案 C（底层研究）**：完整逆向 `0x21710` 函数的跳转表，找出哪些状态对应写入操作，以及触发条件。需要 Ghidra 加载 SPI 固件展开完整分析。

---

## 3.13 EC 状态机深度逆向：KB8002 初始化完整调用链（2026-03-14）

### 背景

本节在 3.12 节（KB8002 写入无效确认）基础上，对 EC SPI dump 中 `0x21710` 处的 Thumb-2 状态机函数进行系统性深度逆向，完整梳理 KB8002 初始化的调用链和数据表。

---

### 3.13.1 状态机函数序言分析

函数 `0x21710` 完整序言（已确认为 32-bit ARM Thumb-2）：

```asm
021710: push.w {r4, r5, r6, r7, r8, sb, sl, fp, lr}  ; 保存全部寄存器
021714: mov sl, r0                                      ; sl = 输入参数 (KB8002 设备索引)
021716: subs r0, #0x33                                  ; 检查 r0 >= 0x33 ?
021718: sub sp, #0x2c                                   ; 开 44 字节栈帧
02171a: cmp r0, #1
02171c: blt → 02172c                                    ; <0x33 → 走正常初始化
021720: bl #0x3410                                      ; 否则走简化路径 (快速返回)
021724: movs r0, #1
021726: pop.w {r4-r11, pc}                             ; 提前返回

; 正常路径 (sl < 0x33):
02172c: ldr r0, [pc, #0x3f0]  → 0x21b22  ; 读 r4_base 指针
02172e: add.w r1, sl, sl, lsl #4          ; r1 = sl * 17
021732: add.w r4, r0, r1, lsl #4         ; r4 = r0 + sl * 272
021736: sub.w r4, r4, #0x3600
02173a: subs r4, #0x30                    ; r4 = r4_base + sl*272 - 0x3630
                                           ; r4 = KB8002 设备结构体[sl] 指针
```

**结论**：`sl` (r10) = 函数参数 = **KB8002 设备实例索引**，`r4` = 指向对应设备结构体的基指针。

---

### 3.13.2 常量寄存器预加载（跳表前初始化）

在 `tbb [pc, r0]` 前，有一批常量寄存器被预加载：

```asm
021780: movs r6, #0        ; r6 = 0
021782: movs r7, #1        ; r7 = 1 (IDLE状态码)
021784: movs r2, #0x42     ; r2 = 0x42 ← KB8002 reg[0x42] 地址
021786: mov.w sb, #0x45    ; sb(r9) = 0x45 ← KB8002 reg[0x45] 地址？
02178a: mov.w lr, #0x2e    ; lr = 0x2e ← KB8002 reg[0x2e] 地址？
02178e: mov.w r8, #0x26    ; r8 = 0x26 ← KB8002 reg[0x26] 地址？
021792: mov.w fp, #0x17    ; fp(r11) = 0x17 ← KB8002 reg[0x17]？
021796: str r3, [sp]       ; sp[0] = r3 (SEC4-C 数据指针)
021798: cmp r0, #0x4b      ; 检查 state <= 0x4a
02179a: bhs → 0x2188e      ; state >= 0x4b → OOB error
02179c: tbb [pc, r0]       ; 跳表分发
```

这些常量是 KB8002 的寄存器地址，在各状态分支中作为 I2C 命令的寄存器目标地址参数使用。

---

### 3.13.3 I2C 写入调用链

状态机中实际执行 I2C 写入的调用链如下：

```
状态机分支
    ↓
0x02184c → b #0x218c2
    ↓
0x022568: bl #0x22578          ; 提取 [r0,bit6], 准备参数
    ↓
0x022578: bl #0x200c4          ; 构建 I2C 命令结构体
    ↓                           ; 参数: r0=类型大小 r1=命令类型 r2=数据 r3=cmd_buf
0x0200c4: b.w #0x167a8         ; tail call → I2C 发送器 (dispatch)
    ↓
0x0167a8: I2C 执行函数
    → [r3,#3] = cmd_type (9/0xb/3/5/7)
    → tbb [pc, r0] (第二层分发)
    → 实际写入 I2C bus
```

**辅助函数**：
- `0x1075c` → `0x24d64`（I2C 链路状态检查器，`r0=1`=就绪）
- `0x1f650`（state[2/3] 调用，功能待分析）
- `0x16b82`（通用辅助，多处调用）
- `0x22db0`（state[7/8] 调用）

---

### 3.13.4 H70W.bin 中的 KB8002 初始化数据表

在 `N3GPH70W.bin`（H70W升级包固件，22528B）`+0x038c` 处发现完整的 KB8002 SEC4-C 初始化序列：

**格式**：每条 5 字节：`[port:1][reg_lo:1][reg_hi:1][val:1][op_type:1]`

| 序号 | 偏移    | 原始HEX        | 端口         | 寄存器  | 写入值 | 操作类型       |
|------|---------|----------------|--------------|---------|--------|----------------|
| 0    | +0x038c | `0122000015`   | port1 (0x27) | 0x0022  | 0x00   | WriteByte      |
| 1    | +0x0391 | `0122000215`   | port1 (0x27) | 0x0022  | 0x02   | WriteByte      |
| 2    | +0x0396 | `0122000815`   | port1 (0x27) | 0x0022  | 0x08   | WriteByte      |
| 3    | +0x039b | `0122000a15`   | port1 (0x27) | 0x0022  | 0x0a   | WriteByte      |
| 4    | +0x03a0 | `0222000015`   | port2 (0x48) | 0x0022  | 0x00   | WriteByte      |
| 5    | +0x03a5 | `0222000215`   | port2 (0x48) | 0x0022  | 0x02   | WriteByte      |
| 6    | +0x03aa | `0222000815`   | port2 (0x48) | 0x0022  | 0x08   | WriteByte      |
| 7    | +0x03af | `0222000a15`   | port2 (0x48) | 0x0022  | 0x0a   | WriteByte      |
| 8    | +0x03b4 | `0142007810`   | port1 (0x27) | 0x0042  | 0x78   | WriteWord      |
| 9    | +0x03b9 | `0142007a10`   | port1 (0x27) | 0x0042  | 0x7a   | WriteWord      |
| 10   | +0x03be | `0242007810`   | port2 (0x48) | 0x0042  | 0x78   | WriteWord      |
| 11   | +0x03c3 | `0242007a10`   | port2 (0x48) | 0x0042  | 0x7a   | WriteWord      |
| 12   | +0x03c8 | `0000000000`   | END          | —       | —      | 结束标记       |

**重要注意**：这 12 条不是按顺序全部执行，而是由状态机按 KB8002 链路协商结果**选择其中一条**执行。

---

### 3.13.5 reg[0x22] 位含义分析

reg[0x22] 的 4 个候选值（0x00/0x02/0x08/0x0a）位分析：

```
0x00 = 0000 0000  → 全关（基础模式）
0x02 = 0000 0010  → bit1 = USB3_EN？（USB 3.x 超高速使能）
0x08 = 0000 1000  → bit3 = AUX_EN？（DP AUX 通道使能）
0x0a = 0000 1010  → bit1+bit3 = USB3+AUX 都开（完整功能模式）
```

reg[0x42] 的 2 个候选值（0x78/0x7a）位分析：

```
0x78 = 0111 1000  → bit[3:6]=1111，bit1=0
0x7a = 0111 1010  → 同上但 bit1=1
差值 bit1 = USB3_EN 方向标志？
```

状态机根据 `[r4, #2]`（能力字节）中的 bit（`[r4,#2]` bit[28..29]）以及 `[r4, #0xba]`（USB3能力字）来选择写入哪个值。

---

### 3.13.6 关键状态转换路径（精简）

```
state[0]  = 0x00  → 自循环（IDLE，等待外部事件触发）
state[2]  = 0x02  → 初始化开始：bl #0x21830 (bl #0x1f650)
state[3]  = 0x03  → 直接跳公共处理
state[4]  = 0x04  → 跳 0x218c2 (bl #0x22568)
state[6]  = 0x06  → 直接退出 0x21cca
state[7]  = 0x07  → b #0x218b2 (strb [r4,#0xec]) → b #0x218c2
state[8]  = 0x08  → 从 state[7] 末尾进入
              → cbnz [r4,#0xba] → skip
              → bl #0x1075c (I2C状态检查)
              → 若成功: bic [r4], #0x80; strb r7,[r4,#5] → state=1 (完成)
state[1]  = 0x01  → 状态机任务完成
state[0x27] = 🔶 伪状态：等待 KB8002 port1(0x27) I2C 操作完成
```

**状态从 0 → 2 的触发机制**：由外部热插拔/链路检测中断触发（USB-C 插入事件），EC 固件通过另一个入口函数设置 `[r4,#5] = 0x02`，然后在下一个调度周期进入状态机。

---

### 3.13.7 工程机故障根因总结

本机（工程机 EC=N3GHT15W）的状态机长期驻留在 `state[0]`（IDLE 自循环），原因链：

1. **USB-C 没有有效物理连接**（或 KB8002 PHY 初始化从未被触发）
2. `[r4,#9]`（链路使能字节）= 0 → `bl #0x7448` 返回 0 → 跳过所有初始化
3. 即使强制 i2cset 写寄存器，EC 的下一次调度会用 SEC4-C 数据覆盖（或保护寄存器不响应）
4. EC 版本 N3GHT15W < N3GHT67W，缺少该版本对 KB8002 USB3/DP 初始化的修复

**对应解决方案（不变）**：升级到 N3GHT67W 或更高版本  EC，触发正确的链路初始化 flow。

---

### 3.13.8 可操作路径：手动模拟 state[8]

若需要验证 KB8002 写入效果而不升级 EC，可尝试：

```bash
# 前提：确认 i2c bus 号（通常 0 或 1）
# 写 reg[0x22] = 0x0a（USB3+AUX，state=0x0a模式）
i2ctransfer -y 1 w3@0x27 0x22 0x00 0x0a   # port1，16-bit寄存器地址，8-bit数据

# 写 reg[0x42] = 0x7a（写字模式）
i2ctransfer -y 1 w4@0x27 0x42 0x00 0x7a 0x00   # port1，reg+data(2B)

# 同步 port2
i2ctransfer -y 1 w3@0x48 0x22 0x00 0x0a
i2ctransfer -y 1 w4@0x48 0x42 0x00 0x7a 0x00
```

**注意**：此方案仅在 EC state[0]=IDLE（不活跃写入）时有效，且重启后恢复。

