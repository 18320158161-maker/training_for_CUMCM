# Q2 Logistic Model Report: alpha & beta (Symmetric Antagonistic)

## Model Formulation

alpha and beta have **equal status** in a symmetric antagonistic structure:

$$\frac{dx}{dt} = \frac{\gamma}{1+\beta} \cdot x \cdot \left(1 - \frac{x}{K(1+\alpha)}\right)$$

- $\alpha \geq 0$ (promotion): expands effective carrying capacity $\;\rightarrow\; K_{\text{eff}} = K(1+\alpha)$
- $\beta \geq 0$ (inhibition): reduces effective growth rate $\;\rightarrow\; r = \gamma/(1+\beta)$

The two coefficients act on **different logistic parameters** with the **same functional form**
$(1+\text{coeff})^{\pm 1}$, reflecting their equal status as symmetric antagonists.

## Standard Logistic Form

$$\frac{dx}{dt} = r \cdot x \cdot \left(1 - \frac{x}{K_{\text{eff}}}\right)$$

$$r = \frac{\gamma}{1+\beta}, \qquad K_{\text{eff}} = K(1+\alpha)$$

**Analytical solution:**
$$x(t) = \frac{K_{\text{eff}}}{1 + \left(\frac{K_{\text{eff}}}{x_0} - 1\right) e^{-rt}}$$

## Parameter Identification

Fitting $r$ and $K_{\text{eff}}$ gives two independent equations:

$$\beta = \frac{\gamma}{r} - 1, \qquad \alpha = \frac{K_{\text{eff}}}{K} - 1$$

$r \leq \gamma$ ensures $\beta \geq 0$; $K_{\text{eff}} \geq K$ ensures $\alpha \geq 0$.

## Parameters

| Role | Symbol | Value | Unit |
|------|--------|-------|------|
| Fixed | $K$ | 8011 | tons/day |
| Fixed | $\gamma$ | 0.022 | 1/day |
| Fixed | $x_0$ | 6314 | tons/day |
| **Fitted** | $r$ | **0.008485** $\pm$ 0.000655 | 1/day |
| **Fitted** | $K_{\text{eff}}$ | **8142.22** $\pm$ 72.77 | tons/day |
| Derived | $\alpha$ | **0.016379** | — |
| Derived | $\beta$ | **1.592906** | — |

### Physical Interpretation

- $\alpha = 0.016379 > 0$: promotion expands effective capacity by $1.6\%$ above $K=8011$
- $\beta = 1.592906 > 0$: inhibition slows growth to $r = \gamma/(1+\beta) = 0.0085$
- $r / \gamma = 1/(1+\beta) = 38.6\%$: effective rate as fraction of intrinsic rate
- Antagonistic balance: $\alpha$ pushes up the ceiling, $\beta$ stretches out the timeline

## Evaluation

| Metric | Q1 (no $\alpha,\beta$) | Q2 (with $\alpha,\beta$) |
|--------|--------------------------|----------------------------|
| $R^2$ | 0.5319 | **0.9915** |
| MAE | 315.6 | **38.3** |
| MAPE | 4.42% | **0.53%** |

## Predictions

| $t$ (days) | Actual | Predicted | Residual | Rel.Err |
|:----------:|:------:|:---------:|:--------:|:-------:|
| 0 | 6314 | 6314.0 | +0.0 | +0.00% |
| 30 | 6542 | 6649.5 | -107.5 | -1.64% |
| 60 | 6875 | 6935.3 | -60.3 | -0.88% |
| 90 | 7173 | 7174.2 | -1.2 | -0.02% |
| 120 | 7368 | 7371.2 | -3.2 | -0.04% |
| 150 | 7591 | 7531.5 | +59.5 | +0.78% |
| 180 | 7724 | 7660.6 | +63.4 | +0.82% |
| 270 | 7896 | 7910.5 | -14.5 | -0.18% |
| 365 | 8002 | 8037.1 | -35.1 | -0.44% |

## Key Findings

- $\alpha = 0.016379 > 0$, $\beta = 1.592906 > 0$: **both positive by construction**
- $\alpha$ and $\beta$ have equal status: symmetric $(1+\text{coeff})^{\pm 1}$ structure
- $K_{\text{eff}} = 8142.2$ tons/day: promotion expands capacity by $1.6\%$
- $r = 0.0085$: inhibition reduces growth rate to $38.6\%$ of intrinsic $\gamma$
- The system with $\alpha,\beta \geq 0$ is **structurally stable**: no bifurcation, no collapse risk
