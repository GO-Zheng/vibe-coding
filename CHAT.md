# Handoff: addyosmani/agent-skills 分析 — 可复制/参考的内容

## 概述

已完整分析 [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (76.4k stars). 该仓库提供 24 个 SDLC 全生命周期 skill + 4 个 agent personas + 7 个 reference checklists + 8 个 slash commands. 以下是与现有 vibe-coding 项目的对比及具体采纳建议.

## 当前状态对比

| 维度 | vibe-coding 现有 | addyosmani 有 | 建议 |
|------|------------------|---------------|------|
| AGENTS.md | 简短, 仅有基础指令 | 完整: intent→skill mapping + lifecycle + anti-rationalization | **重写** |
| CLAUDE.md | 11 字节, 几乎空 | 完整: 项目结构/约定/boundaries | **填写** |
| Skills | 4 个 (code-review, grilling, handoff, plan-review) | 24 个, 覆盖 Define→Plan→Build→Verify→Review→Ship | **新增 5-8 个** |
| Agent Personas | 0 (code-review 用内置 subagent) | 4 个: code-reviewer, security-auditor, test-engineer, web-perf-auditor | **新增 security-auditor + test-engineer** |
| References | 0 | 7 个: DoD, testing, security, perf, a11y, observability, orchestration | **新增 4 个** |
| Slash Commands | 0 | 8 个: spec, plan, build, test, review, code-simplify, ship, webperf | **暂缓, 仅参考设计** |
| Skill 结构 | 有 frontmatter + 流程 | 有 frontmatter + anti-rationalization tables + red flags + verification | **改进现有技能结构** |

## 建议采纳项 (按优先级)

### P0: 立即复制/参考

#### 1. AGENTS.md 重写

参考 [addyosmani AGENTS.md](https://raw.githubusercontent.com/addyosmani/agent-skills/main/AGENTS.md) 的结构, 加入:

- **Intent→Skill 映射**: feature→spec-driven-dev, bug→debugging, review→code-review 等
- **Lifecycle 绑定**: DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP 各阶段应调用的技能
- **Anti-rationalization**: "这个太小不需要 skill" 等借口及其反驳

对比: 现有 AGENTS.md 只有 22 行, 缺少路由逻辑. addyosmani 的版本提供了完整的决策树.

#### 2. 新增 Agent Personas

直接复制并汉化:

| 文件 | 源 URL | 用途 |
|------|--------|------|
| `agents/security-auditor.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/agents/security-auditor.md) | OWASP 安全审计, 含 LLM AI 安全 (prompt injection, excessive agency 等) |
| `agents/test-engineer.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/agents/test-engineer.md) | 测试策略 + coverage 分析 + Prove-It 模式 |

现有的 `code-review` 技能内部已经用了双 subagent, 可以与这些 personas 组合使用. security-auditor 的内容质量极高, 特别适合在 `/ship` 前做安全门禁.

#### 3. 新增 Reference Checklists

| 文件 | 源 URL | 说明 |
|------|--------|------|
| `references/definition-of-done.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/references/definition-of-done.md) | 项目级完成标准, 与 acceptance criteria 互补 |
| `references/security-checklist.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/references/security-checklist.md) | OWASP Top 10 + LLM Top 10 快速参考 |
| `references/testing-patterns.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/references/testing-patterns.md) | AAA 模式、mock 边界、React/API/E2E 示例、反模式 |
| `references/orchestration-patterns.md` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/references/orchestration-patterns.md) | Agent 协作模式: 并行扇出、序列管道、研究隔离、Agent Teams |

### P1: 参考设计 (需适配汉化)

#### 4. Skill 结构改进

现行 skills 缺少 addyosmani 的 signature 三段:

- **Common Rationalizations table**: 列举 agent 跳过步骤的借口 + 反驳
- **Red Flags**: 该技能执行走偏的预警信号
- **Verification checklist**: 完成后必须检查的条目

建议在 `skills/code-review/SKILL.md` 和 `skills/plan-review/SKILL.md` 中补充这三段. addyosmani 的 [code-review-and-quality](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/code-review-and-quality/SKILL.md) 是很好的范本.

#### 5. 参考新增 Skills

以下技能与现有体系互补, 建议有选择地新增:

| Skill | 参考 URL | 说明 |
|-------|----------|------|
| `context-engineering` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/context-engineering/SKILL.md) | 上下文层次管理、混淆处理、MCP 集成 — 对 session 管理极有价值 |
| `spec-driven-development` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/spec-driven-development/SKILL.md) | 六域 spec 模板 + gated workflow (接替 brainstorming) |
| `incremental-implementation` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/incremental-implementation/SKILL.md) | 垂直切片 + 每次 ~100 行 + scope discipline |
| `documentation-and-adrs` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/documentation-and-adrs/SKILL.md) | ADR 模板 + 生命周期 + API doc + agent context |
| `git-workflow-and-versioning` | [raw](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/git-workflow-and-versioning/SKILL.md) | trunk-based + atomic commit + 版本语义 + changelog |
| `source-driven-development` | 参考 repo | 官方文档优先于 agent 记忆 |

### P2: 设计模式 (不直接复制, 借鉴理念)

#### 6. Meta-skill 路由

addyosmani 的 [using-agent-skills](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/using-agent-skills/SKILL.md) 是一个 meta-skill, 描述了完整决策树. 可参考其流程图设计, 但不需要直接复制文件:

```
Task arrives
  ├── 不知要什么? → interview-me (现有 grilling)
  ├── 新功能? → spec-driven-development (待建)
  ├── 实现代码? → incremental-implementation (待建)
  ├── 测试? → test-driven-development (已有 Superpowers)
  ├── Review? → code-review (已有)
  └── ...
