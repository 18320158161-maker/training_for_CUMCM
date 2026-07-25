% ==================== Q4: Sensitivity Analysis (±10% OAT) ====================
% Base Parameters (from Q2 fit)
K_fixed   = 8011;
gamma_fixed = 0.022;
x0 = 6314;

r_fit     = 0.008485;
K_eff_fit = 8142.22;

alpha_fit = K_eff_fit / K_fixed - 1;   % 0.016379
beta_fit  = gamma_fixed / r_fit - 1;    % 1.592811

% Data
t_data = [0, 30, 60, 90, 120, 150, 180, 270, 365];
y_data = [6314, 6542, 6875, 7173, 7368, 7591, 7724, 7896, 8002];

% Logistic function
logistic = @(r, Keff, t) Keff ./ (1 + (Keff/x0 - 1) .* exp(-r * t));

% Metric computation
compute_metrics = @(r, Keff) deal(...
    (function(r, Keff)
        yp = logistic(r, Keff, t_data);
        res = y_data - yp;
        ss_res = sum(res.^2);
        ss_tot = sum((y_data - mean(y_data)).^2);
        r2 = 1 - ss_res / ss_tot;
        mae = mean(abs(res));
        rmse = sqrt(mean(res.^2));
    end)(r, Keff) ...
);

% Actually, MATLAB anonymous functions can't easily return multiple values.
% Use a subfunction approach.

% Base metrics
[r2_base, mae_base, rmse_base] = calc_metrics(r_fit, K_eff_fit, t_data, y_data, x0);

fprintf('========== Q4 SENSITIVITY (±10%%) ==========\n');
fprintf('Baseline: r=%.6f, K_eff=%.2f, R²=%.4f, MAE=%.1f, RMSE=%.1f\n', ...
    r_fit, K_eff_fit, r2_base, mae_base, rmse_base);
fprintf('alpha=%.6f, beta=%.6f\n', alpha_fit, beta_fit);

% OAT perturbation
pert = 0.10;
params = {'\gamma', '\beta', '\alpha', 'K'};
p_base_vals = [gamma_fixed, beta_fit, alpha_fit, K_fixed];
p_units = {'1/day', '—', '—', 'tons/day'};

for i = 1:4
    p_base = p_base_vals(i);
    p_down = p_base * (1 - pert);
    p_up   = p_base * (1 + pert);

    % Compute r, K_eff for down/up
    [r_d, Keff_d] = apply_perturbation(i, p_base_vals, p_down);
    [r_u, Keff_u] = apply_perturbation(i, p_base_vals, p_up);

    [r2_d, mae_d, rmse_d] = calc_metrics(r_d, Keff_d, t_data, y_data, x0);
    [r2_u, mae_u, rmse_u] = calc_metrics(r_u, Keff_u, t_data, y_data, x0);

    fprintf('\n  %s ±10%%: %.4f → [%.4f, %.4f]\n', params{i}, p_base, p_down, p_up);
    fprintf('    r:       [%.6f, %.6f]  (Δ=%+.6f)\n', r_d, r_u, r_u-r_d);
    fprintf('    K_eff:   [%.1f, %.1f]  (Δ=%+.1f)\n', Keff_d, Keff_u, Keff_u-Keff_d);
    fprintf('    R²:      [%.4f, %.4f]  (Δ=%+.4f)\n', r2_d, r2_u, r2_u-r2_d);
    fprintf('    MAE:     [%.1f, %.1f]  (Δ=%+.1f)\n', mae_d, mae_u, mae_u-mae_d);
    fprintf('    RMSE:    [%.1f, %.1f]  (Δ=%+.1f)\n', rmse_d, rmse_u, rmse_u-rmse_d);
end

eps_r_beta   = -beta_fit / (1 + beta_fit);
eps_K_alpha  = alpha_fit / (1 + alpha_fit);

fprintf('\nAnalytical Elasticities:\n');
fprintf('  ε(r,γ)     = +1.0000\n');
fprintf('  ε(r,β)     = %+.4f\n', eps_r_beta);
fprintf('  ε(Keff,α)  = %+.4f\n', eps_K_alpha);
fprintf('  ε(Keff,K)  = +1.0000\n');
fprintf('============================================\n');

% ==================== Figure 1: Tornado Diagrams ====================
figure('Position', [30, 30, 1600, 1000]);

