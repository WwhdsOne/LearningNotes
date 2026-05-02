---
tags:
  - long-game
  - superpowers
---

# Boss 崩塌修复与连击/进度 UI 重构 实施方案

> **For agentic workers:** 按任务顺序执行，每步使用 checkbox 追踪进度。

**目标:** 修复破甲崩塌不触发 Bug，重构前端连击显示与部位累计进度面板。

**架构:** 后端修复 `>=100` 触发条件 + 计数重置；前端废弃全局风暴/破甲计数器，改为从 SSE 推送的 `TalentCombatState` 读取每个部位的 `PartStormComboCount` / `PartHeavyClickCount`；UI 用 flex 列容器容纳"部位系数 + 连击框 + 部位累计进度"三个面板。

**技术栈:** Go (Hertz + Redis), Vue 3 (Composition API + Pinia), CSS

---

### Task 1: 后端 — 修复崩塌触发与计数重置

**文件:**
- 修改: `backend/internal/vote/store.go`

- [ ] **Step 1: 修改崩塌触发条件 `== 100` → `>= 100`**

`store.go` 约第 1623 行：

```go
// 修改前
if combatState.PartHeavyClickCount[partKey] == 100 {

// 修改后
if combatState.PartHeavyClickCount[partKey] >= 100 {
```

- [ ] **Step 2: 崩塌触发后重置部位计数**

在同一代码块内，事件 append 之后添加重置：

```go
events = append(events, TalentTriggerEvent{
    TalentID: "armor_core", Name: "灭绝穿甲", EffectType: "collapse_trigger",
    Message:  fmt.Sprintf("结构崩塌！护甲归零 %d 秒", cd),
    PartX:    part.X,
    PartY:    part.Y,
})
combatState.PartHeavyClickCount[partKey] = 0 // 新增：触发后归零允许多次崩塌
```

- [ ] **Step 3: 崩塌到期时同步归零部位计数**

修改`store.go`约第 1752-1754 行的崩塌到期逻辑：

```go
// 修改前
if combatState.CollapseEndsAt > 0 && now >= combatState.CollapseEndsAt {
    combatState.CollapseParts = nil
    combatState.CollapseEndsAt = 0
}

// 修改后
if combatState.CollapseEndsAt > 0 && now >= combatState.CollapseEndsAt {
    for _, idx := range combatState.CollapseParts {
        if idx >= 0 && idx < len(boss.Parts) {
            pk := TalentPartKey(boss.Parts[idx].X, boss.Parts[idx].Y)
            combatState.PartHeavyClickCount[pk] = 0
        }
    }
    combatState.CollapseParts = nil
    combatState.CollapseEndsAt = 0
}
```

- [ ] **Step 4: 运行后端测试验证**

```bash
cd backend && go test ./internal/vote/... -run TestCollapse -v -count=1
```

期望：测试通过，崩塌事件正确触发。

- [ ] **Step 5: 提交**

```bash
git add backend/internal/vote/store.go
git commit -m "fix: 破甲崩塌触发条件改为 >=100，触发/到期后归零计数"
```

---

### Task 2: 前端 — 数据层重构（publicPageState.js）

**文件:**
- 修改: `frontend/src/pages/publicPageState.js`

- [ ] **Step 1: 新增 `talentCombatState` ref**

在 `talentVisualState` 定义之后添加：

```js
const talentCombatState = ref(null)
```

- [ ] **Step 2: 修改 `applyTalentCombatState` 同步存储原始状态**

在函数开头（签名后第一行）添加：

```js
function applyTalentCombatState(state) {
  if (!state || typeof state !== 'object') return
  talentCombatState.value = state  // 新增
  // ... 后续逻辑不变
```

- [ ] **Step 3: 新增 `partProgressList` computed**

在 `stormProgress` / `armorProgress` computed 之后添加：

```js
const partProgressList = computed(() => {
  const parts = boss.value?.parts
  const cs = talentCombatState.value
  if (!Array.isArray(parts) || parts.length === 0) return []
  const stormMap = cs?.partStormComboCount || {}
  const heavyMap = cs?.partHeavyClickCount || {}
  const result = []
  for (const part of parts) {
    const key = `${part.x}-${part.y}`
    const storm = Number(stormMap[key]) || 0
    const armor = Number(heavyMap[key]) || 0
    if (storm <= 0 && armor <= 0) continue
    result.push({
      key,
      name: part.displayName || partTypeLabel(part.type),
      type: part.type,
      x: part.x,
      y: part.y,
      storm,
      stormProgress: Math.min(100, Math.round((storm / 100) * 100)),
      armor,
      armorProgress: Math.min(100, Math.round((armor / 100) * 100)),
      alive: part.alive,
    })
  }
  return result
})

function partTypeLabel(type) {
  const labels = { soft: '软组织', heavy: '重甲', weak: '弱点' }
  return labels[type] || type || '未知'
}
```

