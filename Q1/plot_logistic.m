% ==================== Fixed Parameters (from 基础固定参数.md) ====================
K     = 8011;     % saturation capacity (tons/day)
gamma = 0.022;    % intrinsic growth rate (1/day)
x0    = 6314;     % initial recovery (tons/day)

% Derived constant
A = K / x0 - 1;   % 0.26877

% ==================== Measured Data ====================
t_data = [0, 30, 60, 90, 120, 150, 180, 270, 365];
y_data = [6314, 6542, 6875, 7173, 7368, 7591, 7724, 7896, 8002];

% ==================== Logistic Model ====================
% x(t) = K / (1 + (K/x0 - 1) * exp(-gamma * t))
logistic = @(t) K ./ (1 + A * exp(-gamma * t));

% ==================== Predictions & Metrics ====================
y_pred = logistic(t_data);
residuals = y_data - y_pred;

ss_res = sum(residuals.^2);
ss_tot = sum((y_data - mean(y_data)).^2);
r2  = 1 - ss_res / ss_tot;
mae = mean(abs(residuals));
rmse = sqrt(mean(residuals.^2));
mape = mean(abs(residuals ./ y_data)) * 100;

fprintf('========================================\n');
fprintf('  Logistic Model (Zero Free Params)\n');
fprintf('========================================\n');
fprintf('  K = %d, gamma = %.3f, x0 = %d\n', K, gamma, x0);
fprintf('  A = K/x0-1 = %.5f\n', A);
fprintf('  R^2 = %.4f, MAE = %.1f, RMSE = %.1f, MAPE = %.2f%%\n', ...
        r2, mae, rmse, mape);
fprintf('========================================\n');

% ==================== Smooth Curve ====================
t_smooth = linspace(0, 500, 400);
x_smooth = logistic(t_smooth);

% ==================== Figure 1: Main Fit ====================
figure('Position', [100, 100, 1400, 550]);

% --- Left: Model curve + data ---
subplot(1, 2, 1);
hold on;

% Sensitivity band (gamma +/- 10%)
gamma_lo = gamma * 0.9;
gamma_hi = gamma * 1.1;
A_lo = K / x0 - 1;  % same A since x0, K fixed
x_lo = K ./ (1 + A_lo * exp(-gamma_lo * t_smooth));
x_hi = K ./ (1 + A_lo * exp(-gamma_hi * t_smooth));
fill([t_smooth, fliplr(t_smooth)], [x_lo, fliplr(x_hi)], ...
     [0.85, 0.85, 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.6, ...
     'DisplayName', '\gamma \pm 10\%');

% Main logistic curve
plot(t_smooth, x_smooth, 'r-', 'LineWidth', 2.5, ...
     'DisplayName', sprintf('x(t) = K/(1+Ae^{-\\gamma t})'));

% Data points
scatter(t_data, y_data, 70, 'b', 'filled', ...
        'DisplayName', 'Measured data');

% Saturation line
yline(K, 'k--', 'LineWidth', 1.5, ...
      'DisplayName', sprintf('K = %d', K));

% Initial point (forced)
scatter(0, x0, 100, 'g', 's', 'filled', ...
        'DisplayName', sprintf('x_0 = %d (fixed)', x0));

xlabel('Time t (days)', 'FontSize', 12);
ylabel('Recovery Amount x(t) (tons/day)', 'FontSize', 12);
title(sprintf('Logistic Growth Model  (R^2 = %.4f)', r2), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 9);
grid on;
hold off;

% --- Right: Residuals ---
subplot(1, 2, 2);
hold on;

% Zero line
yline(0, 'k-', 'LineWidth', 1);

% Residual stems
stem(t_data, residuals, 'b', 'LineWidth', 2, 'MarkerSize', 8, ...
     'Color', [0.1, 0.4, 0.8]);

% MAE band
yline( mae, 'r--', 'LineWidth', 1.2);
yline(-mae, 'r--', 'LineWidth', 1.2, ...
      'DisplayName', sprintf('MAE = %.1f', mae));

% Color-code: positive vs negative
hold on;
for i = 1:length(t_data)
    if residuals(i) >= 0
        c = [0.2, 0.7, 0.2];  % green: model under-predicts
    else
        c = [0.9, 0.2, 0.2];  % red: model over-predicts
    end
    stem(t_data(i), residuals(i), 'LineWidth', 2, 'MarkerSize', 8, ...
         'Color', c, 'MarkerFaceColor', c);
end

xlabel('Time t (days)', 'FontSize', 12);
ylabel('Residual (tons/day)', 'FontSize', 12);
title(sprintf('Residuals  (RMSE = %.1f, MAPE = %.2f%%)', rmse, mape), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
hold off;

saveas(gcf, 'logistic_fit_matlab.png');
fprintf('Saved: logistic_fit_matlab.png\n');

% ==================== Figure 2: Phase Analysis ====================
figure('Position', [100, 100, 900, 600]);
hold on;

% Plot smooth curve
plot(t_smooth, x_smooth, 'b-', 'LineWidth', 2.5);
% Plot data with residual coloring
for i = 1:length(t_data)
    if residuals(i) >= 0
        scatter(t_data(i), y_data(i), 80, [0.2, 0.7, 0.2], 'filled', 'o');
    else
        scatter(t_data(i), y_data(i), 80, [0.9, 0.2, 0.2], 'filled', 'o');
    end
end
yline(K, 'k--', 'LineWidth', 1.5);

% Phase dividers
xline(60,  ':', 'LineWidth', 1.2, 'Alpha', 0.5);
xline(180, ':', 'LineWidth', 1.2, 'Alpha', 0.5);

% Phase labels
yl = ylim;
y_mid = K + (yl(2) - K) * 0.6;
text(25,  y_mid, 'Phase I\nInitiation',   'FontSize', 11, 'HorizontalAlign', 'center', ...
     'Color', [0.3 0.3 0.3], 'FontWeight', 'bold');
text(120, y_mid, 'Phase II\nRapid Growth', 'FontSize', 11, 'HorizontalAlign', 'center', ...
     'Color', [0.3 0.3 0.3], 'FontWeight', 'bold');
text(320, y_mid, 'Phase III\nSaturation',  'FontSize', 11, 'HorizontalAlign', 'center', ...
     'Color', [0.3 0.3 0.3], 'FontWeight', 'bold');

xlabel('Time t (days)', 'FontSize', 12);
ylabel('Recovery Amount x(t) (tons/day)', 'FontSize', 12);
title(sprintf('Logistic Growth: Three-Phase Analysis  (\\gamma = %.3f)', gamma), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend({'Model x(t)', 'Under-predicted (res>0)', 'Over-predicted (res<0)', ...
        sprintf('K = %d', K)}, ...
        'Location', 'southeast', 'FontSize', 9);
grid on;
hold off;

saveas(gcf, 'logistic_phases_matlab.png');
fprintf('Saved: logistic_phases_matlab.png\n');
