---
name: quick
description: 在用户明确要求对小范围低风险变更使用轻量工作流时使用.
---

# Quick Workflow

仅在用户明确要求使用 `quick` 时启用. 适用于小范围, 低风险, 需求明确的 bug 修复和功能优化.

涉及公共 API, 持久化格式, 并发, 安全或跨模块架构时, 不进入 quick, 改用完整工作流或按 `rule-conflict-resolution` 询问用户.

## 流程

`grilling` → `create branch` → `implement` → `quick-test` → `documentation-sync` → `user approval` → `commit`

1. 通过 `grilling` 确认目标, 范围, 成功标准和方案, 只读取直接相关的上下文.
2. 达成共识后从原分支创建新分支.
3. 执行最小改动, 不顺手重构或扩展范围.
4. 调用独立的 `quick-test` 分析 `git diff HEAD`, 执行必要的定向测试.
5. 按 `documentation-sync` 检查并更新受影响文档.
6. 汇报变更, 验证结果和剩余风险, 主动询问是否结束并进入 commit 确认.

## 约束

- 不执行 `brainstorming`, `writing-plans` 或 `plan-review`.
- 不自动启动 `code-review`; 若需要 review, 必须主动询问用户.
- 仍须遵守 `AGENTS.md`, `CONTEXT.md`, RULES, 文档同步和测试范围规则.
- 发现需求或实现与现有规则冲突时, 立即暂停并按 `rule-conflict-resolution` 询问用户.
- 执行前仍须按 `superpowers` 规则询问是否逐步暂停; 用户选择逐步暂停时, 每完成一个步骤就停下等待校验.
- 不得把未执行的测试描述为已验证, 不得未经用户确认提交.