- [ ] **Step 4: 导出新变量**

在 store 的 `return` 对象中添加 `partProgressList`：

```js
return {
    // ... 现有导出 ...
    partProgressList,
    // ...
}
```

旧的 `stormCombo`、`armorCombo`、`stormProgress`、`armorProgress` 保留不动（其他组件可能引用）。

- [ ] **Step 5: 提交**

```bash
git add frontend/src/pages/publicPageState.js
git commit -m "feat: 添加 partProgressList computed，从 TalentCombatState 读取部位进度"
```

---

### Task 3: 前端 — UI 重构（BattlePage.vue + CSS）

**文件:**
- 修改: `frontend/src/pages/BattlePage.vue`
- 修改: `frontend/src/style.css`

- [ ] **Step 1: 解构新变量**

在 `BattlePage.vue` 的 `usePublicPageState()` 解构中添加 `partProgressList`：

```js
const {
  // ... 现有 ...
  partProgressList,  // 新增
} = usePublicPageState()
```

- [ ] **Step 2: 重构左侧面板 HTML**

用 `.boss-left-panels` 容器包裹三个子面板（部位系数 + 连击框 + 部位累计），替换现有的独立 `boss-part-info` div 及其内部的旧 combo panel。

找到 `BattlePage.vue` 中 `boss-part-info` div（约第 333-363 行），将整个 div **替换为**：

```html
<!-- 左侧面板列 -->
<div class="boss-left-panels">
  <!-- 1. 部位系数 -->
  <div class="boss-part-info">
    <div class="boss-part-info__title">部位系数</div>
    <div class="boss-part-info__item boss-part-info__item--soft">
      <span class="boss-part-info__dot"></span>
      <span class="boss-part-info__label">软组织</span>
      <span class="boss-part-info__value">x1.0</span>
    </div>
    <div class="boss-part-info__item boss-part-info__item--heavy">
      <span class="boss-part-info__dot"></span>
      <span class="boss-part-info__label">重甲</span>
      <span class="boss-part-info__value">x0.4</span>
    </div>
    <div class="boss-part-info__item boss-part-info__item--weak">
      <span class="boss-part-info__dot"></span>
      <span class="boss-part-info__label">弱点</span>
      <span class="boss-part-info__value">x2.5</span>
    </div>
    <div class="boss-part-info__divider"></div>
    <div class="boss-part-info__item boss-part-info__item--armor">
      <span class="boss-part-info__dot"></span>
      <span class="boss-part-info__label">护甲</span>
      <span class="boss-part-info__value">减伤</span>
    </div>
  </div>

  <!-- 2. 连击框：始终可见 -->
  <div class="combo-box">
    <template v-if="comboCount > 0">
      <span class="combo-box__count">连击 x{{ comboCount }}</span>
      <span class="combo-box__timeout-bar">
        <span class="combo-box__timeout-fill" :style="{ width: comboTimeoutPercent + '%' }"></span>
      </span>
      <span class="combo-box__timeout-text">{{ Math.ceil(comboTimeoutPercent / 20) }}s</span>
    </template>
    <template v-else>
      <span class="combo-box__count combo-box__count--idle">x 0</span>
      <span class="combo-box__timeout-bar combo-box__timeout-bar--empty"></span>
    </template>
  </div>

  <!-- 3. 部位累计进度列表：仅当有进度时显示 -->
  <div v-if="partProgressList.length > 0" class="part-progress-panel">
    <div class="part-progress-panel__title">部位累计进度</div>
    <div v-for="p in partProgressList" :key="p.key" class="part-progress-panel__item">
      <span class="part-progress-panel__name" :class="`part-progress-panel__name--${p.type}`">{{ p.name }}</span>
      <span class="part-progress-panel__track part-progress-panel__track--storm">
        追击 {{ p.storm }}/100
        <span class="part-progress-panel__bar"><span class="part-progress-panel__bar-fill part-progress-panel__bar-fill--storm" :style="{ width: p.stormProgress + '%' }"></span></span>
      </span>
      <span v-if="p.type === 'heavy'" class="part-progress-panel__track part-progress-panel__track--armor">
        破甲 {{ p.armor }}/100
        <span class="part-progress-panel__bar"><span class="part-progress-panel__bar-fill part-progress-panel__bar-fill--armor" :style="{ width: p.armorProgress + '%' }"></span></span>
      </span>
    </div>
  </div>
</div>
```

