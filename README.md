# vibe-coding

跨 AI 编程工具的通用工作流, Rules 和 Skills 源库.

本仓库当前维护 Claude Code, Codex, Cursor 和 Antigravity 的用户级安装。Hermes 和 Xcode 不在维护范围内.

## 快速开始

在仓库根目录运行:

```shell
uv run --no-project -m manager list
uv run --no-project -m manager install
```

查看帮助:

```shell
uv run --no-project -m manager install --help
```

常用筛选:

```shell
uv run --no-project -m manager list --target cursor
uv run --no-project -m manager list --kind skills
uv run --no-project -m manager install --target claude
uv run --no-project -m manager install --target cursor --rule core/communication.md
uv run --no-project -m manager install --target cursor --skill quick
```

`antigravity` 默认同时处理 CLI 和 IDE, 也可以使用 `antigravity-cli` 或 `antigravity-ide` 单独安装.

## 用户级目标路径

| Target | Rules | Skills |
| :--- | :--- | :--- |
| `claude` | `~/.claude/rules/` | `~/.claude/skills/` |
| `codex` | `~/.codex/AGENTS.md` | `~/.agents/skills/` |
| `cursor` | `~/.cursor/rules/*.mdc` | `~/.cursor/skills/` |
| `antigravity-cli` | `~/.gemini/GEMINI.md` | `~/.gemini/antigravity-cli/skills/` |
| `antigravity-ide` | `~/.gemini/GEMINI.md` | `~/.gemini/antigravity/skills/` |

## 行为约定

- 每次 `install` 前自动检查目标工具的 `superpowers` 和 `Context7 MCP` 配置.
- 已检测到时静默继续, 未检测到或无法确认时输出 warning, 但不会阻止安装.
- `install` 默认覆盖同名 Rule 或 Skill, 不删除目标目录中的其他文件.
- Codex 和 Antigravity 的单文件 Rules 只更新 `vibe-coding` 受控区块, 保留用户区块外内容.
- Cursor 根据 `rules/manifest.yaml` 生成 `.mdc` 文件.
- `list` 只读取源文件和用户级目标状态, 不修改用户文件.

## 目录结构

```shell
vibe-coding/
├── manager/          # 用户级 Rules 和 Skills 管理器
│   ├── targets/      # 各 AI 工具的路径和格式适配
│   ├── cli.py        # 命令行参数和命令调度
│   ├── common.py     # 源文件扫描和共享文件操作
│   └── README.md     # 管理器使用说明
├── rules/            # Rules 源文件和 manifest
├── skills/           # Agent Skills 源目录
├── AGENTS.md         # 通用指令入口
└── README.md         # 项目说明
```

## 设计原则

1. SSOT: 只在本仓库编辑和维护 `rules/` 与 `skills/` 源文件.
2. 用户级安装: 默认写入各工具的用户级目录, 不修改项目级配置.
3. 最小变更: 安装单个 Rule 或 Skill 时只更新对应内容.

