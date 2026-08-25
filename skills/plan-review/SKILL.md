---
name: plan-review
description: 在 implementation plan 执行前需要检查计划时使用.
---

# Plan Review

对已生成的 implementation plan 进行一次单 agent 审核, 不自动循环.

## 前置条件

- plan 文件已写入工作区根 `superpowers/plans/` 或指定路径
- plan 遵循 writing-plans 技能的标准格式
- 在执行任何 review 动作前, 必须主动询问用户是否启动 plan review.
- reviewer agent 必须继承当前会话使用的模型, 不得自行指定, 切换或回退到其他模型.
- 用户拒绝启动时, 停止并汇报, 不得启动 review.

## 流程

### Step 0: 获取 review 授权

先向用户询问:

> 是否启动 plan review? 本轮将继承当前会话模型, 只执行一轮单审.

未获得明确同意前, 不读取 plan 进入审核流程, 不启动任何 reviewer agent.

### Step 1: 读取 plan

读取 plan 文件的完整内容, 确认所有 task 定义, 文件路径, 代码示例.

### Step 2: 审核

使用当前会话模型启动 1 个 subagent 审核 plan. 审核标准见 `references/reviewer-prompt.md`.

### Step 3: 审核结果

等待 subagent 完成, 汇总审核结果:

- subagent 的审核结论.
- 所有 critical / major 问题列表.
- 所有 minor 建议列表.
- 本次为唯一一轮 review, 不自动启动第二个 reviewer 或第二轮.

## 审核结论定义

| 结论 | 含义 | 处理 |
|------|------|------|
| APPROVED | 无问题或只有 trivial 建议, plan 可以直接执行 | 通过 |
| CONDITIONALLY_APPROVED | 只有 minor 问题, 不阻碍执行 | 本轮结束, 记录建议 |
| REJECTED | 存在 critical 或 major 问题, plan 不可直接执行 | 本轮结束, 记录问题 |

### Step 4: 判定

- subagent 返回 `APPROVED` → 进入 Step 6.
- subagent 返回非 `APPROVED` → 进入 Step 5, 不自动再次审核.
- 本轮结束后, 必须主动询问用户是否循环进行下一轮, 以及是否结束 review.
- 用户未明确允许下一轮时, 停止 review.
- 本轮仍有明显问题, 尤其是 critical / major 或会导致执行失败的缺陷时, 建议结束 review 并从头重写 plan; 不继续局部修订.

### Step 5: 修订与定向验证

根据审核意见修订 plan. 修订后不得自动回到 Step 2; 只有用户明确允许循环时, 才能开始下一轮, 且每次仍只执行一轮审核.

plan review 不执行项目测试. 只检查 plan 中的验证步骤是否覆盖修改或受影响的部分, 并要求验证命令保持最小相关范围; 不得因为 review 自行扩展为全量测试.

修订时同步检查 `rules/workflows/documentation-sync.md` 确认相关文档是否需更新.

### Step 6: 输出

向用户汇报最终结果:

> Plan 审核完成: `<plan 路径>`
> 审核模型: `<继承当前会话模型>`
> 审核结果: `<最终结论>`
> 本轮仅执行 1 轮
> 最终修订包括: ...
> 测试策略: 仅检查与修改或受影响部分相关的验证步骤, 未执行项目测试
> 请确认是否结束 review, 或是否允许开始下一轮?

如果仍有明显问题, 输出 `NEEDS_REPLAN`, 明确列出未解决的问题, 请求用户重新确认需求与 plan, 不得输出“可以执行”.

## 用户确认

用户确认后, 交接到 executing-plans 或 subagent-driven-development 技能.