- [ ] **Step 3: 更新 CSS**

**修改**现有的 `.boss-part-info` 样式，去掉 `position: absolute` 和 `top`，改为 flex item：

```css
.boss-part-info {
  /* 删除: position: absolute; left: 0; top: 10px; */
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 10px 8px;
  border-radius: 12px;
  background: rgba(15, 23, 42, 0.06);
  border: 1px solid rgba(15, 23, 42, 0.08);
  min-width: 0;
  flex-shrink: 0;
}
```

**新增**以下样式到 `style.css` 末尾：

```css
/* 左侧面板列容器 */
.boss-left-panels {
  position: absolute;
  left: 0;
  top: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 1;
  max-width: 180px;
}

/* 连击框 */
.combo-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 12px;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.06);
  border: 1px solid rgba(15, 23, 42, 0.08);
}

.combo-box__count {
  font-size: 1rem;
  font-weight: 900;
  color: #c0dce8;
  text-shadow: 0 0 10px rgba(43, 184, 115, 0.4);
}

.combo-box__count--idle {
  color: #5a6a7a;
  text-shadow: none;
}

.combo-box__timeout-bar {
  width: 100%;
  height: 4px;
  border-radius: 2px;
  background: #253b44;
  overflow: hidden;
}

.combo-box__timeout-bar--empty {
  background: #1a2a30;
}

.combo-box__timeout-fill {
  display: block;
  height: 100%;
  border-radius: 2px;
  background: #5a8a9a;
  transition: width 0.2s linear;
}

.combo-box__timeout-text {
  font-size: 0.6rem;
  font-weight: 700;
  color: #7898a8;
}

/* 部位累计进度面板 */
.part-progress-panel {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.06);
  border: 1px solid rgba(15, 23, 42, 0.08);
}

.part-progress-panel__title {
  font-size: 0.64rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--ink-soft);
  padding-bottom: 4px;
  border-bottom: 1px solid rgba(15, 23, 42, 0.08);
}

.part-progress-panel__item {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.part-progress-panel__name {
  font-size: 0.68rem;
  font-weight: 700;
}

.part-progress-panel__name--soft { color: #4ade80; }
.part-progress-panel__name--heavy { color: #94a3b8; }
.part-progress-panel__name--weak { color: #ef4444; }

.part-progress-panel__track {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.6rem;
  color: var(--ink-soft);
  white-space: nowrap;
}

.part-progress-panel__bar {
  flex: 1;
  height: 4px;
  border-radius: 2px;
  background: #253b44;
  overflow: hidden;
  min-width: 40px;
}

.part-progress-panel__bar-fill {
  display: block;
  height: 100%;
  border-radius: 2px;
  transition: width 0.3s ease;
}

.part-progress-panel__bar-fill--storm {
  background: linear-gradient(90deg, #2bb873, #4ade80);
}

.part-progress-panel__bar-fill--armor {
  background: linear-gradient(90deg, #f59e0b, #fbbf24);
}
```

- [ ] **Step 4: 运行前端构建验证**

```bash
npm --prefix frontend run build
```

确保无编译错误。

- [ ] **Step 5: 提交**

```bash
git add frontend/src/pages/BattlePage.vue frontend/src/style.css
git commit -m "feat: 重构左侧面板，拆分连击框与部位累计进度"
```

---

### Task 4: 后端 — 验证 PartStormComboCount 持久化

`PartStormComboCount` 已通过 `SaveTalentCombatState` 持久化，无需额外修改。

- [ ] **Step 1: 运行完整后端测试**

```bash
cd backend && go test ./... -count=1
```

- [ ] **Step 2: 运行前端测试**

```bash
npm --prefix frontend run test
```

---

### Task 5: 最终验证

- [ ] **Step 1: 确认所有改动已提交**

```bash
git status
git log --oneline -5
```
