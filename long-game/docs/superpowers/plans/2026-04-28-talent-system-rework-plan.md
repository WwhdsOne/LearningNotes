---
tags:
  - long-game
  - superpowers
---

# 天赋系统重构 实施计划

> 状态：实施记录。
>
> 本文保留“如何落地”的执行步骤与历史提交语义，但当前正式数值与成本模型以设计文档和成本总结为准：
>
> - `docs/superpowers/specs/2026-04-28-talent-system-rework-design.md`
> - `docs/reports/2026-04-28-天赋成本调整总结.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 三系天赋树全部改为 Lv1~Lv5 等级制，暴击系重构（死兆收割→被动、死亡狂喜→终极、末日审判→小技能），全系数值大幅提高，前端增加节点等级视觉表现。

**Architecture:** 后端 `talent.go` 负责定义、升级、修正计算，`store.go` 负责战斗触发逻辑；前端 `TalentsPage.vue` 负责树形展示和升级交互，等级视觉效果通过 CSS filter/box-shadow + canvas 粒子实现。

**Tech Stack:** Go (Hertz) 后端 + Vue 3 前端 + Redis 持久化

**影响范围:**
- `backend/internal/vote/talent.go` — 定义、状态、升级、修正计算
- `backend/internal/vote/store.go` — 战斗触发（`applyTriggeredTalentDamage`, `applyBossPartDamage`）
- `backend/internal/httpapi/talent_routes.go` — API 路由
- `backend/internal/httpapi/router_test.go` — mock 更新
- `backend/internal/vote/store_test.go` — 测试更新
- `frontend/src/pages/TalentsPage.vue` — 天赋页面主组件
- `frontend/src/pages/publicPageState.js` — 共享状态

---

### Task 1: 更新 TalentDef 结构体和成本常量

**Files:**
- Modify: `backend/internal/vote/talent.go:55-65` (TalentDef struct)
- Modify: `backend/internal/vote/talent.go:22-53` (cost constants)
- Modify: `backend/internal/vote/talent.go:140-152` (cost map + filler cost map)
- Modify: `backend/internal/vote/talent.go:213-228` (init cost assignment)

- [ ] **Step 1: 修改 TalentDef 结构体，增加 MaxLevel 字段**

```go
// TalentDef 天赋节点定义
type TalentDef struct {
	ID           string     `json:"id"`
	Tree         TalentTree `json:"tree"`
	Tier         int        `json:"tier"`     // 0=基石, 1-3=中间, 4=终极
	Cost         int64      `json:"cost"`     // Lv1 学习消耗的天赋点（基准成本）
	MaxLevel     int        `json:"maxLevel"` // 最高可学等级，默认 5
	Name         string     `json:"name"`
	EffectType   string     `json:"effectType"`
	EffectValue  any        `json:"effectValue"`
	Prerequisite string     `json:"prerequisite,omitempty"` // 前置天赋 ID
}
```

- [ ] **Step 2: 替换成本常量和映射表**

删除旧的成本常量（`TalentCostTier0`..`TalentCostTier4`, `TalentCostFillerTier1`..`TalentCostFillerTier3`），替换为新的基准成本：

```go
const (
	// 主节点 Lv1 基准成本（等级制）
	TalentCostTier0Main int64 = 20   // 基石
	TalentCostTier1Main int64 = 30   // 一阶
	TalentCostTier2Main int64 = 80   // 二阶
	TalentCostTier3Main int64 = 150  // 三阶
	TalentCostTier4Main int64 = 200  // 终极

	// 小节点 Lv1 基准成本
	TalentCostTier1Filler int64 = 15
	TalentCostTier2Filler int64 = 35
	TalentCostTier3Filler int64 = 60

	// 默认最高等级
	TalentDefaultMaxLevel = 5
)

// TalentLevelCost 计算升到指定等级这一次的单级消耗。
// 公式：cost(level) = round(base × level^0.85 × 1.8)
func TalentLevelCost(base int64, targetLevel int) int64 {
	if base <= 0 || targetLevel <= 0 {
		return 0
	}
	return int64(math.Round(float64(base) * math.Pow(float64(targetLevel), 0.85) * 1.8))
}

// TalentLevelCostDiff 从当前等级升到目标等级需要支付的差价
func TalentLevelCostDiff(base int64, currentLevel, targetLevel int) int64 {
	var total int64
	for lv := currentLevel + 1; lv <= targetLevel; lv++ {
		total += TalentLevelCost(base, lv)
	}
	return total
}

// TalentCumulativeCost 计算从 0 级升到目标等级的累计总消耗
func TalentCumulativeCost(base int64, targetLevel int) int64 {
	return TalentLevelCostDiff(base, 0, targetLevel)
}
```

- [ ] **Step 3: 更新成本映射表**

```go
var talentTierMainCosts = map[int]int64{
	0: TalentCostTier0Main,
	1: TalentCostTier1Main,
	2: TalentCostTier2Main,
	3: TalentCostTier3Main,
	4: TalentCostTier4Main,
}

var talentTierFillerCosts = map[int]int64{
	1: TalentCostTier1Filler,
	2: TalentCostTier2Filler,
	3: TalentCostTier3Filler,
}
```

- [ ] **Step 4: 更新 init() 中的成本赋值**

```go
func init() {
	for id, def := range talentDefs {
		if def.MaxLevel <= 0 {
			def.MaxLevel = TalentDefaultMaxLevel
		}
		var baseCost int64
		if isFillerTalentID(id) {
			baseCost = talentTierFillerCosts[def.Tier]
		} else {
			var ok bool
			baseCost, ok = talentTierMainCosts[def.Tier]
			if !ok {
				baseCost = 0
			}
		}
		def.Cost = baseCost
		talentDefs[id] = def
	}
}
```

- [ ] **Step 5: 删除旧的 `talentCostByTier` 函数**（已被 `TalentLevelCost` 替代）

- [ ] **Step 6: 编译验证**

```bash
cd backend && go build ./...
```

Expected: 编译通过（可能有未使用的 import 警告，后续任务解决）

- [ ] **Step 7: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "refactor(talent): TalentDef 增加 MaxLevel，成本公式改为等级制"
```

---

### Task 2: 更新 talentDefs — 所有天赋定义的新数值

**Files:**
- Modify: `backend/internal/vote/talent.go:78-138` (talentDefs map)

- [ ] **Step 1: 更新普攻系（均衡攻势）定义**

替换 normal 系所有定义的 EffectValue 为新数值，并增加 `MaxLevel: 5`：

