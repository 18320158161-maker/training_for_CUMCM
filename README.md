# 校内预选建模训练 — Problem A: 绿色可回收物回收量动态预测与回收体系稳定性分析

> **XJTLU Mathematical Modelling Training 2026**
>
> 选题：**Problem A** — 上海市"沪尚回收"绿色可回收物回收体系
>
> 方法论：递进式复杂度建模 (Progressive Complexity Modeling)

---

## 📁 项目结构总览

```
training_for_CUMCM/
├── README.md                  ← 你在这里
├── 题目/                      原题 + 数据
├── Q1/                        经典 Logistic (零自由参数)
├── Q2/                        对称拮抗 Logistic (双参数 α, β)
├── Q3/                        稳定性分析
├── Q4/                        灵敏度分析
├── *.md                       参考数据与建模思路
└── 附表.xls                   原始数据表
```

---

## 📋 参考数据文档

建模所使用的全部原始数据均来自题目给出的三张表，已整理为标准 Markdown 格式：

| 文档 | 内容 | 来源 |
|:-----|:-----|:-----|
| [基础固定参数.md](基础固定参数.md) | $x_0$, $K$, $\gamma$ 的数值与单位 | 题目表 (a) |
| [实测时序数据.md](实测时序数据.md) | $t=0\sim365$ 天的 9 组实测回收量 | 题目表 (b) |
| [参数灵敏度对照数据.md](参数灵敏度对照数据.md) | 四参数 ±10% 波动幅度规定 | 题目表 (c) |

> 原始题目 PDF：[题目/xjtlu-mm-training-2026-problems.pdf](题目/xjtlu-mm-training-2026-problems.pdf)
>
> 原始 Excel 数据：[附表.xls](附表.xls)

---

## 🧠 建模思路 (递进式)

```
Q1 ──→ Q2 ──→ Q3 ──→ Q4
│       │       │       │
│       │       │       └── OAT ±10% 灵敏度 → 政策建议
│       │       └── Lyapunov 稳定性 → 安全边界
│       └── 引入 α, β 双参数 → R² 从 0.53 → 0.99
└── 零自由参数 Logistic → 诊断模型不足
```

完整推导过程、经典参考文献、后续改进方向详见 **[建模思路总结.md](建模思路总结.md)**。

---

## 📂 各小题概览

### Q1 · 经典 Logistic 模型

> **目标**：以零自由参数建立基线，诊断模型与实测数据的偏差来源。

| 项目 | 说明 |
|:-----|:-----|
| 核心方程 | $\frac{dx}{dt} = \gamma x \left(1 - \frac{x}{K}\right)$ |
| 解析解 | $x(t) = \frac{K}{1 + A e^{-\gamma t}},\; A = \frac{K}{x_0} - 1$ |
| 拟合质量 | $R^2 = 0.5319$，MAE = 315.6 吨/天 |
| 结论 | 模型系统性地高估回收量，说明缺少增长抑制机制 |

| 文件 | 类型 |
|:-----|:-----|
| [logistic_model.py](Q1/logistic_model.py) | 🔧 Python 计算 + 绘图 + 生成 report.md |
| [plot_logistic.m](Q1/plot_logistic.m) | 🔧 MATLAB 等效脚本 |
| [report_q1.tex](Q1/report_q1.tex) | 📄 LaTeX 正式报告 |
| [report_q1.pdf](Q1/report_q1.pdf) | 📄 编译后的 PDF 报告 |
| [report.md](Q1/report.md) | 📝 自动生成的 Markdown 报告 |
| [logistic_fit.png](Q1/logistic_fit.png) | 📊 拟合曲线 + 残差 + 三阶段分析 |

---

### Q2 · 对称拮抗 Logistic 模型

> **目标**：引入促进系数 $\alpha$ 与抑制系数 $\beta$，通过非线性最小二乘拟合数据。

