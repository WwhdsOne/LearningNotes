---
tags:
  - long-game
  - project
---

# Redis Vote Wall

一个基于 `Vue 3 + Vite + Go(Hertz) + Redis + SSE` 的实时按钮计数墙项目。当前版本已经扩展出装备、英雄、Boss、天赋、任务、留言墙、后台管理和 Mongo 冷数据链路。

## 当前架构

- 前端位于 `frontend/`，不引入路由库，通过 `window.location.pathname` 切分页面。
- 后端位于 `backend/`，模块路径为 `long`。
- 公共态通过 `SSE /api/events` 推送，个人态通过 `SSE /api/events/me` 推送，WebSocket 仅作备选。
- Redis 负责热数据；Mongo 已启用，用于冷数据、日志、任务定义与归档等持久化内容。
- 前端构建产物输出到 `backend/public/`，由容器内的 nginx + Go 服务统一承载。

## 目录入口

- `AGENTS.md` / `CLAUDE.md`
  - 长期协作规则。两份文件内容保持完全一致。
- `Makefile`
  - 本地开发、构建、测试、hook 安装入口。
- `frontend/`
  - Vue 页面、Vite 配置、前端测试。
- `backend/`
  - Hertz 服务、业务逻辑、Redis/Mongo 访问、后端测试。
- `deploy/`
  - 容器入口脚本和 nginx 配置。
- `docs/`
  - 一次性设计、计划、总结、开发参考和历史归档。总索引见 [docs/README.md](./docs/README.md)。

## 本地开发

先安装前端依赖：

```bash
make deps
```

后端运行与测试依赖 Consul 配置，需要设置：

```bash
export CONSUL_ADDR=http://127.0.0.1:8500
export CONSUL_CONFIG_KEY=vote-wall/dev
```

常用命令：

```bash
make dev
make backend-run
make frontend-dev
make build
make test
npm --prefix frontend run test
make check
```

说明：

- `make dev`：同时启动 Go 后端和 Vite 前端。
- `make build`：只构建前端产物到 `backend/public/`。
- `make test`：运行后端测试。
- `make check`：本地手动全量校验，包含后端测试、`go vet`、前端测试和前端构建。
- Go 命令必须在 `backend/` 下执行，或使用 `go -C backend ...`。

## 提交前校验

仓库使用 `lefthook` 管理本地 `pre-commit`。

安装 hook：

```bash
make hooks-install
```

当前 `pre-commit` 会执行：

- `go -C backend fix ./...`
- `go -C backend test ./...`
- `go -C backend vet ./...`
- `npm --prefix frontend run test`

`make check` 仍保留为手动全量校验入口，但不再作为 GitHub Actions 部署步骤的一部分。

## 部署概览

当前 GitHub Actions 部署链路是：

1. 安装前端依赖。
2. 构建前端产物到 `backend/public/`。
3. 交叉编译后端 Linux `amd64` 发布二进制：

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go -C backend build -trimpath -buildvcs=false -ldflags "-w -s -buildid=" -o long ./cmd/server
```

4. 生成 `release.tar.gz`，其中包含：
   - `Dockerfile`
   - `.dockerignore`
   - `docker-compose.yml`
   - `backend/long`
   - `backend/public/`
   - `deploy/entrypoint.sh`
   - `deploy/nginx.container.conf`
5. 上传到服务器后，在服务器端执行 `docker compose build` 和 `docker compose up -d`。

运行镜像以服务器本地已有的 `long-basic:latest` 为基础镜像；部署前 workflow 会先检查该镜像是否存在。

## Redis 与配置

- 热数据仍在 Redis，键前缀统一为 `hai-world:`（通过 Consul KV `redis_prefix` 注入）。
- 运行时配置通过 Consul KV 拉取 YAML。
- `backend/config.example.yaml` 和 `backend/config.yaml` 仅作参考，不直接参与线上运行时加载。
- 详细数据结构和配置字段，见本文档后续章节与 [docs/README.md](./docs/README.md) 的相关专题入口。

## 文档入口

如果你要看当前有效文档，优先从 [docs/README.md](./docs/README.md) 进入。

推荐入口：

- Mongo / 任务系统：
  - [docs/architecture/2026-05-01-任务系统与Mongo整合方案.md](./docs/architecture/2026-05-01-任务系统与Mongo整合方案.md)
  - [docs/architecture/2026-05-01-冷数据迁移与Mongo主存方案.md](./docs/architecture/2026-05-01-冷数据迁移与Mongo主存方案.md)
- 天赋与伤害链路：
  - [docs/reports/2026-04-28-天赋成本调整总结.md](./docs/reports/2026-04-28-天赋成本调整总结.md)
  - [docs/developer-reference/2026-04-26-天赋系统开发参考.md](./docs/developer-reference/2026-04-26-天赋系统开发参考.md)
  - [docs/developer-reference/2026-04-30-V2伤害计算链路总览.md](./docs/developer-reference/2026-04-30-V2伤害计算链路总览.md)

## Redis 数据结构

所有 Redis 键统一使用 `hai-world:` 前缀（通过 Consul 配置项 `redis_prefix` 注入）。

### 核心投票与排行榜

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:user:<nickname>` | Hash | 用户基础信息（nickname、click_count、updated_at） |
| `hai-world:leaderboard` | Sorted Set | 全服排行榜，member=昵称，score=个人累计点击数 |
| `hai-world:players:index` | Sorted Set | 玩家索引，member=昵称，score 为加入时间戳 |
| `hai-world:total:votes` | String | 全服累计总点击数 |

