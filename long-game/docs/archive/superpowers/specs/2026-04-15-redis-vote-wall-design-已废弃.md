---
tags:
  - long-game
  - archive
---

> **⚠️ 本文档已废弃**（2026-04-30 核查：与当前代码不符）
>
> 同上，整个架构已不存在

# Redis Vote Wall Design

**Goal:** Build a Vue + Node.js application that shows a shared vote wall with dynamic buttons backed by Redis, supports realtime count updates for all visitors, and ships as a single app container.

## Requirements

- Show a page with vote buttons and their current totals.
- Seed the initial buttons:
  - `有感觉吗`
  - `有没有懂的`
  - `微信[可怜]表情`
- Any visitor can click a button to increment its total.
- All connected visitors should see updated totals in realtime.
- New buttons should appear automatically when the operator adds a Redis key that matches the agreed naming rule.
- Redis is external and configured by the deployer.
- Frontend and backend must run from the same Docker image.

## Architecture

- `frontend/`: Vue 3 + Vite single-page UI.
- `backend/`: Express server that exposes REST endpoints, hosts Socket.IO, serves the built frontend, and connects to Redis.
- Root helpers: top-level npm scripts coordinate frontend build, backend start, and tests across the two subprojects.

## Redis Data Model

- Each button is stored as a Redis hash under the key pattern `vote:button:<slug>`.
- Required fields:
  - `label`: text shown on the button card.
  - `count`: integer total.
  - `sort`: integer ordering hint.
  - `enabled`: `1` or `0` to show or hide the button.
- Example:

```text
HSET vote:button:feel label "有感觉吗" count 0 sort 10 enabled 1
```

## Backend Behavior

- `GET /api/buttons`
  - Scans Redis for `vote:button:*`.
  - Loads button hashes, normalizes data, filters disabled entries, sorts by `sort` then slug, and returns the list.
- `POST /api/buttons/:slug/click`
  - Validates that the target hash exists and is enabled.
  - Uses `HINCRBY vote:button:<slug> count 1` for an atomic increment.
  - Reloads the updated button, emits a Socket.IO broadcast, and returns the new total.
- Socket.IO
  - Emits an initial snapshot after connection.
  - Broadcasts fresh snapshots after clicks.
  - Polls Redis on a short interval so newly added keys appear automatically without server restarts or Redis keyspace notification setup.

## Frontend Behavior

- Loads the current button list on page load.
- Connects to Socket.IO and replaces local state whenever a fresh snapshot arrives.
- Renders a responsive grid of vote cards.
- Clicking a card calls the click endpoint and disables duplicate submissions for that card until the request completes.
- Unknown or newly added buttons from Redis are rendered automatically.

## Deployment

- One Docker image:
  - Builds the Vue app.
  - Installs backend dependencies.
  - Starts the Node.js server that serves both API and static assets.
- Runtime configuration uses environment variables, documented in `.env.example`.
- Redis host, port, password, database index, poll interval, and key prefix are all configurable.