```go
var talentDefs = map[string]TalentDef{
	// ===== 普攻：均衡攻势 =====
	"normal_core":      {ID: "normal_core", Tree: TalentTreeNormal, Tier: 0, MaxLevel: 5, Name: "暴风连击", EffectType: "storm_combo", EffectValue: map[string]any{"triggerCount": 50.0, "extraHits": 20.0, "chaseRatio": 0.50, "maxChaseRatio": 0.80}},
	"normal_atk_up":    {ID: "normal_atk_up", Tree: TalentTreeNormal, Tier: 1, MaxLevel: 5, Name: "攻击强化", EffectType: "attack_power_percent", EffectValue: map[string]any{"percent": 0.60}, Prerequisite: "normal_core"},
	"normal_dmg_amp":   {ID: "normal_dmg_amp", Tree: TalentTreeNormal, Tier: 1, MaxLevel: 5, Name: "伤害增幅", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.50}, Prerequisite: "normal_core"},
	"normal_soft_atk":  {ID: "normal_soft_atk", Tree: TalentTreeNormal, Tier: 1, MaxLevel: 5, Name: "软组织特攻", EffectType: "part_type_damage", EffectValue: map[string]any{"partType": "soft", "percent": 0.80}, Prerequisite: "normal_core"},
	"normal_charge":    {ID: "normal_charge", Tree: TalentTreeNormal, Tier: 2, MaxLevel: 5, Name: "蓄力返还", EffectType: "charge_retain", EffectValue: map[string]any{"retainPercent": 0.40}, Prerequisite: "normal_atk_up"},
	"normal_chase_up":  {ID: "normal_chase_up", Tree: TalentTreeNormal, Tier: 2, MaxLevel: 5, Name: "追击强化", EffectType: "chase_upgrade", EffectValue: map[string]any{"chaseRatio": 1.00}, Prerequisite: "normal_dmg_amp"},
	"normal_combo_ext": {ID: "normal_combo_ext", Tree: TalentTreeNormal, Tier: 2, MaxLevel: 5, Name: "连击扩展", EffectType: "combo_extend", EffectValue: map[string]any{"extraHits": 30.0}, Prerequisite: "normal_soft_atk"},
	"normal_encircle":  {ID: "normal_encircle", Tree: TalentTreeNormal, Tier: 3, MaxLevel: 5, Name: "围剿", EffectType: "per_part_damage", EffectValue: map[string]any{"percentPerPart": 0.20}, Prerequisite: "normal_charge"},
	"normal_low_hp":    {ID: "normal_low_hp", Tree: TalentTreeNormal, Tier: 3, MaxLevel: 5, Name: "残血收割", EffectType: "low_hp_bonus", EffectValue: map[string]any{"hpThreshold": 0.40, "multiplier": 3.0}, Prerequisite: "normal_chase_up"},
	"normal_ultimate":  {ID: "normal_ultimate", Tree: TalentTreeNormal, Tier: 4, MaxLevel: 5, Name: "白银风暴", EffectType: "silver_storm", EffectValue: map[string]any{"triggerHits": 15, "treatAllAs": "soft"}, Prerequisite: "normal_encircle"},
```

- [ ] **Step 2: 更新破甲系（碎盾攻坚）定义**

```go
	// ===== 破甲：碎盾攻坚 =====
	"armor_core":         {ID: "armor_core", Tree: TalentTreeArmor, Tier: 0, MaxLevel: 5, Name: "灭绝穿甲", EffectType: "permanent_armor_pen", EffectValue: map[string]any{"penPercent": 0.60, "collapseTrigger": 50, "collapseDuration": 8}},
	"armor_pen_up":       {ID: "armor_pen_up", Tree: TalentTreeArmor, Tier: 1, MaxLevel: 5, Name: "穿甲强化", EffectType: "armor_pen_extra", EffectValue: map[string]any{"extraPen": 0.50}, Prerequisite: "armor_core"},
	"armor_boss_hunter":  {ID: "armor_boss_hunter", Tree: TalentTreeArmor, Tier: 1, MaxLevel: 5, Name: "首领猎杀", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.60}, Prerequisite: "armor_core"},
	"armor_heavy_scale":  {ID: "armor_heavy_scale", Tree: TalentTreeArmor, Tier: 1, MaxLevel: 5, Name: "以强制强", EffectType: "armor_scaling", EffectValue: map[string]any{"damagePer100Armor": 0.04}, Prerequisite: "armor_core"},
	"armor_heavy_atk":    {ID: "armor_heavy_atk", Tree: TalentTreeArmor, Tier: 2, MaxLevel: 5, Name: "重甲特攻", EffectType: "part_type_damage", EffectValue: map[string]any{"partType": "heavy", "percent": 1.00}, Prerequisite: "armor_pen_up"},
	"armor_collapse_ext": {ID: "armor_collapse_ext", Tree: TalentTreeArmor, Tier: 2, MaxLevel: 5, Name: "崩塌延长", EffectType: "collapse_extend", EffectValue: map[string]any{"extraDuration": 20.0}, Prerequisite: "armor_boss_hunter"},
	"armor_auto_strike":  {ID: "armor_auto_strike", Tree: TalentTreeArmor, Tier: 2, MaxLevel: 5, Name: "自动打击", EffectType: "auto_strike", EffectValue: map[string]any{"interval": 15.0, "damageRatio": 4.0}, Prerequisite: "armor_heavy_scale"},
	"armor_ruin":         {ID: "armor_ruin", Tree: TalentTreeArmor, Tier: 3, MaxLevel: 5, Name: "废墟打击", EffectType: "collapse_damage_amp", EffectValue: map[string]any{"extraPercent": 2.0}, Prerequisite: "armor_heavy_atk"},
	"armor_pen_convert":  {ID: "armor_pen_convert", Tree: TalentTreeArmor, Tier: 3, MaxLevel: 5, Name: "破甲转化", EffectType: "pen_to_amplify", EffectValue: map[string]any{"convertRatio": 0.60}, Prerequisite: "armor_collapse_ext"},
	"armor_ultimate":     {ID: "armor_ultimate", Tree: TalentTreeArmor, Tier: 4, MaxLevel: 5, Name: "审判日", EffectType: "judgment_day", EffectValue: map[string]any{"triggerCount": 60.0, "hpCutPercent": 0.60}, Prerequisite: "armor_ruin"},
```

- [ ] **Step 3: 更新暴击系（致命洞察）定义**

注意：末日审判改为小技能（Tier1），死兆收割改为被动（保留 Tier2），死亡狂喜改为终极（Tier4）。新增 `crit_doom_judgment` 作为小技能，旧的 `crit_ultimate` 改为死亡狂喜。

```go
	// ===== 暴击：致命洞察 =====
	"crit_core":            {ID: "crit_core", Tree: TalentTreeCrit, Tier: 0, MaxLevel: 5, Name: "溢杀", EffectType: "overkill", EffectValue: map[string]any{"baseCritBonus": 0.35, "overflowToCritDmg": 0.02, "omenPerWeakCrit": 2}},
	"crit_omen_resonate":   {ID: "crit_omen_resonate", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "死兆共鸣", EffectType: "omen_crit_damage", EffectValue: map[string]any{"critDmgPerOmen": 0.008}, Prerequisite: "crit_core"},
	"crit_cruel":           {ID: "crit_cruel", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "残忍", EffectType: "crit_damage_bonus", EffectValue: map[string]any{"percent": 1.20}, Prerequisite: "crit_core"},
	"crit_skinner":         {ID: "crit_skinner", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "剥皮", EffectType: "force_weak", EffectValue: map[string]any{"chance": 0.50, "duration": 8}, Prerequisite: "crit_core"},
	"crit_doom_judgment":   {ID: "crit_doom_judgment", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "末日审判", EffectType: "doom_mark", EffectValue: map[string]any{"markCount": 2.0, "omenPerMark": 25.0, "hpThreshold": 0.30}, Prerequisite: "crit_core"},
	"crit_bleed":           {ID: "crit_bleed", Tree: TalentTreeCrit, Tier: 2, MaxLevel: 5, Name: "致命出血", EffectType: "bleed", EffectValue: map[string]any{"duration": 4, "damageRatio": 1.00}, Prerequisite: "crit_omen_resonate"},
	"crit_omen_kill":       {ID: "crit_omen_kill", Tree: TalentTreeCrit, Tier: 2, MaxLevel: 5, Name: "斩杀预兆", EffectType: "omen_low_hp", EffectValue: map[string]any{"hpThreshold": 0.50, "dmgPerOmen": 0.02}, Prerequisite: "crit_cruel"},
	"crit_omen_reap":       {ID: "crit_omen_reap", Tree: TalentTreeCrit, Tier: 2, MaxLevel: 5, Name: "死兆收割", EffectType: "omen_reap_passive", EffectValue: map[string]any{"thresholds": []float64{30, 60, 90, 120}, "damageMult": []float64{1.5, 2.0, 2.5, 3.0}}, Prerequisite: "crit_skinner"},
	"crit_final_cut":       {ID: "crit_final_cut", Tree: TalentTreeCrit, Tier: 3, MaxLevel: 5, Name: "终末血斩", EffectType: "final_cut", EffectValue: map[string]any{"critCount": 80.0, "hpCutPercent": 0.15, "cooldown": 30}, Prerequisite: "crit_omen_kill"},
	"crit_death_ecstasy":   {ID: "crit_death_ecstasy", Tree: TalentTreeCrit, Tier: 4, MaxLevel: 5, Name: "死亡狂喜", EffectType: "death_ecstasy_ult", EffectValue: map[string]any{"omenCost": 100.0, "critDmgMult": 1.0}, Prerequisite: "crit_bleed"},
```