% Recompute all perturbation data for plotting
pert_data = cell(4, 1);
for i = 1:4
    p_base = p_base_vals(i);
    p_down = p_base * (1 - pert);
    p_up   = p_base * (1 + pert);
    [r_d, Keff_d] = apply_perturbation(i, p_base_vals, p_down);
    [r_u, Keff_u] = apply_perturbation(i, p_base_vals, p_up);
    [r2_d, mae_d, ~] = calc_metrics(r_d, Keff_d, t_data, y_data, x0);
    [r2_u, mae_u, ~] = calc_metrics(r_u, Keff_u, t_data, y_data, x0);
    pert_data{i} = struct('r_d',r_d,'r_u',r_u,'Keff_d',Keff_d,'Keff_u',Keff_u,...
                          'r2_d',r2_d,'r2_u',r2_u,'mae_d',mae_d,'mae_u',mae_u);
end

colors = lines(4);

% Panel 1: R² Tornado
subplot(2,2,1); hold on;
r2_deltas = zeros(4,2);
for i = 1:4
    r2_deltas(i,:) = [pert_data{i}.r2_d - r2_base, pert_data{i}.r2_u - r2_base];
end
[~, order] = sort(abs(r2_deltas(:,2) - r2_deltas(:,1)));
for j = 1:4
    i = order(j);
    barh(j, r2_deltas(i,2), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.85);
    barh(j, r2_deltas(i,1), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.4);
end
set(gca, 'YTick', 1:4, 'YTickLabel', params(order));
xlabel('\Delta R^2'); xline(0,'k');
title(sprintf('R^2 Sensitivity (base=%.4f)', r2_base)); grid on;

% Panel 2: MAE Tornado
subplot(2,2,2); hold on;
mae_deltas = zeros(4,2);
for i = 1:4
    mae_deltas(i,:) = [pert_data{i}.mae_d - mae_base, pert_data{i}.mae_u - mae_base];
end
[~, order] = sort(abs(mae_deltas(:,2) - mae_deltas(:,1)));
for j = 1:4
    i = order(j);
    barh(j, mae_deltas(i,2), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.85);
    barh(j, mae_deltas(i,1), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.4);
end
set(gca, 'YTick', 1:4, 'YTickLabel', params(order));
xlabel('\Delta MAE (tons/day)'); xline(0,'k');
title(sprintf('MAE Sensitivity (base=%.1f)', mae_base)); grid on;

% Panel 3: r Tornado
subplot(2,2,3); hold on;
r_deltas = zeros(4,2);
for i = 1:4
    r_deltas(i,:) = [pert_data{i}.r_d - r_fit, pert_data{i}.r_u - r_fit];
end
[~, order] = sort(abs(r_deltas(:,2) - r_deltas(:,1)));
for j = 1:4
    i = order(j);
    barh(j, r_deltas(i,2), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.85);
    barh(j, r_deltas(i,1), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.4);
end
set(gca, 'YTick', 1:4, 'YTickLabel', params(order));
xlabel('\Delta r (1/day)'); xline(0,'k');
title(sprintf('r Sensitivity (base=%.6f)', r_fit)); grid on;

% Panel 4: K_eff Tornado
subplot(2,2,4); hold on;
Keff_deltas = zeros(4,2);
for i = 1:4
    Keff_deltas(i,:) = [pert_data{i}.Keff_d - K_eff_fit, pert_data{i}.Keff_u - K_eff_fit];
end
[~, order] = sort(abs(Keff_deltas(:,2) - Keff_deltas(:,1)));
for j = 1:4
    i = order(j);
    barh(j, Keff_deltas(i,2), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.85);
    barh(j, Keff_deltas(i,1), 0.55, 'FaceColor', colors(i,:), 'FaceAlpha', 0.4);
end
set(gca, 'YTick', 1:4, 'YTickLabel', params(order));
xlabel('\Delta K_{eff} (tons/day)'); xline(0,'k');
title(sprintf('K_{eff} Sensitivity (base=%.0f)', K_eff_fit)); grid on;

