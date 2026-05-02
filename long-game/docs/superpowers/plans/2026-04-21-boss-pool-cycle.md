---
tags:
  - long-game
  - superpowers
---

# Boss 池循环 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为后台增加 Boss 模板池与循环开关，让 Boss 在被击败后自动随机补位。

**Architecture:** 后端新增 Boss 模板池与循环状态存储，当前场上 Boss 改为实例化对象，击败结算时根据循环状态决定是否立即刷出下一只。后台管理页扩展为模板管理与循环控制，前台接口保持“只看当前 Boss”。

**Tech Stack:** Go、Redis、Vue 3、Vite、Vitest、Go test

---

### Task 1: 文档与数据模型落地

**Files:**
- Create: `docs/superpowers/specs/2026-04-21-boss-pool-cycle-design.md`
- Create: `docs/superpowers/plans/2026-04-21-boss-pool-cycle.md`
- Modify: `backend/internal/vote/store.go`
- Modify: `backend/internal/vote/admin.go`

- [ ] **Step 1: 写清 Boss 模板、实例 Boss、循环状态的字段边界**
- [ ] **Step 2: 在 Store 中补充 Redis key 与辅助方法**
- [ ] **Step 3: 保证当前 Boss 继续兼容前台公共态读取**

### Task 2: 后端测试先行实现循环链路

**Files:**
- Modify: `backend/internal/vote/store_test.go`
- Modify: `backend/internal/vote/admin.go`
- Modify: `backend/internal/vote/store.go`
- Modify: `backend/internal/vote/lua.go`

- [ ] **Step 1: 先写失败测试，覆盖开启循环、击败后自动补位、关闭循环不补位**
- [ ] **Step 2: 单独运行相关 Go 测试，确认先红灯**
- [ ] **Step 3: 写最小实现让测试转绿**
- [ ] **Step 4: 补一轮重构，抽出模板池与实例生成辅助函数**

### Task 3: 暴露后台管理接口

**Files:**
- Modify: `backend/internal/httpapi/router.go`
- Modify: `backend/internal/httpapi/router_test.go`

- [ ] **Step 1: 先写失败测试，覆盖模板增删改、模板掉落池保存、循环开关**
- [ ] **Step 2: 运行路由测试确认失败原因正确**
- [ ] **Step 3: 实现接口并补全 Store 接口契约**
- [ ] **Step 4: 再跑路由测试确认转绿**

### Task 4: 后台页面接入

**Files:**
- Modify: `frontend/src/pages/AdminPage.vue`
- Modify: `frontend/src/style.css`

- [ ] **Step 1: 增加 Boss 池状态、模板表单与模板掉落池编辑态**
- [ ] **Step 2: 接入新增后台接口，保留现有后台视觉风格**
- [ ] **Step 3: 明确“开启循环 / 停止循环 / 跳过当前 Boss”的交互文案**
- [ ] **Step 4: 跑前端构建确认页面通过**

### Task 5: 文档与验证

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 更新 README 的 Boss 后台能力说明**
- [ ] **Step 2: 运行 `rtk go test ./...`**
- [ ] **Step 3: 运行 `rtk go vet ./...`**
- [ ] **Step 4: 运行 `rtk npm run build --prefix frontend`**