| 项目 | 说明 |
|:-----|:-----|
| 核心方程 | $\frac{dx}{dt} = \frac{\gamma}{1+\beta}\, x \left(1 - \frac{x}{K(1+\alpha)}\right)$ |
| 标准形式 | $r = \frac{\gamma}{1+\beta},\quad K_{\text{eff}} = K(1+\alpha)$ |
| 拟合方法 | Levenberg-Marquardt (`scipy.optimize.curve_fit`) |
| 参数结果 | $\alpha = 0.0164,\; \beta = 1.593$（抑制占主导） |
| 拟合质量 | $R^2 = \mathbf{0.9915}$，MAE = 38.3 吨/天（提升 88%） |

| 文件 | 类型 |
|:-----|:-----|
| [advanced_model.py](Q2/advanced_model.py) | 🔧 Python 拟合 + 绘图 + 生成 report_q2.md |
| [plot_q2.m](Q2/plot_q2.m) | 🔧 MATLAB 等效脚本 |
| [report_q2.tex](Q2/report_q2.tex) | 📄 LaTeX 正式报告 |
| [report_q2.pdf](Q2/report_q2.pdf) | 📄 编译后的 PDF 报告 |
| [report_q2.md](Q2/report_q2.md) | 📝 自动生成的 Markdown 报告 |
| [model_q2.png](Q2/model_q2.png) | 📊 拟合曲线 + Q1 vs Q2 对比 + 残差对比 |

---

### Q3 · 稳定性分析

> **目标**：分析系统动力学行为——求平衡点、证明结构稳定性、定义实用安全边界。

| 项目 | 说明 |
|:-----|:-----|
| 平衡点 | $x_1^* = 0$（不稳定），$x_2^* = K_{\text{eff}}$（渐近稳定） |
| 分析方法 | Lyapunov 第一方法（线性稳定性判据） |
| 结构稳定性 | 对全体 $\alpha \ge 0,\; \beta \ge 0$ 均成立，无分岔点 |
| 安全边界 | $\beta \le 3.40$（以 $r_{\min} = 0.005$ 为阈值） |
| 安全裕度 | 当前 $\beta = 1.593$，距安全边界仍有 53.2% 裕量 |

| 文件 | 类型 |
|:-----|:-----|
| [stability_analysis.py](Q3/stability_analysis.py) | 🔧 Python 稳定性分析 + 绘图 + 生成 report_q3.md |
| [plot_stability.m](Q3/plot_stability.m) | 🔧 MATLAB 等效脚本 |
| [report_q3.tex](Q3/report_q3.tex) | 📄 LaTeX 正式报告 |
| [report_q3.pdf](Q3/report_q3.pdf) | 📄 编译后的 PDF 报告 |
| [report_q3.md](Q3/report_q3.md) | 📝 自动生成的 Markdown 报告 |
| [stability_analysis.png](Q3/stability_analysis.png) | 📊 五面板综合分析图 |
| [collapse_scenario.png](Q3/collapse_scenario.png) | 📊 收敛轨迹 + 解耦控制 + 安全边界 |

---

### Q4 · 灵敏度分析

> **目标**：量化各参数对拟合质量与预测输出的影响，导出面向实际运营的政策建议。

| 项目 | 说明 |
|:-----|:-----|
| 方法 | OAT (One-At-a-Time) ±10% 局部灵敏度 + 中心差分弧弹性 |
| 最大敏感参数 | **$K$（饱和总量）**：$R^2$ 弹性 $\approx 96$，碾压其他三个参数 |
| 次敏感参数 | **$\beta$（抑制系数）**：$r$ 弹性 $\approx -0.61$，通过衰减增长率影响拟合 |
| 微弱参数 | **$\alpha$（促进系数）**：弹性仅 $0.016$，近乎无影响 |
| 中间参数 | **$\gamma$（固有增长率）**：在 Logistic 近饱和区被 S 形压缩，弹性仅 $\sim 0.1$ |

**四优先策略**：

