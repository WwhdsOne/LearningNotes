---
tags:
  - long-game
  - superpowers
---

# Boss 战斗区视觉特效更新与主题统一 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 删除三套 Boss 主题变体，统一为默认金属暗色风格（参照 `docs/demos/demo-sword-cursor.html`），加入像素剑光标、命中闪光、屏幕震击等视觉特效。

**Architecture:** 仅修改前端 CSS 和少量 JS。不改变 HTML 结构、格子尺寸、左侧 buff 面板。所有视觉改动集中在 `style.css`（主题删除 + 格子重绘 + 特效动画）和 `BattlePage.vue`（移除主题绑定）。

**Tech Stack:** Vue 3 + CSS（无新依赖）

**约束:** 左侧 buff 面板不动、格子尺寸不变、只改视觉外观

---

### Task 1: 删除 Boss 主题系统（publicPageState.js）

**Files:**
- Modify: `frontend/src/pages/publicPageState.js`

删除 `bossTheme` ref 和 `BOSS_THEMES` 常量，以及 boss 切换时的随机主题赋值。

- [ ] **Step 1: 删除 bossTheme 和 BOSS_THEMES**

找到 `const bossTheme = ref('cyberpunk')`（约第 96 行）和 `const BOSS_THEMES = [...]`（约第 98 行），删除这两行及 boss 切换时赋值 `bossTheme.value = BOSS_THEMES[idx]` 的代码。

- [ ] **Step 2: 从导出中移除 bossTheme**

找到 usePublicPageState 返回值中 `bossTheme,`（约第 2107 行），删除。

- [ ] **Step 3: 提交**

```bash
git add frontend/src/pages/publicPageState.js
git commit -m "feat: 删除 Boss 主题随机切换，统一为默认风格"
```

---

### Task 2: 移除 BattlePage.vue 中的主题绑定

**Files:**
- Modify: `frontend/src/pages/BattlePage.vue`

- [ ] **Step 1: 移除导入**

删除 `bossTheme,` 从 `usePublicPageState()` 的解构中（约第 9 行）。

- [ ] **Step 2: 移除模板中的主题 class**

将第 425 行：
```html
<div v-else class="boss-part-grid-container" :class="`boss-theme--${bossTheme}`">
```
改为：
```html
<div v-else class="boss-part-grid-container">
```

- [ ] **Step 3: 提交**

```bash
git add frontend/src/pages/BattlePage.vue
git commit -m "feat: 移除 BattlePage Boss 主题动态绑定"
```

---

### Task 3: 删除 theme CSS，重写 Boss 格子基础样式

**Files:**
- Modify: `frontend/src/style.css`

删除所有 `.boss-theme--*` 规则，重写 `.boss-part-cell` 为统一暗色金属风。

- [ ] **Step 1: 删除所有 boss-theme CSS**

删除 `style.css` 中第 3260–3320 行附近所有 `.boss-theme--cyberpunk`、`.boss-theme--arcane`、`.boss-theme--cosmic` 规则块。

- [ ] **Step 2: 重写 .boss-part-cell 基础样式**

替换现有 `.boss-part-cell` 规则（约第 2836 行起）为：

```css
.boss-part-cell {
  flex: 1;
  aspect-ratio: 1;
  border: 2px solid rgba(71, 85, 105, 0.5);
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  padding: 4px;
  min-width: 0;
  background: rgba(30, 41, 59, 0.7);
  color: #e2e8f0;
  transition: all 0.2s ease;
  opacity: 0.75;
  filter: brightness(0.85);
  transform: scale(0.98);
}
```

- [ ] **Step 3: 重写 boss-part-cell 类型色**

```css
.boss-part-cell--soft  { border-color: rgba(34, 197, 94, 0.5); }
.boss-part-cell--heavy { border-color: rgba(107, 114, 128, 0.5); }
.boss-part-cell--weak  { border-color: rgba(239, 68, 68, 0.5); }
.boss-part-cell--alive { opacity: 0.8; }
.boss-part-cell--alive:hover {
  opacity: 1;
  filter: brightness(1.15);
  transform: scale(1.04);
  border-color: rgba(148, 163, 184, 0.8);
}
.boss-part-cell--dead  { opacity: 0.35; filter: grayscale(0.6); }
```

- [ ] **Step 4: 添加 boss-part-grid-container 中心聚焦背景**

```css
.boss-part-grid-container {
  position: relative;
  padding: 12px;
  border-radius: 14px;
  background: radial-gradient(ellipse at center, rgba(99, 102, 241, 0.12) 0%, rgba(30, 41, 59, 0.6) 65%, rgba(15, 23, 42, 0.85) 100%);
  box-shadow: 0 0 60px rgba(99, 102, 241, 0.06), inset 0 0 30px rgba(0, 0, 0, 0.15);
}
```

