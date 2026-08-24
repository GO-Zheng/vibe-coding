# Superpowers 补充

## 规则优先级

本文件是 `vibe-coding` 工作流与过程制品约定的权威规则. 当外部 skill 或工具默认流程与本文件冲突时, 以本文件为准.

## 统一工作流

所有任务统一遵循以下流程:

`brainstorming` → `writing-plans` → `plan-review` → `grilling` → 开分支 → implement → `code-review` → `documentation-sync` → 用户确认后 commit

用户明确要求使用 `quick` skill 时, 可以改用其轻量工作流, 不强制执行上述完整流程. `quick` 不是默认模式, 且不能绕过 RULES、项目 `AGENTS.md`、`CONTEXT.md`、文档同步、测试范围或用户确认.

## 计划执行确认

- 开始执行 implementation plan 前, 必须主动询问用户是否需要逐步暂停并校验执行结果.
- 用户选择需要逐步暂停时, 每次只执行一个步骤; 完成后立即停止, 汇报本步骤的变更, 验证结果和待执行步骤, 等待用户校验及继续指令.
- 用户未明确允许继续前, 不得执行下一个步骤, 不得一次性完成整个 plan.
- 用户选择不需要逐步暂停时, 才允许连续执行后续步骤; 仍须按计划完成对应验证并在结束时汇报.

## 文件存放

- implementation plan 统一保存到工作区根目录下的 `superpowers/plans/`
- design spec 统一保存到工作区根目录下的 `superpowers/specs/`
- 目录不存在则自动创建
- 不写入各项目仓库内的 `docs/superpowers/` 路径
- `superpowers/` 是过程制品: **不从项目文档引用**; 对仓库仍有效的结论须同步进该项目仓内 `docs/` (见 `workflows/documentation-sync.md`)

## Plan 约定

- plan 中的关键假设必须使用 `[ASSUMPTION]` 标签显式标记

```markdown
### Task N: 组件名

[ASSUMPTION] 此处写下你的假设
```

- 审核时会以 `[ASSUMPTION]` 为检查重点, 让审校者快速定位决策点

## 技能替换

- code review 使用 `code-review` 技能, 不使用 Superpowers 自带的 `code-reviewer`
- TDD 使用 Superpowers 的 `test-driven-development` 技能, 补充以下步骤:

  **写测试前先确认 seam (测试接缝)**:
  - 写下要测试的 seam (哪个接口, 哪个边界), 和用户确认后再开始写测试
  - 不在未确认的 seam 上写测试

