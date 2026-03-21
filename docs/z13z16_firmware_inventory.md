# Z13/Z16 固件收藏 — 完整清单

> ThinkPad Z13 Gen1 (21D2) / Z16 Gen1 共用固件，主板型号 NM-E161
> 分析日期: 2026-03-21
> 已整理到: `firmware/bios/`, `firmware/ec_spi/`, `firmware/ec/`, `firmware/vbios/`

## 芯片位号说明

| 位号 | 用途 | 容量 | 闪存型号 |
|------|------|------|----------|
| **U2101** | BIOS SPI Flash | 32MB (256Mbit) | Winbond W25Q256 / 同类 |
| **U8505** | EC SPI Flash | 32MB (256Mbit) | Winbond W25Q256 / 同类 |
| U2102 | BIOS SPI (改版/另板) | 32MB | 仅出现在一个目录 |

- `StatusRegVal` 文件 (2字节) = CH341A 编程器读取时保存的 SPI 状态寄存器值 (均为 `0x0002`)
- BIOS 版本 ID 格式: `N3GETxxW` (工程版后缀可能为 T/M)
- EC 版本 ID 格式: `N3GHTxxW`

## 一、VBIOS (Z16 RX 6500M 独显)

三个文件**完全相同** (SHA256 `d1d0ba82...`), 1MB:

| 文件 | 说明 |
|------|------|
| `028.087260.rom` | AMD Device 028 (Navi 24), variant 087260 |
| `vbios-028-094773.rom` | AMD Device 028, variant 094773 |
| `vbios.rom` | 通用名称副本 |

> Z13 无独显，此 VBIOS 仅适用于 Z16 RX 6500M 配置。

## 二、BIOS (U2101) 独立版本清单

按嵌入的 Lenovo BIOS ID 排序，共 **15 个唯一 U2101 dump**:

| # | BIOS ID | 目录标签 | SHA256 前缀 | 备注 |
|---|---------|----------|-------------|------|
| 1 | N3GET04T | 1-bios-0.T3-ec-0.26-rev-0.2 | `85200179` | 最早工程测试版 (T后缀=Test) |
| 2 | N3GET04T | 2-bios-0.T3-ec-0.26-rev-0.2 | `d9b24bce` | 同版本不同dump (不同机器) |
| 3 | N3GET05M | 3-bios-0.05-ec-0.08-rev-0.3 | `2eb55ffe` | 工程版 (M后缀) |
| 4 | N3GET05M | 4-bios-0.05-ec-0.07-rev-0.3 | `2af504ed` | 同BIOS不同EC |
| 5 | N3GET05M | nm-e161-0.3-不开机 | `9b317df1` | 不开机板子的dump |
| 6 | N3GET06W | 4-bios-0.06-ec-0.01A-rev-0.2 (u2102) | `d0fd636e` | 不同芯片位号，板rev 0.2 |
| 7 | N3GET09W | 1-bios-0.05-ec-0.11-rev-0.3 | `007733a8` | (目录标签可能有误) |
| 8 | N3GET09W | 4-bios-0.09-ec-0.11-rev-0.3 | `5eeb1b80` | |
| 9 | N3GET09W | 5-bios-0.09-ec-0.11-rev-0.4 | `2a049580` | 板rev升级到0.4 |
| 10 | N3GET10M | 6-bios-0.1-ec-0.01-rev-0.4 | `9148c3dc` | = 3-bios-ec-rev.0.4/u2101-bak |
| 11 | N3GET10M | rec-0.4/u2101 | `45fc8608` | Recovery 用 |
| 12 | N3GET10M | 3-bios-ec-rev.0.4 (工程版不亮机) | `5884d59c` | 工程版 dump |
| 13 | N3GET10W | 5-bios-0.1-ec-0.12-rev-0.3 | `53045047` | W后缀 = 正式 |
| 14 | N3GET21W | 7-bios=1.02-ec-0.-rec-0.4 | `06c31378` | 第一个正式版 |
| 15 | N3GET21W | bios-1.02/U2101 | `8e19e743` | 不同dump (可能刷入了设置差异) |
| 16 | N3GET42W | bios-1.02/NM-E161 | `04c7541c` | 独立完整板dump |
| 17 | N3GET64W | bios-1.64/U2101-TEST | `9e1921a4` | 测试版 |
| 18 | N3GET64W | bios-1.64/U2101 = bios-1.65/U2101 | `5f04c16c` | 1.64和1.65目录共享相同U2101 |
| 19 | N3GET66W | Z13-0.4-1.66-BIOS.bin | `f040d644` | **最新版本** |

## 三、EC (U8505) 独立版本清单

共 **12 个唯一 EC dump**:

| # | EC ID | 目录标签 | SHA256 前缀 | 备注 |
|---|-------|----------|-------------|------|
| 1 | (EC 0.26) | 1-bios-0.T3-ec-0.26-rev-0.2 | `be75a9c8` | 最早期 EC |
| 2 | (EC 0.26) | 2-bios-0.T3-ec-0.26-rev-0.2 | `fc68437f` | 不同机器dump |
| 3 | (EC 0.08) | 3-bios-0.05-ec-0.08-rev-0.3 | `e13a4725` | |
| 4 | (EC 0.07) | 4-bios-0.05-ec-0.07-rev-0.3 = nm..不开机 | `f844e8dc` | 3份相同 |
| 5 | (EC 0.01) | 6-bios-0.1-ec-0.01-rev-0.4 = 3-bios..bak | `7b96ea46` | 3份相同 |
| 6 | (EC ?) | 3-bios-ec-rev.0.4/U8505 25Q256J BK | `1bbd653c` | |
| 7 | (EC 0.11) | ec-0.11-rev-0.2 = 4/7 bios dirs | `69a3a57d` | **5份相同** |
| 8 | (EC 0.11) | 5-bios-0.09-ec-0.11-rev-0.4 | `f35f330a` | 板rev 0.4 |
| 9 | N3GHT12W | 5-bios-0.1-ec-0.12-rev-0.3 | `a08d4dfd` | |
| 10 | N3GHT25W | bios-1.02/U8505 | `0884b9cc` | |
| 11 | N3GHT64W | bios-1.64+1.65 (3份相同) | `38cf2206` | U8505-TEST = U8505 |
| 12 | (EC ?) | rec-0.4/U8505 | `f5fce895` | Recovery 用 |