- [ ] **Step 5: 提交**

```bash
git add frontend/src/style.css
git commit -m "feat: 统一 Boss 格子为暗色金属风，删除主题变体 CSS"
```

---

### Task 4: 添加命中闪光与屏幕震动动画

**Files:**
- Modify: `frontend/src/style.css`
- Modify: `frontend/src/pages/BattlePage.vue`

- [ ] **Step 1: CSS — 命中闪光动画**

在 `style.css` 末尾追加：

```css
.boss-part-cell.hit-flash {
  animation: boss-hit-flash 0.25s ease-out;
}
@keyframes boss-hit-flash {
  0%   { background: rgba(255, 255, 255, 0.3); box-shadow: 0 0 24px rgba(255, 255, 255, 0.25); }
  100% { background: rgba(30, 41, 59, 0.7); }
}
```

- [ ] **Step 2: CSS — 屏幕震动与闪光**

```css
.boss-part-grid-container.shake      { animation: boss-shake 0.12s ease-out; }
.boss-part-grid-container.shake-hard { animation: boss-shake-hard 0.18s ease-out; }
@keyframes boss-shake {
  0%,100% { transform: translate(0); }
  20% { transform: translate(-3px, 1px); }
  40% { transform: translate(2px, -2px); }
  60% { transform: translate(-1px, -1px); }
  80% { transform: translate(2px, 1px); }
}
@keyframes boss-shake-hard {
  0%,100% { transform: translate(0); }
  15% { transform: translate(-6px, 2px); }
  30% { transform: translate(4px, -3px); }
  60% { transform: translate(5px, 1px); }
  90% { transform: translate(3px, 2px); }
}

.screen-flash {
  position: fixed; inset: 0; pointer-events: none; z-index: 100;
  animation: boss-flash-burst 0.5s ease-out forwards;
}
@keyframes boss-flash-burst {
  0% { background: rgba(251, 191, 36, 0.3); }
  100% { background: transparent; }
}

.screen-vignette {
  position: fixed; inset: 0; pointer-events: none; z-index: 99;
  background: radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.7) 100%);
  animation: boss-vignette-in 0.6s ease-out forwards;
}
@keyframes boss-vignette-in {
  0% { opacity: 0; }
  30% { opacity: 1; }
  100% { opacity: 0; }
}
```

- [ ] **Step 3: Vue — 命中闪光触发**

在 `BattlePage.vue` 的 `clickBossZone` 函数中加入命中闪光。将现有函数改为：

```js
function clickBossZone(zone) {
  const key = getBossZoneButtonKey(zone)
  if (!key) return
  // 命中闪光
  const el = findBossZoneElement(zone.x, zone.y)
  if (el) {
    el.classList.remove('hit-flash')
    void el.offsetWidth
    el.classList.add('hit-flash')
  }
  clickButton(key)
}
```

> `findBossZoneElement` 已在 BattlePage.vue 中存在（约第 196 行），无需新增。

- [ ] **Step 4: 提交**

```bash
git add frontend/src/style.css frontend/src/pages/BattlePage.vue
git commit -m "feat: 添加命中闪光与屏幕震动动画"
```

---

### Task 5: 集成像素剑光标组件到 Boss 区域

**Files:**
- Modify: `frontend/src/pages/BattlePage.vue`
- Modify: `frontend/src/style.css`

`PixelShatter.vue` 已在 Task 4（之前的会话）中创建，现在集成到 boss 区域作为自定义光标。

- [ ] **Step 1: CSS — 隐藏 boss 区域内原生光标**

在 `style.css` 追加：

```css
.boss-part-grid-with-combo {
  cursor: none;
}
```

- [ ] **Step 2: CSS — 自定义光标样式**

```css
#boss-sword-cursor {
  position: fixed;
  pointer-events: none;
  z-index: 9999;
  width: 96px;
  height: 96px;
  background: url('/effects/sword-cursor.png') center/contain no-repeat;
  image-rendering: pixelated;
  transform: translate(-30%, -30%) rotate(0deg);
  transition: transform 0.08s ease-out;
  will-change: transform, left, top;
}
#boss-sword-cursor.swinging {
  transform: translate(-30%, -30%) rotate(60deg);
  transition: transform 0.06s ease-out;
}
#boss-sword-cursor.recovering {
  transform: translate(-30%, -30%) rotate(0deg);
  transition: transform 0.12s ease-out;
}
```

- [ ] **Step 3: Vue — 自定义光标元素和事件**

在 `BattlePage.vue` 模板中，`boss-part-grid-with-combo` div 内部末尾添加：

```html
<div id="boss-sword-cursor" style="display:none;"></div>
```

