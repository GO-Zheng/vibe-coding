---
name: quick
description: Use when the user explicitly requests a lightweight, fast workflow for a small, clear, low-risk change.
---

# Quick Workflow

仅在用户明确要求使用 `quick` 时启用. 目标是在保持必要约束的前提下, 快速完成小范围、需求明确且风险可控的任务.

## 流程

1. 确认目标、范围和成功标准, 只读取直接相关的上下文.
2. 用简短方案说明拟修改内容和最小验证命令, 主动询问是否开始.
3. 执行最小改动, 不顺手重构或扩展范围.
4. 只运行修改或受影响部分的必要测试和验证.
5. 汇报变更、验证结果和剩余风险, 主动询问是否结束、继续或进入后续流程.

## 约束

- 不自动启动 `plan-review` 或 `code-review`; 若需要 review, 必须主动询问用户.
- 仍须遵守 `AGENTS.md`、`CONTEXT.md`、RULES、文档同步和测试范围规则.
- 发现需求或实现与现有规则冲突时, 立即暂停并按 `rule-conflict-resolution` 询问用户.
- 执行前仍须按 `superpowers` 规则询问是否逐步暂停; 用户选择逐步暂停时, 每完成一个步骤就停下等待校验.
- 不得把未执行的测试描述为已验证, 不得未经用户确认提交.
