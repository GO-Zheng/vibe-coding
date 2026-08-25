---
name: quick
description: 对小范围低风险变更执行轻量工作流, 用户明确要求 quick 或快速修复时使用.
---

# 工作流

用户明确要求 `quick` 或需求明确且不涉及公共 API, 持久化格式, 并发, 安全或跨模块架构的变更时启用.
超出范围时不得进入 quick, 应切换完整工作流; 无法判断时按 `rule-conflict-resolution` 询问用户.

## 流程

`grilling` → `create branch` → `implement` → `quick-test` → `documentation-sync` → `user approval` → `commit`

1. 用 `grilling` 确认目标, 范围, 成功标准和方案.
2. 达成共识后创建工作分支并实施最小改动.
3. 用 `quick-test` 执行定向验证, 再按 `documentation-sync` 检查文档.
4. 汇报变更, 验证结果和风险, 等用户确认后 commit.

## 约束

- 不执行 `brainstorming`, `writing-plans` 或 `plan-review`.
- 不自动启动 `code-review`; 若需要 review, 必须主动询问用户.
- 执行前按 `superpowers` 规则询问是否逐步暂停; 选择暂停时, 每完成一个步骤即停下汇报并等待继续指令.
- 仍须遵守 `AGENTS.md`, `CONTEXT.md`, RULES, 文档同步, 测试范围和用户确认规则.
- 发现冲突时按 `rule-conflict-resolution` 暂停; 不把未执行的测试描述为已验证.
