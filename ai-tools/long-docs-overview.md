# long 项目文档索引

> 项目：Redis Vote Wall — Boss 点击放置游戏
> 作者：WwhdsOne
> 仓库：`~/reference/long/`
> 语言：Go (Hertz) + Vue 3 + Redis
> 总文档：78 篇 Markdown，~563 KB

---

## 文档目录结构

```
docs/
├── YYYY-MM-DD-*.md              ← 顶层：单次任务/总结/公告（14篇）
├── designs/                     ← 设计草案/策划案（13篇）
├── developer-reference/         ← 开发参考/数值指南（11篇）
├── effects/                     ← 像素特效清单/约束（2篇）
├── implementation/              ← 实施记录/落地说明（12篇）
├── reports/                     ← 阶段性报告/开发日志（7篇）
├── specs/                       ← 数值规范/判定规程（2篇）
├── superpowers/                 ← AI Agent 生成的计划和设计（16篇）
│   ├── plans/                   ← 实施计划（9篇）
│   └── specs/                   ← 设计规格（4篇）
└── demos/                       ← HTML 演示文件（3个）
```

## 按时间线排序的关键演进

### 2026-04-21 ~ 04-23 — 初期膨胀期
- 原石强化、外观商店、技能树、英雄成长等大量设计
- **多数已废弃**，方向探索阶段

### 2026-04-24 ~ 04-25 — 转型期
- 放弃前台分页/商店，转向 Boss 分区战斗
- Boss 多部位系统设计 + 装备系统
- 装备稀有度/成长数值规范确立

### 2026-04-26 — 装备与数值落地
- 装备实例化 + 强化背包
- 暴击/暴伤调参指南
- 挂机持久化 + 伤害计算

### 2026-04-27 — 天赋与技能体系
- 天赋树大型改造
- 装备掉落事件链路
- 核心技能原理文档（均衡攻势/碎盾攻坚/致命洞察）

### 2026-04-28 — 成本与伤害优化
- 天赋成本调整
- 点击伤害链路全面优化
- 特效清单确立

### 2026-04-29 — UX 与特效
- Boss战斗区 UI 布局调整
- 伤害动画优先级
- 像素特效图鉴墙设计

### 2026-04-30 — V2 版本
- 天赋系统数值 V2
- 伤害计算链路 V2
- Buff 栏与伤害链路改动评估

### 2026-05-01 — 基础设施升级
- MongoDB 主存方案
- 冷数据迁移
- 日志系统演进
- 任务系统与 Mongo 整合

### 2026-05-02 — 最新
- 任务模型升级（`eventKind + windowKind` 替换 `taskType + conditionKind`）
- 红点轮询（10s 间隔）+ 资料页稀有度样式统一
- 资料页装备栏 3+3 槽位 + 生成失败 Mongo 日志
- 版本更新公告发布
- **部署升级**：Dockerfile 改用 `long-basic:latest`（alpine + nginx 精简镜像），Nginx 集成 SSE 代理，Consul 配置热更新

---

## 部署环境

| 项目 | 详情 |
|------|------|
| **服务器** | 阿里云 ECS `47.93.83.136`（杭州） |
| **SSH** | `ssh -i ~/.ssh/id_ed25519 -p 2222 root@47.93.83.136` |
| **OS** | Ubuntu 22.04 LTS |
| **磁盘** | 40G（已用 ~18G / 48%） |
| **带宽** | ↓103 Mbps / ↑3.3 Mbps |
| **Docker 版本** | 29.1.3 |

### 镜像架构

```
long-basic:latest (alpine + nginx + ca-certificates)
  └── long:latest (Go 后端 + Vue3 前端 + Nginx)
       ├── /app/backend/long  (Go 二进制, 19MB)
       ├── /app/backend/public/  (Vite 构建产物)
       ├── /etc/nginx/nginx.conf  (SSE + WebSocket 代理)
       └── /entrypoint.sh  (Go 后端 + nginx 双进程)
```

### 服务端口

| 端口 | 用途 |
|------|------|
| `16002` | 对外暴露（Nginx → Go :18080） |
| `18080` | 容器内 Go 后端 |
| `:8500` | Consul（外部，`my-consul`） |
| `:6379` | Redis（外部） |

### 配置

- **Consul**：`CONSUL_ADDR=my-consul:8500`，`CONSUL_CONFIG_KEY=long-produce.config`
- **Redis**：`.env` 中 `REDIS_HOST=localhost:6379`，`REDIS_DB=2`
- **Nginx**：SSE `/api/events` 长连接代理、WebSocket `/api/ws` 备选、通用 `/` 反向代理

### 项目本地路径

- 源码（用户 Mac）：`/Users/Learning/web/long/`
- 文档仓库（本机）：`~/reference/long/`
- 知识库索引（本机）：`~/reference/ai-tools/long-docs-overview.md`

---

## 核心开发参考（最有价值的文档）

### 体系设计
- `docs/specs/2026-04-23-装备稀有度与成长数值规范.md` — 装备体系核心规范
- `docs/designs/2026-04-26-装备实例化与强化背包系统策划案.md` — 装备系统方案
- `docs/developer-reference/2026-04-30-天赋技能数值总览.md` — 天赋数值大全
- `docs/developer-reference/2026-04-30-V2伤害计算链路总览.md` — 伤害公式总览

### 架构决策
- `docs/2026-05-01-日志与MongoDB演进方案.md` — 数据层演进路线
- `docs/2026-05-01-任务系统与Mongo整合方案.md` — 任务系统设计
- `docs/2026-04-26-ws-optimization.md` — WebSocket 优化

### 技能原理
- `docs/developer-reference/2026-04-27-均衡攻势工作原理.md`
- `docs/developer-reference/2026-04-27-碎盾攻坚工作原理.md`
- `docs/developer-reference/2026-04-27-致命洞察工作原理.md`
- `docs/developer-reference/2026-04-27-装备掉落事件链路.md`

---

## 开发节奏特征

1. **日更频率极高** — 平均每天 3-5 篇文档
2. **废弃文档标记规范** — 文件名带 `-已废弃` 后缀
3. **AI Agent 深度参与** — `superpowers/` 目录下大量 AI 生成的计划和设计
4. **前端测试领先** — BattlePage 有大量 vitest 测试文件（布局/功能/视觉）
5. **无传统数据库** — 全 Redis，转型 Mongo 正在推进中

## 链接

- 项目根：`~/reference/long/`
- AGENTS.md：`~/reference/long/AGENTS.md`
- 前端源码：`~/reference/long/frontend/src/`
- 后端核心：`~/reference/long/backend/internal/vote/`
