---
name: plan-review
description: 对 implementation plan 进行双 agent 交叉审核并自动循环修订。在 writing-plans 之后、executing-plans 之前使用。接收 plan 文件路径作为输入。
---

# Plan Review

对已生成的 implementation plan 进行双 agent 交叉审核, 自动循环直到通过。

## 前置条件

- plan 文件已写入 `docs/superpowers/plans/` 或指定路径
- plan 遵循 writing-plans 技能的标准格式

## 流程

### Step 1: 读取 plan

读取 plan 文件的完整内容, 确认所有 task 定义、文件路径、代码示例。

### Step 2: 双审

并行启动 2 个 subagent (model: `deepseek-v4-flash`), 各自独立审核 plan。审核标准见 `references/reviewer-prompt.md`。

### Step 3: 汇总

等待两个 subagent 完成, 汇总审核结果:

- 每个 subagent 的结论 (见下方定义)
- 所有 critical / major 问题列表
- 所有 minor 建议列表

## 审核结论定义

| 结论 | 含义 | 处理 |
|------|------|------|
| APPROVED | 无问题或只有 trivial 建议, plan 可以直接执行 | 通过 |
| CONDITIONALLY_APPROVED | 有 minor 问题, 但不阻碍执行, 建议修订 | 算作不通过, 进入修订循环 |
| REJECTED | 有 critical 或 major 问题, plan 不可直接执行 | 算作不通过, 进入修订循环 |

### Step 4: 判定

- **两个 subagent 都 APPROVED** → 进入 Step 6
- **任一 subagent 非 APPROVED** → 进入 Step 5

### Step 5: 修订

根据审核意见中所有 critical 和 major 问题修订 plan, 然后回到 Step 2。

修订时同步检查 `rules/workflows/documentation-sync.md` 确认相关文档是否需更新。

### Step 6: 输出

向用户汇报最终结果:

> Plan 审核完成: `<plan 路径>`
> 双审均 APPROVED, 共 x 轮循环
> 最终修订包括: ...
> 请确认是否按此 plan 执行?

## 用户确认

用户确认后, 交接到 executing-plans 或 subagent-driven-development 技能。