### 独立 EC 固件

| 文件 | 大小 | EC ID | SHA256 前缀 |
|------|------|-------|-------------|
| ec-test-1.64.bin | 320KB | N3GHT64W | `b99b2ee0` |

> 这是提取出的纯 EC 固件镜像 (非完整 SPI dump)，可用于通过 UEFI 更新 EC。

## 四、目录重复分析

以下目录对包含**完全相同**的文件 (仅命名差异 `rev-0.x` vs `rev.0.x`):

- `1-bios-0.05-ec-0.11-rev-0.3` == `1-bios-0.05-ec-0.11-rev.0.3`
- `4-bios-0.05-ec-0.07-rev-0.3` == `4-bios-0.05-ec-0.07-rev.0.3`
- `4-bios-0.09-ec-0.11-rev-0.3` == `4-bios-0.09-ec-0.11-rev.0.3`
- `5-bios-0.09-ec-0.11-rev-0.4` == `5-bios-0.09-ec-0.11-rev.0.4`
- `6-bios-0.1-ec-0.01-rev-0.4` == `6-bios-0.1-ec-0.01-rev.0.4`
- `7-bios=1.02-ec-0.-rec-0.4` == `7-bios=1.02-ec-0.-rec.0.4`

> 共 6 对重复目录。可安全删除 `.0.x` 后缀的那批（它们是 `-0.x` 的副本）。

## 五、跨目录相同文件

部分文件虽在不同名称目录中，内容完全相同:

- **U2101** `9148c3dc`: `6-bios-0.1-ec-0.01-rev-0.4/U2101.bin` = `3-bios-ec-rev.0.4/u2101-bak.bin`
- **U8505** `69a3a57d`: `ec-0.11-rev-0.2/u8505.bin` = `4-bios-0.09-ec-0.11-*/u8505.bin` = `7-bios=1.02-*/U8505.bin` (5份)
- **U8505** `f844e8dc`: `4-bios-0.05-ec-0.07-*/U8505.bin` = `nm-e161-0.3-不开机/u8505.bin`
- **U8505** `38cf2206`: `bios-1.64-*/U8505-TEST-1.64.bin` = `bios-1.64-*/U8505.bin` = `bios-1.65-*/U8505.bin`
- **U2101** `5f04c16c`: `bios-1.64-*/U2101.bin` = `bios-1.65-*/U2101.bin`

## 六、版本时间线

```
板修订 rev 0.2 (原型)
  └─ BIOS 0.T3 (N3GET04T) + EC 0.26  ← 最早工程测试版
  └─ BIOS 0.06 (N3GET06W) + EC 0.01A ← u2102芯片，另一台/改版

板修订 rev 0.3 (量产前)
  └─ BIOS 0.05 (N3GET05M) + EC 0.07
  └─ BIOS 0.05 (N3GET05M) + EC 0.08  
  └─ BIOS 0.05 (N3GET09W) + EC 0.11  ← 注意: GET09W > GET05M
  └─ BIOS 0.09 (N3GET09W) + EC 0.11
  └─ BIOS 0.1  (N3GET10W) + EC 0.12 (N3GHT12W)

板修订 rev 0.4 (量产/最终)
  └─ BIOS 0.09 (N3GET09W) + EC 0.11
  └─ BIOS 0.1  (N3GET10M) + EC 0.01  ← rec-0.4 recovery
  └─ BIOS 1.02 (N3GET21W) + EC 0.11  ← 第一个正式版
  └─ BIOS 1.02 (N3GET42W)            ← NM-E161 完整dump (晚于21W)
  └─ BIOS 1.64 (N3GET64W) + EC 1.64 (N3GHT64W)  ← 正式版
  └─ BIOS 1.65 (N3GET64W) + EC 1.65 (N3GHT64W)  ← 目录标签不同，内容=1.64
  └─ BIOS 1.66 (N3GET66W)            ← Z13-0.4-1.66-BIOS.bin 最新
```

## 七、特殊/问题文件

| 文件 | 说明 |
|------|------|
| `nm-e161-0.3-不开机/` | 板rev 0.3 不开机的dump (BIOS=05M, EC同07版) |
| `3-bios-ec-rev.0.4/bios 74M25J U2101 工程版不亮机的bk.bin` | 工程版不亮机的备份 |
| `3-bios-ec-rev.0.4/U8505 2..BK.rar` | 压缩的EC备份 (150KB) |
| `U8505-TEST-1.64.bin` | 与正式 U8505.bin 完全相同 |
| `bios-1.65` 目录 | U2101 和 U8505 均与 1.64 目录相同 |

## 八、统计

- 总文件数: ~65 个 (含 StatusRegVal 和 .DS_Store)
- 唯一二进制文件: ~28 个
- 重复副本: ~22 个
- 总磁盘占用: ~2 GB
- BIOS 独立版本: 15-19 个
- EC 独立版本: 12 个
- VBIOS: 1 个 (3份相同)
