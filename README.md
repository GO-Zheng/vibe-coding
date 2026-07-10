# vibe-coding

跨 AI 编程工具的通用工作流库. 单一数据源 (SSOT), 脚本同步到各工具.

## 支持的工具

| 工具 | 规则入口 | Skills 目录 | 备注 |
|------|----------|-------------|------|
| **Cursor** | User Rules + `.cursor/rules/` | `~/.cursor/skills/` 或项目 `.cursor/skills/` | 也读项目根 `AGENTS.md` |
| **Claude Code** | `CLAUDE.md` (桥接) | `~/.claude/skills/` | **不原生读 AGENTS.md**, 用 `@AGENTS.md` 或 symlink |
| **Hermes** | `SOUL.md` (可选) | `~/.hermes/skills/` + `external_dirs` | 兼容 [agentskills.io](https://agentskills.io) |
| **Xcode** | `CLAUDE.md` / `AGENTS.md` | `~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/.claude/skills/` | 能力受限, 无 hooks/MCP |

## 快速开始

```bash
# 安装到所有已配置的工具 (默认全局 personal 模式)
./adapters/install.sh

# 只同步某一个工具
./adapters/install.sh --cursor
./adapters/install.sh --claude
./adapters/install.sh --hermes
./adapters/install.sh --xcode

# 预览, 不实际写入
./adapters/install.sh --dry-run
```

## 目录结构

```
vibe-coding/
├── AGENTS.md         # 跨工具通用指令 (SSOT 入口, 保持 <200 行)
├── CLAUDE.md         # Claude Code 桥接 (由 sync 生成, 勿手改)
├── README.md         # 本文件
├── ROADMAP.md        # 迁移与整理计划
├── rules/            # 可组合规则片段 (SSOT)
│   ├── core/         # 沟通、书写风格、代码原则、Superpowers 补充
│   ├── workflows/    # Git 工作流、文档同步
│   ├── docs/         # 图示、目录结构、文档格式
│   └── languages/    # 语言专项 (Rust、Python)
├── skills/           # Agent Skills 标准 (skill-name/SKILL.md)
│   └── plan-review/  # 双 agent plan 审核技能
├── scripts/          # (预留) 工具脚本
└── adapters/         # 同步到各工具
    ├── install.sh    # 总入口
    ├── common.sh
    ├── cursor.sh
    ├── claude.sh
    ├── hermes.sh
    └── xcode.sh
```

## 设计原则

1. **SSOT**: 只在本仓库编辑 `rules/` 和 `skills/`, 不直接改各工具目录里的副本
2. **同步而非复制**: adapters 优先用 symlink, 方便改一处处处生效
3. **全局优先**: 默认装到用户级目录 (`~/.cursor`, `~/.claude`, `~/.hermes`), 不绑特定项目
4. **项目 overlay**: 某项目有特殊需求时, 在项目仓库单独加 rules/skills, 不污染本库
