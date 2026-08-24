# 书写风格

适用于 AI 编写的注释, 文档, commit message 正文等 prose 内容 (非对话).

## 语言

- 注释, 文档, commit message 正文: 使用中文
- 专业术语保留英文 (如 commit, mutex, WAL, span)
- 中文与 English/数字/符号之间加空格: `使用 WAL 写入`, 而非 `使用WAL写入`

## 标点

- 注释和文档中默认使用英文标点 (`,` `.` `:` `;` 等, `, ` 使用 `, ` 替代)
- 仅当语义需要或只能使用中文标点时例外 (如中文引号「」, 书名号《》)

## 标识符与代码

- 文档与注释中, 函数名, 类型, 路径, 命令, 文件名用反引号包裹
- 例: 调用 `open_db()`, 见 `src/wal.rs`, 运行 `cargo test`

## Markdown 标题

- 每个文件一个 `#` 标题
- 不跳级 (`##` 下直接用 `###`, 不要跳到 `####`)
- 避免一篇文档堆叠过多 `#` 层级

## 文档专用格式

写 Markdown 文档时的图示与目录结构, 见 `rules/docs/`:

- [diagrams.md](../docs/diagrams.md) — Mermaid 流程图/时序图/状态图
- [directory-tree.md](../docs/directory-tree.md) — tree 风格目录结构
