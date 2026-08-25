# 文档格式

除已有固定格式的 `README.md`, `CHANGELOG.md`, `LICENSE`, `CONTRIBUTING.md`,
`AGENTS.md` 和 `CLAUDE.md` 外, 项目说明文档统一使用 SKILL 格式.

## SKILL 格式要求

使用 agentskills.io 标准 frontmatter:

```markdown
---
name: project-overview
description: 用于说明项目概览和使用方式
---

# 文档标题

正文内容...
```

- `name`: 小写字母, 数字和短横线, 与文件名一致.
- `description`: 简明说明用途, 帮助 AI 判断是否需要加载.
- 正文使用纯 Markdown.
