---
tags:
  - long-game
  - docs
---

# docs 文档索引

`docs/` 只放一次性任务文档、设计说明、实施计划、开发参考、阶段总结和历史归档。

长期稳定的协作规则放在仓库根目录的 `AGENTS.md` / `CLAUDE.md`，不要回写到这里。

## 当前目录分层

- `announcements/`
  - 版本公告、变更播报。
- `architecture/`
  - 跨模块架构、存储、迁移、演进方案。
- `designs/`
  - 仍有参考价值的策划案、页面设计、系统草案。
- `developer-reference/`
  - 当前实现的开发参考、链路说明、调参说明。
- `effects/`
  - 像素特效资源和约束说明。
- `implementation/`
  - 具体实施计划、落地说明、修复记录。
- `reports/`
  - 阶段总结、优化总结、实施复盘。
- `specs/`
  - 当前仍有效的规则和规范。
- `superpowers/`
  - 历史 spec / plan 工作流产物。
- `demos/`
  - 本地静态 demo 和视觉试验稿。
- `archive/`
  - 已废弃、失效、仅保留快照价值的历史文档。

## 推荐入口

### 当前主线

- Mongo/任务系统演进：
  - [architecture/2026-05-01-任务系统与Mongo整合方案.md](./architecture/2026-05-01-任务系统与Mongo整合方案.md)
  - [architecture/2026-05-01-冷数据迁移与Mongo主存方案.md](./architecture/2026-05-01-冷数据迁移与Mongo主存方案.md)
  - [architecture/2026-05-01-日志与MongoDB演进方案.md](./architecture/2026-05-01-日志与MongoDB演进方案.md)
- 任务系统实施：
  - [implementation/2026-05-02-任务模型升级实施计划.md](./implementation/2026-05-02-任务模型升级实施计划.md)
  - [implementation/2026-05-02-任务红点轮询与资料页稀有度样式实施计划.md](./implementation/2026-05-02-任务红点轮询与资料页稀有度样式实施计划.md)
  - [implementation/2026-05-02-资料页装备栏与生成失败日志实施计划.md](./implementation/2026-05-02-资料页装备栏与生成失败日志实施计划.md)

### 天赋与伤害链路

- 正式口径：
  - [designs/2026-04-30-天赋系统数值策划案-V2.0.md](./designs/2026-04-30-天赋系统数值策划案-V2.0.md)
  - [designs/2026-04-30-BattlePage-Buff栏与伤害链路V2改动评估.md](./designs/2026-04-30-BattlePage-Buff栏与伤害链路V2改动评估.md)
  - [reports/2026-04-28-天赋成本调整总结.md](./reports/2026-04-28-天赋成本调整总结.md)
  - [superpowers/specs/2026-04-28-talent-system-rework-design.md](./superpowers/specs/2026-04-28-talent-system-rework-design.md)
- 开发参考：
  - [developer-reference/2026-04-26-天赋系统开发参考.md](./developer-reference/2026-04-26-天赋系统开发参考.md)
  - [developer-reference/2026-04-27-均衡攻势工作原理.md](./developer-reference/2026-04-27-均衡攻势工作原理.md)
  - [developer-reference/2026-04-27-碎盾攻坚工作原理.md](./developer-reference/2026-04-27-碎盾攻坚工作原理.md)
  - [developer-reference/2026-04-30-V2伤害计算链路总览.md](./developer-reference/2026-04-30-V2伤害计算链路总览.md)
  - [developer-reference/2026-04-30-天赋技能数值总览.md](./developer-reference/2026-04-30-天赋技能数值总览.md)

### Boss 与战斗表现

- [designs/2026-04-25-Boss分区基础视觉与点击口径设计.md](./designs/2026-04-25-Boss分区基础视觉与点击口径设计.md)
- [reports/2026-04-25-Boss分区改造实施记录.md](./reports/2026-04-25-Boss分区改造实施记录.md)
- [implementation/2026-04-29-Boss战斗区右侧信息与连击跳字布局调整.md](./implementation/2026-04-29-Boss战斗区右侧信息与连击跳字布局调整.md)
- [implementation/2026-04-29-伤害动画解析优先级.md](./implementation/2026-04-29-伤害动画解析优先级.md)
- [demos/](./demos/)

## 归档约定

- `archive/` 下的文档不再作为当前实现依据。
- 文件名带 `已废弃`，或被移入 `archive/`，都表示只保留历史快照价值。
- 当前仓库中：
  - `archive/developer-reference/2026-04-27-致命洞察工作原理.md`
  - `archive/designs/2026-04-27-天赋树大型改造方案.md`
  - `archive/designs/2026-04-27-天赋树改造案.md`
  都属于历史参考，不应作为现行规则。

## 维护规则

- 新文档优先放入已有分类目录，不要继续把大量文件直接堆在 `docs/` 顶层。
- 顶层 `docs/` 除 `README.md` 外，原则上不再新增新文件。
- 新增正式文档时，补一条到本索引的“推荐入口”或“当前主线”。
- 如果文档失效：
  - 明确标注为失效，并移入 `archive/`
  - 或在文件名上追加 `-已废弃`
