---
name: code-review
description: 在实现完成、提交前需要检查代码变更时使用.
---

# Code Review

对代码变更进行一次单 agent 审核, 不自动循环.

## 前置条件

- 变更已暂存或 commit, 提供固定的版本点 (commit SHA / branch / tag / `main` 等)
- 通过 `git diff <fixed-point>...HEAD` 获取 diff
- 在执行任何 review 动作前, 必须主动询问用户是否启动 code review.
- reviewer agent 必须继承当前会话使用的模型, 不得自行指定, 切换或回退到其他模型.
- 用户拒绝启动时, 停止并汇报, 不得启动 review.

## 流程

### Step 0: 获取 review 授权

先向用户询问:

> 是否启动 code review? 本轮将继承当前会话模型, 只执行一轮单审.

未获得明确同意前, 不获取审核结论, 不启动任何 reviewer agent.

### Step 1: 获取 diff

确认版本点可解析且 diff 非空.记录 `git log <fixed-point>..HEAD --oneline` 的 commit 列表.

### Step 2: 审核

使用当前会话模型启动 1 个 subagent 审核 diff.审核标准见 `references/reviewer-prompt.md`.

### Step 3: 审核结果

等待 subagent 完成, 汇总审核结果:

- subagent 的审核结论 (见下方定义)
- 所有 critical / major 问题列表
- 所有 minor 建议列表
- 本次为唯一一轮 review, 不自动启动第二个 reviewer 或第二轮.

## 审核结论定义

| 结论 | 含义 | 处理 |
|------|------|------|
| APPROVED | 无问题或只有 trivial 建议, 代码可以直接 commit | 通过 |
| CONDITIONALLY_APPROVED | 有 minor 问题, 但不阻碍提交, 建议修订 | 本轮结束, 记录建议 |
| REJECTED | 存在 critical 或 major 问题, 代码不可直接提交 | 本轮结束, 记录问题 |

### Step 4: 判定

- subagent 返回 `APPROVED` → 进入 Step 6.
- subagent 返回非 `APPROVED` → 进入 Step 5, 不自动再次审核.
- 本轮结束后, 必须主动询问用户是否循环进行下一轮, 以及是否结束 review.
- 用户未明确允许下一轮时, 停止 review.
- 本轮仍有明显 bug, 尤其是 critical / major 或相关测试失败时, 建议结束 review 并返回需求, 设计, 测试 seam 和 implementation plan, 从头梳理后再实现; 不继续局部打补丁.

### Step 5: 修订

根据审核意见修订代码, 然后停止本轮 review. 修订后不得自动回到 Step 1; 只有用户明确允许循环时, 才能开始下一轮, 且每次仍只执行一轮审核.

修订后只运行与本次修改直接涉及或受影响部分相关的测试或验证命令. 优先选择单测, 目标 integration test, 目标 feature 或单个测试过滤器; 不得为了 review 运行无关的全量测试.

如果没有可直接对应的自动化测试, 说明原因并执行最小必要的静态检查或手动验证. 相关测试失败按明显 bug 处理.

修订时同步检查 `rules/workflows/documentation-sync.md` 确认相关文档是否需更新.

### Step 6: 文档同步

按 `rules/workflows/documentation-sync.md` 检查并更新相关文档 (或确认无需变更). 过程制品在 `superpowers/`; 仓内仍有效的结论写入本仓 `docs/` 等, 不链到仓库外 plan/spec.

### Step 7: 输出

向用户汇报最终结果:

> Code Review 完成: `<diff 范围>`
> 审核模型: `<继承当前会话模型>`
> 审核结果: `<最终结论>`
> 本轮仅执行 1 轮
> 最终修订包括: ...
> 测试策略: 仅运行与修改或受影响部分相关的测试 / 验证
> 文档同步: <已更新路径 / 无需变更>
> 请确认是否结束 review, 或是否允许开始下一轮?

如果仍有明显 bug, 输出 `NEEDS_REPLAN`, 明确列出未解决的问题, 请求用户重新确认需求与 plan, 不得输出“可以提交”.

## 用户确认

用户确认后, 按 `rules/workflows/git-workflow.md` 执行 commit.