sgtitle(sprintf(['Q4: Sensitivity — Tornado Diagrams\n' ...
    '\\gamma=%.4f, \\beta=%.4f, \\alpha=%.4f, K=%d (±10%%)'], ...
    gamma_fixed, beta_fit, alpha_fit, K_fixed), 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_tornado_matlab.png');
fprintf('Saved: sensitivity_tornado_matlab.png\n');

% ==================== Figure 2: Envelope + Elasticity ====================
figure('Position', [30, 30, 1800, 500]);
t_smooth = linspace(0, 500, 400);
x_base = logistic(r_fit, K_eff_fit, t_smooth);

% Panel 1: Full envelope
subplot(1,3,1); hold on;
all_preds = zeros(8, length(t_smooth));
idx = 1;
for i = 1:4
    p_down = p_base_vals(i) * (1 - pert);
    p_up   = p_base_vals(i) * (1 + pert);
    [r_d, Keff_d] = apply_perturbation(i, p_base_vals, p_down);
    [r_u, Keff_u] = apply_perturbation(i, p_base_vals, p_up);
    all_preds(idx,:)   = logistic(r_d, Keff_d, t_smooth);
    all_preds(idx+1,:) = logistic(r_u, Keff_u, t_smooth);
    idx = idx + 2;
end
pred_min = min(all_preds); pred_max = max(all_preds);
fill([t_smooth, fliplr(t_smooth)], [pred_min, fliplr(pred_max)], ...
     [0.7 0.7 0.7], 'FaceAlpha', 0.25, 'EdgeColor', 'none', ...
     'DisplayName', '±10% envelope');
plot(t_smooth, x_base, 'k-', 'LineWidth', 2, 'DisplayName', 'Base');
scatter(t_data, y_data, 50, 'b', 'filled', 'DisplayName', 'Data');
scatter(0, x0, 70, 'g', 's', 'filled', 'DisplayName', sprintf('x_0=%d', x0));
yline(K_eff_fit, ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2);
yline(K_fixed, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);
xlabel('t (days)'); ylabel('Recovery (tons/day)');
title('Prediction Envelope (All Perturbations)');
legend('Location', 'se', 'FontSize', 7); grid on;

% Panel 2: Per-parameter bands
subplot(1,3,2); hold on;
param_colors = lines(4);
for i = 1:4
    p_down = p_base_vals(i) * (1 - pert);
    p_up   = p_base_vals(i) * (1 + pert);
    [r_d, Keff_d] = apply_perturbation(i, p_base_vals, p_down);
    [r_u, Keff_u] = apply_perturbation(i, p_base_vals, p_up);
    x_down = logistic(r_d, Keff_d, t_smooth);
    x_up   = logistic(r_u, Keff_u, t_smooth);
    fill([t_smooth, fliplr(t_smooth)], [x_down, fliplr(x_up)], ...
         param_colors(i,:), 'FaceAlpha', 0.12, 'EdgeColor', 'none', ...
         'DisplayName', sprintf('%s ±10%%', params{i}));
end
plot(t_smooth, x_base, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Base');
scatter(t_data, y_data, 30, 'b', 'filled');
xlabel('t (days)'); ylabel('Recovery (tons/day)');
title('Parameter-wise Prediction Bands');
legend('Location', 'se', 'FontSize', 8); grid on;

% Panel 3: Elasticity
subplot(1,3,3); hold on;
e_labels = {'ε(r,γ)', 'ε(r,β)', 'ε(K_{eff},α)', 'ε(K_{eff},K)'};
e_values = [1.0, eps_r_beta, eps_K_alpha, 1.0];
e_colors = lines(4);
bh = barh(1:4, e_values, 0.5);
for i = 1:4
    bh.FaceColor = 'flat';
    bh.CData(i,:) = e_colors(i,:);
    bh.FaceAlpha = 0.85;
end
set(gca, 'YTick', 1:4, 'YTickLabel', e_labels);
xline(0, 'k'); xlabel('Elasticity ε');
title('Analytical Elasticities'); grid on;
for i = 1:4
    if e_values(i) >= 0
        text(e_values(i)+0.05, i, sprintf('%+.4f', e_values(i)), ...
            'VerticalAlignment', 'middle', 'FontWeight', 'bold');
    else
        text(e_values(i)-0.05, i, sprintf('%+.4f', e_values(i)), ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'right', 'FontWeight', 'bold');
    end
end

sgtitle('Q4: Prediction Envelope & Elasticity Overview', ...
    'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_envelope_matlab.png');
fprintf('Saved: sensitivity_envelope_matlab.png\n');

fprintf('\nQ4 MATLAB sensitivity analysis complete.\n');

% ==================== Helper Functions ====================
function [r, Keff] = apply_perturbation(idx, base_vec, new_val)
    % idx: 1=gamma, 2=beta, 3=alpha, 4=K
    v = base_vec;
    v(idx) = new_val;
    r    = v(1) / (1 + v(2));        % gamma / (1+beta)
    Keff = v(4) * (1 + v(3));        % K * (1+alpha)
end

function [r2, mae, rmse] = calc_metrics(r, Keff, t_data, y_data, x0)
    yp = Keff ./ (1 + (Keff/x0 - 1) .* exp(-r * t_data));
    res = y_data - yp;
    ss_res = sum(res.^2);
    ss_tot = sum((y_data - mean(y_data)).^2);
    r2  = 1 - ss_res / ss_tot;
    mae = mean(abs(res));
    rmse = sqrt(mean(res.^2));
end
