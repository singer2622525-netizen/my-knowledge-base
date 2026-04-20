# 招聘人格评测（assessment）搬迁与 PM2 上线踩坑复盘（2026-04）

> **唯一维护位置**：本文件为该项目相关经验教训的**单一真相源**（不再与项目内 `.cursor/rules/lessons-learned.md` 双写）。  
> 项目仓库 README 中有指向本文件的链接。

---

## 1. 背景与现象

- Dell 服务器搬迁、更换网线，内网 IP 从文档中的 `192.168.13.x` 变为 **`192.168.0.23`**（示例）。
- 公网 **`https://assessment.suuntoyun.com`** 出现 **502**；修复后出现 **静态资源 404**、**管理后台数据为空/白屏**、**候选人列整列空白** 等问题。

---

## 2. 根因与对策（按时间线可复用）

### 2.1 Cloudflare Tunnel 仍指向旧 IP / 错误端口

- **现象**：502。
- **根因**：`/etc/cloudflared/config.yml` 中 `assessment.suuntoyun.com` 指向 **`http://192.168.13.44:30080`**，搬迁后该地址不可达或 **30080 无监听**。
- **对策**：改为 **`http://127.0.0.1:<PM2 实际端口>`**（本项目为 **3015**），执行 `sudo systemctl restart cloudflared`。  
- **教训**：Tunnel **ingress 优先用本机回环地址 + 应用端口**，避免写死会随机房变化的局域网 IP。

### 2.2 Next.js `output: 'standalone'` 缺少静态文件

- **现象**：HTML 能打开，`/_next/static/*`、`/favicon.ico` 等 404，页面无样式。
- **根因**：`standalone` 目录内 **`.next/static` 为空**；构建产物在上一级 `.next/static`。
- **对策**：每次 `npm run build` 后执行（路径按实际部署目录调整）：

```bash
ST=/home/songtuo/下载/.next/standalone
ROOT=/home/songtuo/下载
mkdir -p "$ST/.next/static"
rsync -a --delete "$ROOT/.next/static/" "$ST/.next/static/"
test -d "$ROOT/public" && rsync -a --delete "$ROOT/public/" "$ST/public/"
```

### 2.3 本机 3000 已被其他应用占用

- **根因**：评测应用若绑 **3000**，与同机 **draw-io** 等冲突。
- **对策**：使用 **`PORT=3015`**（示例）+ **`ecosystem.config.cjs`** 持久化；Tunnel 指向 **3015**。

### 2.4 `next build` 覆盖 standalone 内的 SQLite

- **现象**：「数据又没了」或只剩空库。
- **根因**：**`next build` 会重新生成 `.next/standalone`，其中 `data/` 可能被重置**；业务库权威副本若在 **`/mnt/data/k8s/personality-assessment/`** 等路径，与 standalone 内 **`data/assessment.db`** 脱节。
- **对策**：每次在服务器构建后 **固定一步**：停止 PM2 → 从权威路径 **拷回 `assessment.db`（及 `-shm`、`-wal` 若存在）** → 再启动；或将 **`DATABASE_PATH`** 指向 standalone **外**的目录（需改代码并评估权限）。  
- **教训**：**不要把「唯一真库」只放在会被构建覆盖的目录里**。

### 2.5 `GET /api/sessions` 使用 `...session` 导致 snake_case

- **现象**：统计/时间/状态看似正常，**候选人姓名、邮箱、手机列整列为空**。
- **根因**：接口 JSON 为 **`candidate_name`** 等，前端读 **`candidateName`**。
- **对策**：服务端 **显式映射驼峰**；客户端在 **`sessionApi.get` / `getAll`** 增加 **`normalizeSessionFromApi`** 双保险；`answers`/`results` 使用 **安全 JSON 解析**，避免单行坏数据拖垮整表。

### 2.6 管理后台 `toLowerCase` 白屏

- **根因**：历史数据字段为 **NULL**，旧前端对 **`candidateName` 直接 `.toLowerCase()`**。
- **对策**：搜索与展示前 **`String(x ?? '')`**；状态用 **`coerceSessionStatus`** 归一到联合类型。

---

## 3. 推荐检查清单（上线 / 搬迁后）

1. `curl -I https://assessment.suuntoyun.com` 非 502。  
2. `grep -A1 assessment /etc/cloudflared/config.yml` 为 `127.0.0.1` + 正确端口。  
3. `pm2 list` 中 `personality-assessment` 为 **online**。  
4. `curl -s http://127.0.0.1:3015/api/sessions | head -c 400` 中字段为 **`candidateName`**（驼峰）。  
5. `curl -I http://127.0.0.1:3015/_next/static/css/` 或任取一个 chunk URL 为 **200**。  
6. 构建后已 **从权威路径恢复 `assessment.db*`**（若库不在 standalone 外）。

---

## 4. 相关仓库与运维记录

- 应用代码：`personality-assessment-system`（GitHub）。  
- 运维流水：`my-ops-log` 下 **`招聘人格评测结果智能分析-ok/2026-04.md`**。

---

**文档位置**：`/Users/a1/Documents/Projects/cursor/03-knowledge-base/failure-cases/personality-assessment-deployment-2026-04.md`  
**最后更新**：2026-04-14
