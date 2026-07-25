% ==================== Fixed Parameters ====================
K     = 8011;     % saturation capacity (tons/day)
gamma = 0.022;    % intrinsic growth rate (1/day)
x0    = 6314;     % initial recovery (tons/day)

% ==================== Measured Data ====================
t_data = [0, 30, 60, 90, 120, 150, 180, 270, 365];
y_data = [6314, 6542, 6875, 7173, 7368, 7591, 7724, 7896, 8002];

% ====================================================================
% Q2 SYMMETRIC MODEL
% ODE: dx/dt = gamma/(1+beta) * x * (1 - x/(K*(1+alpha)))
% Standard logistic: r = gamma/(1+beta), K_eff = K*(1+alpha)
% ====================================================================

logistic_q2 = @(p, t) p(2) ./ (1 + (p(2)/x0 - 1) .* exp(-p(1) * t));

% Fit with constraints: r <= gamma, K_eff >= K (alpha, beta >= 0)
cost = @(p) sum((logistic_q2(p, t_data) - y_data).^2) + ...
            1e6 * max(0, p(1) - gamma)^2 + ...      % r <= gamma
            1e6 * max(0, K - p(2))^2;                 % K_eff >= K

p0 = [0.01, 8100];
p_opt = fminsearch(cost, p0);
r_fit = min(p_opt(1), gamma);
K_eff_fit = max(p_opt(2), K);

% Derive alpha, beta
beta_fit  = gamma / r_fit - 1;
alpha_fit = K_eff_fit / K - 1;

% Predictions
y_pred = logistic_q2(p_opt, t_data);
residuals = y_data - y_pred;
ss_res = sum(residuals.^2);
ss_tot = sum((y_data - mean(y_data)).^2);
r2  = 1 - ss_res / ss_tot;
mae = mean(abs(residuals));
mape = mean(abs(residuals ./ y_data)) * 100;

% Q1 comparison
r_q1 = gamma;
y_q1_pred = logistic_q2([r_q1, K], t_data);
res_q1 = y_data - y_q1_pred;
ss_res_q1 = sum(res_q1.^2);
r2_q1 = 1 - ss_res_q1 / ss_tot;
mae_q1 = mean(abs(res_q1));

fprintf('========== Q2 SYMMETRIC MODEL ==========\n');
fprintf('Model: dx/dt = gamma/(1+beta)*x*(1-x/(K*(1+alpha)))\n');
fprintf('Fitted: r = %.6f, K_eff = %.2f\n', r_fit, K_eff_fit);
fprintf('Derived: alpha = %.6f, beta = %.6f\n', alpha_fit, beta_fit);
fprintf('R^2 = %.4f, MAE = %.1f, MAPE = %.2f%%\n', r2, mae, mape);
fprintf('Q1 ref: R^2 = %.4f, MAE = %.1f\n', r2_q1, mae_q1);
fprintf('=========================================\n');

% ==================== Smooth curves ====================
t_smooth = linspace(0, 500, 400);
x_q2 = logistic_q2(p_opt, t_smooth);
x_q1 = logistic_q2([r_q1, K], t_smooth);

% ==================== Figure ====================
figure('Position', [50, 50, 1600, 500]);

% --- Subplot 1: Q2 Fit ---
subplot(1, 3, 1);
hold on;
r_lo = r_fit * 0.9; r_hi = r_fit * 1.1;
x_lo = logistic_q2([r_lo, K_eff_fit], t_smooth);
x_hi = logistic_q2([r_hi, K_eff_fit], t_smooth);
fill([t_smooth, fliplr(t_smooth)], [x_lo, fliplr(x_hi)], ...
     [0.85 0.85 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5, ...
     'DisplayName', 'r \pm 10%');
plot(t_smooth, x_q2, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Q2 fitted');
scatter(t_data, y_data, 70, 'b', 'filled', 'DisplayName', 'Data');
scatter(0, x0, 100, 'g', 's', 'filled', 'DisplayName', sprintf('x_0=%d', x0));
yline(K_eff_fit, 'r--', 'LineWidth', 1.2, 'DisplayName', sprintf('K_{eff}=%.0f', K_eff_fit));
yline(K, 'k:', 'LineWidth', 1.2, 'DisplayName', sprintf('K=%d', K));
xlabel('t (days)', 'FontSize', 12);
ylabel('x(t) (tons/day)', 'FontSize', 12);
title(sprintf(['Q2: r = %.4f, K_{eff} = %.0f\n' ...
               '\\alpha = %.4f, \\beta = %.4f, R^2 = %.4f, MAE = %.1f'], ...
              r_fit, K_eff_fit, alpha_fit, beta_fit, r2, mae), ...
      'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 8);
grid on; hold off;

% --- Subplot 2: Q1 vs Q2 ---
subplot(1, 3, 2);
hold on;
plot(t_smooth, x_q2, 'r-', 'LineWidth', 2.5, ...
     'DisplayName', sprintf('Q2: r=%.4f, K_{eff}=%.0f (R^2=%.4f)', r_fit, K_eff_fit, r2));
plot(t_smooth, x_q1, 'Color', [0.17 0.63 0.17], 'LineWidth', 2.5, 'LineStyle', '--', ...
     'DisplayName', sprintf('Q1: \\gamma=%.3f, K=%d (R^2=%.4f)', r_q1, K, r2_q1));
scatter(t_data, y_data, 70, 'b', 'filled', 'DisplayName', 'Data');
yline(K, 'k:', 'LineWidth', 1.5);
xlabel('t (days)', 'FontSize', 12);
ylabel('x(t) (tons/day)', 'FontSize', 12);
title('Q1 vs Q2', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 8);
grid on; hold off;

% --- Subplot 3: Residuals ---
subplot(1, 3, 3);
hold on;
yline(0, 'k-', 'LineWidth', 1);
h1 = stem(t_data, residuals, 'r', 'LineWidth', 2, 'MarkerSize', 8);
h2 = stem(t_data, res_q1, 'Color', [0.17 0.63 0.17], 'LineWidth', 2, 'MarkerSize', 8);
xlabel('t (days)', 'FontSize', 12);
ylabel('Residual (tons/day)', 'FontSize', 12);
title(sprintf('Residuals: Q2 MAE=%.0f vs Q1 MAE=%.0f', mae, mae_q1), ...
      'FontSize', 13, 'FontWeight', 'bold');
legend([h1, h2], {'Q2', 'Q1'}, 'Location', 'best', 'FontSize', 9);
grid on; hold off;

sgtitle(sprintf(['Q2 Symmetric Model: \\alpha=%.4f, \\beta=%.4f, ' ...
                 'r=%.4f, K_{eff}=%.0f'], alpha_fit, beta_fit, r_fit, K_eff_fit), ...
        'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'model_q2_matlab.png');
fprintf('Saved: model_q2_matlab.png\n');
