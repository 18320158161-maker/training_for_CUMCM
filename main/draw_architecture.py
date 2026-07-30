"""
Generate CUMCM-standard technical roadmap (技术路线图) for the paper.

Architecture:
    Data + Prior params
        → Q1: Basic Logistic (R²=0.53, reveals overestimation)
            → Q2: α/β Antagonistic model (R²=0.99, MAPE=0.53%)
                → Q3: Stability analysis (Lyapunov + Bifurcation, τ≈118d, βmax=3.40)
                → Q4: Sensitivity analysis (OAT, K-dominant, α near-zero)
                    → Layered Strategy (普查K → 降β → α转型 → γ监测)

Output: architecture.png (high-DPI, CUMCM-compatible)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

fig, ax = plt.subplots(1, 1, figsize=(16, 9))
ax.set_xlim(0, 16)
ax.set_ylim(0, 9)
ax.axis('off')

# ── Color Palette (CUMCM-friendly, print-safe) ──
C_DATA   = '#5B9BD5'  # blue
C_Q1     = '#ED7D31'  # orange
C_Q2     = '#4472C4'  # deep blue
C_Q3     = '#70AD47'  # green
C_Q4     = '#FFC000'  # gold
C_OUT    = '#C00000'  # red
C_ARROW  = '#595959'  # dark gray
C_BG     = '#F2F2F2'  # light gray bg for boxes
C_TEXT   = '#1a1a1a'

# ── Helper: rounded box with label ──
def draw_box(x, y, w, h, color, title, subtitle='', fs_title=11, fs_sub=9,
             edge_color=None, lw=2.5):
    if edge_color is None:
        edge_color = color
    rect = FancyBboxPatch((x, y), w, h,
                          boxstyle="round,pad=0.15", facecolor=color,
                          edgecolor=edge_color, linewidth=lw, alpha=0.15)
    ax.add_patch(rect)
    rect2 = FancyBboxPatch((x, y), w, h,
                           boxstyle="round,pad=0.15", facecolor='none',
                           edgecolor=edge_color, linewidth=lw)
    ax.add_patch(rect2)
    ax.text(x + w/2, y + h/2 + (0.15 if subtitle else 0), title,
            ha='center', va='center', fontsize=fs_title, fontweight='bold', color=C_TEXT)
    if subtitle:
        ax.text(x + w/2, y + h/2 - 0.28, subtitle,
                ha='center', va='center', fontsize=fs_sub, color='#555555')

def draw_arrow(x1, y1, x2, y2, lw=2.0, color=C_ARROW):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                                connectionstyle='arc3,rad=0'))

def draw_connector(x, y_top, y_bot, lw=1.8, color=C_ARROW):
    """Vertical connector line from y_bot to y_top (middle of box)."""
    ax.plot([x, x], [y_bot, y_top], color=color, lw=lw, zorder=1)
    # arrowhead
    ax.annotate('', xy=(x, y_top), xytext=(x, y_top + 0.12),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

# ── Column Layout ──
COL_DATA = 2.0
COL_Q12  = 5.5
COL_Q3   = 9.0
COL_Q4   = 12.5
COL_OUT  = 14.0

ROW_TOP    = 7.0
ROW_MID1   = 5.0
ROW_MID2   = 3.0
ROW_BOTTOM = 1.2

BOX_W = 2.4
BOX_H = 1.2
BOX_W_WIDE = 3.0

# ═══════════════════════════════════════════════════
#  LAYER 0: Data Input
# ═══════════════════════════════════════════════════
draw_box(COL_DATA - BOX_W/2, ROW_TOP, BOX_W, BOX_H * 0.9, C_DATA,
         '实测数据与先验参数',
         r'$K$=8011, $\gamma$=0.022, $x_0$=6314', fs_title=10, fs_sub=8)

# ═══════════════════════════════════════════════════
#  LAYER 1: Q1 → Q2  (progressive)
# ═══════════════════════════════════════════════════
draw_box(COL_Q12 - BOX_W_WIDE/2, ROW_MID1 + 0.4, BOX_W_WIDE, BOX_H, C_Q1,
         'Q1 基础Logistic模型',
         r'$R^2$=0.5319, 系统性高估', fs_title=10, fs_sub=8)

draw_box(COL_Q12 - BOX_W_WIDE/2, ROW_MID2 + 1.0, BOX_W_WIDE, BOX_H, C_Q2,
         'Q2 对称拮抗扩展模型',
         r'$\alpha$=0.016, $\beta$=1.59, $R^2$=0.9915, MAPE=0.53%', fs_title=10, fs_sub=8)

# Arrow: DATA → Q1
draw_arrow(COL_DATA + BOX_W/2, ROW_TOP + BOX_H*0.45,
           COL_Q12 - BOX_W_WIDE/2, ROW_MID1 + 0.4 + BOX_H/2)
# Arrow: Q1 → Q2
draw_arrow(COL_Q12, ROW_MID1 + 0.4, COL_Q12, ROW_MID2 + 1.0 + BOX_H)

# ═══════════════════════════════════════════════════
#  LAYER 2: Q3 & Q4  (parallel from Q2)
# ═══════════════════════════════════════════════════
draw_box(COL_Q3 - BOX_W/2, ROW_MID2 + 1.0, BOX_W, BOX_H, C_Q3,
         'Q3 稳定性分析',
         r'Lyapunov + 分岔, $\tau$$\approx$118d, $\beta_{\max}$=3.40', fs_title=10, fs_sub=8)

draw_box(COL_Q4 - BOX_W/2, ROW_MID2 + 1.0, BOX_W, BOX_H, C_Q4,
         'Q4 灵敏度分析',
         r'OAT, $K$主导, $\varepsilon_{\alpha}$$\approx$0', fs_title=10, fs_sub=8)

# Arrow: Q2 → Q3
ax.annotate('', xy=(COL_Q3 - BOX_W/2, ROW_MID2 + 1.0 + BOX_H/2),
            xytext=(COL_Q12 - BOX_W_WIDE/2 + BOX_W_WIDE, ROW_MID2 + 1.0 + BOX_H/2),
            arrowprops=dict(arrowstyle='->', color=C_ARROW, lw=2.0,
                            connectionstyle='arc3,rad=0.2'))
# Arrow: Q2 → Q4
draw_arrow(COL_Q12 + BOX_W_WIDE/2, ROW_MID2 + 1.0 + BOX_H/2,
           COL_Q4 + BOX_W/2, ROW_MID2 + 1.0 + BOX_H/2)

# ═══════════════════════════════════════════════════
#  LAYER 3: Synthesis → Strategy
# ═══════════════════════════════════════════════════
draw_box(COL_OUT - 1.0, ROW_MID2 - 0.8, BOX_W_WIDE * 0.9, BOX_H, C_OUT,
         '分层运维策略',
         '普查K(优先) → 降β → α转型 → γ监测', fs_title=10, fs_sub=8)

# Arrows: Q3 → Strategy, Q4 → Strategy
ax.annotate('', xy=(COL_OUT - 1.0 + BOX_W_WIDE*0.9/2, ROW_MID2 - 0.8 + BOX_H),
            xytext=(COL_Q3, ROW_MID2 + 1.0),
            arrowprops=dict(arrowstyle='->', color=C_ARROW, lw=2.0,
                            connectionstyle='arc3,rad=-0.3'))
ax.annotate('', xy=(COL_OUT - 1.0 + BOX_W_WIDE*0.9/2, ROW_MID2 - 0.8 + BOX_H),
            xytext=(COL_Q4, ROW_MID2 + 1.0),
            arrowprops=dict(arrowstyle='->', color=C_ARROW, lw=2.0,
                            connectionstyle='arc3,rad=0.3'))

# ═══════════════════════════════════════════════════
#  Phase labels (left side)
# ═══════════════════════════════════════════════════
LABEL_X = 0.3
ax.text(LABEL_X, ROW_TOP + BOX_H*0.3, '输入层',
        fontsize=9, fontweight='bold', color='#888888', rotation=0)
ax.text(LABEL_X, ROW_MID1 + 0.7, '正向建模',
        fontsize=9, fontweight='bold', color='#888888', va='center')
ax.text(LABEL_X, ROW_MID2 + 0.7, '稳定性判定\n与灵敏度控制',
        fontsize=9, fontweight='bold', color='#888888', va='center', ha='center')
ax.text(LABEL_X, ROW_MID2 - 0.5, '策略输出',
        fontsize=9, fontweight='bold', color='#888888', va='center')

# Vertical braces / brackets for phases
for y_center, label in [(7.3, ''), (5.5, ''), (3.5, ''), (1.5, '')]:
    pass  # labels already placed

# Dashed phase separator lines
for x_pos in [0.6, 0.6]:
    ax.plot([0.6, 16], [ROW_TOP + 1.2, ROW_TOP + 1.2],
            color='#CCCCCC', lw=1, linestyle='--', alpha=0.6)
    ax.plot([0.6, 16], [ROW_MID1 - 0.05, ROW_MID1 - 0.05],
            color='#CCCCCC', lw=1, linestyle='--', alpha=0.6)
    ax.plot([0.6, 16], [ROW_MID2 - 0.9, ROW_MID2 - 0.9],
            color='#CCCCCC', lw=1, linestyle='--', alpha=0.6)

# Phase labels on dashed lines
ax.text(0.5, ROW_TOP + 1.35, '正向建模', fontsize=8, color='#999999', fontweight='bold')
ax.text(0.5, ROW_MID1 + 0.1, '稳定性判定\n  +\n灵敏度控制', fontsize=8, color='#999999',
        fontweight='bold', va='center')
ax.text(0.5, ROW_MID2 - 0.6, '综合决策', fontsize=8, color='#999999', fontweight='bold')

# ═══════════════════════════════════════════════════
#  Title
# ═══════════════════════════════════════════════════
ax.text(8, 8.5, '技术路线图', ha='center', va='center',
        fontsize=14, fontweight='bold', color=C_TEXT)

# ═══════════════════════════════════════════════════
#  Key insights annotations (small text next to boxes)
# ═══════════════════════════════════════════════════
ax.text(COL_Q3, ROW_MID2 + 0.3, '结构稳定\n无分岔',
        ha='center', fontsize=7.5, color=C_Q3, fontweight='bold')
ax.text(COL_Q4, ROW_MID2 + 0.3, '吸引子错位\n隐蔽风险',
        ha='center', fontsize=7.5, color=C_Q4, fontweight='bold')

# Bootstrap badge
ax.text(COL_Q12, ROW_MID2 + 0.3, 'Bootstrap\n交叉验证',
        ha='center', fontsize=7.5, color=C_Q2, fontweight='bold')

plt.tight_layout(pad=0.5)
plt.savefig('architecture.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved: architecture.png")
plt.close()
