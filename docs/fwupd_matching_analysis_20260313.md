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
