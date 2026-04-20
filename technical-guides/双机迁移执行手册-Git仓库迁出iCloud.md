# 双机开发环境迁移手册（Git 仓库迁出 iCloud Documents）

> 背景：iCloud Drive 同步 `~/Documents/` 会连同 Git 仓库的 `.git/` 内部文件一起同步，
> 偶尔产生坏 ref（如 `refs/heads/main 2`）或损坏 commit 对象，导致 `git fetch` 报
> `bad object`。本手册给出把 Git 仓库迁出 iCloud、改用纯 Git 同步的步骤。
>
> **前置原则**：必须在**两台 Mac 都在场的当天**做，避免跨机器数据丢失。

---

## 为什么本手册存在

2026-04-20 在家里 Mac 尝试迁移，发现两个关键困难：

1. **iCloud 占位符**：家里 Mac 上，`~/Documents/` 里的文件大部分是 iCloud 云端占位符（没下载到本地）。`cp -R` 或 `rsync` 读取时会一个一个触发下载，慢到不可用（实测 rsync cursor 目录 2.5 小时只复制 58M）。
2. **node_modules 符号链接循环**：npm 项目的 `node_modules/.bin/` 里有大量符号链接，`cp -R` 会陷入无限递归并报 "Too many levels of symbolic links"。

所以家里 Mac 上不能直接本地搬迁 —— 必须**绕过 iCloud，通过 git clone 从 GitHub 拉取**。

---

## 迁移目标

```
迁移前：
  ~/Documents/Projects/cursor/...              （14 个 Git 仓库，iCloud 同步中）
  ~/Documents/my-ops-log                       （iCloud 同步中）

迁移后：
  ~/Projects/<仓库名>/                          （纯 Git 同步，不碰 iCloud）
  ~/Documents/... 下旧副本                      （保留做冷备份，不再操作）
```

---

## 前置条件（开始前确认）

- [ ] 两台 Mac 今天都在场（家里 Mac + 公司 Mac）
- [ ] 两台 Mac 都有 SSH key 配置好，能访问所有要迁的 GitHub 仓库
- [ ] 家里 Mac 的 `~/Projects/` 下已有 3 个"引路"仓库：祈福牌源码、my-ops-log、my-knowledge-base（2026-04-20 已由 clone 建立）
- [ ] 公司 Mac 的 `~/Projects/` 目录**不存在**（避免冲突）
- [ ] 所有仓库在**两台 Mac 的原位置**都已 `git push`，无丢失风险

---

## 步骤 A：确认两台都无未 push 改动

在**两台 Mac** 各自执行：

```bash
# 对每个 Git 仓库都做一遍
cd <某仓库路径>
git status                        # 未提交改动
git log @{u}..HEAD --oneline      # 未 push 的 commit
```

发现未 push 的 commit → 先 `git push` 到远程。
发现未提交的改动 → commit 后 push，或用 `git stash push` 暂存（stash 会随仓库迁移一起过去）。

**建议使用的便捷函数**（已加在 `~/.zshrc`）：

```bash
check-repos   # 查看 3 个核心仓库的未提交/未 push 情况
```

如需扩展到更多仓库，编辑 `~/.zshrc` 里的 `_DEV_REPOS` 数组。

---

## 步骤 B：给无 remote 的仓库补 remote（可选但强烈推荐）

诊断脚本发现有 3 个仓库没有 GitHub remote：

- `SSH远程登录服务器工具包（基于mac）`
- `sursor 环境配置`
- `next-ai-draw-io -本地 2`

这 3 个没有云端备份，**迁移过程中任何意外都会导致丢失**。两种处理方式：

### B1：给它们建 GitHub 私有仓库并 push（推荐）
在 GitHub 网页创建 3 个空私有仓库，然后在本地分别：
```bash
cd <仓库路径>
git remote add origin git@github.com:singer2622525-netizen/<仓库名>.git
git push -u origin main
```

### B2：临时打包备份
```bash
tar czf ~/Desktop/<名字>-backup-$(date +%Y%m%d).tar.gz <仓库路径>
```
放到桌面或 U 盘，迁移后删除即可。

---

## 步骤 C：在家里 Mac 迁移（2026-04-20 已完成 3 个核心仓库）

家里 Mac **已经有** `~/Projects/` 下的 3 个核心仓库（祈福牌源码、my-ops-log、my-knowledge-base）。其他仓库需要同样 clone：

```bash
cd ~/Projects
# 每个有 remote 的仓库都 clone 一次
git clone <ssh_or_https_url> <目标目录名>
```

对于**无 remote 的仓库**，参考步骤 B1 先给它建 remote，再 clone。

**关键：不要 cp 或 rsync**。clone 的速度比本地 cp 快 10~100 倍（因为不经过 iCloud 占位符下载）。

---

## 步骤 D：在公司 Mac 迁移

公司 Mac 上 `~/Documents/Projects/` 里的文件**大概率已全部下载到本地**（日常工作机，iCloud 一直在同步）。所以公司 Mac 上用本地 cp/mv 都行，比家里快得多。但为了一致性，**推荐同样用 git clone**：

```bash
mkdir -p ~/Projects
cd ~/Projects
git clone <url> <目标目录名>
# 对每个仓库重复
```

或者**本地直接复制**（公司 Mac 速度快时）：

```bash
mkdir -p ~/Projects
# 只搬有 Git 的目录，排除 node_modules
rsync -aq --exclude 'node_modules' --exclude 'dist' --exclude 'build' \
  ~/Documents/Projects/cursor ~/Projects/cursor
rsync -aq ~/Documents/my-ops-log ~/Projects/my-ops-log
```

