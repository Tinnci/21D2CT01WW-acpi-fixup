========================================================================
ThinkPad Z13 Gen 1 (21D2CT01WW) — EC Only Firmware Update USB
========================================================================
构建日期: 2026-03-13
目标固件: N3GHT69W (EC v6.9)  — 最新量产版 EC
配套BIOS: N3GET76W (v7.6)
来源 ISO: n3gur27w.iso (SHA256 已验证)

!! 重要: 此 USB 仅刷新 EC 固件，主 SPI (BIOS) 不会被触碰 !!
!! FL1 (BIOS 镜像) 已被故意排除在 Flash 目录之外            !!

------------------------------------------------------------------------
目录结构
------------------------------------------------------------------------

/EFI/Boot/BootX64.efi            ← UEFI 启动入口 (= NoDCCheck 版本)
                                   无需 AC 适配器 / 电池电量检查

/Flash/BootX64.efi               ← 原版更新工具 (需要 AC 电源)
/Flash/NoDCCheck_BootX64.efi     ← 无 DC 检查版本 (推荐手动使用)
/Flash/SHELLFLASH.EFI            ← EFI Shell 辅助启动器
/Flash/N3GET76W/$0AN3G00.FL2     ← EC 固件 N3GHT69W v6.9 (320KB)
                                   !! $0AN3G00.FL1 故意缺失 !!

/startup.nsh                     ← EFI Shell 自动运行脚本
/Tools/ldiag.EFI                 ← Lenovo 硬件诊断工具
/Tools/LBGRW.efi                 ← BIOS 通用 R/W (DMI)
/Tools/LvarEfi64V231.efi         ← Lenovo UEFI 变量编辑器
/Tools/MBD3.efi                  ← Machine Board Data 读写

------------------------------------------------------------------------
使用方法 A: 直接 UEFI 启动 (最简单，推荐首次尝试)
------------------------------------------------------------------------

1. 确保 ThinkPad 接上 AC 电源 (保险起见)
2. 从此 USB 启动 (F12 → 选择 USB 设备)
3. NoDCCheck_BootX64.efi 自动启动
4. 工具会自动扫描 Flash/N3GET76W/ 目录
5. 找到 $0AN3G00.FL2，执行 EC 更新
6. 完成后自动重启

注意: 如果出现 "BIOS is not compatible" 或签名错误，
      请尝试方法 B (EFI Shell 手动参数)。

------------------------------------------------------------------------
使用方法 B: EFI Shell 手动执行 (可控参数，推荐)
------------------------------------------------------------------------

1. 从 USB 启动后，如果进入 EFI Shell，执行:

   Shell> fs0:
   Shell> cd Flash
   Shell> NoDCCheck_BootX64.efi "ECFW Update" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"

   或者直接运行 startup.nsh:
   Shell> fs0:\startup.nsh

2. 观察输出:
   - "ECFW Update" 表示仅 EC 更新模式
   - "Skip ECFW image check" 跳过签名验证
   - "Verifying..." → "Flashing..." → "BIOS is updated successfully"
   - 机器自动重启

------------------------------------------------------------------------
使用方法 C: 如果方法 A/B 均报签名错误
------------------------------------------------------------------------

这说明工程版 BIOS (N3GET04WE) 拒绝量产版 EC 签名。

此时唯一可行路径是 CH341A 物理编程器直接写入 EC SPI (U8505):
  - 参考: docs/ec_spi_operation_guide.md
  - 备份文件: firmware/spi_dump/ec_spi_read_20260313_104036.bin
  - 写入镜像: 需要构建 [原始头部][FL2 payload] 拼接镜像

------------------------------------------------------------------------
关键固件版本信息
------------------------------------------------------------------------

当前机器状态 (写入前):
  BIOS:  N3GET04WE (工程版 v0.04f)
  EC:    N3GHT15W  (工程版 v0.15)
  PD:    N3GPD04W / N3GPH03W / N3GPH53W (工程版 PD 固件)

更新目标:
  EC:    N3GHT69W  (量产版 v6.9)  ← 此 USB 将刷入此版本
  PD:    N3GPD17W / N3GPH20W / N3GPH70W (量产版, 内嵌于 FL2)
  BIOS:  N3GET04WE ← 不变 (FL1 未包含)

预期效果 (如果成功):
  - /sys/class/typec/ 出现 USB-C Type-C 端口管理
  - USB PD 控制器 (04d8:0039) 接收生产 PD 固件
  - USB3 SuperSpeed / DP Alt Mode 可能恢复

------------------------------------------------------------------------
芯片物理位置参考
------------------------------------------------------------------------

U2101 (主 SPI, W25Q256JWEIQ, 32MB) — 主板正面  ← 此次不操作
U8505 (EC SPI,  W74M25JWZEIQ)      — 主板背面  ← FL2 写入目标

两颗芯片完全独立，分属不同总线:
  U2101: AMD SoC SPI 总线 → BIOS/PSP/UEFI
  U8505: EC 独立 SPI 总线 → EC 固件 + PD blob

------------------------------------------------------------------------
校验和
------------------------------------------------------------------------

$0AN3G00.FL2  SHA256: 011c3027195b7f640df3c9b5b72cf95e3dc09ef8c04413c4417f29c6347b03de
  内嵌版本串: N3GHT69W / N3GPD17W / N3GPH20W / N3GPH70W

EFI/Boot/BootX64.efi (= NoDCCheck):
              SHA256: 14b44c53e093cf322d0c263c52fe2ac9fbbb281e658a110e865362ae5ac91416

Flash/BootX64.efi (原版含 DC 检查):
              SHA256: 8ff68780369e69a6e00e9a77a03a864b010f564852a0641e2e53315af63465e7

------------------------------------------------------------------------
参考文档 (在项目 repo 中)
------------------------------------------------------------------------

docs/ec_fl2_analysis.md          — FL2 结构逆向分析
docs/ec_spi_operation_guide.md   — EC SPI CH341A 操作清单
docs/ec_spi_read_20260313_analysis.md — 实读样本分析
docs/usb4_analysis.md §19-§20    — FL1/FL2 架构 + BootX64.efi 逆向

========================================================================
