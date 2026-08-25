# Rules

可组合的规则片段, **单一数据源 (SSOT)**.

本目录只维护**纯 Markdown 正文** (无 YAML frontmatter). 各工具的 frontmatter 由 `manifest.yaml` + `manager/` 生成.

## 目录

| 目录 | 用途 |
|------|------|
| `core/` | 通用行为, 书写, 代码和流程规则 |
| `docs/` | 文档专用: 图示, 目录结构, 文档格式 |
| `workflows/` | Git, 文档同步和领域术语 |
| `languages/` | 语言专项 (Rust, Python) |

## 编写约定

1. 源文件使用纯 Markdown, 一条规则一个文件, 尽量少于 50 行.
2. 在 `manifest.yaml` 声明 `description`, 必要时声明 `alwaysApply` 或 `globs`.
3. 写好源文件后更新 manifest, 审阅, 再运行 `uv run --no-project -m manager install`.

### 源文件模板

```markdown
# 规则标题

- 可执行的指令
- 具体, 无歧义
```

### manifest 条目模板

```yaml
rules:
  - source: core/communication.md
    description: 简短描述 (Cursor intelligent apply / 规则选择器显示)
    alwaysApply: true  # 每次对话加载

  - source: languages/rust.md
    description: Rust 开发规范
    globs: "**/*.rs"   # 仅匹配文件在上下文中时加载
```

---


## 官方文档

> 如果有变更, 以官方文档为准

- [Antigravity IDE](https://antigravity.google/docs/ide/rules/)
- [Cursor](https://cursor.com/docs/rules)
- [Claude](https://code.claude.com/docs/zh-CN/memory)
