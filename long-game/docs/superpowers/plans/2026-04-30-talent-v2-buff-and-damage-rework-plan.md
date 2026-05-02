---
tags:
  - long-game
  - superpowers
---

# Talent V2 Buff 栏与伤害链路改造 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 以 `2026-04-30-天赋系统数值策划案-V2.0` 为唯一目标口径，完成 BattlePage 左侧 Buff 栏、倒计时、后端暴击系动态战斗态与伤害链路改造。

**Architecture:** 继续复用当前“静态面板编译 + 单场战斗态持久化 + 主伤害 / 触发伤害分层”的结构，但把暴击系从旧的“暴击计数 + 死亡狂喜”体系整体切换到“150 死兆 + 自动血斩”体系。前端继续复用 `globalStatusList / partProgressList / partStatusList` 三层结构，只改聚合逻辑和字段定义。

**Tech Stack:** Go、Hertz、Redis、Vue 3、Pinia 风格组合式状态、SSE

---

## 任务总览

### Task 1: 重构天赋定义与编译缓存

**Files:**
- Modify: `backend/internal/vote/talent.go`
- Modify: `backend/internal/vote/talent_compile.go`
- Test: `backend/internal/vote/combat_cache_test.go`

- [ ] **Step 1: 先把 V2.0 暴击系规则逐项对照进定义表**

核对以下目标是否一致：

- `crit_core`：弱点暴击 +1 死兆、每层死兆暴伤、溢出暴击转暴伤
- `crit_skinner`：持续时间 + 冷却
- `crit_doom_judgment`：≤35% HP 后单次触发、1~5 标记、15~27 死兆
- `crit_bleed`：3 秒、40%~100% 基础伤害
- `crit_omen_kill`：45%~55% 阈值、每层 +1%~3%
- `crit_omen_reap`：15/30/60/90/120 档、1.10~1.50
- `crit_final_cut`：150 层死兆自动触发、1500%~3000%

- [ ] **Step 2: 删除旧暴击系编译字段**

删除或停用：

- `DeathEcstasyMult`
- `FinalCutTrigger`
- `FinalCutHpCut`

- [ ] **Step 3: 新增 V2.0 暴击系编译字段**

补齐：

- `OmenCap`
- `OmenPerWeakCrit`
- `OmenCritDmgPerStack`
- `SkinnerCooldown`
- `OmenReapThresholds`
- `OmenReapMultipliers`
- `WeakspotInsightMult`
- `FinalCutDamageRatio`

- [ ] **Step 4: 运行编译缓存测试**

Run: `go -C backend test ./internal/vote -run 'TestCompile|TestCombatCache'`

- [ ] **Step 5: 如测试口径变化，补断言**

重点补：

- 暴击系编译结果
- 已移除旧字段的断言

### Task 2: 重构单场战斗态模型

**Files:**
- Modify: `backend/internal/vote/talent.go`
- Modify: `backend/internal/vote/store.go`
- Test: `backend/internal/vote/store_test.go`

- [ ] **Step 1: 调整 `TalentCombatState` 字段**

目标：

- 保留：`OmenStacks`、`Collapse*`、`SilverStorm*`、`PartHeavyClickCount`、`PartStormComboCount`、`AutoStrike*`、`JudgmentDayUsed`、`SkinnerParts`、`DoomMarks`
- 删除：`CritCount`、`FinalCutTriggerCount`、`LastFinalCutAt` 的旧规则依赖
- 新增：`HasTriggeredDoom`、`SkinnerCooldownEndsAt`、必要的持续时间字段

- [ ] **Step 2: 确保 `NewTalentCombatState()` 初始化完整**

重点检查：

- map 字段全部初始化
- 新增布尔 / 时间字段有安全零值

- [ ] **Step 3: 保持 Redis 读写兼容**

要求：

- 老状态反序列化时不 panic
- 缺字段时走零值

- [ ] **Step 4: 写测试覆盖新旧状态兼容**

Run: `go -C backend test ./internal/vote -run 'TestGetTalentCombatState|TestTalentCombatState'`

### Task 3: 重排主伤害链路

**Files:**
- Modify: `backend/internal/vote/store.go`
- Test: `backend/internal/vote/store_test.go`

- [ ] **Step 1: 抽出 V2.0 条件乘区 helper**

将以下规则从 `applyBossPartDamage` 内联 if 中抽离：

- 崩塌增伤
- 斩杀预兆
- 溢杀每层暴伤
- 死兆收割档位
- 弱点洞察

- [ ] **Step 2: 重写死兆获取规则**

改为：

- 弱点暴击 +1
- 普通暴击不加
- 击碎末日审判标记部位才加

- [ ] **Step 3: 把 `终末血斩` 从暴击计数改为死兆满层自动触发**

要求：