- [ ] **Step 4: 更新三系小节点（filler）定义**

```go
	// ===== 均衡攻势 小节点 =====
	"normal_filler_t1a": {ID: "normal_filler_t1a", Tree: TalentTreeNormal, Tier: 1, MaxLevel: 5, Name: "锐锋", EffectType: "attack_power_percent", EffectValue: map[string]any{"percent": 0.15}},
	"normal_filler_t1b": {ID: "normal_filler_t1b", Tree: TalentTreeNormal, Tier: 1, MaxLevel: 5, Name: "乱舞", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.12}},
	"normal_filler_t2a": {ID: "normal_filler_t2a", Tree: TalentTreeNormal, Tier: 2, MaxLevel: 5, Name: "追猎", EffectType: "chase_ratio_bonus", EffectValue: map[string]any{"percent": 0.15}},
	"normal_filler_t2b": {ID: "normal_filler_t2b", Tree: TalentTreeNormal, Tier: 2, MaxLevel: 5, Name: "穿刺", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.12}},
	"normal_filler_t3a": {ID: "normal_filler_t3a", Tree: TalentTreeNormal, Tier: 3, MaxLevel: 5, Name: "狩猎", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.20}},
	"normal_filler_t3b": {ID: "normal_filler_t3b", Tree: TalentTreeNormal, Tier: 3, MaxLevel: 5, Name: "铁腕", EffectType: "attack_power_percent", EffectValue: map[string]any{"percent": 0.15}},

	// ===== 碎盾攻坚 小节点 =====
	"armor_filler_t1a": {ID: "armor_filler_t1a", Tree: TalentTreeArmor, Tier: 1, MaxLevel: 5, Name: "破岩", EffectType: "attack_power_percent", EffectValue: map[string]any{"percent": 0.15}},
	"armor_filler_t1b": {ID: "armor_filler_t1b", Tree: TalentTreeArmor, Tier: 1, MaxLevel: 5, Name: "凿裂", EffectType: "armor_pen_extra", EffectValue: map[string]any{"extraPen": 0.08}},
	"armor_filler_t2a": {ID: "armor_filler_t2a", Tree: TalentTreeArmor, Tier: 2, MaxLevel: 5, Name: "瓦解", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.12}},
	"armor_filler_t2b": {ID: "armor_filler_t2b", Tree: TalentTreeArmor, Tier: 2, MaxLevel: 5, Name: "碾碎", EffectType: "armor_scaling", EffectValue: map[string]any{"damagePer100Armor": 0.015}},
	"armor_filler_t3a": {ID: "armor_filler_t3a", Tree: TalentTreeArmor, Tier: 3, MaxLevel: 5, Name: "碎颅", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.20}},
	"armor_filler_t3b": {ID: "armor_filler_t3b", Tree: TalentTreeArmor, Tier: 3, MaxLevel: 5, Name: "摧坚", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.12}},

	// ===== 致命洞察 小节点 =====
	"crit_filler_t1a": {ID: "crit_filler_t1a", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "锐眼", EffectType: "attack_power_percent", EffectValue: map[string]any{"percent": 0.15}},
	"crit_filler_t1b": {ID: "crit_filler_t1b", Tree: TalentTreeCrit, Tier: 1, MaxLevel: 5, Name: "残酷", EffectType: "crit_damage_bonus", EffectValue: map[string]any{"percent": 0.15}},
	"crit_filler_t2a": {ID: "crit_filler_t2a", Tree: TalentTreeCrit, Tier: 2, MaxLevel: 5, Name: "深创", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.12}},
	"crit_filler_t2b": {ID: "crit_filler_t2b", Tree: TalentTreeCrit, Tier: 2, MaxLevel: 5, Name: "喋血", EffectType: "omen_crit_damage", EffectValue: map[string]any{"critDmgPerOmen": 0.003}},
	"crit_filler_t3a": {ID: "crit_filler_t3a", Tree: TalentTreeCrit, Tier: 3, MaxLevel: 5, Name: "追魂", EffectType: "all_damage_amplify", EffectValue: map[string]any{"percent": 0.20}},
	"crit_filler_t3b": {ID: "crit_filler_t3b", Tree: TalentTreeCrit, Tier: 3, MaxLevel: 5, Name: "暴虐", EffectType: "crit_damage_bonus", EffectValue: map[string]any{"percent": 0.15}},
}
```

- [ ] **Step 5: 编译验证**

```bash
cd backend && go build ./...
```

Expected: 编译通过

- [ ] **Step 6: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "refactor(talent): 更新全部天赋定义为新数值+等级制+暴击系重构"
```

---

### Task 3: 更新 TalentState 存储格式

**Files:**
- Modify: `backend/internal/vote/talent.go:67-75` (TalentState + talentPlayerData)
- Modify: `backend/internal/vote/talent.go:456-479` (GetTalentState)
- Modify: `backend/internal/vote/talent.go:742-754` (HasTalent)
- Modify: `backend/internal/vote/talent.go:207-211` (isFillerTalentID — no change needed but verify)

- [ ] **Step 1: 修改 TalentState 和 talentPlayerData**

```go
// TalentState 玩家天赋状态
type TalentState struct {
	Talents map[string]int `json:"talents"` // talentID → 当前等级
}

// talentPlayerData Redis 中存储的原始结构
type talentPlayerData struct {
	Talents string `json:"talents"` // JSON: map[string]int
}
```

- [ ] **Step 2: 重写 GetTalentState**

```go
func (s *Store) GetTalentState(ctx context.Context, nickname string) (*TalentState, error) {
	values, err := s.client.HGetAll(ctx, s.talentKey(nickname)).Result()
	if err != nil {
		return nil, err
	}
	if len(values) == 0 {
		return &TalentState{Talents: make(map[string]int)}, nil
	}

	state := &TalentState{}
	talentsRaw := values["talents"]
	if talentsRaw != "" {
		talents := make(map[string]int)
		if err := sonic.Unmarshal([]byte(talentsRaw), &talents); err != nil {
			// 兼容旧格式: []string → 迁移为 map[string]int (均为 Lv1)
			var oldTalents []string
			if err2 := sonic.Unmarshal([]byte(talentsRaw), &oldTalents); err2 != nil {
				return nil, err
			}
			for _, id := range oldTalents {
				talents[id] = 1
			}
		}
		state.Talents = talents
	} else {
		state.Talents = make(map[string]int)
	}

	return state, nil
}
```

- [ ] **Step 3: 添加辅助函数**

```go
// GetTalentLevel 获取指定天赋的当前等级（0 表示未学）
func GetTalentLevel(state *TalentState, talentID string) int {
	if state == nil || state.Talents == nil {
		return 0
	}
	return state.Talents[talentID]
}

