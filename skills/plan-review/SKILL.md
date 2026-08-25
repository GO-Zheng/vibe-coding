---
name: plan-review
description: 审查 implementation plan 的完整性, 可行性, 风险和测试覆盖, 用于执行 plan 前.
---

# Plan Review

对已生成的 implementation plan 进行一次单 agent 审核, 不自动循环.
审核维度见 `references/reviewer-prompt.md`.

## 前置条件

- plan 已写入工作区根 `superpowers/plans/` 或指定路径, 并遵循 `writing-plans` 格式.
- 执行 review 前先询问用户是否启动; reviewer 必须继承当前会话模型, 不得自行指定, 切换或回退.
- 用户拒绝时停止, 不启动 reviewer.

## 流程

1. 获得授权后读取 plan 全文, 确认 task, 路径和示例.
2. 启动 1 个 reviewer, 按 `references/reviewer-prompt.md` 审核.
3. 汇总结论, critical / major 问题和 minor 建议.
4. 只检查验证步骤是否覆盖受影响范围, 不执行项目测试.
5. `REJECTED` 时修订 plan 后停止; 不自动开启第二轮.
6. 无论结论如何, 按 `rules/workflows/documentation-sync.md` 确认 plan 相关文档.
7. 本轮结束后主动询问用户是否结束 review 或允许下一轮; 未获允许不得重审.

## 结论

- `APPROVED`: 无阻塞问题, 仅有 trivial 或可选 minor 建议, 可以执行.
- `REJECTED`: 存在必须修订的问题, 包括 critical / major 问题或会导致执行失败的缺陷.

向用户报告 plan 路径, 审核模型, 结论, 问题, 修订和测试策略, 并说明本轮只执行 1 次.
若存在 critical / major 或会导致执行失败的问题, 回到需求和 plan 重新梳理, 不局部打补丁;
输出 `NEEDS_REPLAN`, 不得声称可以执行.

用户确认后, 交接到 `executing-plans` 或 `subagent-driven-development`.
