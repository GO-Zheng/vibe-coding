---
name: code-review
description: 对代码 diff 进行双 agent 交叉审核并自动循环修订。在 implement 之后、commit 之前使用。接收固定的版本点 (commit/branch/tag) 作为输入。
---

# Code Review

对代码变更进行双 agent 交叉审核, 自动循环直到通过。

## 前置条件

- 变更已暂存或 commit, 提供固定的版本点 (commit SHA / branch / tag / `main` 等)
- 通过 `git diff <fixed-point>...HEAD` 获取 diff

## 流程

### Step 1: 获取 diff

确认版本点可解析且 diff 非空。记录 `git log <fixed-point>..HEAD --oneline` 的 commit 列表。

### Step 2: 双审

并行启动 2 个 subagent (`deepseek-v4-flash`), 各自独立审核 diff。审核标准见 `references/reviewer-prompt.md`。

### Step 3: 汇总

等待两个 subagent 完成, 汇总审核结果:

- 每个 subagent 的结论 (见下方定义)
- 所有 critical / major 问题列表
- 所有 minor 建议列表

## 审核结论定义

| 结论 | 含义 | 处理 |
|------|------|------|
| APPROVED | 无问题或只有 trivial 建议, 代码可以直接 commit | 通过 |
| CONDITIONALLY_APPROVED | 有 minor 问题, 但不阻碍提交, 建议修订 | 算作不通过, 进入修订循环 |
| REJECTED | 存在 critical 或 major 问题, 代码不可直接提交 | 算作不通过, 进入修订循环 |

### Step 4: 判定

- **两个 subagent 都 APPROVED** → 进入 Step 6
- **任一 subagent 非 APPROVED** → 进入 Step 5

### Step 5: 修订

根据审核意见中所有 critical 和 major 问题修改代码, 然后回到 Step 1 重新获取 diff。

修订时同步检查 `rules/workflows/documentation-sync.md` 确认相关文档是否需更新。

### Step 6: 输出

向用户汇报最终结果:

> Code Review 完成: `<diff 范围>`
> 双审均 APPROVED, 共 x 轮循环
> 最终修订包括: ...
> 可以提交到当前分支。

## 用户确认

用户确认后, 按 `rules/workflows/git-workflow.md` 执行 commit。