### Boss 系统

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:boss:current` | Hash | 当前活跃 Boss 的状态（ID、血量、阶段等） |
| `hai-world:boss:history` | Sorted Set | Boss 历史记录索引，member=bossID，score=时间戳 |
| `hai-world:boss:history:<bossID>` | Hash | 单个 Boss 的历史详情（参战人数、总伤害、击杀时间等） |
| `hai-world:boss:cycle` | Hash | Boss 轮换配置（enabled、当前队列状态） |
| `hai-world:boss:instance:seq` | String | Boss 实例自增 ID 计数器 |
| `hai-world:boss:<bossID>:damage` | Sorted Set | Boss 伤害排行榜，member=昵称，score=累计伤害 |
| `hai-world:boss:<bossID>:loot` | Sorted Set | Boss 掉落池，member=物品标识，score=权重 |
| `hai-world:boss:<bossID>:reward-lock` | String (SetNX) | Boss 奖励发放分布式锁 |
| `hai-world:boss:pool:index` | Set | Boss 模板 ID 集合 |
| `hai-world:boss:pool:<templateID>` | Hash | Boss 模板定义（名称、血量、掉落等） |
| `hai-world:boss:pool:<templateID>:loot` | Sorted Set | Boss 模板掉落配置，member=物品标识，score=权重 |

### 装备系统

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:equipment:index` | Set | 装备定义 ID 集合 |
| `hai-world:equip:def:<itemID>` | Hash | 装备定义详情（名称、类型、属性、稀有度等） |
| `hai-world:instance:seq` | String | 装备实例自增 ID 计数器 |
| `hai-world:instance:<instanceID>` | Hash | 装备实例数据（所属玩家、属性值、强化等级等） |
| `hai-world:player-instances:<nickname>` | Set | 玩家拥有的装备实例 ID 集合 |
| `hai-world:user-inventory:<nickname>` | Hash | 玩家背包（物品与数量映射） |
| `hai-world:user-loadout:<nickname>` | Hash | 玩家当前配装（槽位 → 装备实例 ID） |
| `hai-world:user-equipment-spent:<nickname>` | Hash | 玩家装备累计花费记录 |
| `hai-world:user-equipment-enhance:<nickname>` | Hash | 玩家装备强化状态记录 |

