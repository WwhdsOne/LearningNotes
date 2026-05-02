---
tags:
  - long-game
  - archive
---

> **⚠️ 本文档已废弃**（2026-04-30 核查：与当前代码不符）
>
> 系统已完全迁移至 Go + Boss 部位架构，Node.js/Express/Socket.IO/按钮 REST API 均不存在

# Redis Vote Wall Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Vue + Node.js vote wall that reads dynamic buttons from Redis, increments counts atomically, syncs updates in realtime, and ships in a single Docker image.

**Architecture:** Use a small Node.js backend to serve REST + Socket.IO + static frontend assets. Store each vote button in a Redis hash under a shared prefix and poll for topology changes so newly added keys show up automatically. Keep the frontend schema-driven so new buttons render without code changes.

**Tech Stack:** Node.js, Express, Socket.IO, Redis, Vue 3, Vite, node:test, Supertest, Docker

---

### Task 1: Scaffold workspace

**Files:**
- Create: `package.json`
- Create: `frontend/package.json`
- Create: `backend/package.json`
- Create: `frontend/vite.config.js`
- Create: `frontend/index.html`

- [ ] Step 1: Create root helper scripts for build, dev, and test.
- [ ] Step 2: Create frontend Vite app skeleton.
- [ ] Step 3: Create backend package with runtime and test dependencies.

### Task 2: Write failing backend tests first

**Files:**
- Create: `backend/tests/buttonStore.test.js`
- Create: `backend/tests/app.test.js`

- [ ] Step 1: Write failing tests for Redis button normalization, sorting, and filtering.
- [ ] Step 2: Run the targeted tests and confirm they fail for missing implementation.
- [ ] Step 3: Write failing API tests for listing buttons and incrementing counts.
- [ ] Step 4: Run the API tests and confirm they fail for missing app code.

### Task 3: Implement backend

**Files:**
- Create: `backend/src/config.js`
- Create: `backend/src/redisClient.js`
- Create: `backend/src/buttonStore.js`
- Create: `backend/src/createApp.js`
- Create: `backend/src/server.js`

- [ ] Step 1: Implement Redis config loading and connection helpers.
- [ ] Step 2: Implement button discovery, normalization, sorting, and atomic click logic.
- [ ] Step 3: Implement Express endpoints and Socket.IO broadcast hooks.
- [ ] Step 4: Re-run backend tests until green.

### Task 4: Implement frontend

**Files:**
- Create: `frontend/src/main.js`
- Create: `frontend/src/App.vue`
- Create: `frontend/src/style.css`

- [ ] Step 1: Build a data-driven UI for vote cards and totals.
- [ ] Step 2: Add REST bootstrap + Socket.IO sync.
- [ ] Step 3: Handle loading, empty, and click-pending states.
- [ ] Step 4: Build the frontend and verify assets emit successfully.

### Task 5: Wire production build and Docker

**Files:**
- Create: `Dockerfile`
- Create: `.dockerignore`
- Create: `.env.example`
- Create: `README.md`

- [ ] Step 1: Make frontend build output available to the backend static server.
- [ ] Step 2: Write the single-container Dockerfile.
- [ ] Step 3: Document Redis key format, local development, and deployment.
- [ ] Step 4: Run tests and production build verification.
