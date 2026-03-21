# SPI Flash Recovery Log — CH341A External Programming

## 事件背景

ThinkPad 21D2CT01WW 在通过 Linux 内部 flashrom 刷入修改后的 SPI 固件后变砖。
原因：EC 干扰或 flashrom 内部写入中断，导致 SPI 内容处于不一致状态。

## 硬件信息

| 项目 | 详情 |
|------|------|
| SPI 芯片 | Winbond W25Q256JW (32768 kB / 32 MB) |
| 编程器 | CH341A (USB VID:0x1a86, PID:0x5512) |
| 连接方式 | SOIC-8 SOP 测试夹 |
| 恢复主机 | macOS (Darwin 24.4.0, x86_64) |

## 恢复操作流程 (2026-03-12)

### 1. 环境准备

```bash
# 安装 flashrom
brew install flashrom

# 验证 CH341A 连接
system_profiler SPUSBDataType | grep -A 5 "1a86"
# → USB UART-LPT, Product ID: 0x5512, Vendor ID: 0x1a86
```

### 2. macOS USB 权限处理

- flashrom 需要 `sudo` 权限控制 USB 设备
- macOS USB 串口驱动可能抢占 CH341A → 重新插拔 CH341A 解决
- libusb 警告 `no capture entitlements` 是信息性的，不影响操作

### 3. 探测芯片

```bash
sudo flashrom -p ch341a_spi -c W25Q256JW
# → Found Winbond flash chip "W25Q256JW" (32768 kB, SPI) on ch341a_spi.
```

### 4. 读取砖后状态（备份）

```bash
sudo flashrom -p ch341a_spi -c W25Q256JW -r build/bricked_state_20260312.bin
```

进行了两次读取验证，SHA256 完全一致，确认连接可靠：
- `379d451b8ca94af38b3d271b7c39069f1b6ba1e0f1adc1c3e39dbbf2546ae699`

### 5. 写入原始备份恢复

```bash
sudo flashrom -p ch341a_spi -c W25Q256JW -w build/fresh_backup_preflash_20260310.bin
# → Erase/write done from 0 to 1ffffff
# → Verifying flash... VERIFIED.
```

### 6. 结果

笔记本成功开机并进入系统。

## 固件文件 SHA256

| 文件 | SHA256 | 说明 |
|------|--------|------|
| `fresh_backup_preflash_20260310.bin` | `9bd9bcb1f8450efdfda380f272ea59129e25095cbe3441d8c91c66f5ebb4a151` | 原始未修改备份 ✓ |
| `bricked_state_20260312.bin` | `379d451b8ca94af38b3d271b7c39069f1b6ba1e0f1adc1c3e39dbbf2546ae699` | 砖后状态 |
| `spi_usb4_patched_20260310_144703.bin` | `ef00e791c7fc7b44769d3893d10179169c505925482ff6198326f5c315b09066` | USB4 补丁 (导致变砖) |
| `spi_primary_only_patch_20260310_193315.bin` | `576fd1ec0e15f094b26202dedc26176065acb08ec0bf65cc24accdec46c883a0` | Primary-only 补丁 |

## ⚠️ 电压警告

**此次操作使用的 CH341A 输出 3.3V，但 W25Q256JW 工作电压为 1.8V！**

| 项目 | 电压 |
|------|------|
| CH341A 默认输出 | 3.3V |
| W25Q256JW 额定工作电压 | 1.65V ~ 1.95V (典型 1.8V) |
| 实际过压 | ~1.5V (83% 过压) |

**风险：**
- 1.8V SPI 芯片被 3.3V 驱动可能导致芯片损坏或寿命缩短
- 读取数据可能存在不可靠性（虽然本次两次读取 hash 一致）
- 写入过程中高电压可能导致编程质量下降

**正确做法（今后操作）：**
- 使用 1.8V 电平转换适配器（CH341A 1.8V adapter board）
- 或使用原生支持 1.8V 的编程器（如带电压选择的 CH341A 改版）
- 某些 CH341A 板载 1.8V/3.3V 跳线切换，检查你的板子是否有此选项

本次操作虽然成功恢复，但属于**冒险操作**，不建议重复。

## 经验教训

1. **不要通过内部 flashrom 直接刷写笔记本 SPI** — EC 会干扰，极易变砖
2. **外部编程器 (CH341A) 是最可靠的恢复方式** — 绕过 EC，直接操作 SPI
3. **刷写前永远备份** — `fresh_backup_preflash` 是救命稻草
4. **读取两次验证一致性** — 确保 SOP 夹子连接稳定再进行写入
5. **macOS 上 flashrom 需要 sudo + 可能需要重新插拔 CH341A** — USB 驱动冲突的标准处理方式
6. **W25Q256JW 需要 `-c` 指定芯片** — 否则 flashrom 因多个匹配定义而拒绝操作
7. **CH341A 默认 3.3V 不适合 1.8V SPI 芯片** — 应使用 1.8V 电平转换器，本次属于冒险操作
