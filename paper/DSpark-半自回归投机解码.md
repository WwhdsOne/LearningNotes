---
title: "DSpark: Confidence-Scheduled Speculative Decoding with Semi-Autoregressive Generation"
authors:
  - 北京大学 (Peking University)
  - DeepSeek-AI
year: 2026
tags: [dspark, speculative-decoding, deepseek, v4, llm-inference, 2026, semi-autoregressive]
source: "https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf"
code: "https://github.com/deepseek-ai/DeepSpec"
model: "https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-DSpark"
---

# DSpark: Confidence-Scheduled Speculative Decoding with Semi-Autoregressive Generation

## 论文基本信息

| 项目 | 内容 |
|------|------|
| **标题** | DSpark: Confidence-Scheduled Speculative Decoding with Semi-Autoregressive Generation |
| **作者** | Xin Cheng, Xingkai Yu, Chenze Shao, Jiashi Li, Yunfan Xiong 等 (Peking University & DeepSeek-AI) |
| **发表年份** | 2026 年 6 月 |
| **来源** | 伴随 DeepSeek-V4 技术报告发布的技术论文 |
| **论文链接** | [DSpark_paper.pdf](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) |
| **代码仓库** | [github.com/deepseek-ai/DeepSpec](https://github.com/deepseek-ai/DeepSpec) (MIT License) |
| **模型权重** | [HuggingFace: deepseek-ai/DeepSeek-V4-Pro-DSpark](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-DSpark) |

## 架构图

<img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA5MDAgNjAwIiBmb250LWZhbWlseT0iJ1NlZ29lIFVJJywgQXJpYWwsIHNhbnMtc2VyaWYiPgogIDxkZWZzPgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJiZ0dyYWQiIHgxPSIwIiB5MT0iMCIgeDI9IjAiIHkyPSIxIj4KICAgICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2Y4ZjlmZiIvPgogICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNlZWYwZmYiLz4KICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgICA8bGluZWFyR3JhZGllbnQgaWQ9ImJsdWVHcmFkIiB4MT0iMCIgeTE9IjAiIHgyPSIxIiB5Mj0iMSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiM0QjZFRjciLz4KICAgICAgPHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSIjM0E1NkQ0Ii8+CiAgICA8L2xpbmVhckdyYWRpZW50PgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJwdXJwbGVHcmFkIiB4MT0iMCIgeTE9IjAiIHgyPSIxIiB5Mj0iMSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiM3QzNBRUQiLz4KICAgICAgPHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSIjNkQyOEQ5Ii8+CiAgICA8L2xpbmVhckdyYWRpZW50PgogICAgPGxpbmVhckdyYWRpZW50IGlkPSJ0ZWFsR3JhZCIgeDE9IjAiIHkxPSIwIiB4Mj0iMSIgeTI9IjEiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjMEVBNUU5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzAyODRDNyIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JlZW5HcmFkIiB4MT0iMCIgeTE9IjAiIHgyPSIxIiB5Mj0iMSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiMxMEI5ODEiLz4KICAgICAgPHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSIjMDU5NjY5Ii8+CiAgICA8L2xpbmVhckdyYWRpZW50PgogICAgPGZpbHRlciBpZD0ic2hhZG93IiB4PSItNSUiIHk9Ii01JSIgd2lkdGg9IjExNSUiIGhlaWdodD0iMTE1JSI+CiAgICAgIDxmZURyb3BTaGFkb3cgZHg9IjAiIGR5PSIyIiBzdGREZXZpYXRpb249IjMiIGZsb29kLWNvbG9yPSIjMDAwMDAwMTgiLz4KICAgIDwvZmlsdGVyPgogICAgPGZpbHRlciBpZD0ic2hhZG93TGlnaHQiIHg9Ii01JSIgeT0iLSUiIHdpZHRoPSIxMTUlIiBoZWlnaHQ9IjExNSUiPgogICAgICA8ZmVEcm9wU2hhZG93IGR4PSIwIiBkeT0iMSIgc3RkRGV2aWF0aW9uPSIyIiBmbG9vZC1jb2xvcj0iIzAwMDAwMDEwIi8+CiAgICA8L2ZpbHRlcj4KICAgIDxtYXJrZXIgaWQ9ImFycm93Qmx1ZSIgdmlld0JveD0iMCAwIDEwIDEwIiByZWZYPSI5IiByZWZZPSI1IiBtYXJrZXJXaWR0aD0iOCIgbWFya2VySGVpZ2h0PSI4IiBvcmllbnQ9ImF1dG8iPgogICAgICA8cGF0aCBkPSJNIDAgMCBMIDEwIDUgTCAwIDEwIHoiIGZpbGw9IiM0QjZFRjciLz4KICAgIDwvbWFya2VyPgogICAgPG1hcmtlciBpZD0iYXJyb3dQdXJwbGUiIHZpZXdCb3g9IjAgMCAxMCAxMCIgcmVmWD0iOSIgcmVmWT0iNSIgbWFya2VyV2lkdGg9IjgiIG1hcmtlckhlaWdodD0iOCIgb3JpZW50PSJhdXRvIj4KICAgICAgPHBhdGggZD0iTSAwIDAgTCAxMCA1IEwgMCAxMCB6IiBmaWxsPSIjN0MzQUVEIi8+CiAgICA8L21hcmtlcj4KICAgIDxtYXJrZXIgaWQ9ImFycm93VGVhbCIgdmlld0JveD0iMCAwIDEwIDEwIiByZWZYPSI5IiByZWZZPSI1IiBtYXJrZXJXaWR0aD0iOCIgbWFya2VySGVpZ2h0PSI4IiBvcmllbnQ9ImF1dG8iPgogICAgICA8cGF0aCBkPSJNIDAgMCBMIDEwIDUgTCAwIDEwIHoiIGZpbGw9IiMwRUE1RTkiLz4KICAgIDwvbWFya2VyPgogICAgPG1hcmtlciBpZD0iYXJyb3dHcmVlbiIgdmlld0JveD0iMCAwIDEwIDEwIiByZWZYPSI5IiByZWZZPSI1IiBtYXJrZXJXaWR0aD0iOCIgbWFya2VySGVpZ2h0PSI4IiBvcmllbnQ9ImF1dG8iPgogICAgICA8cGF0aCBkPSJNIDAgMCBMIDEwIDUgTCAwIDEwIHoiIGZpbGw9IiMxMEI5ODEiLz4KICAgIDwvbWFya2VyPgogIDwvZGVmcz4KICA8cmVjdCB3aWR0aD0iOTAwIiBoZWlnaHQ9IjYwMCIgZmlsbD0idXJsKCNiZ0dyYWQpIiByeD0iMTIiLz4KICA8dGV4dCB4PSI0NTAiIHk9IjM2IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXNpemU9IjIwIiBmb250LXdlaWdodD0iYm9sZCIgZmlsbD0iIzFFMjkzQiI+RFNwYXJrIEFyY2hpdGVjdHVyZSDigJQgU2VtaS1BdXRvcmVncmVzc2l2ZSBTcGVjdWxhdGl2ZSBEZWNvZGluZzwvdGV4dD4KPC9zdmc+" alt="DSpark Architecture Diagram" style="width:100%;max-width:900px;"/>

---

## 1. 核心问题

投机解码（Speculative Decoding）是加速 LLM 推理的关键技术，其核心思想是用一个轻量级的 draft 模型快速生成候选 token 序列，再由目标 LLM 在单个前向传播中并行验证。DSpark 要解决的是现有方法在**三个层面**上的瓶颈：

### 1.1 并行 Draft 模型的后缀接受率衰减（Generation Quality）

并行 draft 模型（如 DFlash、PARD）在单次前向传播中同时生成多个候选 token，draft 延迟与 block size 无关——这是它们相比自回归 draft 模型（如 Eagle3）的核心优势。然而，**并行 draft 位置之间相互独立**，无法建模 block 内部 token 之间的依赖关系。

当存在多个合理的延续路径时（例如 "of course" 和 "no problem"），并行模型可能生成跨模态冲突的组合（如 "of problem" 或 "no course"），因为每个位置对所有可能的前驱进行了边缘化，而不是基于实际采样的前驱进行条件化。这种**接受率衰减**（acceptance decay）在序列的靠后位置尤其严重，浪费了 draft 和验证两端的计算资源。

### 1.2 无差别全量验证导致的系统瓶颈（System Efficiency）

即使生成了足够长的 draft block，不加区分地对所有 draft token 进行验证也会严重损害系统吞吐——特别是在**高并发服务场景**下。验证的代价取决于系统负载：
- **轻负载**：验证额外 token 的 penalties 几乎为零
- **高负载**：验证一个高拒绝风险的 token 占用了批处理容量，本可以服务于其他活跃请求

数据层面的领域差异进一步加剧了这一问题：结构化任务（如代码生成）的接受率天然较高，而开放式对话的接受率较低。固定的验证长度无法适应这种动态变化。

### 1.3 已有方案的系统级局限性

在 DSpark 之前，DeepSeek-V4 生产中部署的是 MTP-1（单 token 预测），因为静态的多 token draft 模型（如 MTP-3/5）在高并发下会因过多的验证开销而**严格降低**总体吞吐。AI 社区对投机解码的生产价值也曾长期存疑——直到 DSpark 用实际生产数据证明了其有效性。

---

## 2. 方法概述

DSpark 是一个将**高通量并行生成**与**自适应负载感知验证**相结合的投机解码框架。其核心创新通过两个互补的机制实现：

### 2.1 半自回归生成架构（Semi-Autoregressive Generation）

DSpark 将 draft 生成拆分为两个阶段：
1. **并行阶段**：计算密集的并行骨干网络（基于 DFlash）在单次前向传播中生成 base logits 和隐藏状态
2. **串行阶段**：轻量级的串行 head 注入局部转移信息，在 block 内部建模 token 依赖关系

这种设计保留了并行模型的 drafting 速度，同时显著缓解了后缀衰减。

### 2.2 置信度调度验证（Confidence-Scheduled Verification）

通过两个组件实现：
1. **置信度头（Confidence Head）**：为每个 draft token 估计其在目标验证中的存活概率
2. **硬件感知前缀调度器（Hardware-Aware Prefix Scheduler）**：根据实时引擎吞吐量曲线，动态自定义每个请求的最优验证长度

---

## 3. 算法细节

### 3.1 Block-Wise Speculative Decoding

DSpark 采用标准的 block-wise 投机解码循环：

1. **目标模型执行一步** → 生成 anchor token D（基于前缀 ABC）
2. **Draft 阶段**：DSpark 使用 anchor 作为输入，生成 draft tokens E、F、G、H 及其置信度分数
3. **调度阶段**：硬件感知前缀调度器评估置信度分数，保留高置信前缀 EFG，丢弃低置信度 token H
4. **验证阶段**：目标模型并行验证调度后的前缀，接受 E、F，拒绝 G 并生成修正 token G\*

这一流程保持了对目标模型输出分布的**精确重建**（lossless）。

### 3.2 半自回归 Draft 生成（Semi-Autoregressive Drafting）

**并行骨干网络（Parallel Backbone）**：
- 基于 DFlash，运行单次前向传播，产生隐藏状态 h₁…hᵧ 和 base logits U₁…Uᵧ
- 锚点本身作为第一个预测位置，因此 γ 个输入 token（锚点 + γ−1 个 mask）产生 γ 个 draft logits
- 骨干网络深度可达 5 层 MoE 层（draft latency O(1)，与 block size 无关）

**串行 Markov Head**：
- 为每个 draft 位置 k 添加一个前缀依赖的转移偏置 B_k(x₀, x_{<k}, x_k)
- 通过自回归分解定义因果 block 分布：

  P(X | x₀) = ∏_{k=1}^γ p_k(x_k | x₀, x_{<k})

  其中 p_k(v | x₀, x_{<k}) = exp(U_k(v) + B_k(x₀, x_{<k}, v)) / Σ_u exp(U_k(u) + B_k(x₀, x_{<k}, u))

- **Markov Head（默认）**：简化为 1 阶转移 B(x_{k-1}, x_k)，采用低秩分解 B = W₁W₂（r=256），存储和计算成本极低
- **RNN Head（可选）**：维护循环状态 s_k 来累积 block 内的完整前缀历史，性能提升有限但复杂度更高

### 3.3 置信度调度验证（Confidence-Scheduled Verification）

**置信度头（Confidence Head）**：
- 为每个 draft 位置 k 输出标量估计 c_k ∈ (0, 1)
- c_k 建模的是条件概率：给定 block 中所有前面 token 通过验证的情况下位置 k 的 draft token 存活概率
- 架构：轻量级线性投影 + sigmoid
- 监督信号：基于 draft 分布 pᵈ_k 和目标分布 pᵗ_k 之间的总变差距离（Total Variation Distance）计算的理论接受率
- **后处理校准**：使用 Sequential Temperature Scaling（STS）校准累积接受概率，将 ECE 从 ~5-8% 降低到 ~1%

**硬件感知前缀调度器（Hardware-Aware Prefix Scheduler）**：
- 将验证长度选择问题建模为**全局吞吐量最大化问题**
- 基于预配置的 SPS(B) 曲线（Profiled Steps Per Second，即引擎吞吐量曲线）
- 通过贪心方式在候选 token 的累计存活概率上逐步添加，找到最优的验证 batch size
- **异步适配生产环境**：使用两步之前的置信度预测来决定动态截断长度，与 ZOS（Zero-Overhead Scheduling）和 CUDA graph replay 兼容，完全隐藏调度延迟

### 3.4 训练目标

训练目标由三项损失组成（目标模型冻结，只更新 draft 模型）：

- **交叉熵损失** ℒ_ce：训练 drafter 预测正确的 next token
- **分布匹配损失** ℒ_tv：最小化 draft 分布与目标分布之间的 TV 距离（直接提升接受率）
- **置信度损失** ℒ_conf：使用二值交叉熵训练置信度头（预测软接受标签 c\*_k）

所有损失使用位置权重 w_k = exp(-(k-1)/γ) 来强调较早的 block 位置。

默认权重：α_ce = 0.1, α_tv = 0.9, α_conf = 1.0。

---

## 4. 关键数据

### 4.1 Offline Benchmark 结果

**测试配置**：目标模型包括 Qwen3-{4B, 8B, 14B} 和 Gemma4-12B，draft 模型对比 Eagle3（自回归）和 DFlash（并行），training data 为 Open-PerfectBlend（130万样本，覆盖 math/code/chat）。

**主表——平均接受长度 τ（每轮）**：

| Target | Drafter | Math | Code | Chat |
|--------|---------|------|------|------|
| **Qwen3-4B** | Eagle3 | 4.56 | 3.87 | 2.40 |
| | DFlash | 4.80 | 4.44 | 2.95 |
| | **DSpark** | **5.57** | **5.12** | **3.49** |
| **Qwen3-8B** | Eagle3 | 4.66 | 4.15 | 2.58 |
| | DFlash | 4.77 | 4.46 | 2.97 |
| | **DSpark** | **5.65** | **5.28** | **3.50** |
| **Qwen3-14B** | Eagle3 | 4.52 | 3.99 | 2.52 |
| | DFlash | 4.74 | 4.45 | 2.92 |
| | **DSpark** | **5.63** | **5.24** | **3.47** |
| **Gemma4-12B** | Eagle3 | 5.39 | 4.42 | 2.99 |
| | DFlash | 4.90 | 4.35 | 2.80 |
| | **DSpark** | **5.65** | **5.09** | **3.25** |

**宏观平均提升**（Qwen3 系列）：

| 对比 | 提升范围 |
|------|---------|
| DSpark vs Eagle3 | +26.7% ~ +30.9% |
| DSpark vs DFlash | +16.3% ~ +18.4% |

### 4.2 关键发现：为什么半自回归能超越全自回归和纯并行？

论文通过**逐位条件接受率（Conditional Acceptance）**分析揭示了一个反直觉的现象：

- **Position 1 优势**：并行模型 (DFlash) 可以使用更深的网络（O(1) latency 允许 5 层），在首位置的条件接受率远高于 Eagle3（Eagle3 受 O(γ) latency 限制只能使用 1 层）。例如在 Chat 领域：DFlash 0.72 vs Eagle3 0.53。
- **后续位置衰减**：纯并行模型因无法建模依赖关系而快速衰减（Chat 领域从 0.72 降至 0.63），而自回归模型 Eagle3 反而能逐步上升（从 0.53 升至 0.74）。
- **DSpark 的结合优势**：继承并行模型的高首位置接受率（0.93 on Math），同时串行头缓解后缀衰减，在整个 draft block 上保持高且稳定的条件接受率。

### 4.3 深度与长度分析

**Drafter 深度**：2 层 DSpark 超过 5 层 DFlash，证明轻量级串行头提供了极好的精度-参数权衡。

**Proposal 长度**：随着 block size 增加，DSpark 的优势更加显著——γ=7 时提升 15-18%，γ=15 时提升 22-30%。串行 head 的延迟开销仅为全轮延迟的 0.2%-1.3%。

### 4.4 生产部署性能

部署于 DeepSeek-V4（Flash 和 Pro），与生产基线 MTP-1 对比：

| 指标 | V4-Flash | V4-Pro |
|------|----------|--------|
| **用户生成速度提升** | +60% ~ +85% | +57% ~ +78% |
| **吞吐量提升（中等 SLA）** | +51% (80 tok/s/user SLA) | +52% (35 tok/s/user SLA) |
| **极端 SLA 下的吞吐量** | +661% (120 tok/s/user SLA) | +406% (50 tok/s/user SLA) |
| **动态验证 budget** | 中等并发：2→4-6 tokens | 中等并发：2→4-6 tokens |
| | 高并发自动缩减 | 高并发自动缩减 |

关键意义：DSpark 不只是在已有的 Pareto 前沿上提升性能——它**拓展了可行交互性边界**，使得以前无法达到的严格 SLA 要求成为可能。

---

## 5. 训练与推理流程

### 5.1 训练流程（DeepSpec 框架）

**三个阶段：**

1. **数据准备**（Data Preparation）
   - 下载 prompt 数据（Open-PerfectBlend，含 17.6% chat / 39.4% math / 38.9% code / 4.1% instruction）
   - 使用目标模型推理引擎重新生成 response，构建 target cache
   - 注意：默认配置（Qwen3-4B）target cache 约需 **38TB** 存储

2. **模型训练**（Training）
   - `bash scripts/train/train.sh`
   - 目标模型冻结，draft 模型共享其 embedding 层和 LM head（也冻结）
   - 仅更新：backbone drafter + sequential block + confidence head
   - 默认硬件：单节点 8 GPU

3. **评估验证**（Evaluation）
   - `bash scripts/eval/eval.sh`
   - 测量多个 benchmark 上的接受情况
   - 数据集：GSM8K, MATH500, AIME25, HumanEval, MBPP, LiveCodeBench, MT-Bench, Alpaca, Arena-Hard-v2

**训练优化**：
- 隐藏状态通信（减少带宽瓶颈，从 O(V) 降至 O(d)）
- Anchor-bounded sequence packing（将预测 block 打包为密集训练 batch）

### 5.2 推理流程

- **异步调度**：使用两步之前的置信度估计决定当前步的验证长度（历史预测仅用于确定截止长度 K，不依赖当前 token 的具体值），形成因果关系屏障，在最大化物理吞吐量的同时保持对目标分布的精确重建
- **可变长度验证**：将物理执行与逻辑序列跟踪解耦，所有 token 展平后作为独立元素处理，通过 marker tensor 传递序列依赖关系
- **CUDA graph replay + ZOS 兼容**：避免 GPU pipeline stalls

---

## 6. 个人思考

### 6.1 技术亮点

**对问题本质的深刻理解**。DSpark 最令人印象深刻的地方在于，它不仅解决了一个算法层面的问题（并行 draft 的接受率衰减），还系统地处理了系统层面的瓶颈（无差别验证带来的高并发吞吐下降）。这两个问题实际上是同一枚硬币的两面——生产级投机解码的关键瓶颈已经从"如何生成好的 candidate"转移到了"如何在系统约束下高效利用 candidate"。

**半自回归设计的优雅性**。将串行干预限制在局部（通过轻量级 Markov head），使得 per-token 概率仍然是精确的 softmax 计算，这与 CRF-NAT 或 CTC-drafter 等方法不同——它们由于全局归一化或潜在边缘化而无法提供精确的逐 token 概率。DSpark 的设计在并行效率与串行质量之间找到了一个**极优的平衡点**。

**从理论到工程的完整性**。论文不仅提出了算法，还完整地解决了生产部署所需的工程挑战：异步调度、CUDA graph replay 兼容、可变长度查询处理、SPS 非平滑曲线下的全局搜索等。这种完整性非常罕见。

### 6.2 工程价值

**生产成本优化路径清晰**。DSpark 是在 DeepSeek-V4 同一 checkpoint 上附加投机解码模块（不是新模型），这意味着部署成本增量极低。在生产中，DeepSeek-V4 发布两周内就从 MTP-1 切换到了 DSpark，清楚地显示了其工程优先级和 ROI。

**DeepSpec 的生态价值**。将 DSpark、DFlash、Eagle3 三个 draft 模型集成到同一框架中，统一了数据准备、训练、评估流程，对于投机解码研究社区来说是一个重要的基础设施贡献。

**Pareto 前沿的拓展**。最令人信服的数据点不是平均加速比，而是 DSpark 在严格 SLA 约束下维持有用吞吐的能力——在 MTP-1 已经失效的区域（120 TPS for Flash, 50 TPS for Pro），DSpark 仍然能够提供有意义的服务。

### 6.3 与其他方法的比较

| 维度 | DSpark | Eagle3 | DFlash | MTP-1 |
|------|--------|--------|--------|-------|
| **Draft 策略** | 半自回归 | 自回归 | 并行（扩散） | 单 token |
| **Draft 延迟** | O(1) + 低串行开销 | O(γ) | O(1) | O(1) |
| **接受率保持** | 好 | 中（浅层网络限制） | 后缀快速衰减 | — |
| **系统感知验证** | ✅ 有 | ❌ 无 | ❌ 无 | ❌ 无 |
| **生产验证** | DeepSeek-V4 | — | — | DeepSeek-V4(旧) |

### 6.4 局限与展望

- **固定 draft-side 成本**：对于本身接受率极低的复杂查询，即使有调度器的优化，生成初始 γ-token block 的 upfront 计算仍然不可恢复。未来可以引入难度感知的 early exiting 来跳过全 block 生成。
- **额外的训练数据需求**：需要目标模型重新生成 response 来构建 target cache（~38TB），这对于资源受限的团队是一个门槛。
- **串行头的信息局限**：Markov head 仅依赖前一个 token，虽然工程友好但在长 block 场景下可能不如 RNN head。目前 RNN head 的额外收益较小，但在更大 block size 或更复杂场景中可能变得更重要。
- **行业影响**：DSpark 的成功表明投机解码已经进入了**生产可用的成熟阶段**。与早期 Skepticism 相反（有人担心投机解码会损害输出质量或导致幻觉增加），DSpark 通过精确的 rejection sampling 和 lossless 的理论保证，证明了"更快"和"更好"可以同时实现。这种生产级的验证可能会加速整个行业对投机解码的采纳。

---

## 7. 参考文献

1. DeepSeek-AI. *DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence*. arXiv:2606.19348, 2026.
2. DeepSeek-AI. *DeepSeek-V3 Technical Report*. arXiv:2412.19437, 2024.
3. Chen et al. *Accelerating Large Language Model Decoding with Speculative Sampling*. arXiv:2302.01318, 2023.
4. Leviathan et al. *Fast Inference from Transformers via Speculative Decoding*. ICML 2023.
5. Chen et al. *DFlash: Block Diffusion for Flash Speculative Decoding*. arXiv:2602.06036, 2026.
6. Li et al. *EAGLE-3: Scaling Up Inference Acceleration of Large Language Models via Training-Time Test*. NeurIPS 2025.
7. Cai et al. *Medusa: Simple LLM Inference Acceleration Framework with Multiple Decoding Heads*. ICML 2024.
8. Huang et al. *SpecDec++: Boosting Speculative Decoding via Adaptive Candidate Lengths*. arXiv:2405.19715, 2024.
9. Hu et al. *Echo: Elastic Speculative Decoding with Sparse Gating for High-Concurrency Scenarios*. arXiv:2604.09603, 2026.
10. Gu et al. *Non-Autoregressive Neural Machine Translation*. ICLR 2018.
11. Stern et al. *Blockwise Parallel Decoding for Deep Autoregressive Models*. NeurIPS 2018.
12. Liu et al. *DART: Diffusion-inspired Speculative Decoding for Fast LLM Inference*. arXiv:2601.19278, 2026.
13. An et al. *PARD: Accelerating LLM Inference with Low-Cost PARallel Draft Model Adaptation*. ICLR 2026.
14. Miao et al. *SpecInfer: Accelerating Large Language Model Serving with Tree-based Speculative Inference and Verification*. ASPLOS 2024.
15. Wu et al. *TETRIS: Optimal Draft Token Selection for Batch Speculative Decoding*. ACL 2025.
16. Liu et al. *TurboSpec: Closed-Loop Speculation Control System for Optimizing LLM Serving Goodput*. arXiv:2406.14066, 2024.
17. Guo et al. *On Calibration of Modern Neural Networks*. ICML 2017.

---

*本文档由 Hermes Agent 自动生成，基于 DSpark 论文原文、DeepSeek V4 技术报告、DeepSpec README 及多篇产业报道综合分析。*