// HasTalentLearned 检查天赋是否至少 Lv1
func HasTalentLearned(state *TalentState, talentID string) bool {
	return GetTalentLevel(state, talentID) > 0
}
```

- [ ] **Step 4: 更新 HasTalent store 方法**

```go
func (s *Store) HasTalent(ctx context.Context, nickname string, talentID string) (bool, error) {
	state, err := s.GetTalentState(ctx, nickname)
	if err != nil {
		return false, err
	}
	return HasTalentLearned(state, talentID), nil
}
```

- [ ] **Step 5: 更新所有调用 `state.Talents` 的地方（遍历改为 map 遍历）**

在后续 Task 中逐步修改。当前 TalentState 的使用者：
- `UpgradeTalent`（原 LearnTalent）— Task 4
- `ResetTalents` — Task 4
- `ComputeTalentModifiers` — Task 6
- `isLearnedTierFull` — 修改为接受 `map[string]int`
- 前端 API 返回 — Task 15

- [ ] **Step 6: 更新 isLearnedTierFull**

```go
func isLearnedTierFull(tree TalentTree, tier int, talents map[string]int) bool {
	needed := tierNodeCount[tier]
	if needed == 0 {
		return true
	}
	count := 0
	for id, level := range talents {
		if level <= 0 {
			continue
		}
		def, ok := talentDefs[id]
		if !ok {
			continue
		}
		if def.Tree == tree && def.Tier == tier {
			count++
		}
	}
	return count >= needed
}
```

- [ ] **Step 7: 编译验证**

```bash
cd backend && go build ./...
```

Expected: 可能有编译错误（其他文件引用了旧的 `state.Talents` 切片类型），在后续 Task 逐个修复。

- [ ] **Step 8: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "refactor(talent): TalentState 存储改为 map[string]int 等级制"
```

---

### Task 4: 重写 UpgradeTalent 和 ResetTalents

**Files:**
- Modify: `backend/internal/vote/talent.go:481-571`

- [ ] **Step 1: 重写 LearnTalent → UpgradeTalent**

```go
// UpgradeTalent 升级一个天赋节点到指定等级（或 Lv1 首次学习）。
func (s *Store) UpgradeTalent(ctx context.Context, nickname string, talentID string, targetLevel int) error {
	if targetLevel < 1 {
		return ErrTalentInvalidLevel
	}

	def, ok := talentDefs[talentID]
	if !ok {
		return ErrTalentNotFound
	}
	if targetLevel > def.MaxLevel {
		return ErrTalentMaxLevel
	}

	state, err := s.GetTalentState(ctx, nickname)
	if err != nil {
		return err
	}
	currentLevel := GetTalentLevel(state, talentID)
	if currentLevel >= targetLevel {
		return ErrTalentAlreadyLearned
	}
	if currentLevel == 0 && targetLevel >= 1 {
		// 首次学习：检查前置
		if def.Prerequisite != "" {
			if !HasTalentLearned(state, def.Prerequisite) {
				return ErrTalentPrerequisite
			}
		}
		// 层锁校验
		if def.Tier > 0 {
			if !isLearnedTierFull(def.Tree, def.Tier-1, state.Talents) {
				return ErrTalentPrerequisite
			}
		}
	}

	// 计算差价
	diff := TalentLevelCostDiff(def.Cost, currentLevel, targetLevel)
	if diff <= 0 {
		return ErrTalentInvalidCost
	}

	resources, err := s.resourcesForNickname(ctx, nickname)
	if err != nil {
		return err
	}
	if resources.TalentPoints < diff {
		return ErrTalentPointsInsufficient
	}

	// 保存
	state.Talents[talentID] = targetLevel
	talentsJSON, err := sonic.Marshal(state.Talents)
	if err != nil {
		return err
	}

	pipe := s.client.TxPipeline()
	pipe.HSet(ctx, s.talentKey(nickname), "talents", string(talentsJSON))
	pipe.HIncrBy(ctx, s.resourceKey(nickname), "talent_points", -diff)
	_, err = pipe.Exec(ctx)
	return err
}
```

- [ ] **Step 2: 添加新的错误类型**

在 `store.go` 或 `talent.go` 的错误定义区域添加：

```go
var (
	ErrTalentInvalidLevel = errors.New("无效的等级")
	ErrTalentMaxLevel     = errors.New("已达到最高等级")
)
```

- [ ] **Step 3: 重写 ResetTalents**

```go
func (s *Store) ResetTalents(ctx context.Context, nickname string) error {
	state, err := s.GetTalentState(ctx, nickname)
	if err != nil {
		return err
	}
	if state == nil || len(state.Talents) == 0 {
		return s.client.HSet(ctx, s.talentKey(nickname), "talents", "{}").Err()
	}

	var refund int64
	for id, level := range state.Talents {
		def, ok := talentDefs[id]
		if !ok {
			continue
		}
		refund += TalentCumulativeCost(def.Cost, level)
	}

	pipe := s.client.TxPipeline()
	pipe.HSet(ctx, s.talentKey(nickname), "talents", "{}")
	if refund > 0 {
		pipe.HIncrBy(ctx, s.resourceKey(nickname), "talent_points", refund)
	}
	_, err = pipe.Exec(ctx)
	return err
}
```

- [ ] **Step 4: 编译验证**

```bash
cd backend && go build ./...
```

Expected: 少量编译错误（调用方尚未更新），后续 Task 修复。

- [ ] **Step 5: Commit**

```bash
git add backend/internal/vote/talent.go backend/internal/vote/store.go
git commit -m "refactor(talent): LearnTalent→UpgradeTalent 支持等级制，ResetTalents 适配新格式"
```

---

### Task 5: 重写 ComputeTalentModifiers 支持等级累加

**Files:**
- Modify: `backend/internal/vote/talent.go:600-739`

- [ ] **Step 1: 重写 ComputeTalentModifiers**

