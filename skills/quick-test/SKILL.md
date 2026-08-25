---
name: quick-test
description: 根据当前 Git diff 选择最小必要测试, 用于小范围变更后的快速验证.
---

# Quick Test

针对当前仓库的 Git diff 做定向验证, 可独立调用或作为 `quick` 的测试阶段.

## 流程

1. 用 `git diff HEAD` 获取 staged 和 unstaged 变更; diff 为空则停止.
2. 根据修改的文件, 符号, 行为和依赖关系识别受影响测试.
3. 选择最小范围, 优先 unit test, 目标 integration test, feature 或过滤器.
4. 影响范围不明确时, 说明扩大范围的原因和成本并询问用户.
5. 按确认范围执行; 失败后停止, 不自动修复或重试, 汇报命令, 覆盖范围, 结果和未验证部分.

## 约束

- 不运行无关的全量, workspace 或压力测试.
- 用户指定范围或项目硬性门禁优先; 冲突时按 `rule-conflict-resolution` 处理.
- 不把未执行的测试描述为已验证.
