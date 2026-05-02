---
tags:
  - long-game
  - implementation
---

# WebSocket 交互优化方案

**日期**：2026-04-26
**状态**：待实施
**原则**：低风险分阶段，第一阶段只做防抖 + 压缩，不做增量 diff

---

## 一、当前问题

- 每次 StateChange 都触发全量 Snapshot 广播（1.5-5KB）和全量 UserState 广播（3-15KB）
- 高频点击场景下，广播次数 = 点击次数，无合并
- 无 WebSocket 消息压缩

---

## 二、第一阶段：防抖 + 压缩

### 2.1 目标

- 连点时 click_ack 不延迟
- 连点 N 次，公共广播次数从 N 降至 1-2 次
- 带宽减少 60-80%（压缩）
- 前端逻辑几乎不变

### 2.2 数据流

```
点击路径（不变）：
  点击 → handleMessage → send(click_ack) 立即返回

广播路径（加防抖）：
  点击 → publishChange → Dispatcher 标记 publicDirty + 启动 50ms timer
                              ↓ (50ms 后)
                         RefreshSnapshot → BroadcastPublic 全量快照
```

### 2.3 改动清单（5 个文件）

#### 文件 1：`backend/internal/config/config.go`

新增 `RealtimeConfig` 结构体：

```go
type RealtimeConfig struct {
    DebounceMs int // 公共态防抖窗口，毫秒；0 使用默认值 50
}
```

在 `Config` 中新增字段：

```go
type Config struct {
    // ... 现有字段
    Realtime RealtimeConfig
}
```

在 `fileConfig` 中新增：

```go
type fileConfig struct {
    // ... 现有字段
    Realtime struct {
        DebounceMs int `yaml:"debounce_ms"`
    } `yaml:"realtime"`
}
```

在 `loadFromConsul` 中解析，设置默认值：

```go
debounceMs := parsed.Realtime.DebounceMs
if debounceMs <= 0 {
    debounceMs = 50
}
config.Realtime = RealtimeConfig{DebounceMs: debounceMs}
```

#### 文件 2：`backend/config.example.yaml`

新增配置项：

```yaml
realtime:
  debounce_ms: 50
```

#### 文件 3：`backend/internal/httpapi/realtime_socket.go`

**改动 A：启用 permessage-deflate**

第 119-121 行，Upgrader 加压缩：

```go
upgrader := websocket.HertzUpgrader{
    CheckOrigin:       func(_ *app.RequestContext) bool { return true },
    EnableCompression: true,
}
```

**改动 B：click_ack 携带 userDelta**

`realtimeClickAckPayload` 新增可选字段：

```go
type realtimeClickAckPayload struct {
    Delta      int64  `json:"delta"`
    Critical   bool   `json:"critical"`
    BossDamage int64  `json:"bossDamage,omitempty"`
    DamageType string `json:"damageType,omitempty"`
    Button     struct {
        Key string `json:"key"`
    } `json:"button"`
    // 新增：个人即时反馈
    UserDelta *realtimeUserDelta `json:"userDelta,omitempty"`
}

type realtimeUserDelta struct {
    Gold         *int64 `json:"gold,omitempty"`
    Stones       *int64 `json:"stones,omitempty"`
    TalentPoints *int64 `json:"talentPoints,omitempty"`
}
```

`handleMessage` 中 click 处理，发送 ack 前获取用户态变化：

```go
// 获取用户态用于即时反馈
if s.nickname != "" && s.stateView != nil {
    if userState, err := s.stateView.GetUserState(ctx, s.nickname); err == nil {
        ack.Payload.UserDelta = &realtimeUserDelta{
            Gold:         &userState.Gold,
            Stones:       &userState.Stones,
            TalentPoints: &userState.TalentPoints,
        }
    }
}
```

注意：这里直接从 stateView 读取最新用户态，不依赖 Cache 的 diff，简单可靠。

#### 文件 4：`backend/internal/events/dispatcher.go`

加防抖逻辑，新增字段：

```go
type Dispatcher struct {
    cache       *Cache
    hub         *Hub
    debounceMs  int
    mu          sync.Mutex
    publicDirty bool
    publicTimer *time.Timer
}
```

`NewDispatcher` 改为接收 debounceMs 参数：

```go
func NewDispatcher(cache *Cache, hub *Hub, debounceMs int) *Dispatcher {
    return &Dispatcher{
        cache:      cache,
        hub:        hub,
        debounceMs: debounceMs,
    }
}
```

`HandleChange` 改造：公共态路径改为防抖，用户态路径保持不变：

