# HR 招聘助手：PyMySQL 未 commit 导致导入脚本误报成功（2026-05）

> **唯一维护位置**：本文件为该项目相关经验教训的**单一真相源**。  
> 项目仓库 [ailink-hr](https://github.com/singer2622525-netizen/ailink-hr) 内 `.cursor/rules/lessons-learned.md` 仅保留摘要；代码修复见 commit `17d350f`。

---

## 1. 背景与现象

- 生产环境 `https://hr.suuntoyun.com` 完成 HR-00 步骤 7 部署后，执行 `scripts/provision-dingtalk-dept-users.py` 批量导入 IT 测试部（部门 ID `1075848627`）9 人。
- 脚本逐行打印 `[ok]`，`check-dingtalk-provision.sh` 表面成功。
- 钉钉工作台打开「艾联-HR助手」仍返回 **403「尚未开通权限」**。
- 排查过程中曾误判为：钉钉 JSAPI 缺失、OpenAPI 权限、PM2 未加载 `.env` 等。

---

## 2. 根因

`MySQLUserAccountRepository.create_user()`（`apps/api/app/repositories/user_account.py`）使用 PyMySQL 连接，**默认 `autocommit=False`**：

1. `INSERT INTO user_account ...` 在同一连接内执行；
2. 紧接着 `SELECT` 能读到刚插入的行（同一未提交事务内可见）；
3. 函数返回成功，脚本打印 `[ok]`；
4. **`conn.commit()` 从未调用**，连接关闭时事务回滚；
5. 库里 `user_account` 实际 **0 行**，登录查库找不到用户 → 403。

验证命令（生产 API venv / MySQL）：

```sql
SELECT COUNT(*) FROM user_account;
-- 修复前：0
-- 修复并重新导入后：9
```

---

## 3. 解决

1. 在 `create_user()` 成功路径加 `conn.commit()`，异常时 `conn.rollback()`；
2. 重新部署 API（PM2 restart）；
3. 重新执行 `bash scripts/check-dingtalk-provision.sh` 导入 9 人；
4. 钉钉工作台重新打开，登录成功。

**代码 commit**：`17d350f` — `fix(db): user_account 写入后显式 commit`

---

## 4. 排查时间线（可复用）

| 阶段 | 怀疑方向 | 结果 |
|------|----------|------|
| 1 | 未引入钉钉 JSAPI | 已修 `8de614a`，仍 403 |
| 2 | 钉钉 OpenAPI 502 / 权限 | 开放平台权限已开，仍 403 |
| 3 | PM2 API 未读 `.env` | 已修 `95a1492`，仍 403 |
| 4 | **`create_user` 未 commit** | ✅ 根因；修后登录成功 |

**教训**：脚本/日志显示成功 ≠ 数据已持久化；MySQL 写操作必须查库确认。

---

## 5. 预防措施

### 5.1 代码规范

- 凡 PyMySQL **手动管理连接**的写操作（INSERT/UPDATE/DELETE），成功路径必须 **`conn.commit()`**；
- 批量导入、provision 脚本验收不能只看 `[ok]`，应查 `SELECT COUNT(*)` 或 health 指标（如 `staff_users`）。

### 5.2 部署验收清单

```bash
# 导入后必做
curl -s http://127.0.0.1:5106/health   # 期望 user_store=mysql, staff_users>=1
# 或直连 MySQL
SELECT COUNT(*) FROM user_account;
```

### 5.3 同类风险扫描

项目中其他 Repository 若使用相同 `_connection()` + cursor 模式，应逐一确认写操作是否有 commit。

---

## 6. 相关链接

- 项目：`https://github.com/singer2622525-netizen/ailink-hr`
- 生产域名：`https://hr.suuntoyun.com`
- 排障文档：`ailink-hr` 仓库 `docs/ops/HR-00-B1-IT测试部登录.md`

---

**创建日期**：2026-05-21  
**严重程度**：🟡 中（部署后功能不可用，修复成本低）  
**案例价值**：⭐⭐⭐⭐ 高（PyMySQL 事务 + 脚本误报，易在其他项目复现）
