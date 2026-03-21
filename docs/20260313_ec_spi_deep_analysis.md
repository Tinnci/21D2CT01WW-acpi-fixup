# EC SPI 深度分析报告

> 日期：2026-03-13
> 设备：ThinkPad Z13 Gen 1 21D2CT01WW（工程样机）
> 输入样本：`firmware/spi_dump/ec_spi_read_20260313_104036.bin`（32MB），SHA256 `9b4a58ca...`
> 对比参考：`firmware/ec/N3GHT68W.FL2`（327,968B），`firmware/ec/N3GHT69W.FL2`（327,968B）
> 结论状态：分析完成，写入策略待验证

---

## 关键结论

1. **EC dump 是 Nuvoton NPCX EC 的完整 SPI 镜像**，包含引导头、主代码区、后续数据区、3MB 密集代码区，以稀疏填充方式分布在 32MB 芯片中。
2. **工程版（N3GHT15W）与量产版（N3GHT68W/69W）是完全不同的编译版本**：
   - 相同 SRAM 基址（SP = `0x200C7C00`）
   - 代码入口偏移相差 274,239 bytes（`0x4_2F3F`）
   - 整体字节匹配率仅约 6%，不可直接覆盖
3. **3MB 块（`0x1D00000-0x1FFFFFF`）是纯 ARM Thumb-2 代码区**，字节密度 92%，无可读字符串，与 FL2 量产版仅有零散碎片匹配（6.1%）。
4. **不能用量产 FL2 payload 直接覆盖工程版 EC dump**；需要通过 `BootX64.efi` / fwupd EC 路径由 EC 自身完成更新。

---

## 输入与方法

### 输入文件

| 文件 | 大小 | SHA256 前16位 |
|---|---|---|
| `ec_spi_read_20260313_104036.bin` | 32MB / 33,554,432 B | `9b4a58ca8fe71...` |
| `N3GHT68W.FL2` | 327,968 B | `a8355b2a...` |
| `N3GHT69W.FL2` | 327,968 B | `011c3027...` |

### 分析方法

- Python 字节扫描：区域密度统计、头部 magic 搜索、特征串定位
- ARM 向量表解析（Little-endian 32-bit Thumb-2 指针）
- FL2 载荷提取与 dump 交叉搜索（64-byte 精确匹配、偏移推算）
- 多偏移窗口匹配率计算

---

## 结果与证据

### 3.1 EC dump 完整布局地图

| 区域 | 偏移范围 | 大小 | 数据密度 | SHA256前12位 |
|---|---|---|---|---|
| EC容器头/引导参数 | `0x0000000–0x0002500` | 9.2 KB | 11% | `79af52c8d573` |
| 主执行固件（含PD串） | `0x0002500–0x0044400` | 263.8 KB | 86% | `60cbcfa6deca` |
| 稀疏空洞区1 | `0x0044400–0x1C50000` | ~28.1 MB | 0% | — |
| 后续数据区A | `0x1C50000–0x1CB7000` | 412 KB | 79% | `512987befe5f` |
| 稀疏空洞区2 | `0x1CB7000–0x1D00000` | 292 KB | 0% | — |
| **3MB 密集代码区** | `0x1D00000–0x2000000` | **3072 KB** | **92%** | `1aeca4ab5f63` |
| 尾部空洞区 | `0x2000000–0x2000000` | 0（芯片边界） | — | — |

### 3.2 关键偏移汇总

| 偏移 | 内容 | 值 |
|---|---|---|
| `0x001000` | `_EC2` 容器头 | `5f 45 43 02 40 01 05 00` |
| `0x0010C0` | Boot Config magic | `5e 4d 3b 2a 1e ab 04 03` |
| `0x001454` | ARM 向量表（SP）| `0x200C7C00` |
| `0x001458` | ARM 向量表（Reset）| `0x100B3134`（Thumb 入口 `0x100B3133`）|
| `0x001508` | EC 版本串 | `N3GHT15W` |
| `0x0364D3` | PD 固件串1 | `N3GPD04W` |
| `0x039E54` | PD 固件串2 | `N3GPH03W` |
| `0x03D7D5` | PD 固件串3 | `N3GPH53W` |
| `0x1C50000` | 后续数据区A 起始 | `20 f0 bd 70 b5 05 46 10`（ARM Thumb-2 代码） |
| `0x1D00000` | 3MB 密集区起始 | `b0 0b 40 c4 00 0b 10 07`（ARM Thumb-2 代码） |

### 3.3 ARM 向量表对比（工程版 vs 量产版）