```go
func (d *Dispatcher) HandleChange(ctx context.Context, change vote.StateChange) error {
    if d == nil || d.cache == nil || d.hub == nil {
        return nil
    }

    // 公共态：防抖
    if affectsPublicState(change.Type) {
        d.mu.Lock()
        d.publicDirty = true
        if d.publicTimer != nil {
            d.publicTimer.Stop()
        }
        d.publicTimer = time.AfterFunc(
            time.Duration(d.debounceMs)*time.Millisecond,
            d.flushPublic,
        )
        d.mu.Unlock()
    }

    // 用户态：保持不变，不防抖
    targetNicknames := userTargetsForChange(change, d.hub.ActiveNicknames())
    if len(targetNicknames) == 0 {
        return nil
    }
    userStates, err := d.cache.RefreshUsers(ctx, targetNicknames)
    if err != nil {
        return err
    }
    for nickname, userState := range userStates {
        if err := d.hub.BroadcastUser(nickname, userState); err != nil {
            return err
        }
    }
    return nil
}
```

新增 `flushPublic` 方法：

```go
func (d *Dispatcher) flushPublic() {
    d.mu.Lock()
    if !d.publicDirty {
        d.mu.Unlock()
        return
    }
    d.publicDirty = false
    d.publicTimer = nil
    d.mu.Unlock()

    ctx := context.Background()
    snapshot, err := d.cache.RefreshSnapshot(ctx)
    if err != nil {
        return
    }
    if snapshot.Boss != nil {
        if _, err := d.cache.RefreshBossResources(ctx); err != nil {
            // log error, non-fatal
        }
    }
    if err := d.hub.BroadcastPublic(snapshot); err != nil {
        return
    }
}
```

#### 文件 5：前端 `publicPageState.js`（可选）

click_ack 的 userDelta 需要前端消费。在 `applyClickResult` 中：

```js
function applyClickResult(payload) {
    if (!payload || typeof payload !== 'object') return

    buttonTotalVotes.value = Math.max(0, buttonTotalVotes.value + Number(payload.delta || 0))

    // 新增：应用 userDelta 即时反馈
    if (payload.userDelta) {
        if (payload.userDelta.gold !== undefined) {
            gold.value = Number(payload.userDelta.gold)
        }
        if (payload.userDelta.stones !== undefined) {
            stones.value = Number(payload.userDelta.stones)
        }
        if (payload.userDelta.talentPoints !== undefined) {
            talentPoints.value = Number(payload.userDelta.talentPoints)
        }
    }

    // 现有逻辑保持不变
    const nextClickState = mergeClickFallbackState(...)
    // ...
}
```

---

### 2.4 验收标准

- [ ] 连点时 click_ack 不延迟
- [ ] 连点 10 次，公共广播次数明显下降（从 10 降至 1-2 次）
- [ ] Boss 血量最终一致
- [ ] 多用户页面最终一致
- [ ] 断线重连后仍能收到完整快照
- [ ] 排行榜不会出现错位、残留、重复
- [ ] 没有 data race
- [ ] permessage-deflate 失败不影响连接

---

## 三、第二阶段预留（不实现）

以下方向在第一阶段稳定后考虑，当前只记录，不实现：

### 3.1 PublicDeltaPayload（简单字段）

只对以下字段做增量，排行榜继续全量：

```go
type PublicDeltaPayload struct {
    Version    int64  `json:"version"`
    TotalVotes *int64 `json:"totalVotes,omitempty"`
    BossHP     *int64 `json:"bossHp,omitempty"`
}
```

### 3.2 BroadcastPublicDelta

Hub 新增方法，广播简单增量。前端 applyPublicState 增加 merge 分支。

### 3.3 UserDeltaPayload

click_ack 的 userDelta 扩展到更多字段（combatStats、inventory 等）。

### 3.4 Cache diff

cache.go 维护 lastSnapshot，ComputePublicDelta 计算简单 diff。

---

## 四、风险与降级

| 风险 | 降级方案 |
|---|---|
| 防抖导致公共态更新延迟 50ms | 人眼无感知；配置 debounce_ms=0 可禁用 |
| permessage-deflate 增加 CPU | 客户端不支持时自动降级；可后续关闭 |
| timer goroutine 泄漏 | timer.Stop() + 置 nil，无泄漏风险 |
| flushPublic 中 context.Background() 无超时 | RefreshSnapshot 内部已有 Redis 超时 |

---

## 五、实施顺序

1. `config.go` + `config.example.yaml`：新增 `RealtimeConfig`
2. `dispatcher.go`：加防抖逻辑 + `flushPublic`
3. `realtime_socket.go`：Upgrader 加压缩 + click_ack 加 userDelta
4. 前端 `publicPageState.js`：消费 click_ack 的 userDelta
5. 测试验证
