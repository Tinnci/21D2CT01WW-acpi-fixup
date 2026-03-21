# NoDCCheck_BootX64.efi 逆向分析（第2轮）

> 日期: 2026-03-13
> 目标文件: `/Volumes/UNTITLED/Flash/NoDCCheck_BootX64.efi`
> 对照文件: `/Volumes/UNTITLED/Flash/BootX64.efi`

## 1. 文件与结构确认

- `NoDCCheck_BootX64.efi` SHA256:
  - `14b44c53e093cf322d0c263c52fe2ac9fbbb281e658a110e865362ae5ac91416`
- 原版 `BootX64.efi` SHA256:
  - `8ff68780369e69a6e00e9a77a03a864b010f564852a0641e2e53315af63465e7`
- PE 头部确认:
  - `PE32+` (`EFI application`)
  - `EntryPoint RVA = 0x001A5980`
  - 主要段:
    - `.text` size `0x00205A1A`
    - `.xdata` size `0x000018B8`
    - `.reloc` size `0x00000FEC`

## 2. 两层参数系统证据（已确认）

在 `NoDCCheck_BootX64.efi` 字符串表中出现:

### 2.1 FlashCommand 语义层（长句命令）

- `FlashCommand`
- `filename`
- `EC Update`
- `BIOS Update`
- `ECFW Update`
- `Skip Battery check`
- `Skip ECFW image check`
- `Skip AC Adapter check`

### 2.2 CLI 帮助层（描述字符串）

- `Show command list.`
- `Show command list includes hidden commands.`
- `Specify the OEM command line.`
- `Output a verify.bin before flash.`
- `Skip flash options in BIOS FlashCommand.`
- `Skip part number checking.`
- `Enable flash verification.`
- `Enable Microsoft Bit-locker check.`
- `Specify admin's password.`

结论: 该工具确实同时存在“FlashCommand命令层 + CLI开关层”两套解析语义。

## 3. 内部短 token 证据（已确认）

字符串表中出现:

- `.bios`
- `.ecfw`
- `.sbat`
- `.fbc`
- `.sac`
- `.reboot`
- `.forcebackup`
- `.pwc`
- `.sbl`
- `.bkup`

这与此前推断一致，说明存在 dot-token 内部命令体系。

## 4. 关键脚本证据（实操链路）

U 盘脚本 `/Volumes/UNTITLED/startup.nsh` 直接调用:

```nsh
fsX:\Flash\NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
```

这说明当前介质上的实际策略是“直接喂长句参数”，而非只用 `/x` 短开关。

## 5. 兼容检查层证据（拦截点）

字符串表显示:

- `BIOS part numbers do not match`
- `Failed to get partnumber from ROM BCP!`
- `Failed to get partnumber from image BCP!`
- `This BIOS image can not flash to this system.`
- `OEM check failed from BIOS service`
- `ModelPartNumber`

结论: 你的失败点仍在“机型/Part Number/OEM”兼容检查链，尚未进入稳定写入阶段。

## 6. 未完全锁定项（当前阻塞）

仍未直接提取到“Skip part number checking”对应的**真实短 argv key**（如 `/xxx`），原因:

1. 二进制中大量用 `/%s` 模板拼接，开关名可能由表索引间接构造。
2. 明文帮助描述存在，但开关键值未直接以完整字符串常量暴露。
3. 现有 CLI 片段更倾向“描述文本 + 动态格式化”。

## 7. 实测结果 (2026-03-13)

**已执行, 结果: Part Number 不匹配, 跳过参数未生效。**

命令:
```nsh
NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
```

工具报告机型不兼容, 拒绝执行 EC 更新。`"Skip part number checking"` 未能绕过检查。

可能原因:
1. 长句 FlashCommand 参数与 CLI dot-token 之间的映射方式不正确
2. OEM 兼容检查在参数处理之前执行 (硬编码)
3. 工程 BIOS 的 BCP NVRAM 区域可能不存在或格式不符

## 8. 下一步建议（第3轮）

1. 动态参数探测（EFI Shell）
   - 在不刷写条件下执行 help/usage 路径，枚举隐藏命令输出。
   - 记录每次失败码和输出文本，建立“开关->错误变化”映射。
2. 静态索引回溯
   - 对 `/%s` 输出点做交叉引用，定位格式化参数来源表。
   - 目标是找到“描述字符串索引 -> 真实短键名”映射。
3. 保留双轨方案
   - A: 长句参数链（当前已知可调用）
   - B: dot-token + OEM command line 包装（待锁定包装开关）

## 8. 可复现命令

```bash
# 头部与段信息
objdump -x /Volumes/UNTITLED/Flash/NoDCCheck_BootX64.efi | sed -n '1,170p'

# 关键字符串抓取
strings /Volumes/UNTITLED/Flash/NoDCCheck_BootX64.efi | rg -n "FlashCommand|ECFW Update|Skip part number checking|Specify the OEM command line|ModelPartNumber|\.ecfw|\.sbat|\.sac"

# 帮助描述窗口
strings /Volumes/UNTITLED/Flash/NoDCCheck_BootX64.efi | nl -ba | sed -n '9800,9925p'

# token 窗口
strings /Volumes/UNTITLED/Flash/NoDCCheck_BootX64.efi | nl -ba | sed -n '9780,9800p'
```
