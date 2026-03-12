# EC SPI 操作准备清单 — U8505 (W74M25JWZEIQ)

> 编写日期: 2026-03-13
> 目标: CH341A 外部编程器读取/备份/写入 EC SPI 闪存
> 设备: ThinkPad Z13 Gen 1 (21D2CT01WW)

---

## 1. 硬件总览

| 项目 | EC SPI (目标) | Main SPI (已操作过) |
|------|--------------|-------------------|
| **位号** | U8505 | U2101 |
| **芯片** | W74M25JWZEIQ | W25Q256JWEIQ |
| **制造商** | Winbond | Winbond |
| **封装** | WSON 8mm×6mm | WSON 8mm×6mm |
| **工作电压** | 1.8V (JW 后缀) | 1.8V (JW 后缀) |
| **连接对象** | EC (NPCX997KA0BX) | AMD PSP + EC (共享) |
| **功能** | 存储 EC 固件 (非 NPCX 内部 flash) | BIOS/PSP 固件 |
| **容量** | 未知 — 需探测 JEDEC ID | 32MB (256Mbit) |
| **位置** | 主板背面 | 主板正面 |

### 1.1 NPCX997KA0BX ("K" 后缀 = 无内部 Flash)

- ARM Cortex-M4, 无内部 NOR Flash
- 所有固件存储在外部 SPI (U8505)
- Boot ROM (mask ROM ~64KB) 从 SPI 加载代码到 SRAM (~256-320KB)
- **U8505 是 EC 运行的唯一代码来源**

### 1.2 W74M25JWZEIQ 芯片说明

- flashrom 已知 W74M51NW (64MB, W25R512NW 的别名)
- W74M25JW **不在** flashrom 当前芯片列表中
- 需要用 `flashrom -p ch341a_spi` **自动探测** JEDEC ID
- 如果识别失败，可尝试 force 兼容芯片名

---

## 2. ⚠️ 关键安全事项

### 2.1 电压问题 (最重要！)

```
╔══════════════════════════════════════════════════════════════╗
║  W74M25JWZEIQ 额定电压: 1.65V ~ 1.95V (典型 1.8V)          ║
║  CH341A 默认输出: 3.3V                                      ║
║  过压幅度: ~83%                                              ║
║                                                              ║
║  上次 U2101 操作在 3.3V 下成功但属冒险！                       ║
║  建议: 使用 1.8V 电平转换适配板                               ║
╚══════════════════════════════════════════════════════════════╝
```

**解决方案 (按推荐度排序):**

1. **1.8V 适配板** — CH341A 1.8V adapter board (淘宝/Amazon ~¥15)
   - 插在 CH341A 和 SOP 夹之间
   - 使用目标芯片 VCC 作为参考电压，自动匹配 1.8V

2. **CH341A 硬件改造** — 切断 VCC 供电，外接 1.8V LDO
   - 需要焊接技能
   - 永久性修改

3. **直接 3.3V** — 与上次相同 (不推荐)
   - 上次 U2101 成功但可能缩短芯片寿命
   - EC SPI 更关键 (无法通过软件恢复)

### 2.2 操作前断电

```bash
# 必须执行:
# 1. 关机 (shutdown -h now)
# 2. 断开 AC 电源
# 3. 断开电池排线 (ThinkPad Z13 内置电池)
# 4. 按住电源键 10 秒释放残余电荷
# 5. 等待 30 秒
# 6. 然后连接 CH341A SOP 夹
```

### 2.3 U8505 在主板背面

- 需要翻转主板或使用弯折延长线
- SOP 夹要夹稳，避免接触偏移
- **确认 U8505 位置**: 参考原理图 (Z13G1-schem.png) 和 boardview (Z13G1-bv.png)

---

## 3. 操作步骤

### Phase 1: 探测芯片

