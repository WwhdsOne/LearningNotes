---
tags:
  - long-game
  - archive
---

> **⚠️ 本文档已废弃**（2026-04-30 核查：与当前代码不符）
>
> REST API 端点已变更（GET /api/buttons 等已不存在），实时通信现为 WebSocket 优先 SSE 降级

# Go + SSE Migration

## Goal

在不重做现有页面视觉的前提下，把实时投票墙后端从 `Node.js + Socket.IO` 迁移到 `Go + SSE`，继续沿用 Redis 按钮结构和单容器部署方式。

## Scope

- 后端改为 Go，负责 Redis 读写、REST 接口、SSE 推送、静态文件托管。
- 前端只替换实时连接协议，页面布局和交互风格保持基本不动。
- Docker 运行时切到 Go 二进制。

## API

- `GET /api/health`
- `GET /api/buttons`
- `POST /api/buttons/{slug}/click`
- `GET /api/events`

## Redis

- 键格式继续使用 `vote:button:<slug>`
- 字段继续兼容 `label`、`count`、`sort`、`enabled`、`image_path`、`image_alt`
- 点击继续使用 Redis 原子自增

## Execution

1. 建立 Go 服务骨架和 Redis 存储层
2. 用 SSE 替换 Socket.IO 实时推送
3. 让前端改用 `EventSource`
4. 更新 Dockerfile、脚本和说明文档
5. 跑 Go 测试、前端构建和镜像构建校验
