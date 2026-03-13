# EC SPI 实读分析报告 (2026-03-13)

> 目标文件: `firmware/spi_dump/ec_spi_read_20260313_104036.bin`
> 采集方式: `python3 -m spiflash read ... --chip W25Q256JW --target ec_spi`
> 读取结果: 双读一致，校验通过

## 1. 关键结论

1. 本次读取样本呈现明显 EC 固件结构特征，不是此前主 SPI 备份的重复数据。
2. 在 SPI 偏移 `0x001000` 发现 Insyde `_EC2` 头部，且字段显示:
   - `Total = 0x00050140`
   - `Data  = 0x00050000`
3. 在 SPI 偏移 `0x0010C0` 发现引导配置块 magic:
   - `5e 4d 3b 2a 1e ab 04 03`
4. 在 SPI 偏移 `0x001508` 发现版本字符串 `N3GHT15W`。
5. 发现工程版 PD 版本串:
   - `N3GPD04W` @ `0x0364D3`
   - `N3GPH03W` @ `0x039E54`
   - `N3GPH53W` @ `0x03D7D5`
6. N3GHT68W/N3GHT69W 两个正式版 FL2 payload 均未直接匹配到当前 dump。

## 2. 采集文件信息

- 文件: `firmware/spi_dump/ec_spi_read_20260313_104036.bin`
- 大小: `33,554,432` bytes (`32MB`, `256Mbit`)
- SHA256: `9b4a58ca8fe7152bffa067ebfabf859e0723f4ac91a7485cdddbb1fbbacc170e`

空间分布:

- `0xFF`: `3,286,008` bytes (`9.8%`)
- `0x00`: `26,810,312` bytes (`79.9%`)
- 非 0/FF 数据: `3,458,112` bytes (`10.3%`)

这说明芯片容量较大，但有效固件主要集中在局部区域，其他区域为擦除态或空洞。

## 3. 结构定位

来自 `python3 -m spiflash analyze` 与 `scripts/analyze_ec_spi_dump.py` 的一致结果:

- ARM 向量表命中: `SPI[0x001454]`
  - `SP = 0x200C7C00`
  - `Reset = 0x100B3134`
- Boot Config 命中: `SPI[0x0010C0]`
- `_EC2` 头部命中: `SPI[0x001000]`

映射推断:

- 当前镜像前部存在引导/封装区，固件并非从 `SPI[0x0]` 直接起始。
- 写入策略不能简单使用 `FL2[0x120:]` 直接覆盖全片。
- 至少应保留 `SPI[0x0:0x1454]` 头部区域，再进行后续写入映射设计。

## 4. 与主 SPI 历史样本对比

对比对象:

- `build/fresh_backup_preflash_20260310.bin`
- `build/bricked_state_20260312.bin`

结果:

- 新样本与上述两者字节差异约 `87.6%~88.3%`。
- 在历史主 SPI 备份中未找到以下关键串:
  - `N3GHT15W`
  - `N3GPD04W`
  - `N3GPH03W`
  - `N3GPH53W`
  - `_EC2`

结论: 本次样本与此前主 SPI 备份显著不同，具备独立 EC 固件映像特征。

## 5. 与正式版 FL2 的差异

已知正式版:

- `N3GHT68W.FL2`
- `N3GHT69W.FL2`

当前样本特征:

- EC 版本: `N3GHT15W`（工程版）
- PD 字符串: `N3GPD04W/N3GPH03W/N3GPH53W`

结论:

- 工程版与正式版之间存在明显代际差异。
- 正式版 FL2 payload 不可直接视为当前镜像的 1:1 覆盖体。

## 6. 操作建议 (下一步)

1. 再读取一次并交叉验证
   - 可尝试 `--chip W25R256JW` 再读一份
   - 核对 SHA256 与关键偏移 (`0x1000/0x10C0/0x1454/0x1508`) 是否一致
2. 从当前 dump 提取 EC 有效区块做独立归档
   - 至少保留 `0x000000-0x0511FF` 区域
3. 写入前策略
   - 禁止全片盲写
   - 先建立“保留头部 + 替换有效 payload”的拼接模板
4. 电压安全
   - 继续坚持 1.8V 适配板，避免 3.3V 长时间读写

## 7. 新增基线对比（2026-03-13 会话补充）

新增对比对象:

- `firmware/spi_dump/bios_dump_20260306_104957.bin`
- `firmware/spi_dump/ec_spi_read_20260313_104036.bin`

对比结果:

- 两者均为 `32MB`，但 SHA256 完全不同
- 字节差异约 `29,644,510` bytes（`88.35%`）
- 差异段数量约 `304,350` 段（高度碎片化）

结论:

- `ec_spi_read_20260313_104036.bin` 不是“主 BIOS dump 的轻微改动版”，而是不同映射/内容布局样本。
- 结合 `_EC2`、Boot Config、向量表与版本串证据，可继续将其视为 EC 相关镜像样本。

## 8. 风险与后续任务

1. 目前已通过 fwupd 本地重定向 CAB 进入待重启队列：
   - System Firmware `0.1.76`
   - Embedded Controller `0.1.67`
2. 在重启并完成固件阶段应用前，避免再做新的写入动作，以免交叉影响验证结果。
3. 重启后建议立即采集：
   - `fwupdmgr get-history`
   - `fwupdmgr get-devices`
   - 必要时再次读取 SPI/EC dump，做“升级前后”二次差异分析。

## 9. 可复现命令

```bash
# 主分析
python3 -m spiflash analyze firmware/spi_dump/ec_spi_read_20260313_104036.bin

# 深度分析脚本
python3 scripts/analyze_ec_spi_dump.py firmware/spi_dump/ec_spi_read_20260313_104036.bin firmware/ec

# FL2 对比基线
python3 -m spiflash fl2 firmware/ec/N3GHT68W.FL2 firmware/ec/N3GHT69W.FL2

# 新增：与 3/6 样本做整体差异统计
python3 - << 'PY'
from pathlib import Path
import hashlib

a = Path('firmware/spi_dump/bios_dump_20260306_104957.bin').read_bytes()
b = Path('firmware/spi_dump/ec_spi_read_20260313_104036.bin').read_bytes()
print('sha256 A=', hashlib.sha256(a).hexdigest())
print('sha256 B=', hashlib.sha256(b).hexdigest())
print('changed=', sum(x != y for x, y in zip(a, b)))
PY
```