```go
func (s *Store) ComputeTalentModifiers(ctx context.Context, nickname string) (*TalentModifiers, error) {
	state, err := s.GetTalentState(ctx, nickname)
	if err != nil {
		return nil, err
	}
	if state == nil || len(state.Talents) == 0 {
		return &TalentModifiers{}, nil
	}

	mods := &TalentModifiers{
		PartTypeBonus: make(map[PartType]float64),
		Learned:       make([]string, 0, len(state.Talents)),
	}

	for id, level := range state.Talents {
		if level <= 0 {
			continue
		}
		def, ok := talentDefs[id]
		if !ok {
			continue
		}

		mods.Learned = append(mods.Learned, id)
		val, _ := def.EffectValue.(map[string]any)
		levelFactor := float64(level)

		switch def.EffectType {
		case "attack_power_percent":
			if p, ok := val["percent"].(float64); ok {
				mods.AttackPowerPercent += p * levelFactor
			}
		case "all_damage_amplify":
			if p, ok := val["percent"].(float64); ok {
				mods.AllDamageAmplify += p * levelFactor
			}
		case "part_type_damage":
			partTypeStr, _ := val["partType"].(string)
			percent, _ := val["percent"].(float64)
			if partTypeStr != "" {
				mods.PartTypeBonus[PartType(partTypeStr)] += percent * levelFactor
			}
		case "armor_pen_extra":
			if p, ok := val["extraPen"].(float64); ok {
				mods.ArmorPenExtra += p * levelFactor
			}
		case "crit_damage_bonus":
			if p, ok := val["percent"].(float64); ok {
				mods.CritDamagePercentBonus += p * levelFactor
			}
		case "per_part_damage":
			if p, ok := val["percentPerPart"].(float64); ok {
				mods.PerPartDamagePercent += p * levelFactor
			}
		case "low_hp_bonus":
			if m, ok := val["multiplier"].(float64); ok {
				mods.LowHpMultiplier += m * levelFactor
			}
			if threshold, ok := val["hpThreshold"].(float64); ok {
				// 阈值取最高等级值
				t := threshold * levelFactor
				if t > mods.LowHpThreshold {
					mods.LowHpThreshold = t
				}
			}
		case "collapse_extend":
			if d, ok := val["extraDuration"].(float64); ok {
				mods.CollapseDuration += int(d) * level
			}
		case "pen_to_amplify":
			// 破甲转化比例也按等级累加
			if r, ok := val["convertRatio"].(float64); ok {
				_ = r * levelFactor // 在 ApplyTalentEffectsToCombatStats 中使用
			}
		case "chase_ratio_bonus":
			if p, ok := val["percent"].(float64); ok {
				mods.ChaseRatioBonus += p * levelFactor
			}
		case "omen_crit_damage":
			if p, ok := val["critDmgPerOmen"].(float64); ok {
				mods.OmenCritDmgExtra += p * levelFactor
			}
		}
	}

	// 层满奖励检测（逻辑不变，只适配 map[string]int）
	learnedTrees := map[TalentTree]bool{}
	for id, level := range state.Talents {
		if level <= 0 {
			continue
		}
		if def, ok := talentDefs[id]; ok {
			learnedTrees[def.Tree] = true
		}
	}
	for tree := range learnedTrees {
		treeStr := string(tree)
		for tier := 0; tier <= 4; tier++ {
			count := 0
			for id, level := range state.Talents {
				if level <= 0 {
					continue
				}
				def, ok := talentDefs[id]
				if !ok {
					continue
				}
				if def.Tier == tier && string(def.Tree) == treeStr {
					count++
				}
			}
			needed, ok := tierNodeCount[tier]
			if !ok {
				continue
			}
			if count >= needed {
				applyTierCompletionBonus(mods, treeStr, tier)
			}
		}
	}

	return mods, nil
}

// applyTierCompletionBonus 应用层满奖励
func applyTierCompletionBonus(mods *TalentModifiers, treeStr string, tier int) {
	switch {
	case treeStr == "normal" && tier == 0:
		mods.AllDamageAmplify += 0.10
	case treeStr == "normal" && tier == 1:
		mods.AttackPowerPercent += 0.15
	case treeStr == "normal" && tier == 2:
		mods.StormTriggerReduce += 20
		mods.AllDamageAmplify += 0.10
	case treeStr == "normal" && tier == 3:
		mods.AllDamageAmplify += 0.15
	case treeStr == "normal" && tier == 4:
		mods.StormExtraHits += 5
		mods.AllDamageAmplify += 0.10
	case treeStr == "armor" && tier == 0:
		mods.AllDamageAmplify += 0.10
	case treeStr == "armor" && tier == 1:
		mods.CollapseTriggerReduce += 30
		mods.AllDamageAmplify += 0.10
	case treeStr == "armor" && tier == 2:
		mods.ArmorPenExtra += 0.15
	case treeStr == "armor" && tier == 3:
		mods.CollapseVulnerability += 0.15
	case treeStr == "armor" && tier == 4:
		mods.JudgmentDayBoost += 0.10
	case treeStr == "crit" && tier == 0:
		mods.AllDamageAmplify += 0.10
	case treeStr == "crit" && tier == 1:
		mods.CritRateBonus += 0.10
	case treeStr == "crit" && tier == 2:
		mods.OmenKillThresholdRaise += 0.05
	case treeStr == "crit" && tier == 3:
		mods.OmenCritDmgExtra += 0.005
	case treeStr == "crit" && tier == 4:
		mods.DoomMultBoost += 2.0
	}
}
```

- [ ] **Step 2: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "refactor(talent): ComputeTalentModifiers 支持等级倍率累加+层满奖励更新"
```

---

### Task 6: 更新层满奖励标签文本

**Files:**
- Modify: `backend/internal/vote/talent.go:182-205` (tierCompletionBonusLabels)

- [ ] **Step 1: 替换标签文本**

```go
var tierCompletionBonusLabels = map[TalentTree]map[int]string{
	TalentTreeNormal: {
		0: "全伤害 +10%",
		1: "攻击力 +15%",
		2: "触发 -20 次 + 全伤害 +10%",
		3: "全伤害 +15%",
		4: "+5 段 + 全伤害 +10%",
	},
	TalentTreeArmor: {
		0: "全伤害 +10%",
		1: "崩塌触发 -30 + 全伤害 +10%",
		2: "护甲穿透 +15%",
		3: "崩塌易伤 +15%",
		4: "审判日削除 +10%",
	},
	TalentTreeCrit: {
		0: "全伤害 +10%",
		1: "暴击率 +10%",
		2: "斩杀血线 +5%",
		3: "每层死兆暴伤 +0.5%",
		4: "狂喜倍率 +2x",
	},
}
```

- [ ] **Step 2: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "feat(talent): 更新层满奖励标签为新数值"
```

---

### Task 7: 重构死兆收割为被动档位

**Files:**
- Modify: `backend/internal/vote/store.go:1695-1708` (crit_omen_reap 触发逻辑)
- Modify: `backend/internal/vote/store.go:1778-1780` (crit_omen_reap 消耗逻辑 — 删除)
- Modify: `backend/internal/vote/store.go:1415-1422` (applyBossPartDamage 中被动增伤)

- [ ] **Step 1: 在 applyBossPartDamage 中添加死兆收割被动判定**

在 `crit_omen_kill` 判定之后（约 line 1418 之后）添加：

```go
	// 死兆收割被动：根据死兆层数档位提供增伤（不消耗层数）
	if hasTalent(learned, "crit_omen_reap") && combatState.OmenStacks >= 30 {
		def, ok := talentDefs["crit_omen_reap"]
		if ok {
			val, _ := def.EffectValue.(map[string]any)
			thresholds, _ := val["thresholds"].([]float64)
			damageMults, _ := val["damageMult"].([]float64)
			if thresholds != nil && damageMults != nil && len(thresholds) == len(damageMults) {
				var reapMult float64 = 1.0
				for i := len(thresholds) - 1; i >= 0; i-- {
					if float64(combatState.OmenStacks) >= thresholds[i] {
						reapMult = damageMults[i]
						break
					}
				}
				if reapMult > 1.0 {
					partDamage = int64(float64(partDamage) * reapMult)
				}
			}
		}
	}
```

- [ ] **Step 2: 删除旧的消耗型收割逻辑**

在 `applyTriggeredTalentDamage` 中删除第 1695-1708 行的旧收割代码块（触发额外伤害），以及第 1778-1780 行的层数消耗代码。

- [ ] **Step 3: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add backend/internal/vote/store.go
git commit -m "refactor(talent): 死兆收割从消耗型改为被动档位增伤"
```

---

### Task 8: 重构死亡狂喜为终极技能（100层瞬间大伤害）

**Files:**
- Modify: `backend/internal/vote/store.go:1729-1737` (crit_death_ecstasy 旧逻辑)
- Modify: `backend/internal/vote/store.go:1401-1409` (DeathEcstasy 判定)
- Modify: `backend/internal/vote/store.go:1373-1383` (DeathEcstasy 部位覆写)
- Modify: `backend/internal/vote/store.go:1775-1777` (DeathEcstasy 过期清理)

- [ ] **Step 1: 重写死亡狂喜触发逻辑**

替换 `applyTriggeredTalentDamage` 中 1729-1737 行的旧代码：

```go
	if hasTalent(learned, "crit_death_ecstasy") && combatState.OmenStacks >= 100 {
		def, ok := talentDefs["crit_death_ecstasy"]
		if ok {
			val, _ := def.EffectValue.(map[string]any)
			critDmgMult := 1.0
			if m, ok := val["critDmgMult"].(float64); ok {
				critDmgMult = m
			}
			// 消耗 100 层（多余保留）
			consumed := 100
			if combatState.OmenStacks < consumed {
				consumed = combatState.OmenStacks
			}
			combatState.OmenStacks -= consumed

			// 层数系数锁死 100 上限
			effStacks := minInt(consumed, 100)
			ed := int64(float64(baseDamage) * float64(effStacks) * critDmgMult)
			if ed > part.CurrentHP { ed = part.CurrentHP }
			part.CurrentHP -= ed
			if part.CurrentHP <= 0 { part.CurrentHP = 0; part.Alive = false }
			boss.CurrentHP = sumBossPartCurrentHP(boss.Parts)
			totalExtra += ed
			events = append(events, TalentTriggerEvent{
				TalentID: "crit_death_ecstasy", Name: "死亡狂喜", EffectType: "death_ecstasy_ult",
				ExtraDamage: ed, Message: fmt.Sprintf("死亡狂喜！消耗%d层", consumed),
				PartX: part.X, PartY: part.Y,
			})
			damageTypeOverride = "doomsday"
		}
	}
