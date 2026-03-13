# fwupd CAB GUID 重定向实验记录（2026-03-13）

## 背景
- 设备当前 System Firmware GUID：`66d47c53-a746-4495-a444-e6b26a04906d`
- Lenovo BIOS CAB（N3GET76W）原 metainfo 目标 GUID：`ce5cfa7d-0ce2-4974-b866-a367f9e85481`
- 原始 CAB 因 GUID 不匹配无法安装。

## 实验方法（仅改 metainfo）
1. 读取原始 CAB：
   - `firmware.bin`
   - `firmware.jcat`
   - `firmware.metainfo.xml`
2. 只替换 `firmware.metainfo.xml` 中 `<provides><firmware type="flashed">...` GUID：
   - `ce5cfa7d-0ce2-4974-b866-a367f9e85481`
   - → `66d47c53-a746-4495-a444-e6b26a04906d`
3. 保持 `firmware.bin` 与 `firmware.jcat` 不变，重新打包 CAB。

输出测试包：
- `build/N3GET76W_guid_retarget_test.cab`

## 结果
- `fwupdmgr get-details build/N3GET76W_guid_retarget_test.cab`：可识别到 `System Firmware`
- `fwupdmgr local-install ... --force --allow-reinstall --allow-older -y`：执行成功
- `fwupdmgr get-history`：
  - 显示 `System Firmware` 更新状态为“需要重启”
  - 目标版本显示为 `0.1.76`
  - `Problems: An update is in progress`

## 当前状态
- 更新已排队，等待重启进入固件阶段应用。
- 该方案证明：在本机环境下，CAB 的 metainfo GUID 重定向可以让 fwupd 匹配并进入安装队列。

## 注意事项
- 此方法属于实验性方案，重启后的实际刷写结果仍需验证。
- 当前会话尚未重启，不代表固件已真正写入完成。