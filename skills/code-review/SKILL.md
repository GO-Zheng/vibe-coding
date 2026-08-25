---
name: code-review
description: 审查 Git diff 的正确性, 风险, 测试覆盖和改动边界, 用于提交前.
---

# Code Review

对代码变更进行一次单 agent 审核, 不自动循环.
审核维度见 `references/reviewer-prompt.md`.

## 前置条件

- 变更已暂存或 commit, 且有固定版本点 `commit SHA`, branch, tag 或 `main`.
- 用 `git diff <fixed-point>...HEAD` 获取非空 diff.
- 执行 review 前先询问用户是否启动; reviewer 必须继承当前会话模型, 不得自行指定, 切换或回退.
- 若存在 critical / major, 相关测试失败或明显 bug, 回到需求, 设计, 测试 seam 和 implementation plan 重新梳理, 不局部打补丁.
- 用户拒绝时停止, 不启动 reviewer.

## 流程

1. 获得授权后确认版本点, 记录 `git log <fixed-point>..HEAD --oneline`.
2. 启动 1 个 reviewer, 按 `references/reviewer-prompt.md` 审核 diff.
3. 汇总结论, critical / major 问题和 minor 建议.
4. `APPROVED` 时直接进入文档同步; `REJECTED` 时按意见修订并停止.
5. 发生修订时, 只运行受影响部分的最小测试或静态检查; 没有自动化测试时说明原因.
6. 无论结论如何, 都按 `rules/workflows/documentation-sync.md` 检查文档.
7. 本轮结束后主动询问用户是否结束 review 或允许下一轮; 未获允许不得重审.

## 结论

- `APPROVED`: 无阻塞问题, 仅有 trivial 或可选 minor 建议, 可以提交.
- `REJECTED`: 存在必须修改的问题, 包括 critical / major 问题或相关测试失败.

向用户报告 diff 范围, 审核模型, 结论, 问题, 修订, 测试策略和文档同步结果,
并说明本轮只执行 1 次. 若存在 critical / major 或明显 bug, 回到需求, 设计, 测试 seam 和
implementation plan 重新梳理, 不局部打补丁; 输出 `NEEDS_REPLAN`, 不得声称可以提交.

用户确认后, 按 `rules/workflows/git-workflow.md` 执行 commit.
