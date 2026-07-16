# 文档同步

commit 或完成 plan 时, 检查本次变更是否影响相关文档, 有影响则更新。

## 检查范围

- README.md（功能说明、使用方式、依赖变更）
- API / 模块文档（`docs/modules/` 等: 接口、行为、边界变更）
- 架构 / 设计说明（ARCHITECTURE.md、DESIGN.md: 模块增减、取舍变更）
- 项目 AGENTS.md、CONTEXT.md（术语、硬约束、工作流约定）
- CHANGELOG.md（如有更新日志惯例）

## 过程制品 vs 仓内文档

- 工作区根 `superpower/plans/`、`superpower/specs/` 是过程制品, **不进项目仓库**, 也 **不从项目文档引用**
- 对仓库仍有效的结论、约束、对照表, 须同步进本仓 `docs/` (或 DESIGN / ARCHITECTURE), 再以仓内路径引用

## 操作要求

- commit 前: 检查变更涉及的文档, 不一致则更新后再提交
- plan 完成后: 在审核通过前确认文档是否需同步更新
- 文档无影响时, 向用户明示「文档无需变更」后再进入确认 commit