```

- [ ] **Step 2: 删除旧的 DeathEcstasyEndsAt 相关逻辑**

在 `applyBossPartDamage` 中删除：
- 原 1377-1379 行（`DeathEcstasyEndsAt > now` 部位覆写为 weak）
- 原 1403-1405 行（`DeathEcstasyEndsAt > now` 暴伤 ×3）

在 `applyTriggeredTalentDamage` 末尾删除 1775-1777 行（`DeathEcstasyEndsAt` 过期清理）。

- [ ] **Step 3: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add backend/internal/vote/store.go
git commit -m "refactor(talent): 死亡狂喜改为终极技能 100层瞬间大伤害"
```

---

### Task 9: 重构末日审判为小技能（30%HP追踪标记）

**Files:**
- Modify: `backend/internal/vote/talent.go:791-810` (TalentCombatState)
- Modify: `backend/internal/vote/store.go:1497-1499` (DoomMarks 初始标记)
- Modify: `backend/internal/vote/store.go:1739-1763` (DoomMarks 触发逻辑)

- [ ] **Step 1: 更新 TalentCombatState**

```go
type TalentCombatState struct {
	OmenStacks           int              `json:"omenStacks"`
	CollapseParts        []int            `json:"collapseParts"`
	CollapseEndsAt       int64            `json:"collapseEndsAt"`
	DoomMarks            []int            `json:"doomMarks"`
	DoomMarkCumDamage    map[string]int64 `json:"doomMarkCumDamage"` // key=TalentPartKey, 累计伤害
	DoomCritBuff         bool             `json:"doomCritBuff"`
	SilverStormRemaining int              `json:"silverStormRemaining"`
	SilverStormActive    bool             `json:"silverStormActive"`
	LastAutoStrikeAt     int64            `json:"lastAutoStrikeAt"`
	LastFinalCutAt       int64            `json:"lastFinalCutAt"`
	JudgmentDayUsed      map[string]bool  `json:"judgmentDayUsed"`
	PartHeavyClickCount  map[string]int64 `json:"partHeavyClickCount"`
	PartRetainedClicks   map[string]int64 `json:"partRetainedClicks"`
	PartStormComboCount   map[string]int64 `json:"partStormComboCount"`
	CritCount            int64            `json:"critCount"`
	SkinnerParts         map[string]int64 `json:"skinnerParts"`
}
```

- [ ] **Step 2: 重写标记触发逻辑**

替换 `applyTriggeredTalentDamage` 中 1739-1763 行的旧代码：

```go
	if hasTalent(learned, "crit_doom_judgment") && !part.Alive && len(combatState.DoomMarks) > 0 {
		for _, idx := range combatState.DoomMarks {
			if idx == partIndex {
				def, ok := talentDefs["crit_doom_judgment"]
				if !ok { break }
				val, _ := def.EffectValue.(map[string]any)
				omenReward := 25.0
				if r, ok := val["omenPerMark"].(float64); ok && r > 0 { omenReward = r }
				combatState.OmenStacks += int(omenReward)
				events = append(events, TalentTriggerEvent{
					TalentID: "crit_doom_judgment", Name: "末日审判", EffectType: "doom_mark",
					Message: fmt.Sprintf("标记触发！+%d 死兆", int(omenReward)),
					PartX: part.X, PartY: part.Y,
				})
				damageTypeOverride = "doomsday"
				break
			}
		}
	}
```

- [ ] **Step 3: 更新初始标记逻辑**

替换 `applyBossPartDamage` 中 1497-1499 行：

```go
	if hasTalent(learned, "crit_doom_judgment") && len(combatState.DoomMarks) == 0 && len(boss.Parts) >= 2 {
		def, ok := talentDefs["crit_doom_judgment"]
		if ok {
			val, _ := def.EffectValue.(map[string]any)
			markCount := 2
			if mc, ok := val["markCount"].(float64); ok { markCount = int(mc) }
			combatState.DoomMarks = randomMarkIndices(len(boss.Parts), markCount, s.roll)
			if combatState.DoomMarkCumDamage == nil {
				combatState.DoomMarkCumDamage = make(map[string]int64)
			}
		}
	}
```

- [ ] **Step 4: 更新 NewTalentCombatState**

```go
func NewTalentCombatState() *TalentCombatState {
	return &TalentCombatState{
		JudgmentDayUsed:      make(map[string]bool),
		PartHeavyClickCount:  make(map[string]int64),
		PartStormComboCount:  make(map[string]int64),
		PartRetainedClicks:   make(map[string]int64),
		SkinnerParts:         make(map[string]int64),
		DoomMarkCumDamage:    make(map[string]int64),
	}
}
```

- [ ] **Step 5: 更新 GetTalentCombatState 的 nil 检查**

在 `GetTalentCombatState` 中添加：

```go
if state.DoomMarkCumDamage == nil {
	state.DoomMarkCumDamage = make(map[string]int64)
}
```

- [ ] **Step 6: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 7: Commit**

```bash
git add backend/internal/vote/talent.go backend/internal/vote/store.go
git commit -m "refactor(talent): 末日审判改为小技能 标记触发+30%HP追踪"
```

---

### Task 10: 更新死兆层数获取途径 + DoomCritBuff 清理

**Files:**
- Modify: `backend/internal/vote/store.go:1442-1444` (弱点击杀 +1 层)
- Modify: `backend/internal/vote/store.go:1406-1408` (DoomCritBuff 清理)

- [ ] **Step 1: 更新叠层逻辑**

替换原来的弱点暴击 +1 逻辑（1442-1444 行）：

```go
	// 死兆层数获取：弱点暴击 +2，普通暴击 +1，击碎部位 +5
	if critical && hasTalent(learned, "crit_core") {
		if effectivePartType == PartTypeWeak && partWasAlive {
			combatState.OmenStacks += 2
		} else {
			combatState.OmenStacks++
		}
	}
	if partJustDied && hasTalent(learned, "crit_core") {
		combatState.OmenStacks += 5
	}
```

- [ ] **Step 2: 删除旧的 DoomCritBuff 逻辑**

删除 `applyBossPartDamage` 中 1406-1408 行的 DoomCritBuff 判定的代码块（死亡狂喜已改为瞬间结算，不再需要 duration buff 叠加）。

- [ ] **Step 3: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add backend/internal/vote/store.go
git commit -m "refactor(talent): 死兆层数获取改为多途径+清理DoomCritBuff旧逻辑"
```

---

### Task 11: 更新 API 路由（talent_routes.go）

**Files:**
- Modify: `backend/internal/httpapi/talent_routes.go`

- [ ] **Step 1: 更新 learn 请求结构体和处理函数**

```go
type talentUpgradeRequest struct {
	TalentID     string `json:"talentId"`
	TargetLevel  int    `json:"targetLevel"`
}

