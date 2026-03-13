# fwupd 本地 CAB 强制安装匹配分析（2026-03-13）

## 目标
在不重启的前提下，验证两个本地 CAB 是否能通过 fwupd/fwupdtool 强制安装到当前机器。

## 环境
- fwupd: 2.0.20
- fwupdtool: 2.0.20
- 设备: LENOVO 21D2CT01WW（工程样机）

## CAB 目标与本机设备匹配

| 包 | CAB 目标 GUID | 本机对应设备 GUID | 结论 |
|---|---|---|---|
| N3GET76W 系统固件 CAB | `ce5cfa7d-0ce2-4974-b866-a367f9e85481` | System Firmware: `66d47c53-a746-4495-a444-e6b26a04906d` | 不匹配 |
| EC 1.67 CAB | `b7787ed5-7008-4da9-8475-b8779d835882` | 未发现同 GUID 设备 | 不匹配 |

> 说明：`fwupdmgr get-details` 对两个 CAB 都显示为“未知设备 / Device was not found”。

## 已执行的尝试（均未触发重启）

1. `fwupdmgr local-install <cab> --force --allow-older --allow-reinstall --no-reboot-check -y`
   - 结果：`No supported devices found`

2. `fwupdtool install <cab> <System Firmware Device-ID> --force --allow-older --allow-reinstall --ignore-requirements --ignore-vid-pid --no-reboot-check`
   - 结果：`device ID ... was not found`

## 结论
- 当前失败根因是**设备匹配链路不成立**（GUID/设备绑定不匹配），不是简单的版本检查或“开关不够强”。
- `--force`、`--allow-older`、`--allow-reinstall` 可放宽运行时限制，但通常**不能绕过固件目标设备标识绑定**。

## 关于 fwupd 的安装机制（简述）
1. 解析 CAB（payload + metainfo + 签名）并验证元数据/载荷可信性。
2. 读取本机可更新设备（插件枚举，如 UEFI Capsule/USB DFU/TPM 等）。
3. 用 GUID/HWID/协议能力做匹配。
4. 匹配成功才进入写入流程（部分设备为离线更新，写入 EFI 变量并等待重启）。
5. 重启后由固件阶段执行真正刷写，回到系统后上报结果。

## 下一步建议
- 做一次只读深挖：导出 ESRT 与 UEFI 变量，确认工程 BIOS 暴露的 Capsule 设备路径是否与 CAB 期望不一致。
- 若仍不匹配，fwupd 路径基本不可行，继续采用你已验证可控的 SPI/分区级方案更现实。

---

## ESRT GUID 来源分析（2026-03-13 深挖结果）

### 问题根因确认

**工程样机 ESRT System Firmware GUID `66d47c53-a746-4495-a444-e6b26a04906d` 是硬编码在 DXE 驱动中的。**

搜索路径：
1. 在 SPI dump 中搜索所有字节编码（EFI LE / Big-Endian / raw / SMBIOS 等） → 无命中
2. 在 ESRT 字符串附近（SPI `0x01028e34`）找到的 GUID 是 `4bea12df`（UEFI Device Firmware），不是 System Firmware
3. 用 `uefiextract` 解析 DXE FV（`0x01b10000`，4.3 MB）→ 生成 2154 行报告
4. 找到模块 `SystemEsrtDxe`（GUID `7E99BC9E-EDE9-48C1-85B9-689432817F8F`）
5. 提取其 PE32 body（7,456 bytes）→ 工程 GUID 在 PE32 偏移 `0x18c8` 处！
6. PE32 在 LZMA 压缩 section 中，解压后在偏移 `0x005733c4` 和 `0x00574e3c` 共 **2 处**出现

### SPI Flash 结构定位

| 项目 | 值 |
|---|---|
| DXE FV 基址 | `0x01b10000` |
| FFS 文件 `7e73eb50` 起始 | `0x01b10078` |
| FFS size 字段（bytes 20-22） | `0x01b1008c`–`0x01b1008e` |
| LZMA section 头 | `0x01b10090` |
| LZMA 压缩数据起始 | `0x01b100a8` |
| 原始压缩数据大小 | `0x35a67e`（3,516,030 bytes） |
| 原始 section 大小 | `0x35a696` |
| 原始 FFS 大小 | `0x35a6ae` |

### 补丁方案（已实施）

目标：将工程 GUID 替换为生产 GUID，使 fwupd 能匹配 N3GET76W CAB。

| 项目 | 工程值 | 生产值 |
|---|---|---|
| ESRT FwClass GUID | `66d47c53-a746-4495-a444-e6b26a04906d` | `ce5cfa7d-0ce2-4974-b866-a367f9e85481` |
| EFI LE 字节序 | `537cd46646a79544a444e6b26a04906d` | `7dfa5ccee20c7449b866a367f9e85481` |

步骤：
1. 从 SPI `0x01b100a8` 读取 3,516,030 bytes LZMA（`FORMAT_ALONE`）数据并解压（→ 15,548,432 bytes）
2. 在解压数据中替换全部 2 处工程 GUID → 生产 GUID
3. LZMA 重压缩（`dict_size=16MB, lc=3, lp=0, pb=2`）→ 3,503,360 bytes（**缩小 12,670 bytes，可完全放入原空间**）
4. 更新 GUID-defined section size：`0x35a696` → `0x357518`（3 bytes LE 于 `0x01b10090`）
5. 更新 FFS 文件 size：`0x35a6ae` → `0x357530`（3 bytes LE 于 `0x01b1008c`）
6. 重算 FFS header checksum（byte 16 of FFS header = `0x73`；file checksum = `0xAA`）
7. 在新压缩数据后用 `0xFF` 填充 12,670 bytes
8. 全量验证（重新解压新数据，确认生产 GUID 存在、工程 GUID 消失）

### 输出文件

```
build/spi_esrt_guid_patch_20260313_205948.bin
SHA256: 699389374bc127b01116f3a148d57776e27767ffcf72fe7c87d158f940b762da
大小: 33,554,432 bytes (32 MB)
```

### 待验证
1. 刷写 `spi_esrt_guid_patch_20260313_205948.bin` 后重启
2. 执行 `fwupdmgr get-devices | grep -A5 "System Firmware"` 确认 GUID 变为 `ce5cfa7d`
3. 执行 `fwupdmgr local-install firmware/packages/345d6a1a...-N3GET76W.cab`
