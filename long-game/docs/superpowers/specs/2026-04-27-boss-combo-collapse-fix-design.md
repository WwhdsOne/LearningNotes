---
tags:
  - long-game
  - superpowers
---

# Boss 战崩塌修复与连击/进度 UI 重构

## 概述

修复破甲崩塌不触发 Bug，重构连击系统与部位累计进度的前端显示。

## Bug 修复：破甲崩塌不触发

### 问题诊断

1. **`== 100` 精确匹配**：`store.go:1623` 崩塌触发条件为 `PartHeavyClickCount[partKey] == 100`，崩塌结束后计数未归零，导致二次点击时计数为 101 不再触发
2. 前后端计数语义不一致（前端全局、后端按部位）加剧了用户预期与实际的偏差

### 修复方案

- `== 100` 改为 `>= 100`
- 崩塌触发后将 `PartHeavyClickCount[partKey]` 归零
- 崩塌到期时同步归零对应部位计数

## 前端重构

### 数据层（publicPageState.js）

- 废弃前端自维护的全局 `stormCombo`/`armorCombo`，改为从 SSE 推送的 `TalentCombatState.PartStormComboCount` / `PartHeavyClickCount` 读取
- 连击计数继续由前端维护（超时 5 秒归零，与部位无关）

### UI 布局（BattlePage.vue）

左侧面板从上到下：

1. **部位系数**（保留现有）
2. **连击框**：始终可见，无连击显示 "✖️ 0" + 空进度条，有连击显示连击数 + 倒计时条
3. **部位累计进度列表**：仅当至少一个部位有进度时显示，每个部位一行，显示部位名称、风暴追击进度（所有部位）和破甲进度（仅重甲）
