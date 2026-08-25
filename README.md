# vibe-coding

跨 AI 编程工具的通用工作流, Rules 和 Skills 源库.

## 快速开始

在仓库根目录运行:

```shell
uv run --no-project -m manager list
uv run --no-project -m manager install
```

管理器的命令、参数、目标路径和安装行为见 [`manager/README.md`](./manager/README.md).

## 规则和技能

- Rules 源文件和 `manifest.yaml` 约定见 [`rules/README.md`](./rules/README.md).
- Skills 目录和 `SKILL.md` 约定见 [`skills/README.md`](./skills/README.md).
- 通用 AI 行为入口见 [`AGENTS.md`](./AGENTS.md).

## 设计原则

1. 用户级安装: 通过 `manager/` 安装到各工具的用户级目录.
2. 最小变更: 安装单个 Rule 或 Skill 时只更新对应内容.
