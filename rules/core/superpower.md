# Superpowers 补充

## 文件存放

- implementation plan 统一保存到工作区根目录下的 `superpower/plans/`
- design spec 统一保存到工作区根目录下的 `superpower/specs/`
- 目录不存在则自动创建
- 不写入各项目仓库内的 `docs/superpowers/` 路径

## Plan 约定

- plan 中的关键假设必须使用 `[ASSUMPTION]` 标签显式标记

```markdown
### Task N: 组件名

[ASSUMPTION] 此处写下你的假设
```

- 审核时会以 `[ASSUMPTION]` 为检查重点, 让审校者快速定位决策点
