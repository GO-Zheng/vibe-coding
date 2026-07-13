# Session: addyosmani/agent-skills 分析 — interview-me 深读

> 延续 CHAT.md 的上次分析, 当前 session 聚焦逐个深读 addyosmani 的 SKILL.md,
> 从 interview-me 开始, 提取可借鉴的设计模式。

## 时间

2026-07-13

## 关键纠正 (from 用户)

1. **CLAUDE.md 引用 AGENTS.md**: 这是行业标准做法, 不应改变。当前 `CLAUDE.md` 只写
   `@AGENTS.md` 是正确的, 不需要填充更多内容。
2. **AGENTS.md 修改顺序**: 应先完善工作流 (skills) 再写路由映射, 不能反过来。
3. **Skills 结构符合官方标准**: 当前 skills 遵循 [agentskills.io 规范](https://agentskills.io/specification)
   — 必需 frontmatter (name + description), 正文无格式限制. addyosmani 的
   "6 段标准结构" (Overview → When to Use → Process → Rationalizations → Red Flags → Verification)
   是其仓库自身的推荐模式, 不是官方标准。之前的对比分析混淆了这一点。

## addyosmani 生命周期概览

| Phase | Skills 数 | Skills 列表 |
|-------|-----------|-------------|
| DEFINE | 3 | interview-me, idea-refine, spec-driven-development |
| PLAN | 1 | planning-and-task-breakdown |
| BUILD | 7 | incremental-implementation, tdd, context-engineering, source-driven-development, doubt-driven-development, frontend-ui-engineering, api-and-interface-design |
| VERIFY | 2 | browser-testing-with-devtools, debugging-and-error-recovery |
| REVIEW | 4 | code-review-and-quality, code-simplification, security-and-hardening, performance-optimization |
| SHIP | 6 | git-workflow-and-versioning, ci-cd-and-automation, deprecation-and-migration, documentation-and-adrs, observability-and-instrumentation, shipping-and-launch |
| META | 1 | using-agent-skills |

合计 24 skills. vibe-coding 现有 4 个 (code-review, plan-review, grilling, handoff),
BUILD 和 VERIFY 阶段为空白。

## 深读: interview-me

### 核心思想

用户在说"我要一个仪表盘"时, 真正想要的可能是"一个列表"。这个 gap 在写第一行代码前
修复是零成本, 之后成本巨大。

### 可借鉴的设计模式

1. **Hypothesis + Confidence**: 提问前先写一句话假设 + 0-100% 置信度数字, 迫使 agent
   暴露隐性假设。
2. **GUESS 附在每个问题后**: `Q: ... GUESS: ...` 格式。用户修正错误假设比从零生成答案
   快得多。
3. **"想要 vs 应该要" 探测**: 识别"可扩展"、"整洁架构"等信号词, 用"如果你不需要向任何人
   解释, 你真正想要什么?"破局。
4. **6 行结构化 Restate**: Outcome / User / Why now / Success / Constraint / Out of scope。
   Out of scope 不可省略 — 一半的误解来自对"不做什么"的沉默假设。
5. **95% 信心停止条件**: "我能预测用户接下来三个问题怎么回答吗?" — 可检验的退出标准。
6. **三段式尾声**: Common Rationalizations (8 条) + Red Flags (12 条) + Verification (8 条)。

### 现状对比: grilling vs interview-me

| 维度 | grilling | interview-me |
|------|----------|--------------|
| 获取假设 | 没有 | Hypothesis + Confidence % |
| 提问方式 | 一次一个 ✅ | 一次一个 + 每个附带 GUESS |
| 检测假共识 | 没有 | "想要 vs 应该要"探测器 |
| 确认模板 | "达成共识"(模糊) | 6 行结构化 Restate |
| 退出条件 | 没有 | 95% 可检验标准 |
| Anti-Rationalization | 没有 | 8 条 |
| Red Flags | 没有 | 12 条 |
| Verification | 没有 | 8 条 |

## 待讨论的 7 个决策点

1. **Hypothesis + Confidence**: 是否融入 grilling?
2. **GUESS 格式**: 格式化增强还是纯形式变化?
3. **"想要 vs 应该要" 探测**: 适合 grilling 还是新建需求澄清 skill?
4. **结构化 Restate**: 6 行确认模板是否通用?
5. **95% 停止条件**: grilling 是否要量化退出条件?
6. **三段式结构**: 作为所有 skill 的统一结尾, 还是仅 grilling?
7. **skill 合并策略**: 把 interview-me 模式融入 grilling, 还是保持独立?

## 待执行的技能深读 (按 SDLC 顺序)

1. interview-me ✅ (已完成)
2. idea-refine
3. spec-driven-development
4. planning-and-task-breakdown
5. incremental-implementation
6. test-driven-development
7. context-engineering
8. source-driven-development
9. doubt-driven-development
10. frontend-ui-engineering
11. api-and-interface-design
12. browser-testing-with-devtools
13. debugging-and-error-recovery
14. code-review-and-quality
15. code-simplification
16. security-and-hardening
17. performance-optimization
18. git-workflow-and-versioning
19. ci-cd-and-automation
20. deprecation-and-migration
21. documentation-and-adrs
22. observability-and-instrumentation
23. shipping-and-launch
24. using-agent-skills

## 当前 git 状态

- 分支: main, up-to-date with origin/main
- 未暂存修改: adapters/claude.sh (上次遗留的 rules 同步逻辑, 非本次变更)
- 无其他未提交变更

## 下一步建议 (用户确认后执行)

1. 确认 7 个决策点的方向
2. 按 SDLC 顺序逐个深读剩余 skills
3. 所有技能读完后, 再决定最终修改方案
4. 最后更新 AGENTS.md 做 intent→skill 映射
