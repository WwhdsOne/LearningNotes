# 1. 安装

> brew install claude

# 2. Skills 安装记录

本文档记录了当前环境中所有已安装的 Skills 及其安装流程。

---

## 目录

- [插件市场（Marketplace）安装的 Skills](#插件市场marketplace安装的-skills)
  - [1. Superpowers 插件](#1-superpowers-插件)
  - [2. Document Skills 插件（Anthropic 官方技能包）](#2-document-skills-插件anthropic-官方技能包)
  - [3. Frontend Design 插件](#3-frontend-design-插件)
  - [4. Skill Creator 插件](#4-skill-creator-插件)
  - [5. Code Review 插件](#5-code-review-插件)
  - [6. Code Simplifier 插件](#6-code-simplifier-插件)
  - [7. Ralph Loop 插件](#7-ralph-loop-插件)
  - [8. GitHub 插件](#8-github-插件)
  - [9. UI/UX Pro Max 插件](#9-uiux-pro-max-插件)
  - [10. Claude HUD 插件](#10-claude-hud-插件)
- [独立安装的第三方 Skills](#独立安装的第三方-skills)
  - [11. Golang Pro](#11-golang-pro)
  - [12. Academic Writing Workflow (中文)](#12-academic-writing-workflow-中文)
  - [13. Skill Vetter](#13-skill-vetter)
- [Claude Code 扩展工具](#claude-code-扩展工具)
  - [14. ccstatusline](#14-ccstatusline)
- [项目级别 Skills](#项目级别-skills)
- [内置 Skills](#内置-skills)
- [已注册的插件市场](#已注册的插件市场)

---

## 插件市场（Marketplace）安装的 Skills

插件市场是安装 Skills 的主要方式，通过 `claude plugins add` 命令从 GitHub 仓库安装。

### 1. Superpowers 插件

- **来源仓库：** `obra/superpowers`（通过 `anthropics/claude-plugins-official` 市场）
- **版本：** 5.0.7
- **许可证：** MIT
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official superpowers
  ```
- **包含的 Skills（14 个）：**

  | Skill | 说明 |
  |-------|------|
  | `brainstorming` | 在创意工作前探索用户意图、需求和设计 |
  | `dispatching-parallel-agents` | 并行运行多个独立任务 |
  | `executing-plans` | 执行实现计划并设置审查检查点 |
  | `finishing-a-development-branch` | 开发完成后指导合并、PR 或清理 |
  | `receiving-code-review` | 以技术严谨性处理代码审查反馈 |
  | `requesting-code-review` | 合并前验证工作是否符合要求 |
  | `subagent-driven-development` | 通过子代理执行独立任务的计划 |
  | `systematic-debugging` | 在提出修复前进行结构化调试 |
  | `test-driven-development` | TDD 工作流：先写测试再实现 |
  | `using-git-worktrees` | 创建隔离的 git worktree 进行功能开发 |
  | `using-superpowers` | 在会话开始时建立如何查找和使用技能 |
  | `verification-before-completion` | 在声称工作完成前运行验证 |
  | `writing-plans` | 根据规范/需求编写实现计划 |
  | `writing-skills` | 创建和验证技能后再部署 |

---

### 2. Document Skills 插件（Anthropic 官方技能包）

- **来源仓库：** `anthropics/skills`（通过 `anthropic-agent-skills` 市场）
- **版本/提交：** `887114fd09f8`
- **安装命令：**
  ```bash
  # 首先注册 Anthropic 官方技能市场（如果尚未注册）
  claude marketplace add anthropic-agent-skills https://github.com/anthropics/skills
  # 然后安装 document-skills 插件
  claude plugins add --marketplace anthropic-agent-skills document-skills
  ```
- **包含的 Skills（18 个）：**

  | Skill | 说明 |
  |-------|------|
  | `algorithmic-art` | 使用 p5.js 创建生成式艺术 |
  | `brand-guidelines` | 应用 Anthropic 官方品牌颜色和排版 |
  | `canvas-design` | 使用设计理念创建 PNG/PDF 视觉艺术 |
  | `claude-api` | 使用 Claude API / Anthropic SDK / Agent SDK 构建应用 |
  | `doc-coauthoring` | 结构化的文档协作工作流 |
  | `docx` | 创建、读取、编辑 Word .docx 文件 |
  | `frontend-design` | 生产级前端界面设计 |
  | `internal-comms` | 撰写内部沟通文档（状态报告、新闻通讯等） |
  | `mcp-builder` | 创建 MCP 服务器以集成外部服务 |
  | `pdf` | PDF 操作：提取文本、合并、拆分、表单、OCR、加密 |
  | `pptx` | 创建、编辑、分析 PowerPoint 演示文稿 |
  | `skill-creator` | 创建、修改、改进技能并运行评估 |
  | `slack-gif-creator` | 创建适用于 Slack 的动画 GIF |
  | `theme-factory` | 将专业主题（10 种预设）应用于工件 |
  | `web-artifacts-builder` | 构建多组件 HTML 工件（React、Tailwind、shadcn/ui） |
  | `webapp-testing` | 使用 Playwright 测试本地 Web 应用 |
  | `xlsx` | 创建、读取、编辑电子表格 |
  | `template-skill` | 创建新技能的空白模板 |

---

### 3. Frontend Design 插件

- **来源市场：** `claude-plugins-official`（`anthropics/claude-plugins-official`）
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official frontend-design
  ```
- **包含的 Skill：** `frontend-design` — 高设计质量的生产级前端界面

---

### 4. Skill Creator 插件

- **来源市场：** `claude-plugins-official`
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official skill-creator
  ```
- **包含的 Skill：** `skill-creator` — 创建、修改、改进技能并运行评估和基准测试

---

### 5. Code Review 插件

- **来源市场：** `claude-plugins-official`
- **作者：** Anthropic
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official code-review
  ```
- **说明：** 使用多代理置信度评分的自动化代码审查

---

### 6. Code Simplifier 插件

- **来源市场：** `claude-plugins-official`
- **版本：** 1.0.0
- **作者：** Anthropic
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official code-simplifier
  ```
- **包含的 Skill：** `simplify` — 简化代码以提高清晰度、一致性和可维护性

---

### 7. Ralph Loop 插件

- **来源市场：** `claude-plugins-official`
- **版本：** 1.0.0
- **作者：** Anthropic
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official ralph-loop
  ```
- **说明：** 持续自引用 AI 循环，用于迭代开发

---

### 8. GitHub 插件

- **来源市场：** `claude-plugins-official`
- **作者：** GitHub
- **安装命令：**
  ```bash
  claude plugins add --marketplace claude-plugins-official github
  ```
- **说明：** 提供 GitHub MCP 服务器集成

---

### 9. UI/UX Pro Max 插件

- **来源仓库：** `nextlevelbuilder/ui-ux-pro-max-skill`
- **版本：** 2.5.0
- **许可证：** MIT
- **安装命令：**
  ```bash
  # 首先注册市场
  claude marketplace add ui-ux-pro-max-skill https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
  # 安装插件
  claude plugins add --marketplace ui-ux-pro-max-skill ui-ux-pro-max
  ```
- **包含的 Skills（7 个）：**

  | Skill | 说明 |
  |-------|------|
  | `ui-ux-pro-max` | 主技能：50+ 风格、161 调色板、57 字体配对，覆盖 10 种技术栈 |
  | `ckm:design` | 综合设计：品牌标识、Logo、CIP、幻灯片、横幅、图标 |
  | `ckm:brand` | 品牌声音、视觉标识、信息框架 |
  | `ckm:slides` | 使用 Chart.js 的 HTML 演示文稿 |
  | `ckm:banner-design` | 社交/广告/网页/印刷的横幅设计 |
  | `ckm:design-system` | Token 架构和组件规范 |
  | `ckm:ui-styling` | shadcn/ui 组件 + Tailwind CSS 样式 |

---

### 10. Claude HUD 插件

- **来源仓库：** `jarrodwatts/claude-hud`
- **版本：** 0.0.11
- **许可证：** MIT
- **作者：** Jarrod Watts
- **安装命令：**
  ```bash
  # 首先注册市场
  claude marketplace add claude-hud https://github.com/jarrodwatts/claude-hud
  # 安装插件
  claude plugins add --marketplace claude-hud claude-hud
  ```
- **说明：** Claude Code 实时状态栏 HUD（上下文健康、工具活动、代理跟踪、待办进度）
- **可用命令：** `setup`、`configure`

---

## 独立安装的第三方 Skills

这些 Skill 安装在 `~/.claude/skills/` 目录中，不通过插件市场管理。

### 11. Golang Pro

- **作者：** `github.com/Jeffallan`
- **版本：** 1.1.0
- **许可证：** MIT
- **安装方式：** 手动安装到 `~/.claude/skills/golang-pro/`
- **说明：** 并发 Go 模式（goroutine、channel）、微服务（gRPC、REST）、性能优化（pprof）、泛型、接口、错误处理

### 12. Academic Writing Workflow (中文)

- **安装方式：** 手动安装到 `~/.claude/skills/academic-writing-workflow-zh/`
- **说明：** 面向 AI/CS 论文写作全流程的中文主导技能，包括学术翻译（中英互译）、润色、去 AI 味、实验结果分析、图表标题生成、审稿视角检查、会议投稿准备

### 13. Skill Vetter

- **来源：** OpenClaw / ClawHub
- **安装方式：** 手动安装到 `~/.claude/skills/skill-vetter/`
- **说明：** 在安装来自 ClawHub、GitHub 或其他来源的技能前进行安全审查

---

## Claude Code 扩展工具

### 14. ccstatusline

- **来源仓库：** [sirmalloc/ccstatusline](https://github.com/sirmalloc/ccstatusline)
- **npm 包：** `ccstatusline`
- **版本：** 2.2.x
- **作者：** Matthew Breedlove (@sirmalloc)
- **许可证：** MIT
- **说明：** 高度可定制的 Claude Code CLI 状态栏格式化工具，支持 Powerline 风格、主题、30+ 可配置小组件（模型信息、Git 分支、Token 用量、会话费用、上下文使用率等）
- **安装命令：**
  ```bash
  # 方式一：使用 npx（无需全局安装）
  npx -y ccstatusline@latest

  # 方式二：使用 bunx（更快）
  bunx -y ccstatusline@latest
  ```
- **配置步骤：**
  1. 运行上述命令启动交互式 TUI 配置界面
  2. 在 TUI 中添加/排序/自定义小组件和颜色
  3. 在 TUI 中选择「Install to Claude Code settings」将配置写入 `~/.claude/settings.json`
  4. 重启 Claude Code 即可看到状态栏
- **写入的 Claude Code 配置格式：**
  ```json
  {
    "statusLine": {
      "type": "command",
      "command": "npx -y ccstatusline@latest",
      "padding": 0
    }
  }
  ```
- **配置文件位置：**
  - ccstatusline 设置：`~/.config/ccstatusline/settings.json`
  - Claude Code 设置：`~/.claude/settings.json`
  - 块计时器缓存：`~/.cache/ccstatusline/block-cache-*.json`
- **主要功能：**

  | 功能 | 说明 |
  |------|------|
  | 30+ 小组件 | Model、Git Branch、Token 用量、会话费用、上下文使用率、Block Timer 等 |
  | Powerline 支持 | 箭头分隔符、自定义字体、多种预设主题 |
  | 交互式 TUI | React/Ink 构建的终端配置界面，实时预览 |
  | 多行状态栏 | 支持配置多条独立的状态栏 |
  | 自定义命令 | 支持执行 Shell 命令并动态显示输出 |
  | 跨平台 | macOS、Linux、Windows 均支持 |

- **Widget 编辑器快捷键：**

  | 按键 | 功能 |
  |------|------|
  | `a` | 添加小组件 |
  | `i` | 插入小组件 |
  | `d` | 删除选中小组件 |
  | `Enter` | 进入/退出移动模式 |
  | `r` | 切换原始值模式（隐藏标签） |
  | `m` | 循环合并模式 |
  | `p` | 编辑全局内边距 |
  | `s` | 编辑全局分隔符 |

---

## 项目级别 Skills

这些 Skills 存在于特定项目仓库中，仅在对应项目目录下生效。

| Skill | 路径 | 说明 |
|-------|------|------|
| `go-revive-setup` | `/Users/wwhds/Go/revive/go-revive-setup-skill/SKILL.md` | Go 项目 revive linter 自动配置 |
| `browser-use` | `/Users/wwhds/graduation_project/browser-use/skills/browser-use/SKILL.md` | 通过 CLI 自动化浏览器交互 |
| `cloud` | `/Users/wwhds/graduation_project/browser-use/skills/cloud/SKILL.md` | Browser Use Cloud REST API/SDK 参考 |
| `open-source` | `/Users/wwhds/graduation_project/browser-use/skills/open-source/SKILL.md` | browser-use Python 库参考文档 |
| `remote-browser` | `/Users/wwhds/graduation_project/browser-use/skills/remote-browser/SKILL.md` | 沙盒代理的浏览器自动化 |

---

## 内置 Skills

以下 Skills 内置于 Claude Code 运行时，无需安装：

| Skill | 说明 |
|-------|------|
| `update-config` | 配置 settings.json（hooks、权限、环境变量） |
| `simplify` | 审查已更改的代码以检查复用性、质量和效率 |
| `loop` | 按固定间隔重复运行提示或命令 |

---

## 已注册的插件市场

| 市场名称 | GitHub 仓库 | 说明 |
|----------|------------|------|
| `claude-plugins-official` | `anthropics/claude-plugins-official` | Anthropic 官方插件市场 |
| `anthropic-agent-skills` | `anthropics/skills` | Anthropic 官方 Agent Skills |
| `ui-ux-pro-max-skill` | `nextlevelbuilder/ui-ux-pro-max-skill` | UI/UX Pro Max 技能 |
| `claude-hud` | `jarrodwatts/claude-hud` | Claude HUD 状态栏 |

---

## 快速参考：通用安装命令

```bash
# 查看已安装的插件
claude plugins list

# 查看已注册的市场
claude marketplace list

# 注册新的插件市场
claude marketplace add <name> <github-repo-url>

# 从市场安装插件
claude plugins add --marketplace <marketplace-name> <plugin-name>

# 查看可用技能
claude skills list
```
