# EC SPI ↔ FL2 映射关系与版本对比 — ThinkPad Z13 Gen 1

> 日期: 2026-03-13
> 基于: CH341A 读取的 `ec_spi_read_20260313_104036.bin` + 量产 FL2 (N3GHT68W/69W)

---

## 1. 三个 EC 版本总览

| 属性 | 工程版 (当前机器) | 量产 v6.8 | 量产 v6.9 |
|------|-------------------|-----------|-----------|
| **EC 版本** | N3GHT15W (v0.15) | N3GHT68W | N3GHT69W |
| **配套 BIOS** | N3GET04WE (v0.04f) | N3GET74W (v7.4) | N3GET76W (v7.6) |
| **来源** | 出厂工程 SPI dump | n3gur25w.iso | n3gur27w.iso |
| **FL2 大小** | — | 327,968 B | 327,968 B |
| **_EC2 Total** | `0x50140` | `0x4F140` | `0x4F140` |
| **_EC2 Data** | `0x50000` (320KB) | `0x4F000` (316KB) | `0x4F000` (316KB) |
| **SP (栈顶)** | `0x200C8000` | `0x200C7C00` | `0x200C7C00` |
| **Reset 入口** | `0x100701F5` | `0x100701F5` | `0x100701F5` |
| **签名 (64B)** | `3669e21d...` | (不同) | `9b97b851...` |
| **PD 固件** | D04W/H03W/H53W | D17W/H20W/H70W | D17W/H20W/H70W |

关键发现:
- **Reset 向量完全相同** — 三版本共享启动框架
- SP 差 1KB (工程版 SRAM 稍大)
- 工程版 EC payload 比量产版多 4KB
- **签名互不相同** — 工程版与量产版使用不同密钥
- 两个量产版之间 76% 字节不同 (完全重编译)

---

## 2. 核心映射公式

```
SPI[address] = FL2[address - 0x0FE0]      (address >= 0x1000)
```

FL2 的 `_EC2` 头在 offset `0x0020`, SPI 上 `_EC2` 头在 `0x1000`, 差值 = `0x0FE0`。

SPI 前 4KB (`0x0000-0x0FFF`) 是 NPCX 引导元数据，FL2 不包含。

---

## 3. 可视化布局

```
FL2 文件 (328KB)                          SPI 芯片 (32MB)
════════════════                          ═══════════════
[0x0000] ┌──────────────────┐
         │ _EC1 头部 (32B)   │ ─ × ──→ 不存在于 SPI
[0x0020] ├──────────────────┤             ┌──────────────────┐ [0x0000]
         │                  │             │ NPCX 引导元数据    │
         │  (FL2 不含此区域)  │             │ 00 10 00 00 ...  │
         │                  │             │ (4KB, 0xFF 填充)  │
         │                  │             └──────────────────┘ [0x0FFF]
         │ _EC2 头部 (32B)   │ ═══════════→ _EC2 头部          [0x1000]
[0x0040] │ 零填充             │ ═══════════→ 零填充               [0x1020]
[0x0060] │ 0xEC 分隔符        │ ═══════════→ 0xEC 分隔符          [0x1040]
[0x0080] │ ★ 数字签名 (64B) ★ │ ═══════════→ ★ 数字签名 (64B) ★   [0x1060]
[0x00C0] │ 0xEC 分隔符        │ ═══════════→ 0xEC 分隔符          [0x10A0]
[0x00E0] │ Boot Config (64B) │ ═══════════→ Boot Config         [0x10C0]
[0x0120] │ ARM 向量表         │ ═══════════→ ARM 向量表            [0x1100]
[0x0140] │ EC 代码...         │ ═══════════→ EC 代码...           [0x1120]
[0x0528] │  "N3GHT69W"       │             │  "N3GHT15W"        [0x1508]
         │  ...               │             │  ...
         │  PD: N3GPD17W     │             │  PD: N3GPD04W
         │  PD: N3GPH20W     │             │  PD: N3GPH03W
         │  PD: N3GPH70W     │             │  PD: N3GPH53W
[0x50120]└──────────────────┘             │
                                          │  (余下 0xFF/0x00)
                                          └──────────────────┘ [0x1FFFFFF]
```

---

## 4. 精确偏移映射表

