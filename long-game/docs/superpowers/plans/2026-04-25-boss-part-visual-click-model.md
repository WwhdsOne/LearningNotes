---
tags:
  - long-game
  - superpowers
---

# Boss 分区基础视觉与点击口径 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 删除前台旧按钮依赖，改为 Boss 部位自定义展示，并拆分手动点击次数、Boss 伤害和官方挂机口径。

**Architecture:** 保留现有 Go + Redis + Vue 结构，最小化接口迁移风险。后端先扩展 `BossPart` 展示字段并新增部位点击入口语义，前端战斗页直接用 Boss 部位渲染，不再从按钮池抽名；官方挂机走独立 Boss 伤害结算，不写用户点击数。

**Tech Stack:** Go、Hertz、Redis、Vue 3、Vite、Vitest、miniredis、`rtk`。

---

## File Map

- Modify: `backend/internal/vote/store.go`
  - 扩展 `BossPart` 字段。
  - 拆出手动部位点击、挂机部位伤害结算。
  - 保留普通按钮接口的历史兼容，逐步让战斗页不依赖它。
- Modify: `backend/internal/vote/boss_parts.go`
  - 归一化 `displayName`、`imagePath`。
  - 提供部位展示兜底。
- Modify: `backend/internal/vote/store_test.go`
  - 覆盖部位字段保存、手动点击计数、挂机不计点击数。
- Modify: `backend/internal/httpapi/auto_click_service.go`
  - 官方挂机调用不增加点击数的 Boss 结算入口。
- Modify: `backend/internal/httpapi/auto_click_service_test.go`
  - 覆盖挂机不增加用户点击数。
- Modify: `frontend/src/components/admin/AdminBossTab.vue`
  - 后台部位编辑器新增部位名称、小图路径。
- Modify: `frontend/src/components/admin/AdminBossTab.layout.test.js`
  - 覆盖后台部位字段和总血量只读。
- Modify: `frontend/src/pages/admin/useAdminPageActions.js`
  - 保存 Boss 模板时提交新增部位字段。
- Modify: `frontend/src/pages/BattlePage.vue`
  - 移除 `displayedButtons` 抽名逻辑，分区使用部位名称/小图。
  - 统计栏改为点击总数，不再展示按钮数量。
- Modify: `frontend/src/pages/publicPageState.js`
  - 前台点击目标从按钮 key 改为 Boss 部位坐标/索引。
  - 官方挂机状态目标从按钮 key 改为 Boss 部位目标。
- Modify: `frontend/src/style.css`
  - 落软组织、重甲、弱点基础样式和状态动画。
- Modify: `frontend/src/pages/PublicPage.threePageRefactor.test.js`
  - 覆盖战斗页不再使用按钮抽名和票数。
- Modify: `frontend/src/pages/PublicPage.clickResponse.test.js`
  - 覆盖点击次数与 Boss 伤害拆分。
- Add/Modify docs in `docs/`
  - 记录阶段实现结果。

## Task 1: BossPart 展示字段

**Files:**
- Modify: `backend/internal/vote/store.go`
- Modify: `backend/internal/vote/boss_parts.go`
- Test: `backend/internal/vote/store_test.go`

- [ ] **Step 1: 写失败测试**

在 `store_test.go` 新增测试：保存带 `DisplayName`、`ImagePath` 的 Boss 模板后，`ListBossTemplates` 和激活实例都保留字段。

- [ ] **Step 2: 验证失败**

Run: `rtk go test ./internal/vote -run TestBossPartDisplayFieldsPersist -count=1`

Expected: FAIL，字段不存在或为空。

- [ ] **Step 3: 最小实现**

给 `BossPart` 增加：

```go
DisplayName string `json:"displayName,omitempty"`
ImagePath   string `json:"imagePath,omitempty"`
```

在 `normalizeBossPartLayout` 中 trim 字符串并保留。

