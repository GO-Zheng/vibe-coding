# Superpowers 补充

本文件是 `vibe-coding` 工作流与过程制品约定的权威规则.
当外部 skill 或工具默认流程与本文件冲突时, 以本文件为准.

## 统一工作流

所有任务统一遵循以下流程:

`brainstorming` → `writing-plans` → `plan-review` → `grilling` → `create branch` → `implement` → `code-review` → `documentation-sync` → `user approval` → `commit`

用户明确要求使用 `quick` skill 时, 可以改用其轻量工作流, 不强制执行上述完整流程.

## 过程制品

- 目录不存在时自动创建.
- implementation plan 放在工作区根目录 `superpowers/plans/`.
- design spec 放在工作区根目录 `superpowers/specs/`.
- 这些文件是过程制品, 不写入项目仓库的 `docs/superpowers/`, 也不从项目文档引用或被引用.
- plan 中的关键假设使用 `[ASSUMPTION]` 标记, 审核时重点检查.

## 执行确认

- 执行 plan 前, 主动询问用户是否需要逐步暂停.
- 选择逐步暂停时, 未获用户明确允许继续前, 不得执行下一个步骤或一次性完成 plan.
- 暂停时, 每次只执行一个步骤并汇报结果, 等待继续指令.
- 用户明确不需要逐步暂停时, 才允许连续执行后续步骤; 仍须完成验证并在结束时汇报.
- 写测试前先写明测试 seam (接口或边界), 并与用户确认; 不在未确认的 seam 上写测试.
- 使用 `quick` 时仍须遵守上述确认约束; code review 使用 `code-review` Skill.