- 150 层立即触发
- 消耗全部死兆
- 不再依赖 30 秒冷却

- [ ] **Step 4: 删除 `死亡狂喜` 主链路影响**

要求：

- 不再结算
- 不再占用展示位

- [ ] **Step 5: 跑主伤害与 Boss 扣血相关测试**

Run: `go -C backend test ./internal/vote -run 'TestApplyBossPartDamage|TestApplyBossPartDamageDelta|TestClickBossPart'`

### Task 4: 重写触发器与状态型效果

**Files:**
- Modify: `backend/internal/vote/talent_triggers.go`
- Modify: `backend/internal/vote/store.go`
- Test: `backend/internal/vote/store_test.go`

- [ ] **Step 1: 重写 `applyCritFinalCutTrigger`**

目标：

- 从“暴击次数触发”改为“满死兆后由主链路或资源链路触发”
- 若触发器函数不再适用，直接删除并改成新的 `applyCritFinalCutOnOmenFull`

- [ ] **Step 2: 删除 `applyCritDeathEcstasyTrigger`**

同步清理：

- handler 注册
- 事件类型
- 测试断言

- [ ] **Step 3: 重写 `applyCritDoomJudgmentTrigger`**

要求：

- 低血量时单次初始化标记
- 标记部位被击碎后给死兆
- 每场 Boss 仅触发一次初始化

- [ ] **Step 4: 为 `剥皮` 增加冷却语义**

要求：

- 触发成功才进 CD
- 无非弱点部位时不触发、不进 CD

- [ ] **Step 5: 明确 `致命出血` 的持续伤害落地方式**

这里必须落成代码方案，不能保留成 TODO。实现后补测试。

- [ ] **Step 6: 跑触发器专项测试**

Run: `go -C backend test ./internal/vote -run 'Test.*Trigger|Test.*Omen|Test.*Skinner|Test.*Doom'`

### Task 5: 统一前端状态载荷与聚合

**Files:**
- Modify: `frontend/src/pages/publicPageState.js`
- Test: `frontend/src/pages/PublicPage.publicResources.test.js`
- Test: `frontend/src/utils/clickResponse.test.js`

- [ ] **Step 1: 重写 `globalStatusList` 的暴击系展示口径**

改为：

- 死兆显示 `x / 150`
- 终末血斩显示“资源待命态”而非暴击计数 / 冷却态
- 白银风暴继续作为全局限时 Buff

- [ ] **Step 2: 扩展 `partStatusList`**

支持：

- 倒计时型状态：崩塌、剥皮
- 标记型状态：末日审判

- [ ] **Step 3: 统一前端倒计时规则**

要求：

- 优先用 `endsAt`
- 仅在画进度条时使用 `duration`
- 删除对旧暴击系冷却语义的推断

- [ ] **Step 4: 更新 `talentVisualState` 合并逻辑**

补齐：

- `omenCap`
- `omenReapTier`
- `skinnerCooldownEndsAt`
- `doomMarks`

- [ ] **Step 5: 跑前端静态测试**

Run: `npm --prefix frontend run test`

### Task 6: 调整 BattlePage 左侧 HUD 渲染

**Files:**
- Modify: `frontend/src/pages/BattlePage.vue`
- Modify: `frontend/src/style.css`

- [ ] **Step 1: 保持三段面板结构不变**

要求：

- 不新造独立暴击系卡片
- 不回退到旧 `combo-box / omen-panel / final-cut-panel`

- [ ] **Step 2: 扩 `part-status-panel` 渲染分支**

支持：

- 有倒计时状态
- 无倒计时标记状态

- [ ] **Step 3: 调整全局状态文案**

确保：

- 不再出现“死亡狂喜”
- 不再出现“暴击 x / 80 触发终末血斩”

- [ ] **Step 4: 联调左栏与网格标记**

确保：

- `doomMarks` 网格高亮
- 左栏部位状态
- 触发事件弹字

三者一致

### Task 7: 回归测试与文档同步

**Files:**
- Modify: `docs/archive/developer-reference/2026-04-27-致命洞察工作原理.md`
- Modify: `docs/README.md`

- [ ] **Step 1: 运行后端全量测试**

Run: `go -C backend test ./...`

- [ ] **Step 2: 运行前端测试**

Run: `npm --prefix frontend run test`

- [ ] **Step 3: 运行综合校验**

Run: `make check`

- [ ] **Step 4: 更新旧参考文档的失效提示或回链**

至少处理：

- 旧暴击系工作原理
- docs 索引

- [ ] **Step 5: 手工联调验收**

至少验：

- 弱点暴击叠死兆
- 150 死兆自动血斩
- 剥皮有持续和冷却
- 崩塌 / 白银风暴 / 标记状态都能进左栏
- 旧死亡狂喜完全不可见
