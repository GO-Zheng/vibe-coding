# Git 工作流

## 提交

- 遵循 Conventional Commits; `type` 使用英文, 描述和正文使用中文.
- 常用类型: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- 示例: `feat: 添加 WAL 崩溃恢复`.

## 分支与集成

- 设计或方案达成共识后, implement 前, 从原分支创建工作分支.
- 创建前先读取项目 `AGENTS.md`; 约定不明确时主动询问用户.
- 改动完成并经用户审核后才能 commit.
- 计划完成且用户允许后, 将工作分支 squash 合并并删除.
- code review 通过后, 用户确认 commit 前, 按 `documentation-sync` 检查文档.

## 推送

- 不自动推送远程仓库, 只能由用户手动操作.