| 优先级 | 参数 | 策略 |
|:------:|:----:|:-----|
| 🔴 P1 | $K$ | 精准测量饱和容量——弹性 ~96，是系统命脉 |
| 🟠 P2 | $\beta$ | 降低系统摩擦——弹性 ~-0.61，显著影响增长速度 |
| 🟡 P3 | $\alpha$ | 重新评估促进手段——弹性仅 0.016，投入产出比存疑 |
| 🟢 P4 | $\gamma$ | 持续监测——近饱和区影响自然衰减，但仍是系统基础动力 |

| 文件 | 类型 |
|:-----|:-----|
| [sensitivity_analysis.py](Q4/sensitivity_analysis.py) | 🔧 Python 灵敏度计算 + 绘图 + 生成 report_q4.md |
| [plot_sensitivity.m](Q4/plot_sensitivity.m) | 🔧 MATLAB 等效脚本 |
| [report_q4.tex](Q4/report_q4.tex) | 📄 LaTeX 正式报告（最详尽，~517行） |
| [report_q4.pdf](Q4/report_q4.pdf) | 📄 编译后的 PDF 报告 |
| [report_q4.md](Q4/report_q4.md) | 📝 自动生成的 Markdown 报告 |
| [sensitivity_tornado.png](Q4/sensitivity_tornado.png) | 📊 四面板龙卷风图 |
| [sensitivity_envelope.png](Q4/sensitivity_envelope.png) | 📊 预测包络 + 参数贡献带 + 弹性柱状图 |

---

## 🔧 技术栈

| 组件 | 用途 |
|:-----|:-----|
| **Python** (`numpy`, `scipy`, `matplotlib`) | 数值计算、参数拟合、灵敏度分析、自动生成 Markdown 报告 |
| **MATLAB** | 等效实现（每个 Q 文件夹均提供 `.m` 脚本） |
| **LaTeX** (XeLaTeX + `ctex`) | 正式报告排版（每个 Q 文件夹包含 `.tex` 源文件 + 编译后的 `.pdf`） |
| **Git** | 版本控制 |

---

## 🚀 快速复现

```bash
# 1. 激活虚拟环境
cd training_for_CUMCM
source .venv/Scripts/activate   # Windows Git Bash

# 2. 依次运行各小题
python Q1/logistic_model.py       # Q1: 经典 Logistic
python Q2/advanced_model.py       # Q2: 对称拮抗模型拟合
python Q3/stability_analysis.py   # Q3: 稳定性分析
python Q4/sensitivity_analysis.py # Q4: OAT 灵敏度分析

# 3. 编译 LaTeX 报告（需安装 TeX Live 且含 ctex）
cd Q1 && xelatex report_q1.tex && cd ..
cd Q2 && xelatex report_q2.tex && cd ..
cd Q3 && xelatex report_q3.tex && cd ..
cd Q4 && xelatex report_q4.tex && cd ..
```

每次运行 Python 脚本会自动：
- 输出计算结果到终端
- 生成对应的 `report.md` / `report_q*.md` 自动报告
- 保存 `.png` 图表

---

## 📚 参考文献

完整文献列表见 [建模思路总结.md § 参考文献](建模思路总结.md)，核心经典包括：

- **Verhulst (1838)** — Logistic 方程原始提出
- **Pearl & Reed (1920)** — 种群增长曲线的独立重新发现
- **Richards (1959)** — 非对称增长曲线的推广形式
- **Strogatz (2018)** — *Nonlinear Dynamics and Chaos*，稳定性分析的标准参考
- **Saltelli et al. (2008)** — *Global Sensitivity Analysis*，灵敏度分析方法论

---

## 📝 文件命名约定

| 前缀/后缀 | 含义 |
|:----------|:-----|
| `report.md` / `report_q*.md` | 自动生成的 Markdown 报告（Python 脚本输出） |
| `report_q*.tex` | 手写 LaTeX 正式报告 |
| `report_q*.pdf` | 编译后的 PDF 报告 |
| `*.py` | Python 计算脚本 |
| `*.m` | MATLAB 等效脚本 |
| `*.png` | 输出图表 |
