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

原始三个文件**完全相同** (SHA256 `d1d0ba82...`), 1MB:

| 整理后文件 | 原始文件 | 说明 |
|------------|----------|------|
| `firmware/vbios/RX6500M_028_094773.rom` | `028.087260.rom` / `vbios-028-094773.rom` / `vbios.rom` | AMD Device 028 (Navi 24) |

> Z13 无独显，此 VBIOS 仅适用于 Z16 RX 6500M 配置。

## 二、BIOS SPI (U2101) — `firmware/bios/`

共 **21 个文件** (19个来自刷机包 + 2个用户自己机器):

### 工程版 (BIOS ID < N3GET20W)

| 整理后文件名 | BIOS ID | 原始来源 | SHA256 前缀 |
|-------------|---------|----------|-------------|
| `N3GET04T_eng_rev0.2_machine1.bin` | N3GET04T | 1-bios-0.T3-ec-0.26-rev-0.2 | `85200179` |
| `N3GET04T_eng_rev0.2_machine2.bin` | N3GET04T | 2-bios-0.T3-ec-0.26-rev-0.2 | `d9b24bce` |
| `N3GET04W_z13_own_preflash_20260310.bin` | N3GET04W | **用户Z13 preflash备份** | `9bd9bcb1` |
| `N3GET05M_eng_rev0.3_ec0.08.bin` | N3GET05M | 3-bios-0.05-ec-0.08-rev-0.3 | `2eb55ffe` |
| `N3GET05M_eng_rev0.3_ec0.07.bin` | N3GET05M | 4-bios-0.05-ec-0.07-rev-0.3 | `2af504ed` |
| `N3GET05M_eng_rev0.3_nme161_dead.bin` | N3GET05M | nm-e161-0.3-不开机 | `9b317df1` |
| `N3GET06W_eng_rev0.2_u2102.bin` | N3GET06W | 4-bios-0.06-ec-0.01A (u2102芯片) | `d0fd636e` |
| `N3GET09W_eng_rev0.3_ec0.11_dir0.05.bin` | N3GET09W | 1-bios-0.05-ec-0.11-rev-0.3 | `007733a8` |
| `N3GET09W_eng_rev0.3_ec0.11.bin` | N3GET09W | 4-bios-0.09-ec-0.11-rev-0.3 | `5eeb1b80` |
| `N3GET09W_eng_rev0.4_ec0.11.bin` | N3GET09W | 5-bios-0.09-ec-0.11-rev-0.4 | `2a049580` |
| `N3GET10M_eng_rev0.4_ec0.01.bin` | N3GET10M | 6-bios-0.1-ec-0.01-rev-0.4 | `9148c3dc` |
| `N3GET10M_eng_rev0.4_recovery.bin` | N3GET10M | rec-0.4 | `45fc8608` |
| `N3GET10M_eng_rev0.4_dead.bin` | N3GET10M | 3-bios-ec-rev.0.4 工程版不亮机 | `5884d59c` |
| `N3GET10W_eng_rev0.3_ec0.12.bin` | N3GET10W | 5-bios-0.1-ec-0.12-rev-0.3 | `53045047` |

### 正式版 (BIOS ID ≥ N3GET21W)

| 整理后文件名 | BIOS ID | 原始来源 | SHA256 前缀 |
|-------------|---------|----------|-------------|
| `N3GET21W_v1.02_rev0.4_7.bin` | N3GET21W | 7-bios=1.02-ec-0.-rec-0.4 | `06c31378` |
| `N3GET21W_v1.02_rev0.4.bin` | N3GET21W | bios-1.02/U2101 | `8e19e743` |
| `N3GET42W_v1.02_nme161_full.bin` | N3GET42W | bios-1.02/NM-E161 完整板dump | `04c7541c` |
| `N3GET47W_z13_own_chinafix.bin` | N3GET47W | **用户Z13 来自矽曦论坛** | `9c1c8db4` |
| `N3GET64W_v1.64_rev0.4_test.bin` | N3GET64W | bios-1.64 TEST | `9e1921a4` |
| `N3GET64W_v1.64_rev0.4.bin` | N3GET64W | bios-1.64 = bios-1.65 | `5f04c16c` |
| `N3GET66W_v1.66_rev0.4.bin` | N3GET66W | Z13-0.4-1.66-BIOS.bin **最新** | `f040d644` |

## 三、EC SPI (U8505) — `firmware/ec_spi/`

共 **13 个文件** (12个来自刷机包 + 1个用户自己机器):

### 工程版

| 整理后文件名 | EC ID | 原始来源 | SHA256 前缀 |
|-------------|-------|----------|-------------|
| `EC0.26_eng_rev0.2_machine1.bin` | (EC 0.26) | 1-bios-0.T3-ec-0.26-rev-0.2 | `be75a9c8` |
| `EC0.26_eng_rev0.2_machine2.bin` | (EC 0.26) | 2-bios-0.T3-ec-0.26-rev-0.2 | `fc68437f` |
| `EC0.08_eng_rev0.3.bin` | (EC 0.08) | 3-bios-0.05-ec-0.08-rev-0.3 | `e13a4725` |
| `EC0.07_eng_rev0.3.bin` | (EC 0.07) | 4-bios-0.05-ec-0.07-rev-0.3 = nm 不开机 | `f844e8dc` |
| `EC_eng_rev0.4_25q256j_bk.bin` | (未知) | 3-bios-ec-rev.0.4/U8505 25Q256J BK | `1bbd653c` |
| `EC0.11_eng_rev0.2.bin` | (EC 0.11) | ec-0.11-rev-0.2 (=4-bios-0.09/=7-bios=1.02) | `69a3a57d` |
| `EC0.11_eng_rev0.4.bin` | (EC 0.11) | 5-bios-0.09-ec-0.11-rev-0.4 | `f35f330a` |
| `EC0.01_eng_rev0.4.bin` | (EC 0.01) | 6-bios-0.1-ec-0.01-rev-0.4 = 3..bak | `7b96ea46` |
| `N3GHT12W_EC0.12_eng_rev0.3.bin` | N3GHT12W | 5-bios-0.1-ec-0.12-rev-0.3 | `a08d4dfd` |
| `EC_eng_rev0.4_recovery.bin` | (未知) | rec-0.4/U8505 | `f5fce895` |

