---
tags:
  - long-game
  - superpowers
---

# Nickname Sensitive Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add backend-owned nickname sensitive-word validation using the `konsheng/Sensitive-lexicon` political lexicon so users cannot select or switch to blocked nicknames, while the frontend only displays validation results.

**Architecture:** Introduce a reusable nickname validator in the backend that loads the vendored political lexicon and performs substring matching after nickname normalization. Wire the validator into nickname validation, state loading, and click submission so all server entry points share the same rule, then update the frontend to call the backend validation endpoint before persisting a nickname locally.

**Tech Stack:** Go, Vue 3, embedded text lexicon, Go tests, Viteless frontend fetch flow

---

### Task 1: Add failing backend validator tests

**Files:**
- Create: `backend/internal/nickname/validator_test.go`

- [ ] **Step 1: Write failing tests for clean, empty, and political-sensitive nicknames**
- [ ] **Step 2: Run `go -C backend test ./internal/nickname ./internal/vote ./internal/httpapi` and verify failures**

### Task 2: Implement backend validator and wire it into store and HTTP APIs

**Files:**
- Create: `backend/internal/nickname/validator.go`
- Create: `backend/internal/nickname/lexicon/konsheng_political.txt`
- Create: `backend/internal/nickname/lexicon/LICENSE.konsheng.txt`
- Modify: `backend/internal/vote/store.go`
- Modify: `backend/internal/httpapi/router.go`
- Modify: `backend/cmd/server/main.go`

- [ ] **Step 1: Implement lexicon-backed nickname validator**
- [ ] **Step 2: Add a backend validation endpoint for frontend nickname selection**
- [ ] **Step 3: Reuse the same validator in state loading and click submission**
- [ ] **Step 4: Run targeted backend tests and get them green**

### Task 3: Update frontend to display backend validation results

**Files:**
- Modify: `frontend/src/App.vue`

- [ ] **Step 1: Write the failing frontend-facing integration expectations through backend tests first**
- [ ] **Step 2: Update nickname submit and restore flow to call backend validation**
- [ ] **Step 3: Keep frontend responsible only for showing backend messages**

### Task 4: Document and verify

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Document that nickname sensitive-word validation uses vendored `konsheng/Sensitive-lexicon` political lexicon data**
- [ ] **Step 2: Run fresh verification commands for backend tests and frontend build**