### 玩家资源与天赋

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:resource:<nickname>` | Hash | 玩家资源（金币、宝石、天赋点等） |
| `hai-world:user-last-reward:<nickname>` | Hash | 玩家最近一次奖励记录 |
| `hai-world:player:talents:<nickname>` | Hash | 玩家已学习天赋（天赋ID → 等级） |
| `hai-world:player:talent_state:<nickname>:<bossID>` | Hash | 玩家在指定 Boss 战斗中的天赋状态快照 |
| `hai-world:player:talent_events:<nickname>:<bossID>` | List | 玩家在指定 Boss 战斗中待处理的天赋触发事件队列 |

### 公告与留言

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:announcement:seq` | String | 公告自增 ID 计数器 |
| `hai-world:announcements` | Sorted Set | 公告 ID 索引，member=公告ID，score=发布时间戳 |
| `hai-world:announcement:<id>` | Hash | 单条公告详情（标题、内容、发布者、时间等） |
| `hai-world:message:seq` | String | 留言自增 ID 计数器 |
| `hai-world:messages` | Sorted Set | 留言 ID 索引，member=留言ID，score=发布时间戳 |
| `hai-world:message:<id>` | Hash | 单条留言详情（内容、发布者、时间等） |

### 任务系统

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:task:progress:<nickname>:<taskID>:<cycleKey>` | Hash | 玩家任务进度（各阶段完成情况、数值累计），含 TTL |
| `hai-world:task:participants:<taskID>:<cycleKey>` | Set | 任务参与者昵称集合，含 TTL |

### AFK 挂机系统

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:afk:players` | Sorted Set | AFK 在线玩家索引，member=昵称，score=挂机开始时间 |
| `hai-world:afk:player:<nickname>` | Hash | 玩家挂机状态（开始时间、累计收益等） |
| `hai-world:afk:settlement:<nickname>` | Hash | 玩家结算数据（离线期间的收益明细） |

### 玩家认证

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:player-auth:<nickname>` | Hash | 玩家登录凭证（密码哈希、token 等） |

### 实时事件

| 键 | 类型 | 用途 |
|---|---|---|
| `hai-world:events` | Pub/Sub Channel | SSE 实时事件推送频道，广播公共状态变更（点击、Boss 血量、公告等） |

### Lua 脚本操作的键

后端两个核心 Lua 脚本（点击计数、Boss 点击）以原子方式操作多键：

- `clickCountLuaSource`：原子操作 `KEYS[1]=user`、`KEYS[2]=leaderboard`、`KEYS[3]=players:index`、`KEYS[4]=total:votes`
- `bossClickLuaSource`：原子操作 `KEYS[1]=button count`、`KEYS[2]=user click`、`KEYS[3]=leaderboard`、`KEYS[4]=players:index`、`KEYS[5]=boss:current`、`KEYS[6]=boss damage`

## MongoDB 数据结构

MongoDB 数据库名通过 Consul 配置项 `mongo.database` 指定（当前为 `hai-world`），用于冷数据、日志、任务定义与归档等持久化内容。

### 冷数据与日志

| 集合 | 用途 |
|---|---|
| `boss_history` | Boss 历史记录（从 Redis `boss:history:*` 迁移而来的冷数据，包含参战统计、伤害摘要、掉落等） |
| `wall_messages` | 留言历史记录（从 Redis `messages` 迁移而来的冷数据） |
| `system_logs` | 系统运行日志（服务行为、错误、关键操作记录） |
| `admin_audit_logs` | 管理后台审计日志（管理员操作追溯） |
| `domain_events` | 领域事件记录（Boss 击杀、装备获取等重要业务事件） |

### 任务系统

| 集合 | 用途 |
|---|---|
| `task_definitions` | 任务定义（任务模板 ID、目标类型、阶段配置、奖励等） |
| `task_claim_logs` | 任务奖励领取日志（谁、何时、领取了什么奖励） |
| `task_cycle_archives` | 任务周期归档（每轮任务的汇总数据：参与人数、完成率等） |
| `task_cycle_player_results` | 任务周期玩家结果（每轮任务中每位玩家的完成详情） |

### 装备与计数器

| 集合 | 用途 |
|---|---|
| `counters` | 全局计数器（当前仅 `wall_messages` 文档，用于留言 ID 自增序列） |
| `equipment_draft_failures` | 装备抽取失败记录（用于排查装备生成异常） |

### 初始化流程

后端启动时（`cmd/server/main.go`）会依次为以上集合建立索引，然后初始化各 MongoStore 实例并注入到业务层。

## Consul 配置

后端启动时识别两个核心环境变量：

- `CONSUL_ADDR`
- `CONSUL_CONFIG_KEY`

配置从 Consul KV 拉取 YAML；配置变更后，服务会主动退出，由外部进程管理器拉起新进程。
