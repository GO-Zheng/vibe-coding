# vibe-coding

跨 AI 编程工具的通用工作流与规则库。
在本项目集中维护 `rules/` 与 `skills/`，通过适配器脚本一键编译并同步部署到各个 AI Coding Agent。

## 支持的 AI 工具与适配方式

| 工具 (Tool) | 规则入口 (Rules Entry) | Skills 目录 | 适配器实现机制 (Adapter Mechanism) |
| :--- | :--- | :--- | :--- |
| **Antigravity** | `~/.gemini/config/AGENTS.md` | `~/.gemini/config/skills/` | **编译展开**：自动将 `AGENTS.md` 中的 `@rules/...` 内联嵌入，并自动装载 `alwaysApply` 规则 |
| **Claude Code** | `~/.claude/CLAUDE.md` | `~/.claude/skills/` | **桥接与层级同步**：通过 `CLAUDE.md` 引用 `AGENTS.md`，同步规则时完整保留 `rules/` 的子目录层级结构 |
| **Codex (OpenAI)** | `~/.codex/AGENTS.md` | `~/.codex/skills/` | **编译展开与层级同步**：同步 `AGENTS.md` 内联展开并发布规则与技能树 |
| **Cursor** | `~/.cursor/rules/*.mdc` | `~/.cursor/skills/` | **.mdc 生成**：根据 `manifest.yaml` 将纯 Markdown 规则编译为带有 `description`/`globs`/`alwaysApply` 头部的 `.mdc` 文件 |
| **Hermes** | `SOUL.md` (可选) | `~/.hermes/skills/` | **标准装载**：复制标准 Agent Skills，支持配置 `external_dirs` 挂载 |

## 快速开始

```bash
# 一键安装/同步到所有已配置的工具
./adapters/install.sh

# 按需同步指定 AI 工具
./adapters/install.sh --antigravity
./adapters/install.sh --claude
./adapters/install.sh --codex
./adapters/install.sh --cursor
./adapters/install.sh --hermes

# 预览同步动作 (不实际写入文件)
./adapters/install.sh --dry-run
```

## 目录结构

```shell
vibe-coding/
├── AGENTS.md          # 跨工具通用指令 (SSOT 入口，包含 @rules 引用)
├── CLAUDE.md          # Claude Code 桥接文件 (由 sync 自动生成)
├── README.md          # 项目使用指南与架构说明
├── ROADMAP.md         # 迁移、演进与整理计划
├── rules/             # 可组合规则片段 (SSOT 源码)
│   ├── manifest.yaml  # 规则元数据 (Cursor .mdc 生成映射与 alwaysApply 标记)
│   ├── core/          # 沟通、书写风格、代码原则、Superpowers 补充
│   ├── workflows/     # Git 工作流、路由、文档同步、领域建模
│   ├── docs/          # 图示、目录结构、文档格式规范
│   └── languages/     # 语言专项 (Rust、Python 等)
├── skills/            # Agent Skills 标准库 (包含 SKILL.md)
│   ├── code-review/   # 双 Agent 代码审核技能
│   ├── grilling/      # 盘问式设计澄清技能
│   ├── plan-review/   # 双 Agent 计划审核技能
│   └── handoff/       # 会话交接与摘要生成技能
└── adapters/          # 各 AI 工具适配与部署脚本
    ├── install.sh     # 总控入口脚本
    ├── common.sh      # 共享 helper (含 Antigravity 展开、Cursor 编译等核心逻辑)
    ├── antigravity.sh # Antigravity IDE 部署适配器
    ├── codex.sh       # OpenAI Codex 部署适配器
    ├── cursor.sh      # Cursor Rules/.mdc 编译适配器
    ├── claude.sh      # Claude Code 部署适配器
    └── hermes.sh      # Hermes Agent 部署适配器
```

## 设计原则

1. **SSOT (Single Source of Truth)**：只在本仓库编辑与维护 `rules/` 和 `skills/` 源文件，严禁在各 AI 工具配置目录下手动散乱修改。
2. **物理复制与隔离部署**：适配器脚本会将真实的文本与技能目录解包、展开并物理复制到各 AI 工具的本地配置路径（而非使用软链接 symlink），保证各工具独立可靠。
3. **全局优先，解耦项目**：默认部署到用户级配置路径（如 `~/.gemini/config`, `~/.cursor`, `~/.claude`），跨项目通用。
4. **项目级 Overlay 扩展**：个别项目若有特定业务约束，可在项目根目录放置 `.agents/AGENTS.md` 或 `.cursor/rules/` 进行无缝叠加，不污染全局主库。

