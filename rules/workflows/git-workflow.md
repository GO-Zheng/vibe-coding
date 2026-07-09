# Git 工作流

## 提交规范

遵循 Conventional Commits 格式。

- **type** 保留英文: `feat`, `fix`, `refactor`, `test`, `docs`, `chore` 等
- **描述与正文** 使用中文, 简述变更目的
- 例: `feat: 添加 WAL 崩溃恢复`

## 分支工作流

1. 修改前从原分支创建新分支; 原分支优先读项目 `AGENTS.md` 约定, 未明示则询问
2. 改完后必须等用户审核通过后方可 commit
3. 完整计划完成后, 经允许将新分支 squash 合并回原分支, 随后删除新分支

## 推送

- 不推送远程仓库, 由用户手动操作