```

#### 7. Anti-rationalization 机制

addyosmani 的一个创新是每个 skill 都嵌入了 "agent 为什么想跳过这一步" 的辩解 + 反驳表. 这个模式可以应用到现有所有 skills:

```markdown
| 辩解 | 现实 |
|------|------|
| "这个太简单不需要 review" | 简单代码往往隐藏着最复杂的 bug. |
| "我测过了, 看起来没问题" | "看起来"不是证据. 必须运行测试命令. |
```

建议在 `rules/core/coding-principles.md` 中新增 "通用反合理化" 一节, 或在每个 skill 末尾附上.

#### 8. Skill Anatomy 标准化

addyosmani 的 skill 结构有明确的章节顺序:

```
Frontmatter (name, description)
Overview → When to Use → Process → Common Rationalizations → Red Flags → Verification
```

现有 skills 缺少 **When to Use** (何时/何时不用) 和 **Verification** 段. 建议按 [agentskills.io 规范](https://agentskills.io/specification) 统一.

## 不采纳项

| 项 | 理由 |
|----|------|
| Slash Commands (`/spec`, `/plan` 等) | 当前环境 (Cursor) 不支持 Claude Code 的 slash command 机制 |
| `performance-checklist.md` | 适合偏前端场景, 当前项目暂无 web 性能优化需求 |
| `observability-checklist.md` | 适合生产运维, 当前项目尚未进入部署阶段 |
| `shipping-and-launch` skill | 当前项目不涉及生产发布 |
| `web-performance-auditor` persona | 同上, 无 web 性能审计需求 |
| `doubt-driven-development` | 与 `interview-me`/`grilling` 概念重叠, 且需要多模型交互 |

## 关键引用

- addyosmani AGENTS.md: https://raw.githubusercontent.com/addyosmani/agent-skills/main/AGENTS.md
- addyosmani CLAUDE.md: https://raw.githubusercontent.com/addyosmani/agent-skills/main/CLAUDE.md
- 对比文档: https://raw.githubusercontent.com/addyosmani/agent-skills/main/docs/comparison.md
- 项目根: /root/code/dev/vibe-coding/
- 当前有效期 AGENTS.md: /root/code/dev/vibe-coding/AGENTS.md
- 当前有效期 rules manifest: /root/code/dev/vibe-coding/rules/manifest.yaml

## 下一步建议

1. 执行 P0: 复制 security-auditor + test-engineer personas + 4 个 checklists
2. 执行 P0: 重写 AGENTS.md (参考 addyosmani 的 intent→skill mapping)
3. 执行 P0: 填写 CLAUDE.md (参考 addyosmani 的项目结构 + 约定格式)
4. 执行 P1: 为现有 skills 补充 anti-rationalization + red flags + verification
5. 执行 P1: 新增 context-engineering 和 spec-driven-development 技能
6. 执行 P1: 将 git-workflow.md 升级为完整 skill


# link

- https://github.com/addyosmani/agent-skills
- https://github.com/garrytan/gstack
- https://github.com/microsoft/skills
- https://microsoft.github.io/skills
- https://agentskills.io/home