# 文档命名与写作风格统一规范（草案）

> 适用范围：`docs/` 目录下全部分析、操作、记录类文档
> 版本：v1（2026-03-13）

## 1. 现状问题

当前文档存在以下不一致：

- 命名混用：`snake_case`、`kebab-case`、`UPPER_CASE` 同时存在
- 日期后缀混用：有的含 `_YYYYMMDD`，有的不含
- 标题风格混用：中英文、破折号、括号、章节编号风格不统一
- 元信息位置不一致：有的用引用块，有的散落正文

## 2. 统一命名规则

建议采用：

- 文件名统一为小写 `snake_case`
- 扩展名统一为 `.md`（快速卡片可保留 `.txt`）
- 规则：`<topic>_<doc_type>[_YYYYMMDD].md`

其中：

- `topic`：主题域，如 `ec_spi`、`fwupd`、`usb4`
- `doc_type`：`analysis` / `guide` / `log` / `inventory` / `experiment`
- 日期后缀：仅用于“快照类文档”（会持续新增），常驻文档不加日期

## 3. 写作结构模板（统一）

每篇文档建议固定包含以下段落：

1. `# 标题`
2. 元信息区（引用块）
   - 日期
   - 设备
   - 输入样本/版本
   - 结论状态（进行中/已验证/待验证）
3. `## 关键结论`
4. `## 输入与方法`
5. `## 结果与证据`
6. `## 风险与限制`
7. `## 下一步`
8. `## 可复现命令`

## 4. 术语与格式约束

- 偏移统一十六进制：`0x001000`
- 版本统一写法：`N3GHT15W (0.1.5)`
- 命令统一使用代码块（bash）
- “结论”与“推断”显式区分，避免混写
- 所有关键结论尽量附至少一条可复现证据（偏移/哈希/命令输出）

## 5. docs 文件命名迁移建议

建议重命名（仅建议，暂未执行）：

- `QUICK_REFERENCE.txt` → `quick_reference.txt`
- `thinkfan-setup-notes.md` → `thinkfan_setup_notes.md`
- `file_date_audit_20260313.md` → `project_file_date_audit_20260313.md`
- `project_inventory.md`（保持）
- `fwupd_matching_analysis_20260313.md` → `fwupd_matching_analysis_20260313.md`（保持）
- `fwupd_cab_guid_retarget_experiment_20260313.md`（保持）

## 6. 落地顺序建议

1. 新文档全部按本规范命名与编写
2. 对高频维护文档先行迁移（fwupd / ec_spi / usb4）
3. 最后处理低频归档文档并补充索引
4. 在 `README.md` 增加 docs 命名规则摘要与索引入口