| 结构 | FL2 偏移 | SPI 偏移 | 差值 |
|------|----------|----------|------|
| _EC1 头部 (仅FL2) | `0x0000` | 不存在 | — |
| **_EC2 头部** | `0x0020` | `0x1000` | +0x0FE0 |
| 零填充 | `0x0040` | `0x1020` | +0x0FE0 |
| 0xEC 分隔1 | `0x0060` | `0x1040` | +0x0FE0 |
| **数字签名** | `0x0080` | `0x1060` | +0x0FE0 |
| 0xEC 分隔2 | `0x00C0` | `0x10A0` | +0x0FE0 |
| **Boot Config** | `0x00E0` | `0x10C0` | +0x0FE0 |
| **向量表** | `0x0120` | `0x1100` | +0x0FE0 |
| EC 代码开始 | `0x0140` | `0x1120` | +0x0FE0 |
| **版本字符串** | `0x0528` | `0x1508` | +0x0FE0 |

---

## 5. SPI[0x0000-0x000F] NPCX 引导元数据

```
00 10 00 00 00 00 0C 00 00 00 00 00 00 00 00 00
(其余 4080 字节全为 0xFF)
```

- `00 10 00 00` → 固件加载地址 = `0x1000`
- `00 00 0C 00` → 配置标志或长度

此区域由 NPCX 内置 ROM (mask ROM) 在上电时读取，用于指引 EC 从 SPI Flash 的哪个位置加载固件。**CH341A 写入时必须保留此区域不动。**

---

## 6. Boot Config 差异

| 字段 | SPI (工程) | FL2_68 (量产) | FL2_69 (量产) | 说明 |
|------|-----------|---------------|---------------|------|
| +0x00 | `0x2A3B4D5E` | `0x2A3B4D5E` | `0x2A3B4D5E` | magic (相同) |
| +0x04 | `0x0304AB1E` | `0x0304AB1E` | `0x0304AB1E` | magic (相同) |
| +0x08 | `0x07000002` | `0x07000002` | `0x07000002` | SP/配置 (相同) |
| +0x0C | `0x0701F510` | `0x0701F510` | `0x0701F510` | Reset 入口 (相同) |
| +0x14 | **`0x04FFBF00`** | `0x04EFBF00` | `0x04EFBF00` | 内存边界 — 差 64KB |
| +0x18 | **`0x04FFC000`** | `0x04EFC000` | `0x04EFC000` | 内存边界 — 差 64KB |
| +0x38 | **`0x5D5F65A5`** | `0x0F3FFBD8` | `0x0F3FFBD8` | 校验/时间戳 (不同) |
| +0x3C | **`0x26544012`** | `0xBF5B6F98` | `0x0DA831D3` | 校验/时间戳 (三版本互不同) |

Boot Config 中 `+0x14/+0x18` 的差异反映了工程版 payload 多 4KB (`0xFFBF` vs `0xEFBF`)。

---

## 7. 签名分析

```
工程版 SPI[0x1060]:
  3669e21d 1d3d4dc6 41e95d07 5b484b95
  a6932aff 11c0e7cc 8bb8a515 fdf06604
  ef6a9a88 5dc58db2 0243efc0 ab30ab7c
  664b5273 d59008c0 4f4b3889 caf2b8e1

量产版 FL2[0x0080] (N3GHT69W):
  9b97b851 664dda46 b1035769 175eff6c
  368b6da1 f54c8364 be2da3d9 14ab885c
  de7d9d15 47c2d979 9828d772 7a4d49e1
  8fe44c58 89680ca7 aa75fc76 97f6543b
```

64 字节 = 512 位，可能是 ECDSA P-256 签名 (r||s, 各 32 字节) 或 SHA-512 摘要。

---

## 8. SPI 活跃区域分布

| 起始 | 结束 | 大小 | 用途 |
|------|------|------|------|
| `0x000000` | `0x044FFF` | 276KB | **EC 主固件** (头部+代码+PD) |
| `0x051000` | `0x051FFF` | 4KB | 未知数据岛 |
| `0x263000` | `0x263FFF` | 4KB | 未知数据岛 |
| `0x1BE0000` | `0x1BE0FFF` | 4KB | 未知 (高地址) |
| `0x1C50000` | `0x1CA1FFF` | 328KB | 可能是 EC 备份/NVS 区 |
| `0x1CA5000` | `0x1CB6FFF` | 72KB | 可能是 EC 配置/状态区 |
| `0x1D00000` | `0x1FFFFFF` | 3MB | 可能是 EC 备份镜像或日志 |

32MB 芯片中仅使用 ~3.7MB，其余为擦除态。

---

## 9. BootX64.efi/IHISI 写入流程推断

BootX64.efi 在 EC 更新时的预估写入逻辑:

```
1. 读取 FL2 文件, 验证 _EC1 头部校验和
2. 提取 FL2[0x20:] 即 _EC2 容器 (323904 字节)
3. 通过 SMI → IHISI SMM handler → EC mailbox:
   a) EC 擦除 SPI[0x1000:0x51000] (EC 固件区)
   b) EC 将 _EC2 容器写入 SPI[0x1000:]
   c) EC 验证写入完整性
4. SPI[0x0000:0x0FFF] 的 NPCX 引导区不被触碰
5. SPI 高地址区 (0x51000+) 的 NVS/备份区由 EC 自行管理
```

---

## 10. 工具参考

### SHELLFLASH.EFI (23KB, ISO 中)

**不是**一个刷写工具。它是一个 EFI Shell 引导加载器/引导辅助器，只负责搭建 shell 环境然后调用真正的 BootX64.efi。不能用于直接控制 EC 刷写。

### ShellFlash64.efi (530KB, thinkpadOEM 中)

Phoenix/Insyde TDK 工具, 功能:
- BIOS Capsule 全量刷写 (`UpdateCapsule`, `CapsuleOnRam`)
- DMI/SMBIOS 补丁 (`/patch /dus UUID`, `/patch /dsm SN`, `/patch /dps MTM`, `/patch /dvs PN`)
- SecureFlash 签名验证
- PFAT/BIOS Guard 支持

**关键限制:**
- **无 EC 单独刷写能力** — ShellFlash64 只操作 BIOS ROM (Level 1 Capsule 更新)
- EC 更新只能通过 BootX64.efi → IHISI SMM → EC mailbox 路径
- "Skip part number checking" 功能存在于此工具中, 但针对的是 BIOS Part Number
- **对 Z13 平台: 危险** — 已知工程 BIOS + 量产 BIOS capsule = 变砖

### NoDCCheck_BootX64.efi (2.1MB, 更新 USB 中)

唯一能操作 EC 的工具。支持参数:
```
"ECFW Update"               — 仅更新 EC
"Skip part number checking" — 跳过机型检查
"Skip ECFW image check"     — 跳过签名验证
"Skip Battery check"        — 跳过电池检查
"Skip AC Adapter check"     — 跳过电源检查
```

---

## 11. EC 更新阻塞点与可行路径

### 实测结果 (2026-03-13)

**NoDCCheck_BootX64.efi 已在 EFI Shell 中尝试执行，结果: 失败。**

失败原因: **机型/Part Number 不匹配** — `"Skip part number checking"` 参数未能生效。

可能原因分析:
1. **参数传递方式不正确** — 工具可能使用 dot-token 内部命令体系 (如 `.sac`, `.ecfw`)
   而非 FlashCommand 长句参数。第2轮逆向确认该工具存在两层参数系统:
   - FlashCommand 语义层: `"Skip part number checking"` (长句)
   - CLI dot-token 层: `.ecfw`, `.sac`, `.sbat` 等 (短命令)
   这两层如何交互尚未完全锁定。
2. **OEM check 硬编码** — 工具可能在 FlashCommand 参数处理之前就先进行了
   不可跳过的兼容检查 (`OEM check failed from BIOS service`)。
3. **BCP (BIOS Configuration Parameters) 不存在** — 工程 BIOS 的 NVRAM 中可能
   没有 BCP 变量,导致 `Failed to get partnumber from ROM BCP!`。

### 当前阻塞状态

| 检查 | 状态 | 说明 |
|------|------|------|
| **机型/Part Number** | **❌ 已确认阻塞** | Skip 参数未生效, 工具拒绝继续 |
| EC 签名验证 | ? 未到达 | 被 Part Number 检查拦在前面 |
| 电池/AC | ✅ 已绕过 | NoDCCheck 版本有效 |
| IHISI SMM | ? 未到达 | 被 Part Number 检查拦在前面 |

### 可行路径

| 方案 | 原理 | 状态 |
|------|------|------|
| **A: NoDCCheck + 全跳过** | EFI Shell → SMI → EC mailbox | **❌ 已失败** — Part Number 阻塞 |
| **A2: 探索 dot-token 语法** | 使用 `.ecfw` 等短命令 + OEM 包装 | 待定 — 需要更深 EFI 逆向 |
| **B: CH341A 物理写入 U8505** | 直接编程 EC SPI Flash | 可行 — 已有备份和映射 |

**当前结论: 方案 A (EFI 工具链路) 由于 Part Number 检查阻塞, 最可靠的路径是 CH341A 物理编程 (方案 B)。**

方案 B 写入策略:
- 保留 SPI[0x0000-0x0FFF] NPCX 引导元数据不动
- 写入 FL2[0x0020:] (即 _EC2 容器) 到 SPI[0x1000:]
- 需要 1.8V 电平适配板 (W74M25JWZEIQ 是 1.8V)
