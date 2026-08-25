# 书写风格

适用于 AI 编写的注释, 文档, commit message 正文等 prose 内容 (非对话).

## 语言与标点

- 使用中文, 专业术语保留英文 (注释, 文档, commit message 正文).
- 中文与 English/数字/符号之间加空格, 例如 `使用 WAL 写入`.
- 默认使用英文标点; 仅在中文引号「」和书名号《》等必要场景使用中文标点.
- 中文顿号 `、` 使用 `, ` 替代.

## 标识符与代码

- 函数名, 类型, 路径, 命令和文件名使用反引号, 例如调用 `open_db()`.

## Markdown 标题

- 每个文件一个 `#` 标题
- 标题层级连续, 避免堆叠过多层级.

## 文档专用格式

Markdown 图示和目录结构遵循 [`diagrams.md`](../docs/diagrams.md) 与
[`directory-tree.md`](../docs/directory-tree.md).
