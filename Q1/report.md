# Logistic Growth Model Report

## Parameters (All Fixed)

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Saturation capacity | $K$ | 8011 | tons/day | Given |
| Intrinsic growth rate | $\gamma$ | 0.022 | 1/day | Given |
| Initial recovery | $x_0$ | 6314 | tons/day | Given |
| Derived constant | $A = K/x_0 - 1$ | 0.26877 | — | Computed |

**Model equation:**

$$x(t) = \frac{K}{1 + \left(\frac{K}{x_0} - 1\right) e^{-\gamma t}} = \frac{8011}{1 + 0.26877 \cdot e^{-0.022 \cdot t}}$$

**Governing ODE:**

$$\frac{dx}{dt} = \gamma \cdot x \cdot \left(1 - \frac{x}{K}\right), \quad x(0) = x_0$$

## Model Quality

| Metric | Value | Interpretation |
|--------|-------|----------------|
| $R^2$ | 0.5319 | Poor |
| MAE | 315.6 tons/day | Avg absolute deviation |
| RMSE | 385.4 tons/day | RMS deviation |
| MAPE | 4.42% | Avg relative error |

## Predictions vs Actual

| $t$ (days) | Actual $y$ | Predicted $x(t)$ | Residual | Rel. Error |
|:----------:|:----------:|:----------------:|:--------:|:----------:|
|    0 |     6314 |        6314.0 |     -0.0 |   -0.00% |
|   30 |     6542 |        7033.9 |   -491.9 |   -7.52% |
|   60 |     6875 |        7474.4 |   -599.4 |   -8.72% |
|   90 |     7173 |        7724.4 |   -551.4 |   -7.69% |
|  120 |     7368 |        7860.2 |   -492.2 |   -6.68% |
|  150 |     7591 |        7932.4 |   -341.4 |   -4.50% |
|  180 |     7724 |        7970.2 |   -246.2 |   -3.19% |
|  270 |     7896 |        8005.3 |   -109.3 |   -1.38% |
|  365 |     8002 |        8010.3 |     -8.3 |   -0.10% |

## Forecast

| $t$ (days) | $x(t)$ (tons/day) | % of $K$ |
|:----------:|:-----------------:|:--------:|
|  400 | 8010.7 | 100.00% |
|  450 | 8010.9 | 100.00% |
|  500 | 8011.0 | 100.00% |
|  600 | 8011.0 | 100.00% |
|  730 | 8011.0 | 100.00% |

## Residual Analysis

| Statistic | Value |
|-----------|-------|
| Max positive residual | -0.0 at t = 0 days |
| Max negative residual | -599.4 at t = 60 days |
| Mean residual | -315.6 |

**Observation:** The model systematically **overestimates** early-stage recovery (t = 30–150 days),
with errors reaching -599 tons/day. This indicates that the theoretical
$\gamma = 0.022$ is larger than the empirically observed effective growth rate.
Introducing modulation parameters ($\alpha$ for promotion, $\beta$ for inhibition)
could resolve this discrepancy.

## Stage-wise Behavior

| Phase | $t$ (days) | Characteristic |
|-------|------------|----------------|
| Initiation | 0–60 | System optimization, promotion rollout; slow growth |
| Rapid growth | 60–180 | Community engagement peaks; recovery volume accelerates |
| Saturation | 180–365+ | Growth decelerates; asymptotically approaches $K = 8011$ |
