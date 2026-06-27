# 论文阅读总结工作流方案（修订版）

> 将每一次论文阅读转化为结构化的笔记资产，存入 `LearningNotes/paper/`。

---

## 一、流程概要

```
你发链接/PDF
    ↓
我读取全文（web_extract / 终端工具）
    ↓
理解 & 提炼核心内容
    ↓
生成结构化 MD 总结 + 辅助 SVG/HTML 图解
    ↓
打 Obsidian 标签（按内容自动生成，可复用旧标签也可新建）
    ↓
推送至 GitHub（你在本地 git pull）
```

## 二、输入方式

你提供以下任意一种：

| 输入形式 | 示例 |
|---------|------|
| ArXiv 链接 | `https://arxiv.org/abs/xxxx.xxxxx` |
| PDF 链接 | `https://arxiv.org/pdf/xxxx.xxxxx.pdf` |
| DOI | `10.xxxx/xxxxx` |
| PDF 文件 | 上传给我 |
| 论文标题 + 作者 | 我搜到原文 |

## 三、输出结构

```
paper/
├── images/                    # 所有 SVG/HTML 图平铺存放
│   ├── 2025-diffusion-scene-gen-pipeline.svg
│   └── 2025-diffusion-scene-gen-comparison.svg
├── 2025-diffusion-scene-gen.md
└── 2024-neural-field-composition.md
```

- 每篇论文**一个 `.md` 文件**，平铺在 `paper/` 下
- 图片统一放入 `paper/images/`，文件名以论文短标题为前缀
- MD 中用相对路径引用图片：`![pipeline](images/2025-diffusion-scene-gen-pipeline.svg)`

## 四、MD 总结模板

每篇论文生成一个独立 .md 文件，命名规则：`<年份>-<简短英文标题>.md`

```markdown
---
tags: [paper, scene-generation, diffusion-models, 2025]
date: 2025-06-17
source: https://arxiv.org/abs/xxxx.xxxxx
---

# 论文标题

> 一句话概括——这篇论文做了什么。

## 动机

1-3 点说清楚为什么要做这件事，现有方法有什么痛点。

## 方法

- **整体思路**：一两句话说清核心思想
- **关键组件**：
  - 模块 A：做什么，为什么这样设计
  - 模块 B：做什么，为什么这样设计
  - 模块 C：做什么，为什么这样设计
- **训练/推理**：数据集、loss、推理方式等关键设置
- **关键公式**：
  $$ \mathcal{L} = \mathbb{E}_{x,t,\epsilon}[\|\epsilon - \epsilon_\theta(x_t, t)\|^2] $$
  说明这个公式是干嘛的、为什么用这个设计。
  （核心公式写 1-3 个，不含所有推导）

## 关键 Insight

这篇论文最有价值的发现或设计——可以是反直觉的、简洁优雅的、或者启发性的。

## 图表辅助

> 如果方法有清晰的流程/架构，我会生成 SVG 嵌入此处。

![pipeline](images/2025-diffusion-scene-gen-pipeline.svg)

## 值得注意的细节

实验设置、消融发现、Limitation、或者你觉得有意思的小点。

## 评价

- **推荐程度**：⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐⭐
- **一句话**：我的主观判断
- **可引用**：值得摘录的关键句或结论
```

## 五、标签规则

- **固定标签**：`paper` 必含
- **方向标签**：按论文内容自动生成，优先复用已有总结中出现过的标签；如果现有标签都不匹配，创建合理的新标签
- **年份标签**：自动标注
- 每篇 **3-6 个标签**，不多不少

## 六、图解辅助

- 仅对**有清晰架构/流程**的论文生成 SVG
- 风格：手绘风线条，灰/蓝/橙色系
- 存放路径：`paper/images/<文件名前缀>-pipeline.svg`
- 对纯数学/理论推导不强行作图

## 七、数学公式

- 核心公式用 `$$ ... $$` LaTeX 块写在 Typora 可见格式
- 每个公式后附**一两句话说明**：这个公式在干什么、关键符号含义
- 不含完整推导链，只保留对理解方法必要的公式

## 八、推送

```bash
cd /root/LearningNotes
git add paper/
git commit -m "paper: 论文短标题"
git push
```

你本地 `git pull` 同步。

## 九、边界情况

- **超长 PDF（>2M 字符）**：先读摘要+引言给初步判断，你说"继续"再深入
- **读完后想讨论**：我基于已写总结和你聊，不需额外操作