### 正式版

| 整理后文件名 | EC ID | 原始来源 | SHA256 前缀 |
|-------------|-------|----------|-------------|
| `N3GHT15W_z13_own_20260313.bin` | N3GHT15W | **用户Z13 EC SPI dump** | `9b4a58ca` |
| `N3GHT25W_v1.02.bin` | N3GHT25W | bios-1.02/U8505 | `0884b9cc` |
| `N3GHT64W_v1.64.bin` | N3GHT64W | bios-1.64 = 1.65 (3份相同) | `38cf2206` |

## 四、独立 EC 固件 — `firmware/ec/`

| 文件 | 大小 | EC ID | 说明 |
|------|------|-------|------|
| `N3GHT64W_v1.64_standalone.bin` | 320KB | N3GHT64W | 刷机包中提取的纯EC镜像 |
| `N3GHT68W.FL2` | 320KB | N3GHT68W | Lenovo 官方 EC 更新文件 |
| `N3GHT69W.FL2` | 320KB | N3GHT69W | Lenovo 官方 EC 更新文件 (最新) |

## 五、原始目录重复分析

以下目录对包含**完全相同**的文件 (仅命名差异 `rev-0.x` vs `rev.0.x`):

- `1-bios-0.05-ec-0.11-rev-0.3` == `1-bios-0.05-ec-0.11-rev.0.3`
- `4-bios-0.05-ec-0.07-rev-0.3` == `4-bios-0.05-ec-0.07-rev.0.3`
- `4-bios-0.09-ec-0.11-rev-0.3` == `4-bios-0.09-ec-0.11-rev.0.3`
- `5-bios-0.09-ec-0.11-rev-0.4` == `5-bios-0.09-ec-0.11-rev.0.4`
- `6-bios-0.1-ec-0.01-rev-0.4` == `6-bios-0.1-ec-0.01-rev.0.4`
- `7-bios=1.02-ec-0.-rec-0.4` == `7-bios=1.02-ec-0.-rec.0.4`

> 共 6 对重复目录。可安全删除 `.0.x` 后缀的那批（它们是 `-0.x` 的副本）。

## 六、跨目录相同文件 (原始数据中的重复)

部分文件虽在不同名称目录中，内容完全相同:

- **U2101** `9148c3dc`: `6-bios-0.1-ec-0.01-rev-0.4/U2101.bin` = `3-bios-ec-rev.0.4/u2101-bak.bin`
- **U8505** `69a3a57d`: `ec-0.11-rev-0.2/u8505.bin` = `4-bios-0.09-ec-0.11-*/u8505.bin` = `7-bios=1.02-*/U8505.bin` (5份)
- **U8505** `f844e8dc`: `4-bios-0.05-ec-0.07-*/U8505.bin` = `nm-e161-0.3-不开机/u8505.bin`
- **U8505** `38cf2206`: `bios-1.64-*/U8505-TEST-1.64.bin` = `bios-1.64-*/U8505.bin` = `bios-1.65-*/U8505.bin`
- **U2101** `5f04c16c`: `bios-1.64-*/U2101.bin` = `bios-1.65-*/U2101.bin`

## 七、版本时间线

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
    └─ BIOS ?    (N3GET47W)            ← 用户Z13 chinafix 来源
    └─ BIOS 1.64 (N3GET64W) + EC 1.64 (N3GHT64W)  ← 正式版
  └─ BIOS 1.65 (N3GET64W) + EC 1.65 (N3GHT64W)  ← 目录标签不同，内容=1.64
  └─ BIOS 1.66 (N3GET66W)            ← Z13-0.4-1.66-BIOS.bin 最新
```

## 八、特殊/问题文件

| 文件 | 说明 |
|------|------|
| `nm-e161-0.3-不开机/` | 板rev 0.3 不开机的dump (BIOS=05M, EC同07版) |
| `3-bios-ec-rev.0.4/bios 74M25J U2101 工程版不亮机的bk.bin` | 工程版不亮机的备份 |
| `3-bios-ec-rev.0.4/U8505 2..BK.rar` | 压缩的EC备份 (150KB) |
| `U8505-TEST-1.64.bin` | 与正式 U8505.bin 完全相同 |
| `bios-1.65` 目录 | U2101 和 U8505 均与 1.64 目录相同 |
| `N3GET04W` (用户preflash) | 用户自己机器原始BIOS，工程版 |
| `N3GHT15W` (用户EC SPI) | 用户自己机器EC dump |

## 九、统计

- 原始总文件数: ~65 个 (含 StatusRegVal 和 .DS_Store)
- 原始唯一二进制文件: ~28 个
- 原始重复副本: ~22 个
- 整理后文件: **21 BIOS** + **13 EC SPI** + **3 EC FW** + **1 VBIOS** = **38 文件**
- 总磁盘占用 (整理后): ~1.1 GB
- BIOS 独立版本: 21 个 (含用户自己机器)
- EC SPI 独立版本: 13 个 (含用户自己机器)
- EC FW 独立版本: 3 个
- VBIOS: 1 个
