# Rules

可组合的规则片段, **单一数据源 (SSOT)**.

本目录只维护**纯 Markdown 正文** (无 YAML frontmatter). 各工具的 frontmatter 由 `manifest.yaml` + `adapters/` 生成.

## 目录

| 目录 | 用途 | 状态 |
|------|------|------|
| `core/` | 沟通、书写风格、代码原则、Superpowers 补充 | `communication`, `writing-style`, `coding-principles`, `superpower` 已定稿 |
| `docs/` | 文档专用: 图示、目录结构、文档格式 | `diagrams`, `directory-tree`, `document-format` 已定稿 |
| `workflows/` | Git 工作流 | `git-workflow` 已定稿 |
| `languages/` | 语言专项 (Rust、Python) | `rust`, `python` 已定稿 |

## 编写约定

1. **源文件**: 纯 Markdown, 一条规则一个文件, 理想 < 50 行
2. **元数据**: 在 `manifest.yaml` 声明 `description`, `alwaysApply`, `globs`
3. **定稿流程**: 写好源文件 → 更新 manifest → 审阅 → `adapters/install.sh`

### 源文件模板 (本仓库 SSOT)

```markdown
# 规则标题

- 可执行的指令
- 具体、无歧义
```

### manifest 条目模板

```yaml
rules:
  - source: core/communication.md
    description: 简短描述 (Cursor intelligent apply / 规则选择器显示)
    alwaysApply: true          # 每次对话加载

  - source: languages/rust.md
    description: Rust 开发规范
    globs: "**/*.rs"           # 仅匹配文件在上下文中时加载
```

---

## 各工具标准格式与模板

### Cursor — Project Rules (`.mdc`)

- **官方文档**: [cursor.com/docs/rules](https://cursor.com/docs/rules)
- **路径**: `~/.cursor/rules/` (全局) 或 `项目/.cursor/rules/`
- **要点**: 必须用 `.mdc` 扩展名; plain `.md` 在 `.cursor/rules/` 内不会被识别

```markdown
---
description: 沟通与回复语言
alwaysApply: true
---

# 沟通

- 用中文回复
- 标点默认用英文标点
```

| frontmatter | 作用 |
|-------------|------|
| `alwaysApply: true` | 每次对话加载 (慎用, 占 token) |
| `globs: **/*.rs` | 匹配文件在上下文中时加载 |
| `description` only | Agent 按需判断是否加载 |

**User Rules** (Settings → Rules): 纯文本, 无 frontmatter, 全局个人偏好. 见 [cursor.com/docs/rules](https://cursor.com/docs/rules).

本仓库通过 `adapters/cursor.sh` 从 `rules/` + `manifest.yaml` 生成 `~/.cursor/rules/*.mdc`.

---

### Claude Code — Rules + Memory

- **官方文档**: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)
- **路径**: `~/.claude/CLAUDE.md`, `~/.claude/rules/`, 项目根 `CLAUDE.md`

Claude Code **不原生读取** `AGENTS.md`, 需 `CLAUDE.md` 桥接:

```markdown
@AGENTS.md
```

路径限定规则 (`.claude/rules/`):

```markdown
---
paths:
  - "**/*.rs"
---

# Rust 规范

- 生产代码禁止 unwrap()
```

全局始终生效的内容放在 `AGENTS.md` 并用 `@rules/...` 引用:

```markdown
@rules/core/communication.md
```

本仓库通过 `adapters/claude.sh` 同步 `AGENTS.md` + `CLAUDE.md` 桥接.

---

### AGENTS.md — 跨工具通用入口

- **规范**: [agents.md](https://agents.md/) (社区约定)
- **支持**: Cursor, Codex, Xcode, Windsurf, Cline 等
- **格式**: 纯 Markdown, 无 frontmatter

```markdown
# 项目指令

## 沟通

- 用中文回复
```

本仓库根目录 `AGENTS.md` 为 SSOT 入口, 通过 `@rules/...` 组合各片段 (Claude Code 可展开).

---

### Hermes — SOUL.md / 配置

- **官方文档**: [hermes-agent.nousresearch.com/docs/user-guide/configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)
- **路径**: `~/.hermes/SOUL.md` (身份与始终生效偏好)

Hermes 没有独立的 "rules" 目录. 简短全局偏好可写入 `SOUL.md`:

```markdown
# 身份

用中文回复用户. 标点默认使用英文标点.
```

复杂工作流用 Skills (见 `skills/README.md`), 不用本目录.

---

### Xcode — Coding Assistant

- **参考**: [Apple Newsroom — Xcode 26.3 agentic coding](https://www.apple.com/newsroom/2026/02/xcode-26-point-3-unlocks-the-power-of-agentic-coding/)
- **路径**: `~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/`

```markdown
# 沟通

- 用中文回复
- 标点默认用英文标点
```

使用 `AGENTS.md` 或 `CLAUDE.md` (`@AGENTS.md` 桥接). 能力较 CLI 工具有限 (无 hooks/MCP).

本仓库通过 `adapters/xcode.sh` 同步.

---

## 同步

```bash
./adapters/install.sh --cursor   # 生成 ~/.cursor/rules/*.mdc
./adapters/install.sh --claude   # AGENTS.md + CLAUDE.md 桥接
./adapters/install.sh            # 全部工具
```

## 已定稿规则

| 文件 | 说明 |
|------|------|
| [core/communication.md](./core/communication.md) | 对话: 用中文回复 |
| [core/writing-style.md](./core/writing-style.md) | 通用书写: 中文、标点、标识符、标题 |
| [core/coding-principles.md](./core/coding-principles.md) | 代码: 最小改动、SOLID、规模、如实说明、错误处理 |
| [core/superpower.md](./core/superpower.md) | Superpowers: plan/spec 存放路径、[ASSUMPTION] 标签 |
| [docs/diagrams.md](./docs/diagrams.md) | 文档: Mermaid 图示 |
| [docs/directory-tree.md](./docs/directory-tree.md) | 文档: tree 目录结构 |
| [docs/document-format.md](./docs/document-format.md) | 文档: 通用文档使用 SKILL 格式 |
| [workflows/git-workflow.md](./workflows/git-workflow.md) | Git: 提交规范、分支工作流、推送 |
| [languages/rust.md](./languages/rust.md) | Rust: clippy warning 必须处理 |
| [languages/python.md](./languages/python.md) | Python: 统一使用 uv 管理包 |