```bash
# 最小化探测 — 读取 JEDEC ID
sudo flashrom -p ch341a_spi

# 预期结果之一:
# Found Winbond flash chip "XXXXX" (YYYY kB, SPI) on ch341a_spi.
#
# 如果出现 "Multiple flash chip definitions match":
# 记下所有匹配的芯片名，选择最匹配的使用 -c 指定

# 如果完全无法识别:
sudo flashrom -p ch341a_spi -V 2>&1 | head -50
# 查看 JEDEC ID 行: "RDID returned 0xEF XXYY"
# 0xEF = Winbond 制造商 ID
# 然后根据 XXYY 查 Winbond datasheet 确定具体型号
```

**可能的探测结果:**

| 场景 | JEDEC ID | 对应芯片 | 容量 |
|------|----------|---------|------|
| 识别为 W25Q32JW | 0xEF 8016 | 1.8V 32Mbit | 4MB |
| 识别为 W25Q64JW | 0xEF 8017 | 1.8V 64Mbit | 8MB |
| 识别为 W25Q128JW | 0xEF 8018 | 1.8V 128Mbit | 16MB |
| JEDEC 0xEF 7015 | — | W25Q16JW (1.8V) | 2MB |
| JEDEC 0xEF 6015 | — | W25Q16(V) (3.3V?) | 2MB |
| 未知 ID | 需手动查 | — | — |

### Phase 2: 完整备份 (读取两次验证)

```bash
# 替换 CHIPNAME 为 Phase 1 探测到的芯片名
CHIP="CHIPNAME"
DATE=$(date +%Y%m%d_%H%M%S)

# 第一次读取
sudo flashrom -p ch341a_spi -c "$CHIP" -r "ec_spi_read1_${DATE}.bin"

# 第二次读取
sudo flashrom -p ch341a_spi -c "$CHIP" -r "ec_spi_read2_${DATE}.bin"

# 比较两次读取
sha256sum ec_spi_read1_${DATE}.bin ec_spi_read2_${DATE}.bin

# ⚠️ 两个 SHA256 必须完全一致！
# 不一致 → SOP 夹接触问题，重新夹紧后再试
# 一致 → 连接可靠，可以继续

# 保存为正式备份
cp ec_spi_read1_${DATE}.bin ec_spi_backup_${DATE}.bin
```

### Phase 3: 分析 SPI dump — 确定 FL2 映射

**此步骤极其重要 — 在写入任何东西之前，必须理解 SPI 布局！**

将 SPI dump 拷贝到工作站后运行:

```bash
python3 scripts/analyze_ec_spi_dump.py ec_spi_backup_XXXXXXXX.bin
```

需要确认以下几点:

1. **FL2 payload (0x0120+) 在 SPI 中的偏移位置**
   - 搜索 ARM 向量表: SP=0x200C7C00, Reset=0x100701F5
   - 如果在 SPI 偏移 0 找到: FL2[0x120:] → SPI[0x0:]
   - 如果在非零偏移找到: 有 boot header 前缀

2. **Boot Config Block (FL2 0xE0-0x11F) 是否存在于 SPI**
   - 搜索 magic: `5e 4d 3b 2a 1e ab 04 03`
   - 如果找到: 记录 SPI 中的位置

3. **版本字符串位置**
   - 搜索 `N3GHT15W` (当前 EC 版本)
   - 搜索 `N3GPD17W`, `N3GPH20W`, `N3GPH70W` (PD 固件名)

4. **空白区域分布**
   - 识别 0xFF 填充区域 (未使用空间/擦除块)
   - 确认总容量与有效数据比例

### Phase 4: 写入 (仅在完全理解布局后)

**⚠️ 只有在 Phase 3 明确了映射关系后才执行此步骤 ⚠️**

