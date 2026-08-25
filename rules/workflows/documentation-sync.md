# 文档同步

在 commit 或完成 plan 前, 检查本次变更是否影响相关文档, 有影响则更新.

## 检查范围

- `README.md`: 功能, 使用方式或依赖.
- API / 模块文档: 接口, 行为或边界.
- 架构 / 设计文档: 模块或取舍.
- `AGENTS.md`, `CONTEXT.md`: 术语, 硬约束或工作流.
- `CHANGELOG.md`: 项目已有更新日志惯例时.

## 过程制品

- 工作区根 `superpowers/plans/`, `superpowers/specs/` 不进项目仓库, 也不从项目文档引用.
- 对仓库仍有效的结论和约束, 写入本仓 `docs/`, `DESIGN` 或 `ARCHITECTURE`.

## 操作要求

- 文档有影响时, 更新后再提交.
- plan 完成后, 在审核通过前确认是否需要同步文档.
- 文档无影响时, 向用户说明「文档无需变更」后再进入 commit 确认.
