---
tags:
  - long-game
  - design
---

# BattlePage Buff 栏与伤害链路 V2 改动评估

> 关联文档导航：
> - 正式策划口径：[`2026-04-30-天赋系统数值策划案-V2.0`](./2026-04-30-天赋系统数值策划案-V2.0.md)
> - 前端 Buff 栏复用说明：[`../developer-reference/2026-04-29-BattlePage部位状态面板复用说明.md`](../developer-reference/2026-04-29-BattlePage部位状态面板复用说明.md)
> - 新伤害链路总览：[`../developer-reference/2026-04-30-V2伤害计算链路总览.md`](../developer-reference/2026-04-30-V2伤害计算链路总览.md)
> - 实施计划：[`../superpowers/plans/2026-04-30-talent-v2-buff-and-damage-rework-plan.md`](../superpowers/plans/2026-04-30-talent-v2-buff-and-damage-rework-plan.md)

日期：2026-04-30

## 一、结论

本次改造可以在现有框架上推进，但只能复用“结构骨架”，不能复用当前暴击系规则本身。

可复用的骨架主要有 4 类：

- 前端左侧 HUD 的三段聚合结构：
  - `globalStatusList`
  - `partProgressList`
  - `partStatusList`
- BattlePage 左侧面板的统一渲染结构：
  - `status-panel`
  - `part-progress-panel`
  - `part-status-panel`
- 后端主伤害与触发伤害分层：
  - `Store.applyBossPartDamage`
  - `Store.applyTriggeredTalentDamage`
  - `backend/internal/vote/talent_triggers.go`
- 单场 Boss 动态状态持久化模型：
  - `TalentCombatState`
  - Redis 持久化
  - SSE / click response 回传

必须重写或明显改造的部分主要集中在暴击系：

- `死兆 100 层 + 死亡狂喜` 的整套旧逻辑必须下线
- `终末血斩` 必须从“暴击次数 + 冷却触发”改为“150 死兆自动触发并清空”
- `剥皮` 必须新增冷却语义，不能继续沿用“纯概率 + 持续时间”
- `末日审判` 必须从“开局初始化标记”改为“HP 阈值达标后单次触发”
- `致命出血` 不能继续用当前“一次性即刻追加伤害”的旧实现冒充 3 秒持续效果

## 二、前端 Buff 栏评估

### 2.1 可直接复用的部分

1. `publicPageState.js` 已经按“全局状态 / 部位累计 / 部位状态”三类聚合，和 2026-04-29 的复用说明一致。
2. `BattlePage.vue` 已经不再把连击、死兆、终末血斩拆成多套独立卡片，左侧 HUD 统一入口已成型。
3. 倒计时刷新机制已经存在：
   - `BattlePage.vue` 里有每秒 `tick`
   - `publicPageState.js` 会根据 `endsAt` 实时重算剩余秒数与进度条
4. `护甲崩塌`、`剥皮` 已经作为 `partStatusList` 条目展示，说明“按部位状态入左栏”这条 UI 方向已经跑通。

### 2.2 必须修改的部分

#### 全局状态型

当前 `globalStatusList` 仍然内置旧暴击系假设：

- `死兆` 当前显示 `x / 100`
- 提示语是“满层触发死亡狂喜”
- `终末血斩` 当前显示的是：
  - 暴击累计进度
  - 或 30 秒冷却倒计时

这些都与 V2.0 冲突。按目标口径应改为：

- `死兆` 显示 `x / 150`
- 文案改成“150 层自动触发终末血斩”
- `终末血斩` 不再展示暴击计数，也不再展示固定冷却
- 若需要在左栏保留 `终末血斩` 卡片，它应展示“待命 / 即将触发 / 刚触发”这种资源态，而不是冷却态

#### 部位状态型

`partStatusList` 当前只适配“状态名 + 倒计时 + 进度条”。

这对以下状态足够：

- 护甲崩塌
- 剥皮

但 V2.0 下的 `末日审判标记` 是“无倒计时、只标记、单次触发”的部位状态，不适合硬塞进现有格式。需要扩一层可选字段：

- `statusMeta`
- `showCountdown`
- `showProgress`

建议不要新造第四种卡片，只在 `part-status-panel` 上做最小扩展。

### 2.3 倒计时口径问题

当前倒计时口径并不统一：

- `白银风暴` 用 `silverStormEndsAt + silverStormDuration`
- `护甲崩塌` 用 `collapseEndsAt + collapseDuration`
- `剥皮` 用 `skinnerParts[key]`，但时长是前端自行从 `skinnerDurationByPart` 推导
- `终末血斩` 用 `lastFinalCutAt + 30`

建议统一为：

- 后端只回传 `endsAt`
- 若进度条需要百分比，再补一个稳定的 `duration`
- 前端一律根据 `endsAt - now` 计算剩余秒数
- 不再让前端从旧规则推断暴击系冷却或资源逻辑

## 三、后端战斗态评估

### 3.1 可复用的骨架

`TalentCombatState` 的职责是对的：它保存“单场 Boss 中会变化的天赋态”。这个结构可以继续用，但字段要重排。

可直接保留的状态思路：

- `CollapseParts / CollapseEndsAt / CollapseDuration`
- `SilverStormActive / SilverStormEndsAt`
- `PartHeavyClickCount`
- `PartStormComboCount`
- `AutoStrikeTargetPart / AutoStrikeComboCount / AutoStrikeExpiresAt`
- `JudgmentDayUsed`
- `SkinnerParts`
- `DoomMarks`