- [ ] **Step 4: 验证通过**

Run: `rtk go test ./internal/vote -run TestBossPartDisplayFieldsPersist -count=1`

- [ ] **Step 5: 提交**

```bash
git add backend/internal/vote/store.go backend/internal/vote/boss_parts.go backend/internal/vote/store_test.go
git commit -m "扩展Boss部位展示字段"
```

## Task 2: 手动点击次数与 Boss 伤害拆分

**Files:**
- Modify: `backend/internal/vote/store.go`
- Test: `backend/internal/vote/store_test.go`

- [ ] **Step 1: 写失败测试**

新增测试：手动点击 Boss 部位后，用户点击数只增加 `1`，Boss 部位血量按公式扣减，`ClickResult` 同时包含点击增量 `1` 和 Boss 伤害。

- [ ] **Step 2: 验证失败**

Run: `rtk go test ./internal/vote -run TestManualBossPartClickCountsOneButDamageUsesCombatFormula -count=1`

- [ ] **Step 3: 最小实现**

拆分 `ClickResult` 语义：

- 保留 `Delta` 作为点击次数增量，手动点击为 `1`。
- 新增 `BossDamage int64`，用于前端伤害数字和 Boss 伤害榜。
- 部位扣血和伤害榜使用 `BossDamage`。

- [ ] **Step 4: 验证通过**

Run: `rtk go test ./internal/vote -run TestManualBossPartClickCountsOneButDamageUsesCombatFormula -count=1`

- [ ] **Step 5: 提交**

```bash
git add backend/internal/vote/store.go backend/internal/vote/store_test.go
git commit -m "拆分Boss伤害与手动点击次数"
```

## Task 3: 官方挂机不增加点击次数

**Files:**
- Modify: `backend/internal/vote/store.go`
- Modify: `backend/internal/httpapi/auto_click_service.go`
- Test: `backend/internal/vote/store_test.go`
- Test: `backend/internal/httpapi/auto_click_service_test.go`

- [ ] **Step 1: 写失败测试**

新增测试：官方挂机结算 Boss 伤害后，`UserStats.ClickCount` 不变，Boss 伤害榜增加。

- [ ] **Step 2: 验证失败**

Run: `rtk go test ./internal/vote ./internal/httpapi -run 'TestAutoClick.*DoesNotIncreaseClickCount|TestBossAutoClickDoesNotIncreaseUserClicks' -count=1`

- [ ] **Step 3: 最小实现**

新增 Store 方法，例如：

```go
func (s *Store) AutoClickBossPart(ctx context.Context, nickname string) (ClickResult, error)
```

或给内部结算函数加入口类型参数，挂机入口跳过按钮计数、用户点击数、排行榜计数，只更新 Boss 伤害和 Boss 状态。

- [ ] **Step 4: 验证通过**

Run 同 Step 2。

- [ ] **Step 5: 提交**

```bash
git add backend/internal/vote/store.go backend/internal/vote/store_test.go backend/internal/httpapi/auto_click_service.go backend/internal/httpapi/auto_click_service_test.go
git commit -m "调整官方挂机不计点击次数"
```

## Task 4: 后台 Boss 部位配置

**Files:**
- Modify: `frontend/src/components/admin/AdminBossTab.vue`
- Modify: `frontend/src/pages/admin/useAdminPageActions.js`
- Test: `frontend/src/components/admin/AdminBossTab.layout.test.js`

- [ ] **Step 1: 写失败测试**

断言后台 Boss 部位编辑器包含“部位名称”“小图路径”，保存 payload 保留 `displayName`、`imagePath`。

- [ ] **Step 2: 验证失败**

Run: `rtk npm --prefix frontend run test -- AdminBossTab.layout.test.js`

- [ ] **Step 3: 最小实现**

在 inspector 中加入：

- `selectedCell.displayName`
- `selectedCell.imagePath`

保存部位时 trim 字段。

