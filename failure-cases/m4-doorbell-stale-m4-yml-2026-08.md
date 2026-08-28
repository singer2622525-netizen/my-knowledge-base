# 门铃用 fetch 前的旧 m4.yml，误判成测试号密码没配（2026-08）

全文维护在 global-governance：`03-knowledge-base/failure-cases/m4-doorbell-stale-m4-yml-2026-08.md`。

| 属性 | 内容 |
|------|------|
| 日期 | 2026-08-28 |
| 类型 | 误判根因 / 门铃读配置时机 |
| 涉及 | 创联 PMS；门铃 `m4-prod-deploy-watch` |

## 一句话教训

> **别把「测号登不上」默认说成 M4 没配测试密码。先看门铃读的是不是这一版 m4.yml；ERP/SSC 能登就说明密钥在。**