func (h *talentAPI) upgrade(c context.Context, ctx *app.RequestContext) {
	nickname := ctx.GetString("nickname")
	var req talentUpgradeRequest
	if err := ctx.BindAndValidate(&req); err != nil {
		ctx.JSON(400, map[string]string{"error": "INVALID_REQUEST", "message": "参数错误"})
		return
	}
	if req.TargetLevel < 1 {
		req.TargetLevel = 1
	}
	if err := h.store.UpgradeTalent(c, nickname, req.TalentID, req.TargetLevel); err != nil {
		h.writeTalentError(ctx, err)
		return
	}
	resources, _ := h.store.GetResources(c, nickname)
	ctx.JSON(200, map[string]any{
		"status":       "ok",
		"talentId":     req.TalentID,
		"targetLevel":  req.TargetLevel,
		"talentPoints": resources.TalentPoints,
	})
}
```

- [ ] **Step 2: 更新路由注册**

```go
func registerTalentRoutes(router route.IRouter, options Options) {
	h := &talentAPI{store: options.ButtonStore, auth: options.PlayerAuthenticator}
	g := router.Group("/api/talents")
	g.GET("/state", h.getState)
	g.POST("/upgrade", h.upgrade)     // 改名为 upgrade
	g.POST("/reset", h.reset)
	g.GET("/defs", h.getDefs)
}
```

- [ ] **Step 3: 更新 getState 返回值**

`talentStateResponse` 中的 `talents` 字段改为 map（自动序列化为 JSON object），前端同时获取 `talentId → level` 映射：

```go
type talentStateResponse struct {
	Trees        map[string]any `json:"trees"`
	Talents      map[string]int `json:"talents"`      // 改为 map
	TalentPoints int64          `json:"talentPoints"`
}
```

- [ ] **Step 4: 更新 defsToMap 增加 MaxLevel 字段**

在 defsToMap 中添加：

```go
m["maxLevel"] = def.MaxLevel
```

- [ ] **Step 5: 更新错误映射**

添加新错误类型的映射：

```go
func talentErrorCode(err error) string {
	switch {
	case errors.Is(err, vote.ErrTalentNotFound):
		return "TALENT_NOT_FOUND"
	case errors.Is(err, vote.ErrTalentAlreadyLearned):
		return "TALENT_ALREADY_LEARNED"
	case errors.Is(err, vote.ErrTalentPrerequisite):
		return "TALENT_PREREQUISITE"
	case errors.Is(err, vote.ErrTalentPointsInsufficient):
		return "TALENT_POINTS_INSUFFICIENT"
	case errors.Is(err, vote.ErrTalentInvalidCost):
		return "TALENT_INVALID_COST"
	case errors.Is(err, vote.ErrTalentInvalidLevel):
		return "TALENT_INVALID_LEVEL"
	case errors.Is(err, vote.ErrTalentMaxLevel):
		return "TALENT_MAX_LEVEL"
	default:
		return "TALENT_ERROR"
	}
}
```

- [ ] **Step 6: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 7: Commit**

```bash
git add backend/internal/httpapi/talent_routes.go
git commit -m "refactor(talent): API 路由 learn→upgrade 支持等级制"
```

---

### Task 12: 更新后端测试

**Files:**
- Modify: `backend/internal/vote/store_test.go:151-230`
- Modify: `backend/internal/httpapi/router_test.go:378-392`

- [ ] **Step 1: 更新 store_test.go 中的天赋测试**

改写 `TestLearnTalentConsumesTalentPointsAndResetRefunds`:

```go
func TestUpgradeTalentConsumesPointsAndResetRefunds(t *testing.T) {
	_, store := newTestStore(t)
	ctx := context.Background()
	nickname := "testuser"
	key := store.resourceKey(nickname)

	// 种子天赋点
	require.NoError(t, store.client.HSet(ctx, key, "talent_points", int64(5000)).Err())

	// Lv1 学习 normal_core (base=20, Lv1 cost = round(20*1^0.85*1.8) = 36)
	err := store.UpgradeTalent(ctx, nickname, "normal_core", 1)
	require.NoError(t, err)

	// 验证天赋点消耗
	pts, _ := store.client.HGet(ctx, key, "talent_points").Int64()
	assert.True(t, pts < 5000, "应消耗了天赋点")

	// 洗点返还
	require.NoError(t, store.ResetTalents(ctx, nickname))
	ptsAfter, _ := store.client.HGet(ctx, key, "talent_points").Int64()
	assert.Equal(t, int64(5000), ptsAfter, "洗点应全量返还")

	// 验证状态为空
	state, _ := store.GetTalentState(ctx, nickname)
	assert.Equal(t, 0, len(state.Talents))
}
```

- [ ] **Step 2: 更新 insufficient 测试**

```go
func TestUpgradeTalentRejectsInsufficientPoints(t *testing.T) {
	_, store := newTestStore(t)
	ctx := context.Background()
	nickname := "testuser2"
	key := store.resourceKey(nickname)

	require.NoError(t, store.client.HSet(ctx, key, "talent_points", int64(1)).Err())

	err := store.UpgradeTalent(ctx, nickname, "normal_core", 1)
	assert.ErrorIs(t, err, vote.ErrTalentPointsInsufficient)
}
```

- [ ] **Step 3: 更新 mock store**

在 `router_test.go` 中更新 mock 方法签名：

```go
func (m *mockStore) UpgradeTalent(ctx context.Context, nickname string, talentID string, targetLevel int) error {
	return nil
}
```

- [ ] **Step 4: 运行测试**

```bash
cd backend && go test ./internal/vote/... -run "TestUpgrade|TestBossKill" -v
cd backend && go test ./internal/httpapi/... -v
```

Expected: 所有测试通过

- [ ] **Step 5: Commit**

```bash
git add backend/internal/vote/store_test.go backend/internal/httpapi/router_test.go
git commit -m "test(talent): 更新天赋测试适配等级制"
```

---

### Task 13: 更新 TalentEffectDescription 文案

**Files:**
- Modify: `backend/internal/vote/talent.go:270-341`

- [ ] **Step 1: 更新暴击系三个变更技能的文案**

替换 `crit_omen_reap`, `crit_death_ecstasy`, `crit_ultimate` 的 case 分支，添加 `crit_doom_judgment` 的 case：

```go
case "omen_reap_passive":
	thresholds := ""
	if tv, ok := value["thresholds"].([]float64); ok {
		parts := make([]string, len(tv))
		for i, t := range tv {
			parts[i] = fmt.Sprintf("%.0f层", t)
		}
		thresholds = strings.Join(parts, "/")
	}
	mults := ""
	if mv, ok := value["damageMult"].([]float64); ok {
		parts := make([]string, len(mv))
		for i, m := range mv {
			parts[i] = fmt.Sprintf("×%.1f", m)
		}
		mults = strings.Join(parts, "/")
	}
	return fmt.Sprintf("死兆达%s时，伤害自动提升至%s（不消耗层数）。被动生效。", thresholds, mults)

case "death_ecstasy_ult":
	return fmt.Sprintf("死兆达到%d层时消耗%d层，造成 baseDamage × 层数 × 暴伤倍率 的巨额伤害。超出100层层数系数锁死。", talentInt(value["omenCost"]), talentInt(value["omenCost"]))

case "doom_mark":
	return fmt.Sprintf("开局随机标记%d个部位。被标记部位累计受到%s最大血量伤害时触发+%d死兆。可升级增加标记数和层数。", talentInt(value["markCount"]), talentPercent(value["hpThreshold"]), talentInt(value["omenPerMark"]))
```

- [ ] **Step 2: 编译验证**

```bash
cd backend && go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add backend/internal/vote/talent.go
git commit -m "feat(talent): 更新暴击系三个技能的效果描述文案"
```

---

### Task 14: 前端 — TalentsPage.vue 适配等级制

**Files:**
- Modify: `frontend/src/pages/TalentsPage.vue`

- [ ] **Step 1: 更新数据结构和 API 调用**

```javascript
// 将 talentState.talents 从数组改为 map
// 旧: const learnedSet = new Set(talentState.value?.talents || [])
// 新:
const learnedMap = reactive(talentState.value?.talents || {})

// 获取节点当前等级
function nodeLevel(talentId) {
  return learnedMap[talentId] || 0
}

