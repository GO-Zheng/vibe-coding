---
name: vibe-coding-manager
description: 查看和安装 vibe-coding 的用户级 Rules 与 Skills.
---

# vibe-coding Manager

`manager` 使用 Python 标准库, 将仓库中的 Rules 和 Skills 安装到 Claude Code, Codex, Cursor 和 Antigravity 的用户级目录.

## 使用方式

在仓库根目录运行以下命令:

```shell
uv run --no-project -m manager list
uv run --no-project -m manager install
```

## 命令参数

- `--target`: `all`, `claude`, `codex`, `cursor`, `antigravity`, `antigravity-cli` 或 `antigravity-ide`.
- `--kind`: `all`, `rules` 或 `skills`.
- `--rule`: 只选择一个 Rule, 例如 `core/communication.md`.
- `--skill`: 只选择一个 Skill, 例如 `quick`.

`--rule` 和 `--skill` 互斥. 未选择具体项时, 安装指定目标的全部内容.

## 用户级目标路径

| Target | Rules | Skills |
| :--- | :--- | :--- |
| `antigravity` | `~/.gemini/config/GEMINI.md` | `~/.gemini/config/skills/` |
| `claude` | `~/.claude/rules/` | `~/.claude/skills/` |
| `codex` | `~/.codex/AGENTS.md` | `~/.agents/skills/` |
| `cursor` | `~/.cursor/rules/*.mdc` | `~/.cursor/skills/` |

## 安装行为

- 每次 `install` 前自动检查目标工具的 `superpowers` 和 `Context7 MCP` 配置.
- 已检测到时静默继续, 未检测到或无法确认时输出 warning, 但不会阻止安装.
- 不自动安装第三方依赖, 也不进行网络连接或登录验证.
- 同名 Rule 和 Skill 默认覆盖.
- 不删除目标目录中的其他文件.
- Codex 和 Antigravity 使用 `vibe-coding` 受控区块更新单文件 Rules, 区块外内容保持不变.
- Cursor 根据 `rules/manifest.yaml` 生成 `.mdc` frontmatter.
- `CODEX_HOME` 可用于覆盖 Codex 的默认用户目录.