```bash
# 方案 A: 如果 SPI = FL2 payload (最可能)
# 从 FL2 提取 payload:
python3 -c "
data = open('firmware/ec/N3GHT68W.FL2', 'rb').read()
payload = data[0x120:]  # 320KB payload
open('ec_spi_write_image.bin', 'wb').write(payload)
print(f'Extracted {len(payload)} bytes')
"

# 方案 B: 如果 SPI = boot header + payload
# 需要先从原始 SPI dump 中提取 boot header
# 然后拼接: [original boot header] + [FL2 payload]

# 方案 C: 如果 SPI = 完整 FL2
# 直接使用 FL2 文件
cp firmware/ec/N3GHT68W.FL2 ec_spi_write_image.bin

# 无论哪种方案，写入命令:
sudo flashrom -p ch341a_spi -c "$CHIP" -w ec_spi_write_image.bin
# flashrom 会自动验证: "Verifying flash... VERIFIED."
```

---

## 4. FL2 文件结构参考

```
FL2 文件 (327,968 bytes = 0x50120)
├─ 0x0000-0x001F  _EC1 头部 (magic: _EC\x01, 大小, 校验和)
├─ 0x0020-0x003F  _EC2 头部 (magic: _EC\x02, 大小, 校验和)
├─ 0x0040-0x005F  零填充
├─ 0x0060-0x007F  0xEC 填充 (EC 标记)
├─ 0x0080-0x00BF  签名 (64 字节, 每个版本不同)
├─ 0x00C0-0x00DF  0xEC 填充
├─ 0x00E0-0x00FF  引导配置块 (入口点/加载地址/大小等)
├─ 0x0100-0x0117  零填充
├─ 0x0118-0x011F  校验和 (最后 4 字节: 版本相关)
└─ 0x0120-0x5011F  ★ 固件 Payload (327,680 bytes = 320KB)
    ├─ 0x0120  ARM 向量表 (SP=0x200C7C00, Reset=0x100701F5)
    ├─ 0x0528  版本字符串 ("N3GHT68W" 或 "N3GHT69W")
    ├─ 0x1120  _EC2 数据区域开始 (全零开头)
    ├─ 0x3ABA4 PD 固件 1: N3GPD17W (14977 bytes)
    ├─ 0x3E625 PD 固件 2: N3GPH20W (14977 bytes)
    ├─ 0x42145 PD 固件 3: N3GPH70W (14977 bytes)
    ├─ 0x45B27 PD 固件名索引表
    ├─ 0x49020 FF 填充区 (24KB)
    └─ 0x4F020 数据 + 尾部填充

引导配置块 (0xE0-0x11F): 两个 FL2 版本间完全一致 (仅最后 4 字节不同)
  [E0] 0x2A3B4D5E  <- Magic/Tag
  [EC] 0x0701F510  <- 包含 Reset Entry (0x100701F5)
  [F4] 0x04EFBF00  <- 代码大小 - 1 = 323,519
  [F8] 0x04EFC000  <- 代码大小 = 323,520 (= _EC2 大小 - 64 字节签名)
  [118] CRC32 固定  <- 两版本相同
  [11C] 版本校验和  <- 每版本不同
```

### 4.1 可用 FL2 文件

| 文件 | 版本 | SHA256 | 来源 BIOS |
|------|------|--------|-----------|
| N3GHT68W.FL2 | EC 68W | `a8355b2a...` | N3GET74W (n3gur25w.iso) |
| N3GHT69W.FL2 | EC 69W | `011c3027...` | N3GET76W (n3gur27w.iso) |
| (当前运行) | EC 15W (工程版) | — | 无 FL2, 需从 SPI dump 获取 |

### 4.2 版本兼容性考虑

- 当前系统: N3GHT**15**W (**工程版**, v0.15)
- FL2 文件: N3GHT**68**W / N3GHT**69**W (**正式版**)
- 两者之间差异: 76% 的字节不同 = 完全重新编译
- **风险**: 正式版 EC 可能需要正式版 BIOS 配合
- **安全做法**: 先只读取 + 备份当前 EC SPI，不急于写入