// API 调用从 learn 改为 upgrade
async function upgradeTalent(item, targetLevel) {
  learnLoading.value = true
  errorMsg.value = ''
  try {
    const resp = await fetch('/api/talents/upgrade', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ talentId: item.id, targetLevel }),
    })
    if (!resp.ok) {
      const data = await resp.json()
      throw new Error(data.message || '升级失败')
    }
    const data = await resp.json()
    talentPoints.value = data.talentPoints
    learnedMap[item.id] = data.targetLevel
  } catch (e) {
    errorMsg.value = e.message
  } finally {
    learnLoading.value = false
  }
}
```

- [ ] **Step 2: 更新节点状态判定逻辑**

```javascript
function nodeState(def) {
  const lv = nodeLevel(def.id)
  if (lv >= def.maxLevel) return 'maxed'              // 已满级
  if (lv > 0) return 'upgradable'                      // 已学可升级
  // ... 原有的 locked/layer-locked/insufficient/available 逻辑
}

// 升级按钮显示：
// - 点击已学节点（upgradable）→ 弹出"升级到 LvX，消耗 Y 点"
// - 点击未学节点（available）→ 直接确认 Lv1 学习
```

- [ ] **Step 3: 更新节点模板**

```html
<button
  class="talent-dot"
  :class="[
    `talent-dot--${nodeState(item)}`,
    `talent-dot--lv${nodeLevel(item.id)}`,
    { 'talent-dot--filler': isFillerNode(item.id) },
    { 'talent-dot--selected': selectedMarker?.id === item.id }
  ]"
  @click="handleNodeClick(item)"
  @mouseenter="selectNode(item)"
  @mouseleave="clearNode"
>
  <span class="talent-dot__level" v-if="nodeLevel(item.id) > 0">
    Lv{{ nodeLevel(item.id) }}
  </span>
  <!-- ... 原有图标和名称 -->
</button>
```

- [ ] **Step 4: 更新 float 提示面板**

在 `detailFloatStyle` 中显示：
- 当前等级 / 最高等级
- 升级到下一级所需天赋点
- 下一级效果预览

- [ ] **Step 5: Commit**

```bash
git add frontend/src/pages/TalentsPage.vue
git commit -m "feat(frontend): 天赋页适配等级制展示和升级交互"
```

---

### Task 15: 前端 — 节点视觉等级效果

**Files:**
- Modify: `frontend/src/pages/TalentsPage.vue` (scoped CSS)

- [ ] **Step 1: 添加等级对应的 CSS 类**

```css
/* 等级亮度递进 */
.talent-dot--lv1 { filter: brightness(1.0); }
.talent-dot--lv2 { filter: brightness(1.1); box-shadow: 0 0 8px var(--active-color); }
.talent-dot--lv3 { filter: brightness(1.2); box-shadow: 0 0 14px var(--active-color), 0 0 28px color-mix(in srgb, var(--active-color) 30%, transparent); }
.talent-dot--lv4 { filter: brightness(1.35); box-shadow: 0 0 22px var(--active-color), 0 0 44px color-mix(in srgb, var(--active-color) 40%, transparent); }
.talent-dot--lv5 { filter: brightness(1.5); box-shadow: 0 0 30px var(--active-color), 0 0 60px color-mix(in srgb, var(--active-color) 50%, transparent); animation: lv5-pulse 2s ease-in-out infinite; }

.talent-dot--maxed {
  border-color: #f0cd92 !important;
}

/* Lv5 脉冲动画 */
@keyframes lv5-pulse {
  0%, 100% { box-shadow: 0 0 28px var(--active-color), 0 0 56px color-mix(in srgb, var(--active-color) 45%, transparent); }
  50% { box-shadow: 0 0 34px var(--active-color), 0 0 68px color-mix(in srgb, var(--active-color) 60%, transparent); }
}

/* 等级角标 */
.talent-dot__level {
  position: absolute;
  top: -6px;
  right: -6px;
  font-size: 0.52rem;
  font-weight: 700;
  color: #0f1a22;
  background: var(--active-color);
  border-radius: 999px;
  padding: 0.08rem 0.24rem;
  line-height: 1;
  z-index: 2;
}
```

- [ ] **Step 2: 添加粒子 canvas**

在 `talent-plate` 容器内添加一个透明 canvas 层，用 `requestAnimationFrame` 绘制粒子。粒子只在有已学节点（Lv ≥ 2）时显示，粒子颜色取对应节点颜色。

```javascript
// 粒子系统（挂载在 onMounted）
const particleCanvas = ref(null)
function initParticles() {
  const canvas = particleCanvas.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  const particles = []

  function createParticle(nodeEl) {
    // 位置：节点中心
    // 颜色：节点 --active-color ±15% 偏移
    // 大小：2-4px
    // 速度：Lv3-4 慢速环绕，Lv5 中速
  }

  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    for (const p of particles) {
      p.x += p.vx; p.y += p.vy
      // 生命周期衰减
      ctx.fillStyle = p.color; ctx.beginPath()
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2); ctx.fill()
    }
    requestAnimationFrame(animate)
  }
  animate()
}
```

- [ ] **Step 3: Commit**

```bash
git add frontend/src/pages/TalentsPage.vue
git commit -m "feat(frontend): 天赋节点等级视觉效果 亮度辉光+粒子系统"
```

---

### Task 16: 全量编译 + 测试验证

- [ ] **Step 1: 后端全量测试**

```bash
cd backend && go test ./... -count=1 2>&1
```

Expected: 所有测试通过，无编译警告

- [ ] **Step 2: 前端测试**

```bash
npm --prefix frontend run test 2>&1
```

Expected: 通过或仅有与天赋无关的失败

- [ ] **Step 3: 修复所有编译/测试错误**

逐一修复，每次修复后重新运行测试。

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: 全量编译和测试验证通过"
```

---

### Task 17: ButtonStore 接口更新

**Files:**
- Modify: `backend/internal/httpapi/router.go` 中的 `ButtonStore` 接口

需要将 `LearnTalent` 改为 `UpgradeTalent`，签名变化：增加 `targetLevel int` 参数。

- [ ] **Step 1: 更新接口定义**

在 `router.go` 的 `ButtonStore` interface 中：

```go
UpgradeTalent(ctx context.Context, nickname string, talentID string, targetLevel int) error
```

- [ ] **Step 2: 编译验证，修复所有实现和 mock**

```bash
cd backend && go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add backend/internal/httpapi/
git commit -m "refactor(api): ButtonStore.LearnTalent→UpgradeTalent 接口更新"
```

---

### Task 18: 前端 shared state 更新

**Files:**
- Modify: `frontend/src/pages/publicPageState.js`

更新 `talentCombatState` 处理中引用了旧 `DoomDestroyed`/`DeathEcstasyEndsAt` 的地方，改为适配新的 `DoomMarks`/`OmenStacks` 逻辑。

- [ ] **Step 1: 适配 applyClickResult 中的战斗状态更新**

将 `talentCombatState.value.DoomDestroyed` 和 `talentCombatState.value.DeathEcstasyEndsAt` 的引用移除或替换为新的字段。

- [ ] **Step 2: Commit**

```bash
git add frontend/src/pages/publicPageState.js
git commit -m "fix(frontend): 战斗状态适配新版天赋CombatState字段"
```

---

## 验证清单

- [ ] `cd backend && go build ./...` 编译零错误
- [ ] `cd backend && go test ./... -count=1` 所有测试通过
- [ ] `npm --prefix frontend run build` 前端构建成功
- [ ] 手动验证：新账号打开天赋页，能看到 3 系 Lv1 成本、升级交互、视觉等级效果
- [ ] 手动验证：战斗中暴击叠层 → 死兆收割被动生效 → 死亡狂喜 100 层触发 → 末日审判标记触发