在 `<script setup>` 中 `onMounted` 内追加光标跟踪逻辑：

```js
// 自定义像素剑光标
const swordCursor = ref(null)
let cursorVisible = false
let swordSwung = false
let recoverTimer = 0
let lastAttackTime = 0

onMounted(() => {
  // ... existing tickTimer code ...

  swordCursor.value = document.getElementById('boss-sword-cursor')
  const gridArea = document.querySelector('.boss-part-grid-with-combo')
  if (!swordCursor.value || !gridArea) return

  const updatePos = (e) => {
    swordCursor.value.style.left = e.clientX + 'px'
    swordCursor.value.style.top = e.clientY + 'px'
  }

  document.addEventListener('pointermove', (e) => {
    if (!cursorVisible) return
    updatePos(e)
  })

  gridArea.addEventListener('pointerenter', (e) => {
    swordCursor.value.style.display = 'block'
    cursorVisible = true
    updatePos(e)
  })

  gridArea.addEventListener('pointerleave', () => {
    swordCursor.value.style.display = 'none'
    cursorVisible = false
    clearTimeout(recoverTimer)
    swordCursor.value.classList.remove('swinging', 'recovering')
    swordSwung = false
  })

  // 攻击动画（去重 + 最低保持 50ms）
  function doAttack(e) {
    const now = Date.now()
    if (now - lastAttackTime < 32) return
    lastAttackTime = now
    e.preventDefault()

    clearTimeout(recoverTimer)
    swordCursor.value.classList.remove('recovering')
    swordCursor.value.classList.add('swinging')
    swordSwung = true

    recoverTimer = setTimeout(() => {
      swordCursor.value.classList.remove('swinging')
      swordCursor.value.classList.add('recovering')
      swordSwung = false
    }, 50)
  }

  gridArea.addEventListener('pointerdown', doAttack)
  gridArea.addEventListener('click', doAttack)

  gridArea.addEventListener('pointerup', () => {
    if (!swordSwung) {
      swordCursor.value.classList.remove('swinging')
      swordCursor.value.classList.add('recovering')
    }
  })
})
```

- [ ] **Step 4: 确保 sword-cursor.png 存在于 public 目录**

```bash
ls frontend/public/effects/sword-cursor.png
```

（已在之前会话中复制到位，若不存在则从 `pixel-assets/output/sword-cursor.png` 复制 64×64 版本到 `frontend/public/effects/`）

- [ ] **Step 5: 提交**

```bash
git add frontend/src/pages/BattlePage.vue frontend/src/style.css
git commit -m "feat: 集成像素剑光标到 Boss 战斗区域"
```

---

### Task 6: Boss 格子上复用像素盾牌碎裂（已有 PixelShatter）

**Files:**
- 无需改动（已在之前会话中完成）

`PixelShatter.vue` 已替换 `crack-pattern-1.png`，无需额外操作。

- [ ] **Step 1: 验证测试通过**

```bash
npm --prefix frontend run build
cd backend && go test ./internal/vote/...
```

- [ ] **Step 2: 提交（如无改动则跳过）**

---

### Task 7: 最终验证与收尾

- [ ] **Step 1: 构建验证**

```bash
npm --prefix frontend run build
```

预期：构建成功，无报错。

- [ ] **Step 2: 后端测试**

```bash
cd backend && go test ./...
```

- [ ] **Step 3: 视觉效果检查清单**

在浏览器中打开开发环境，确认：
- [ ] Boss 格子为暗色金属风（深灰背景、半透明边框）
- [ ] 鼠标移入格子区时原生光标消失，像素剑出现
- [ ] 点击格子时剑挥动 60°
- [ ] 被点击格子短暂白色闪光
- [ ] 左侧 buff 面板位置/大小不变
- [ ] 格子尺寸与原来一致
- [ ] 三种主题变体不再随机切换

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: Boss 战斗区视觉特效更新完成"
```

---

## 改动文件总览

| 文件 | 操作 | 内容 |
|------|------|------|
| `frontend/src/pages/publicPageState.js` | 删 | bossTheme ref + BOSS_THEMES |
| `frontend/src/pages/BattlePage.vue` | 改 | 移除主题 class、加光标 div、加光标 JS、加命中闪光 |
| `frontend/src/style.css` | 改 | 删 3 套主题 CSS、重写格子样式、加闪光/震动/暗角动画、加光标 CSS |
| `frontend/src/components/PixelShatter.vue` | 不变 | 已在之前会话中集成 |

## 不变内容

- 左侧 `.boss-left-panels` 完整保留
- 格子 `.boss-part-cell` 尺寸（flex + aspect-ratio: 1）不变
- 格子内图片、血条、标签不变
- 连击框、部位进度、崩塌面板不变
