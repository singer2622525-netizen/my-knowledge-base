# 门铃只发 main、未核对其它已上线分支

摘要。全文在 global-governance：`03-knowledge-base/failure-cases/ailink-erp-feat-branch-overwrite-2026-08.md`

- 同事 `feat/2026-04-23-*` 上过正式站；Agent 在 `main` 接门铃反复 `[deploy-prod]`，现网菜单被盖掉。
- 改代码前必须 fetch 并核对其它可能已上线的分支。
