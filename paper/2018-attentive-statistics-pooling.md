---
tags: [paper, speaker-verification, attention-mechanism, speaker-embedding, 2018]
date: 2025-06-17
source: https://arxiv.org/abs/1803.10963
---

# Attentive Statistics Pooling for Deep Speaker Embedding

> 在文本无关的说话人确认中，用注意力机制对帧级特征做加权均值 + 加权标准差池化，替代传统的平均池化或统计池化，提升说话人嵌入的判别力。

## 动机

- 文本无关（text-independent）的说话人确认中，输入语音长度可变，需要 pooling 层将变长帧级特征转为固定维度的 utterance 级特征
- 传统平均池化对所有帧一视同仁，忽略了不同帧对说话人判别的重要性差异
- 统计池化（Snyder et al.）加入了标准差，但仍是等权计算；注意力池化仅有加权均值，缺少方差信息
- 已有工作没有证明标准差和注意力**联合使用**的有效性——这篇论文补上了这个空白

## 方法

- **整体思路**：在 TDNN 骨干网络之上，用一个可训练的注意力网络为每帧打分，再用这些得分同时计算加权均值和加权标准差，拼接后送入后续全连接层

- **关键组件**：
  - **Frame-level 特征提取器**：5 层 TDNN，每层 512 节点（ReLU + BN），输出 1500 维帧级特征
  - **注意力模型**：单隐层（64 节点，ReLU + BN），对每帧输出一个标量得分
  - **Attentive Statistics Pooling**：用 softmax 归一化的注意力权重，同时计算：
    - 加权均值：$\tilde{\mu} = \sum_t \alpha_t h_t$
    - 加权标准差：$\tilde{\sigma} = \sqrt{\sum_t \alpha_t h_t \odot h_t - \tilde{\mu} \odot \tilde{\mu}}$
    - 拼接 $\tilde{\mu}$ 和 $\tilde{\sigma}$ 作为 utterance 级特征
  - **Utterance-level 特征提取器**：2 层 FC（512 维 bottleneck），最终 softmax 分类，bottleneck 输出用作说话人嵌入
  - 训练后可用 PLDA 进一步 scoring

**关键公式：**

$$ e_t = v^T f(W h_t + b) + k $$

$$ \alpha_t = \frac{\exp(e_t)}{\sum_{\tau} \exp(e_{\tau})} $$

> 第一式是注意力得分函数：$h_t$ 是第 t 帧的帧级特征，通过一个可训练的线性层 + 非线性激活得到标量得分。第二式用 softmax 归一化为权重 $\alpha_t$。

$$ \tilde{\mu} = \sum_t \alpha_t h_t, \quad \tilde{\sigma} = \sqrt{\sum_t \alpha_t h_t \odot h_t - \tilde{\mu} \odot \tilde{\mu}} $$

> 用同一套注意力权重同时计算加权均值和加权标准差。$\odot$ 是逐元素乘法。标准差刻画的是帧级特征的长时间变异性（long-term variability），LSTM/GRU 的上下文窗口通常 ~1s，而标准差可以覆盖整段语音。

## 关键 Insight

- **标准差比注意力更重要**：在 NIST SRE 2012 上，仅加标准差（statistics pooling）EER 从 2.57% 降到 1.58%，仅加注意力降到 1.99%，而两者结合降到 1.47%。标准差的贡献比注意力大。
- **短语音场景优势明显**：30s 片段上 attentive statistics 比平均池化低 31% 的 EER（2.46% vs 3.58%），说明注意力在信息有限的短语音中能更好地聚焦关键帧。
- **该层可微、即插即用**：直接替换传统 pooling 层即可，不需要修改网络其他部分。

## 图表辅助

![pipeline](images/2018-attentive-statistics-pooling-pipeline.svg)

## 值得注意的细节

- 实验做了充分的数据增强（加噪、混响、AMR 编码），增强了鲁棒性
- VoxCeleb 上 EER 8.1% 的相对提升略大于 SRE12 的 7.5%
- i-vector 在 300s 长语音上仍然很强（EER 0.58%），说明在极长语音场景下传统方法仍有竞争力
- 论文来自 NEC 研究所 + 东京工业大学，工业界 + 学术界组合

## 评价

- **推荐程度**：⭐⭐⭐⭐
- **一句话**：把注意力加权和统计池化干净地结合在一起，思路简洁、效果明显、影响深远——ECAPA-TDNN 等后续工作直接继承了这一设计。
- **可引用**：Interspeech 2018，引用量 800+（截至 2025），是说话人确认领域注意力池化的奠基性工作。

## 相关资源

| 类型 | 名称/标题 | 链接 | 说明 |
|------|-----------|------|------|
| GitHub | 第三方 PyTorch 复现 | https://github.com/KrishnaDN/Attentive-Statistics-Pooling-for-Deep-Speaker-Embedding | 清晰的 ASP 层实现 |
| 论文 | ECAPA-TDNN（后续工作） | https://arxiv.org/abs/2005.07143 | 在 ASP 基础上加入通道注意力和 Res2Net，VoxCeleb 新 SOTA |
| 框架 | SpeechBrain 官方实现 | https://github.com/speechbrain/speechbrain/blob/develop/speechbrain/lobes/models/ECAPA_TDNN.py | AttentiveStatisticsPooling 层 |
| 论文 | Statistics Pooling（前驱） | https://arxiv.org/abs/1708.01005 | Snyder et al. 的 x-vector + statistics pooling |
| 论文 | Enroll-Aware ASP（后续） | https://arxiv.org/abs/2206.13040 | Interspeech 2022，在 ASP 基础上引入注册语音信息 |
