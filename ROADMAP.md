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
- [x] `rules/workflows/git-workflow.md` — 已定稿 (整合 commit 规范 + 分支工作流)
- [ ] 其余 workflows / languages

从以下来源提取通用内容, 写入 `rules/`:

| 来源 | 目标 | 动作 | 状态 |
|------|------|------|------|
| WiQunTools `.cursor/rules/00-rust-standards` | `rules/languages/rust.md` | 迁移 | ⏳ 待 WiQunTools 仓库拉取 |
| WiQunTools `.cursor/rules/01-testing` | `rules/languages/rust-testing.md` | 迁移 | ⏳ 同上 |
| WiQunTools `.cursor/rules/02-coding-style` | `rules/core/coding-style.md` | 迁移, 去重 | ⏳ 同上 |
| WiQunTools `.cursor/rules/03-development-workflow` | `rules/workflows/development.md` | 迁移 | ⏳ 同上 |
| WiQunTools `.cursor/rules/04-design-principles` | `rules/workflows/design-principles.md` | 迁移, 去重 | ⏳ 同上 |
| WiQunTools `.cursor/rules/05-code-review` | `rules/workflows/code-review.md` | 迁移 | ⏳ 同上 |
| WiQunTools `.cursor/rules/07-patterns` | `rules/workflows/patterns.md` | 迁移 | ⏳ 同上 |

同步时 adapters 会:
- **Cursor**: 生成 `.mdc` 到 `~/.cursor/rules/` (或保留源 `.md` 供引用)
- **Claude Code**: 生成 `.claude/rules/` 带 `paths` frontmatter

## 阶段 2: 收敛 Skills

从 WiQunTools `.cursor/skills/` 迁入 `skills/` (agentskills.io 标准目录结构):

| 现有文件 | 目标目录 | 备注 |
|----------|----------|------|
| `acceptance.md` | `skills/acceptance-report/` | 含 `scripts/acceptance.py` 引用 |
| `brainstorming.md` | `skills/brainstorming/` | 与 Superpowers 重叠, 保留中文版 |
| `debugging.md` | `skills/systematic-debugging/` | 同上 |
| `planning.md` | `skills/writing-plans/` | 同上 |
| `tdd.md` | `skills/test-driven-development/` | 同上 |
| `verification.md` | `skills/verification-before-completion/` | 同上 |

WiQunTools `.claude/skills/writing-design-specs/`:
- 内容偏 wiqun 项目 (引用 WiQunTools/docs/)
- 暂留 WiQunTools, 或迁入 `skills/writing-design-specs/` 并参数化路径

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

WiQunTools 迁移完成后:

- [ ] 删除 `WiQunTools/.cursor/` (或留 README 指向 vibe-coding)
- [ ] 评估 `WiQunTools/.claude/skills/` 去留
- [ ] Cursor User Rules 精简为仅 Cursor 特有项 (不主动 commit 等)
- [ ] 运行 `install.sh` 确保全局 symlink 生效

## 阶段 6: 后续增强 (可选)

- [ ] `adapters/install.sh --watch` 文件变更自动同步
- [ ] CI 校验 skills 符合 agentskills.io 规范
- [ ] 按语言/场景分包 (rust-pack, ios-pack)
- [ ] Hermes `SOUL.md` 模板
