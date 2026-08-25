# 文档图示

适用于 Markdown 文档中的流程, 架构, 数据流, 时序和状态图.

- 统一使用 Mermaid 代码块, 按场景选择 `flowchart`, `sequenceDiagram` 或
  `stateDiagram-v2`.
- 不用 ASCII 艺术图代替 Mermaid.
- 节点名避免 `*`, `()`, `→` 等特殊字符; 说明文字使用中文, 可用 `participant X as 显示名`, 协议关键字和类型名保留英文.

```mermaid
flowchart LR
    A[开始] --> B[完成]
```
