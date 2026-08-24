---
name: handoff
description: 将当前对话压缩为交接摘要, 供新 session 续接.保存到工作区根目录 CHAT.md.
---

# Handoff

将当前对话压缩为交接摘要, 写入工作区根目录 `CHAT.md`.新 session 通过 `@CHAT.md` 引用即可续接.

## 要求

- 不要在交接文档中重复已存在于其他制品 (spec, plan, commit, diff, issue) 的内容, 用路径引用代替
- 包含一个 "建议使用的技能" 小节, 推荐新 session 应调用的技能
- 脱敏: 删除 API key, 密码, 个人身份信息等敏感内容
- 如果用户传入了参数, 按参数描述的焦点定制交接摘要