---

## 5. SPI Dump 自动分析脚本

操作时创建此脚本:

```python
#!/usr/bin/env python3
"""分析 EC SPI dump 并与 FL2 比较，确定布局映射。"""

import struct, hashlib, sys, os

def analyze_dump(dump_path, fl2_paths):
    with open(dump_path, 'rb') as f:
        dump = f.read()
    
    print(f"SPI Dump: {dump_path}")
    print(f"  Size: {len(dump)} bytes ({len(dump)//1024}KB)")
    print(f"  SHA256: {hashlib.sha256(dump).hexdigest()}")
    
    # 搜索 ARM 向量表 (SP=0x200C7C00)
    sp_bytes = struct.pack('<I', 0x200C7C00)
    pos = dump.find(sp_bytes)
    while pos >= 0:
        reset = struct.unpack_from('<I', dump, pos + 4)[0]
        if 0x10070000 <= reset <= 0x100FFFFF:
            print(f"\n  ★ ARM Vector Table found at SPI offset 0x{pos:06X}")
            print(f"    SP=0x{struct.unpack_from('<I', dump, pos)[0]:08X}")
            print(f"    Reset=0x{reset:08X}")
            nmi = struct.unpack_from('<I', dump, pos + 8)[0]
            print(f"    NMI=0x{nmi:08X}")
        pos = dump.find(sp_bytes, pos + 1)
    
    # 搜索 boot config magic
    magic = bytes.fromhex('5e4d3b2a1eab0403')
    pos = dump.find(magic)
    if pos >= 0:
        print(f"\n  ★ Boot Config Block found at SPI offset 0x{pos:06X}")
    else:
        print(f"\n  Boot Config Block (5e4d3b2a...) NOT found in dump")
    
    # 搜索版本字符串
    import re
    print(f"\n  Version strings:")
    for m in re.finditer(rb'N3G[A-Z]{2}\d{2}W', dump):
        print(f"    '{m.group().decode()}' at SPI offset 0x{m.start():06X}")
    
    # 与 FL2 payload 比较
    for fl2_path in fl2_paths:
        with open(fl2_path, 'rb') as f:
            fl2 = f.read()
        payload = fl2[0x120:]
        fl2_name = os.path.basename(fl2_path)
        
        # 在 dump 中搜索 payload 的前 64 字节
        needle = payload[:64]
        pos = dump.find(needle)
        if pos >= 0:
            print(f"\n  ★ FL2 payload ({fl2_name}) found at SPI offset 0x{pos:06X}")
            # 比较全部 payload
            end = pos + len(payload)
            if end <= len(dump):
                match = dump[pos:end] == payload
                print(f"    Full match: {match}")
                if not match:
                    diffs = sum(1 for i in range(len(payload))
                               if dump[pos+i] != payload[i])
                    print(f"    Different bytes: {diffs}/{len(payload)}")
        else:
            print(f"\n  FL2 payload ({fl2_name}) NOT found in dump")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <spi_dump.bin> [fl2_dir]")
        sys.exit(1)
    
    fl2_dir = sys.argv[2] if len(sys.argv) > 2 else 'firmware/ec'
    fl2_files = [os.path.join(fl2_dir, f)
                 for f in sorted(os.listdir(fl2_dir)) if f.endswith('.FL2')]
    
    analyze_dump(sys.argv[1], fl2_files)
```

---

## 6. 替代方案: BootX64.efi 内部更新

如果 CH341A 方案因电压问题不可行，可考虑通过 Lenovo 更新程序内部刷写:

```bash
# BootX64.efi 支持的参数:
# "EC Update"          — 启用 EC 更新
# "ECFW Update"        — 启用 EC 固件更新
# "Skip ECFW image check" — 跳过 EC 固件镜像检查 (可能绕过签名验证)
# "Skip Battery check" — 跳过电池检查
# "Skip AC Adapter check" — 跳过电源适配器检查
```