### 3.2 必须删除或重做的字段

下列字段和 V2.0 目标口径冲突，不能继续作为核心语义：

- `CritCount`
- `LastFinalCutAt`
- `FinalCutTriggerCount`
- `crit_death_ecstasy` 相关状态语义

下列字段需要重定义：

- `OmenStacks`
  - 上限要从现状 100 体系改为 150 体系
- `DoomMarks`
  - 触发时机要改
- `SkinnerParts`
  - 需要补充冷却态，而不是只有持续态

建议新增或明确的状态：

- `HasTriggeredDoom`
- `SkinnerCooldownEndsAt`
- `SkinnerDurationByPart`
- `FinalCutLastTriggerAt`
  - 仅在 UI 想展示“最近触发反馈”时保留
  - 不再作为规则冷却

## 四、后端伤害逻辑评估

### 4.1 可复用的结构

当前主链路分层是合理的：

1. 静态战斗面板：`combatStatsForNickname`
2. 单场动态战斗态：`GetTalentCombatState`
3. 主伤害计算：`CalcBossPartDamage`
4. 主伤害后的条件乘区：`applyBossPartDamage`
5. 触发伤害：`applyTriggeredTalentDamage`
6. 状态回写与广播：Redis + click response + SSE

这个分层本身不需要推倒。

### 4.2 必须修改的规则

#### 溢杀 / 死兆获取

当前实现：

- 弱点暴击 +2
- 普通暴击 +1
- 击碎部位 +5

V2.0 目标：

- 弱点暴击 +1
- 普通暴击不加死兆
- 击碎 `末日审判标记部位` 才加死兆

这里是核心规则变更，不能局部打补丁。

#### 终末血斩

当前实现：

- 暴击次数累计
- 达阈值触发
- 30 秒冷却

V2.0 目标：

- 死兆达到 150 层立即触发
- 消耗全部死兆
- 不依赖暴击计数
- 不依赖固定冷却

这意味着：

- `applyCritFinalCutTrigger` 要重写
- `globalStatusList` 的终末血斩展示逻辑也要同步改写

#### 死亡狂喜

当前实现仍存在 `crit_death_ecstasy`。

V2.0 目标口径中不存在这个技能，必须删除其规则影响、状态字段、前端提示和测试断言。

#### 末日审判

当前实现：

- 战斗中懒初始化 `DoomMarks`
- 击碎标记部位给死兆

V2.0 目标：

- 达到 HP 阈值后单次触发
- 随机标记若干部位
- 每场 Boss 仅一次

当前的“懒初始化”只能复用部分数据结构，不能复用触发时机。

#### 剥皮

当前实现：

- 暴击后按概率挂到当前部位
- 没有冷却

V2.0 目标：

- 暴击触发
- 持续时间 + 冷却并存
- 若不存在非弱点部位则不触发且不进 CD

这要求后端把 `触发成功` 与 `进入冷却` 作为显式状态处理。

#### 致命出血

当前实现是：

- 暴击时立即加一笔额外伤害

V2.0 文案是：

- 3 秒持续
- 重复暴击刷新持续时间
- 不叠加

这是当前后端最难直接复用的点，因为现有伤害链路没有“持续伤害时钟”。本项需要单独定实现方式，不能假装当前逻辑等价。

## 五、事件与前端载荷评估

当前系统已经有两条可复用链路：

- `TalentTriggerEvent`
- `TalentCombatState`

建议继续复用，但补足 V2.0 所需字段，不再让前端猜规则。

建议新增或规范的载荷信息：

- `omenCap`
- `omenReapTier`
- `skinnerCooldownEndsAt`
- `hasTriggeredDoom`
- `doomMarkPartKeys`
- `finalCutTriggered`
- `finalCutConsumedOmen`

不建议继续让前端通过旧字段推断：

- 是否存在固定冷却
- 死兆是否还能继续增长
- 终末血斩何时待命

## 六、风险评估

### 高风险

1. `致命出血` 从即刻伤害改为持续伤害
2. `终末血斩` 触发条件从暴击计数改为资源满层
3. `剥皮` 新增冷却后，前后端都要同步展示

### 中风险

1. `末日审判` 标记时机切换后，前端网格标记与左侧状态要保持一致
2. `part-status-panel` 需要兼容“有倒计时”和“无倒计时”两类状态
3. 旧测试大量依赖 `critCount`、`lastFinalCutAt`、`death_ecstasy`

### 低风险

1. `死兆上限 100 → 150`
2. `白银风暴`、`护甲崩塌` 的倒计时聚合
3. 左侧 Buff 栏整体复用现有结构

## 七、建议实施顺序

建议顺序如下：

1. 先改后端状态模型与规则口径
2. 再改 `click response / SSE` 载荷
3. 再改 `publicPageState.js` 的状态聚合
4. 最后改 `BattlePage.vue` 的左栏展示细节

原因：

- 这次前端主要是“状态展示层”
- 真正决定正确性的，是后端规则和状态字段
- 如果前端先改，最后还是会被后端字段定义反复推翻

## 八、最终建议

本次改造不建议拆成“先补 UI，再慢慢改逻辑”。应按 V2.0 口径一次性改到位。

原因有 3 点：

- 旧暴击系和新暴击系在资源、终结技、触发条件上不是同一种系统
- 前端 Buff 栏已经足够通用，没必要先做一轮临时适配
- 若继续容忍双口径并存，后续所有测试、弹字、状态条、策划复盘都会反复混淆
