# vibe-coding 通用指令

> 跨工具 SSOT 入口. 细则在 `rules/`, 工作流在 `skills/`.
> Claude Code 通过 `@` 引用展开; Cursor 通过 adapters 生成 `.mdc`.

@rules/core/communication.md

## 代码原则

> 待迁入: rules/core/coding-principles.md

- 最小改动: 只改任务相关的代码
- 遵循项目现有风格和约定
- 好代码应自解释, 注释只写非显而易见的业务逻辑
- 先理解再动手, 用命令验证后再声称完成

## Git

> 待迁入: rules/core/git-safety.md

- 只在用户明确要求时 commit
- 不 force push main/master
- 不 skip hooks
