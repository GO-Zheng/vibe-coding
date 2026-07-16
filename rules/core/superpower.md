# Superpowers 补充

## 文件存放

- implementation plan 统一保存到工作区根目录下的 `superpower/plans/`
- design spec 统一保存到工作区根目录下的 `superpower/specs/`
- 目录不存在则自动创建
- 不写入各项目仓库内的 `docs/superpowers/` 路径
- `superpower/` 是过程制品: **不从项目文档引用**; 对仓库仍有效的结论须同步进该项目仓内 `docs/` (见 `workflows/documentation-sync.md`)

## Plan 约定

- plan 中的关键假设必须使用 `[ASSUMPTION]` 标签显式标记

```markdown
### Task N: 组件名

[ASSUMPTION] 此处写下你的假设
```

- 审核时会以 `[ASSUMPTION]` 为检查重点, 让审校者快速定位决策点

## 技能替换

- code review 使用 `code-review` 技能, 不使用 Superpowers 自带的 `code-reviewer`
- TDD 使用 Superpowers 的 `test-driven-development` 技能, 补充以下步骤:

  **写测试前先确认 seam (测试接缝)**:
  - 写下要测试的 seam (哪个接口、哪个边界), 和用户确认后再开始写测试
  - 不在未确认的 seam 上写测试