| 字段 | dump（N3GHT15W） | FL2_68（N3GHT68W） | 是否相同 |
|---|---|---|---|
| SP（栈指针） | `0x200C7C00` | `0x200C7C00` | **✓ 相同** |
| Reset 入口 | `0x100B3133`（Thumb） | `0x100701F4`（Thumb） | ✗ 差异 `0x42F3F` |

**结论**：两版本 EC 使用相同 Nuvoton NPCX SRAM 内存映射，但代码段偏移相差 274KB，
说明工程版代码体量更大（从更高地址加载）或链接顺序不同。

### 3.4 3MB 块详细分析

| 特征 | 结果 |
|---|---|
| 起始字节 | `b0 0b 40 c4 00 0b 10 07`（ARM Thumb-2 指令序列） |
| 字节密度 | 92%（`2,887,719 / 3,145,728 B`） |
| 可读字符串（前320KB） | 65个，均为短噪声串，无人类可读关键词 |
| 己知头部 magic 命中 | 无（`_EC1/2/3`、`$IFT`、`NFCM` 均未找到） |
| 与 FL2_68 的匹配率 | 仅 6.1%（4096B 窗口），非线性偏移关系 |
| SP 向量 `0x200C7C00` 出现 | **未找到**（无向量表，非独立可引导镜像） |

**推断**：3MB 块是 EC 主代码/数据的"主体"段，直接从代码中间加载（无自身头部），
是 EC SPI 布局中最大的连续有效区。不是 FL2 的直接副本，而是工程版特有的编译产物。

### 3.5 FL2 EC2 载荷 vs dump 对比

| 对比项 | 结果 |
|---|---|
| EC2 载荷大小 | `323,584 B`（`0x4F000`） |
| 零字节比例 | 13.6%（非全零） |
| 前640字节特征串在 dump 中 | 零散匹配（假阳性，实为零字节重叠） |
| 非零特征串32B在 dump 中 | **未找到**（量产 EC2 载荷与 dump 代码内容不重叠） |

---

## 风险与限制

1. **工程版 EC 无法用量产 FL2 直接 SPI 覆盖**：
   - Reset 地址不同（代码段偏移差异）
   - 如果 EC 起动时做签名验证（`0x0080–0x00BF` 64B 签名区），量产签名可能被工程版 Bootloader 拒绝
2. **3MB 块用途不明确**：可能是代码、数据、或两个映像的交叉区（需 Ghidra 反汇编确认）
3. **稀疏写入策略必须保留**：空洞区不能用 `00`/`FF` 以外的数据覆盖，否则可能破坏 EC 启动流程
4. **CH341A 直接写 EC SPI 风险极高**：EC 控制电源开关，写坏后机器完全无法开机

---

## 下一步

- [ ] 通过 `BootX64.efi` 路径测试 EC 更新（已尝试 fwupd，待重启验证）
- [ ] 重启后验证：若 EC 0.1.67 成功刷入，再读取 dump 做前后差异分析
- [ ] Ghidra 逆向 3MB 块：加载基址 `0x100B3133`（工程版 Reset 入口前置），ARM Cortex-M4，Thumb-2
- [ ] 研究 `BootX64.efi` 的 `Skip ECFW image check` 参数，是否能绕过签名验证
- [ ] PD 控制器独立更新路径：`dfu-util -d 04d8:0039` 写入从 FL2 提取的 `N3GPD04W` blob

---

## 可复现命令

```bash
# 生成完整布局地图
python3 - << 'PY'
import struct, hashlib
from pathlib import Path
dump = Path('firmware/spi_dump/ec_spi_read_20260313_104036.bin').read_bytes()
fl2  = Path('firmware/ec/N3GHT68W.FL2').read_bytes()
# SP
print("dump SP:  0x%08X" % struct.unpack_from('<I', dump, 0x001454)[0])
print("FL2 SP:   0x%08X" % struct.unpack_from('<I', fl2, 0x120)[0])
# Reset
print("dump Rst: 0x%08X" % struct.unpack_from('<I', dump, 0x001458)[0])
print("FL2 Rst:  0x%08X" % struct.unpack_from('<I', fl2, 0x124)[0])
PY

# 3MB 块字节密度
python3 -c "
data = open('firmware/spi_dump/ec_spi_read_20260313_104036.bin','rb').read()[0x1D00000:0x2000000]
other = sum(1 for b in data if b not in (0,255))
print(f'3MB 块数据密度: {other/len(data)*100:.1f}%')
"

# FL2 EC1 向量表
python3 -c "
import struct
fl2 = open('firmware/ec/N3GHT68W.FL2','rb').read()
sp, rst = struct.unpack_from('<II', fl2, 0x120)
print(f'FL2_68 SP=0x{sp:08X}  Reset=0x{rst:08X}')
"
```
