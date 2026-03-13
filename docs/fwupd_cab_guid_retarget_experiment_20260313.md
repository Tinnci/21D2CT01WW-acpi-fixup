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

---

## EC 1.67 CAB 同法验证（后续追加）

## 原始信息
- EC CAB 原目标 GUID：`b7787ed5-7008-4da9-8475-b8779d835882`
- 本机可见 UEFI Device Firmware GUID：
   - `f766f6e6-b43d-4acd-a4bd-80ff2f0af5cc`
   - `f5536e63-e4c0-4e0d-84d4-e8e152b1ba65`
   - `88440680-8493-43d8-b1cb-51992223a226`
   - `4bea12df-56e3-4cdb-97dd-f133768c9051`

## 试探结果
通过仅修改 `firmware.metainfo.xml` 的 `<firmware type="flashed">GUID</firmware>`，分别生成 4 个测试 CAB：
- `build/EC167_guid_retarget_f766f6e6-...cab`
- `build/EC167_guid_retarget_f5536e63-...cab`
- `build/EC167_guid_retarget_88440680-...cab`
- `build/EC167_guid_retarget_4bea12df-...cab`

`fwupdmgr get-details` 对 4 个包均可匹配到对应 `UEFI Device Firmware`。

其中 `4bea12df` 版本实测安装：
- 命令：`fwupdmgr local-install build/EC167_guid_retarget_4bea12df-...cab --force --allow-older --allow-reinstall -y`
- 结果：`安装固件成功`
- `fwupdmgr get-history` 显示：
   - `Embedded Controller`
   - GUID: `4bea12df-56e3-4cdb-97dd-f133768c9051`
   - 目标版本：`0.1.67`
   - 状态：`需要重启`，`An update is in progress`

## 结论（阶段性）
- CAB metainfo GUID 重定向方案对 BIOS 与 EC 均已通过“排队安装”验证。
- 当前系统已有两个待重启更新：
   1. System Firmware `0.1.76`
   2. Embedded Controller `0.1.67`
- 下一步必须重启，验证固件阶段实际刷写是否成功及版本是否生效。