- [ ] **Step 4: 验证通过**

Run 同 Step 2。

- [ ] **Step 5: 提交**

```bash
git add frontend/src/components/admin/AdminBossTab.vue frontend/src/pages/admin/useAdminPageActions.js frontend/src/components/admin/AdminBossTab.layout.test.js
git commit -m "增加Boss部位展示配置"
```

## Task 5: 前台战斗页移除按钮抽名

**Files:**
- Modify: `frontend/src/pages/BattlePage.vue`
- Modify: `frontend/src/pages/publicPageState.js`
- Modify: `frontend/src/pages/PublicPage.threePageRefactor.test.js`

- [ ] **Step 1: 写失败测试**

断言 `BattlePage.vue` 不再包含：

- `bossZoneButtonPool`
- `pickButtonForBossPart`
- `zone.assignedButton`
- `zone.assignedButton.count`

并包含：

- `zone.displayName`
- `zone.imagePath`

- [ ] **Step 2: 验证失败**

Run: `rtk npm --prefix frontend run test -- PublicPage.threePageRefactor.test.js`

- [ ] **Step 3: 最小实现**

战斗页按 Boss 部位字段渲染：

- 名称：`zone.displayName || partTypeLabels[zone.type]`
- 小图：`zone.imagePath`
- 目标：优先使用 `zone.zoneKey` 或坐标标识，不再需要按钮 key。

- [ ] **Step 4: 验证通过**

Run 同 Step 2。

- [ ] **Step 5: 提交**

```bash
git add frontend/src/pages/BattlePage.vue frontend/src/pages/publicPageState.js frontend/src/pages/PublicPage.threePageRefactor.test.js
git commit -m "战斗页改用Boss部位展示"
```

## Task 6: 三类基础视觉

**Files:**
- Modify: `frontend/src/style.css`
- Modify: `frontend/src/pages/BattlePage.vue`
- Test: `frontend/src/pages/PublicPage.threePageRefactor.test.js`

- [ ] **Step 1: 写失败测试**

断言样式包含：

- `#4ADE80`
- `#9CA3AF`
- `#EF4444`
- `boss-part-cell--soft`
- `boss-part-cell--heavy`
- `boss-part-cell--weak`
- `boss-part-cell--low`

- [ ] **Step 2: 验证失败**

Run: `rtk npm --prefix frontend run test -- PublicPage.threePageRefactor.test.js`

- [ ] **Step 3: 最小实现**

按设计文档添加：

- 软组织绿色呼吸。
- 重甲灰色金属边框与内阴影。
- 弱点红色脉动。
- 低血量、击碎、按下、悬停状态。

- [ ] **Step 4: 验证通过**

Run 同 Step 2。

- [ ] **Step 5: 提交**

```bash
git add frontend/src/style.css frontend/src/pages/BattlePage.vue frontend/src/pages/PublicPage.threePageRefactor.test.js
git commit -m "实现Boss部位基础视觉"
```

## Task 7: 收口验证与记录

**Files:**
- Add: `docs/2026-04-25-Boss分区基础视觉与点击口径实施.md`

- [ ] **Step 1: 运行完整验证**

Run:

```bash
rtk go test ./...
rtk npm --prefix frontend run test
rtk npm --prefix frontend run build
```

- [ ] **Step 2: 写实施记录**

记录完成范围、点击口径、挂机口径、未做的天赋大特效。

- [ ] **Step 3: 提交**

```bash
git add docs/2026-04-25-Boss分区基础视觉与点击口径实施.md
git commit -m "记录Boss分区基础视觉实施"
```

- [ ] **Step 4: 合并回 main**

```bash
git checkout main
git merge --no-ff dev -m "合并Boss分区基础视觉与点击口径改造"
```

- [ ] **Step 5: main 上最终验证**

Run:

```bash
rtk go test ./...
rtk npm --prefix frontend run test
rtk npm --prefix frontend run build
```