**优势:**
- 无电压问题 (EC 自身的 SPI 控制器操作)
- Insyde 更新程序处理 FL2→SPI 映射
- 不需要拆机

**劣势:**
- 可能签名验证失败 (工程版 BIOS vs 正式版 FL2)
- 需要同时更新 BIOS+EC (FL1+FL2) 保持兼容性
- 如果失败可能导致 EC 变砖 (更难恢复)

---

## 7. 风险评估

| 风险 | 级别 | 缓解措施 |
|------|------|---------|
| 3.3V 过压损坏 EC SPI | **高** | 使用 1.8V 适配板 |
| SOP 夹接触不良导致读取错误 | 中 | 读取两次比较 SHA256 |
| 写入错误 EC 固件导致 EC 变砖 | **高** | 先只备份不写入；写入前确认映射 |
| 正式版 EC 与工程版 BIOS 不兼容 | **高** | 如果写入正式版 EC，同时准备好 BIOS 恢复 |
| EC SPI 位于背面，夹子难以固定 | 中 | 使用排线延长，测试台固定主板 |
| flashrom 不识别 W74M25JW | 低 | 读取 JEDEC ID，强制指定兼容芯片 |

---

## 8. 操作 Checklist

### 准备阶段
- [ ] 获取 1.8V 电平转换适配板 (或确认 CH341A 有 1.8V 模式)
- [ ] 准备好 SOP-8 测试夹 + 连接线
- [ ] 确认 boardview 中 U8505 位置
- [ ] 备份此文档到手机 (操作时参考)

### 读取阶段
- [ ] 关机 → 断 AC → 断电池 → 释放残余电荷
- [ ] 拆机，定位 U8505 (主板背面)
- [ ] 连接 CH341A SOP 夹到 U8505
- [ ] `flashrom -p ch341a_spi` 探测芯片 → 记录型号和容量
- [ ] 读取两次，比较 SHA256
- [ ] 一致后保存正式备份: `ec_spi_backup_YYYYMMDD.bin`
- [ ] 断开 CH341A，重新组装，验证机器正常启动

### 分析阶段 (回到工作站)
- [ ] 运行 `analyze_ec_spi_dump.py` 分析 dump
- [ ] 确认 ARM 向量表在 SPI 中的偏移
- [ ] 确认是否存在 boot header / boot config block
- [ ] 确认版本字符串 (应为 N3GHT15W)
- [ ] 确认 FL2 payload 到 SPI 的精确映射

### 写入阶段 (可选，在完全理解布局后)
- [ ] 根据映射分析结果，准备正确格式的写入镜像
- [ ] 再次拆机，连接 CH341A
- [ ] 读取一次确认与之前备份一致 (验证连接)
- [ ] 写入: `flashrom -p ch341a_spi -c CHIP -w ec_spi_write_image.bin`
- [ ] 等待 "VERIFIED." 输出
- [ ] 断开，组装，测试启动

---

## 9. 参考文件

| 文件 | 说明 |
|------|------|
| [docs/spi_recovery_log.md](docs/spi_recovery_log.md) | 主 SPI 恢复记录 (上次 CH341A 操作经验) |
| [docs/ec_fl2_analysis.md](docs/ec_fl2_analysis.md) | FL2 逆向工程分析 |
| [docs/usb4_analysis.md](docs/usb4_analysis.md) | 完整硬件分析报告 (§28 = EC SPI 架构) |
| [scripts/analyze_fl2_spi_mapping.py](scripts/analyze_fl2_spi_mapping.py) | FL2 结构分析脚本 |
| [scripts/analyze_boot_config.py](scripts/analyze_boot_config.py) | 引导配置块分析脚本 |
| Z13G1-schem.png | 原理图 (U8505 位置) |
| Z13G1-bv.png | Boardview (U8505 物理位置) |
