# Skills

按需加载的工作流, 遵循 [Agent Skills 开放标准](https://agentskills.io/specification).

与 `rules/` 的区别:

| | Rules | Skills |
|---|-------|--------|
| 加载时机 | 始终或按文件匹配 | 按需 (描述匹配 / 用户 `/` 触发) |
| 适用 | 偏好, 约束, 风格 | 多步骤流程, 专项任务 |
| 例子 | 「用中文回复」 | TDD 流程, 验收报告 |

## 目录结构 (SSOT)

```
skills/
└── skill-name/              # 目录名 = name 字段
    ├── SKILL.md             # 必需
    ├── scripts/             # 可选: 可执行脚本
    ├── references/          # 可选: 参考文档
    └── assets/              # 可选: 模板等资源
```

## 编写约定

1. 每个 skill 一个目录, 必须有 `SKILL.md`
2. `name` 与目录名一致 (小写, 连字符, max 64 字符)
3. `description` 用第三人称, 说明 **做什么** + **何时用**, 含触发关键词
4. 主文件理想 < 500 行; 详细内容放 `references/`

---

## 各工具标准格式与模板

### Agent Skills (开放标准) — 本仓库 SSOT

- **规范**: [agentskills.io/specification](https://agentskills.io/specification)
- **概述**: [agentskills.io](https://agentskills.io)
- **示例集合**: [github.com/anthropics/skills](https://github.com/anthropics/skills)

```markdown
---
name: systematic-debugging
description: 系统诊断问题后再提出修复方案. 在遇到错误、测试失败或异常行为时使用.
---

# 系统性调试

## 步骤

1. 复现: 确定最小复现步骤
2. 定位: 缩小范围
3. 理解: 分析根因
4. 修复: 先写失败测试, 再修代码
5. 验证: 确认不破坏已有功能
```

| frontmatter | 必需 | 说明 |
|-------------|------|------|
| `name` | 是 | 与目录名一致 |
| `description` | 是 | 发现与触发匹配用 |
| `license` | 否 | 许可证 |
| `compatibility` | 否 | 环境要求 (max 500 字符) |
| `metadata` | 否 | 任意 key-value |

---

### Cursor — Agent Skills

- **官方文档**: [cursor.com/docs/rules](https://cursor.com/docs/rules) (Skills 与 Rules 同文档体系)
- **路径**: `~/.cursor/skills/skill-name/SKILL.md` 或 `项目/.cursor/skills/`
- **格式**: 与 agentskills.io 一致 (`skill-name/SKILL.md`)

```markdown
---
name: test-driven-development
description: 强制遵循 TDD 的 red-green-refactor 循环. 在实现功能或修复 bug 时使用.
disable-model-invocation: true
---

# TDD

没有失败测试就不能写生产代码.
```

`disable-model-invocation: true`: 仅用户显式触发, Agent 不自动加载 (适合 slash command 类 skill).

本仓库通过 `adapters/cursor.sh` 物理复制到 `~/.cursor/skills/`.

---

### Claude Code — Skills

- **官方文档**: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)
- **路径**: `~/.claude/skills/skill-name/SKILL.md`, 项目 `.claude/skills/`
- **格式**: 与 agentskills.io 一致

```markdown
---
name: writing-plans
description: 在编码前创建 implementation plan. 开始多步骤功能或重构时使用.
---

# 实施计划

1. 拆解为可独立验证的子步骤
2. 识别依赖与风险
3. 确定验收标准
```

调用: `Skill(skill-name)` 或对话中自动匹配 description.

本仓库通过 `adapters/claude.sh` 物理复制到 `~/.claude/skills/`.

---

### Hermes — Skills

- **官方文档**: [hermes-agent.nousresearch.com/docs/user-guide/features/skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- **创建指南**: [hermes-agent.nousresearch.com/docs/developer-guide/creating-skills](https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills)
- **路径**: `~/.hermes/skills/skill-name/SKILL.md`
- **格式**: 兼容 agentskills.io, 可扩展 Hermes 字段

```markdown
---
name: my-skill
description: 说明 skill 的作用和使用时机.
version: 1.0.0
platforms: [macos, linux]
metadata:
  hermes:
    tags: [devops]
    category: workflow
---

# My Skill

Instructions here.
```

`~/.hermes/config.yaml` 可配置 `skills.external_dirs` 指向本仓库 `skills/` 目录.

本仓库通过 `adapters/hermes.sh` 物理复制到 `~/.hermes/skills/`.

---

### Xcode — Claude Agent Skills

- **参考**: [Hacking with Swift — Agent skills in Xcode](https://www.hackingwithswift.com/articles/283/how-to-install-and-use-ai-agent-skills-in-xcode)
- **路径**: `~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/.claude/skills/skill-name/SKILL.md`
- **格式**: 与 Claude Code / agentskills.io 一致

安装后需重启 Xcode / Claude Agent 使 skills 生效.

本仓库未提供 Xcode 适配器, 需手动复制 skill 目录到上述路径.

---

## 同步

```bash
./adapters/install.sh --cursor
./adapters/install.sh --claude
./adapters/install.sh --hermes
./adapters/install.sh          # 全部
```

## 待迁入 (来自 WiQunTools)

| Skill | 来源 | 状态 |
|-------|------|------|
| `acceptance-report` | `WiQunTools/.cursor/skills/acceptance.md` | 待迁入 |
| `brainstorming` | `WiQunTools/.cursor/skills/brainstorming.md` | 待迁入 |
| `systematic-debugging` | `WiQunTools/.cursor/skills/debugging.md` | 待迁入 |
| `writing-plans` | `WiQunTools/.cursor/skills/planning.md` | 待迁入 |
| `test-driven-development` | `WiQunTools/.cursor/skills/tdd.md` | 待迁入 |
| `verification-before-completion` | `WiQunTools/.cursor/skills/verification.md` | 待迁入 |