---

## 步骤 E：验证新路径

两台 Mac 都执行：

```bash
cd ~/Projects/<仓库名>
git status                # 应显示 "clean" 或"预期的未提交"
git log -1 --format='%h %s'  # 应和远程最新 commit 一致
git remote -v             # remote 配置正确
```

用封装好的命令一次性检查：

```bash
check-repos
```

---

## 步骤 F：更新 `~/.zshrc` 里的仓库路径

`~/.zshrc` 里的 `_DEV_REPOS` 数组目前指向 `~/Documents/` 下的老位置。迁移后改成新位置：

```bash
# 打开 .zshrc
open -e ~/.zshrc

# 找到 _DEV_REPOS=(...) 部分，改成：
_DEV_REPOS=(
  "$HOME/Projects/祈福牌源码"
  "$HOME/Projects/my-ops-log"
  "$HOME/Projects/my-knowledge-base"
  # 如果要加其他仓库也在这里加
)

# 保存后重新加载
source ~/.zshrc

# 验证
check-repos
```

---

## 步骤 G：更新 Cursor 用户级 Rules 里的硬编码路径

用户级 Rules（在 Cursor 设置 → Rules）里有两处硬编码路径：

1. **运维记录**：`当前工作区根路径对应的用户主目录下的 Documents/my-ops-log`
2. **00-environments**：`<用户主目录>/Documents/Projects/cursor/00-environments`

迁移后应改为：

1. 运维记录：`<用户主目录>/Projects/my-ops-log`（如果 my-ops-log 也迁了）
2. 00-environments：`<用户主目录>/Projects/cursor/00-environments`（如果整个 cursor 也迁了）

**手动编辑方法**：在 Cursor 里 `⌘ + ,` → Rules → 用户级 → 找到"环境配置文档（00-environments）与 Git 同步"和"运维与多项目痕迹记录"两节 → 替换路径 → 保存。

---

## 步骤 H：收尾 — Documents 下的旧副本如何处理

两种策略，任选其一：

### H1：保留作冷备份（推荐，运行 1~2 周稳定后再删）
- 不做任何操作
- 它们继续被 iCloud 同步，但你不再编辑它们
- 1~2 周后新路径确认无问题，再删（见 H2）

### H2：彻底清理
```bash
# ⚠️ 在两台 Mac 都验证新位置工作正常后才做
rm -rf ~/Documents/Projects/cursor/<已迁移的仓库们>
rm -rf ~/Documents/my-ops-log
```

**提醒**：在家里 Mac 做 rm，iCloud 会把"删除"同步到公司 Mac，所以只需在一台 Mac 删即可。但建议**两台都执行 `rm` 之前**再各自检查一次，确保没有意外的未提交改动。

---

## 常见问题

### Q1：家里 Mac 的 `~/Documents/Projects/` 里还有 11 个其他 Git 仓库没迁，怎么办？
A：今天只搬了最活跃的 3 个。其他 11 个如果你不高频双机操作，保持现状（iCloud 同步 + 偶发坏 ref）也能用，坏 ref 出现时手动修即可。
等哪个开始高频操作再迁哪个。

### Q2：迁移后公司 Mac 发现 `~/Documents/` 下的文件被 iCloud 删了（同步了家里的 rm）怎么办？
A：从 `~/Projects/` 或 GitHub 重新拿即可（都是镜像）。所以步骤 A 的"确认两台都 push"是关键保险。

### Q3：迁移后 `check-repos` 还显示旧路径的数据？
A：没改 `.zshrc` 里的 `_DEV_REPOS`。见步骤 F。

### Q4：某个仓库原地有 stash，迁移后 stash 没了？
A：`git stash` 的数据在 `.git/refs/stash` 里，git clone 默认**不复制 stash**。
解决：迁移前 `git stash pop` 应用到工作区，再 commit 或 push 分支；或者用 `git stash show --name-only` 记下哪些文件 stash 了，迁移后重新 stash。

### Q5：无 remote 的仓库想迁但不想上 GitHub？
A：用本地 rsync 复制（公司 Mac 一般能顺利做到）：
```bash
rsync -av <源> <目标>
```

---

## 风险回溯：为什么 2026-04-20 家里 Mac 搬不动？

| 原因 | 具体 | 避免方法 |
|---|---|---|
| iCloud 占位符 | Documents 下 1.8G 的 `agent 课程学习` 目录大部分在云端，cp/rsync 触发下载 | 用 git clone（来自 GitHub 网络，不经过 iCloud） |
| node_modules 符号链接 | npm 的 `.bin/` 目录全是符号链接循环 | 排除 `node_modules`；或用 git clone（GitHub 上本来就不含 node_modules） |
| 网络速度 | 家里上行/下行速度不如公司 | 公司 Mac 做迁移；家里 Mac 只 clone（clone 是单向下载，更快） |

**总结**：双机迁移的正确姿势是**两台都用 git clone 从 GitHub 拉取**，完全不走 iCloud / 本地 cp。

---

## 关联文档

- `.zshrc` 里的 `sync-dev` / `check-repos` 函数（2026-04-21 加）
- `my-ops-log/祈福牌源码/2026-04.md` 的 iCloud 冲突相关记录
- 用户级 Rules 中「Git 双机开发部署最小规范」
- 用户级 Rules 中"反模式：沉没成本谬误"（本次已触发止损）
