# Skills

按需加载的多步骤工作流, 遵循 [Agent Skills 开放标准](https://agentskills.io/specification).

## 与 Rules 的区别

| | Rules | Skills |
|---|---|---|
| 加载时机 | 始终, 按文件匹配或按需 | 按需匹配或用户 `/` 触发 |
| 适用内容 | 偏好, 约束, 风格 | 多步骤流程, 专项任务 |

## 目录结构

```shell
skills/
└── skill-name/  # 目录名与 name 一致
    ├── SKILL.md     # 必需
    ├── scripts/     # 可选脚本
    ├── references/  # 可选参考文档
    └── assets/      # 可选资源
```

## 编写约定

- 每个 Skill 一个目录, 必须包含 `SKILL.md`.
- frontmatter 的 `name` 与目录名一致, 使用小写字母, 数字和短横线, 最多 64 字符.
- `description` 简要说明用途, 使用时机和触发关键词.
- 主文件尽量少于 500 行, 详细内容放入 `references/`.

## SKILL.md 格式

```markdown
---
name: skill-name
description: 说明 Skill 做什么以及何时使用.
---
```

## 官方文档

> 如果有变更, 以官方文档为准

- [Antigravity CLI](https://antigravity.google/docs/cli/plugins/)
- [Antigravity IDE](https://antigravity.google/docs/ide/skills/)
- [Claude](https://code.claude.com/docs/zh-CN/skills)
- [Cursor](https://cursor.com/cn/docs/skills)
