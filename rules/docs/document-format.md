# 文档格式

## 通用规范

除以下已有固定格式的文档外, 所有项目说明文档统一使用 SKILL 格式:

**不适用** (保持原格式):
- README.md — GitHub/GitLab 首页标准
- CHANGELOG.md — 按日期/版本组织
- LICENSE — 固定格式
- CONTRIBUTING.md — GitHub 自动识别
- AGENTS.md / CLAUDE.md — 已有专用格式约定

## SKILL 格式要求

使用 agentskills.io 标准 frontmatter:

```markdown
---
name: 文档名 (短横线分隔, 如 project-overview)
description: 一句话说明文档用途, 帮助 AI 判断何时引用
---

# 文档标题

正文内容...
```

- `name`: 小写字母、数字、短横线, 与文件名一致
- `description`: 简明扼要, 让 AI 能根据上下文判断是否需要加载此文档
- 正文: 纯 Markdown, 与普通文档无异
