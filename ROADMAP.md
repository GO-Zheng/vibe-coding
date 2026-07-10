# 整理路线图

## 阶段 0: 搭骨架 ✅

- [x] 创建目录结构
- [x] 编写 README 与 ROADMAP
- [x] 编写 adapters 同步脚本 (symlink 模式)
- [x] 首次运行 `install.sh` 验证 symlink (含 `--dry-run`)

## 阶段 1: 收敛 Rules (逐条打磨)

- [x] `rules/core/communication.md` — 已定稿
- [x] `rules/manifest.yaml` + Cursor `.mdc` 生成
- [x] `rules/core/coding-principles.md` — 已定稿
- [x] `rules/workflows/git-workflow.md` — 已定稿
- [ ] 其余 workflows / languages — 按需自行整理

同步时 adapters 会:
- **Cursor**: 生成 `.mdc` 到 `~/.cursor/rules/`
- **Claude Code**: 生成 `.claude/rules/` 带 `paths` frontmatter

## 阶段 2: 收敛 Skills

按需自行编写, 遵循 agentskills.io 标准目录结构:

```
skills/
└── skill-name/
    ├── SKILL.md
    ├── scripts/
    ├── references/
    └── assets/
```

## 阶段 3: 编写 AGENTS.md

精简入口文件 (<200 行), 用 `@` 引用 rules:

```markdown
# vibe-coding 通用指令

@rules/core/communication.md
@rules/core/coding-principles.md
@rules/workflows/git-workflow.md
```

语言专项 rules 不放进 AGENTS.md 全局入口, 由各工具按 glob/paths 单独加载.

## 阶段 4: 同步验证

在每个工具中验证:

| 工具 | 验证方式 |
|------|----------|
| Cursor | 新开 Agent 对话, 问 "你的 git commit 规范是什么" |
| Claude Code | `claude` 启动后检查 memory 加载 |
| Hermes | `hermes skills list` 或 `/skill-name` |
| Xcode | Coding Assistant 中测试一条规则 |

## 阶段 5: 清理临时存放

- [ ] Cursor User Rules 精简为仅 Cursor 特有项
- [ ] 运行 `install.sh` 确保全局 symlink 生效

## 阶段 6: 后续增强 (可选)

- [ ] `adapters/install.sh --watch` 文件变更自动同步
- [ ] CI 校验 skills 符合 agentskills.io 规范
- [ ] 按语言/场景分包 (rust-pack, ios-pack)
- [ ] Hermes `SOUL.md` 模板
