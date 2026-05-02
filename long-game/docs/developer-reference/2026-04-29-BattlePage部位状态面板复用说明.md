---
tags:
  - long-game
  - dev-reference
---

# BattlePage 部位状态面板复用说明

## 目的

BattlePage 左侧提示不要继续按“每个天赋单独造一张卡”的方式扩张。

当前建议按信息形态拆分，而不是按技能名字拆分：

- 全局状态型：连击、死兆、终末血斩
- 部位累计型：追击、破甲、碎甲重击
- 部位状态型：剥皮、护甲崩塌，以及后续可能出现的标记、易伤、弱点化

这样后续新增状态时，优先复用已有面板结构，只补数据映射，不再重复造视觉样式。

## 当前落点

### 1. 全局状态型

- 数据入口：`frontend/src/pages/publicPageState.js`
- 聚合字段：`globalStatusList`
- 渲染入口：`frontend/src/pages/BattlePage.vue`
- 面板样式：`status-panel`

用于展示不绑定单个部位的状态，例如：

- 连击
- 死兆
- 终末血斩
- 白银风暴

当前要求：

- 统一走 `globalStatusList`
- 不再在 `BattlePage.vue` 保留 `combo-box`、`omen-panel`、`final-cut-cooldown-panel` 这类专属模板入口
- 类似 `白银风暴` 这类全局限时 Buff，也应优先并入 `globalStatusList`，不要再单独保留底部状态条
- 只统一左侧 HUD 入口，不影响原有特效、弹字和触发链路

### 2. 部位累计型

- 数据入口：`frontend/src/pages/publicPageState.js`
- 聚合字段：`partProgressList`
- 渲染入口：`frontend/src/pages/BattlePage.vue`
- 面板样式：`part-progress-panel`

用于展示按部位累计的触发进度，例如：

- 追击 `X / Y`
- 破甲 `X / Y`
- 碎甲重击 `X / Y + 倒计时`

### 3. 部位状态型

- 数据入口：`frontend/src/pages/publicPageState.js`
- 聚合字段：`partStatusList`
- 渲染入口：`frontend/src/pages/BattlePage.vue`
- 面板样式：`part-status-panel`

`part-status-panel` 不重新定义一整套卡片视觉，而是与 `part-progress-panel` 复用同一组容器、标题、条目、名称样式，只补自己的行内标签和倒计时样式。

## 当前已接入状态

### 护甲崩塌

前端状态来源：

- `talentVisualState.collapsePartKeys`
- `talentVisualState.collapseEndsAt`

前端处理规则：

1. 读取当前崩塌部位 key 列表
2. 只要 `collapseEndsAt > now`，就把这些部位映射进 `partStatusList`
3. 使用统一字段：
   - `statusKey: collapse`
   - `statusLabel: 护甲崩塌`
   - `remainingSec`

说明：

- 护甲崩塌已不再保留 BattlePage 里的独立左侧卡片
- 左侧统一并入 `部位状态` 面板

### 剥皮

后端状态来源：

- `talentCombatState.skinnerParts`

结构含义：

- key：部位坐标 `"x-y"`
- value：状态结束时间戳（Unix 秒）

前端处理规则：

1. 在 `partStatusList` 中遍历当前存活部位
2. 读取 `skinnerParts[key]`
3. 只保留 `endsAt > now` 的部位
4. 映射为：
   - `name`
   - `type`
   - `statusKey`
   - `statusLabel`
   - `remainingSec`

当前 `statusLabel` 固定为 `剥皮`。

## 新增部位状态时的建议流程

1. 先确认它属于“部位状态型”，而不是“部位累计型”
2. 后端优先把状态放进 `talentCombatState`
3. 在 `publicPageState.js` 的 `partStatusList` 中新增映射
4. 尽量复用 `part-status-panel` 现有结构
5. 只有当展示信息超出“状态名 + 剩余时间”时，才考虑扩结构

## 不建议的做法

- 不要为每个状态单独新建一套左侧卡片 CSS
- 不要在 `BattlePage.vue` 里直接硬编码后端原始结构遍历逻辑
- 不要把“部位累计型”和“部位状态型”混进同一列表
- 不要重新引入独立的 `collapse-panel` 这一类单效果卡片
- 不要为了统一左侧入口去删掉战斗特效本身，`PixelEffectCanvas`、弹字和事件链路应保持独立

## 本次相关文件

- `frontend/src/pages/publicPageState.js`
- `frontend/src/pages/BattlePage.vue`
- `frontend/src/style.css`
