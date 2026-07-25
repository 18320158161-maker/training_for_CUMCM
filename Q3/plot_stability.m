% ==================== Fixed Parameters ====================
K     = 8011;     gamma = 0.022;     x0 = 6314;

% ==================== Measured Data ====================
t_data = [0, 30, 60, 90, 120, 150, 180, 270, 365];
y_data = [6314, 6542, 6875, 7173, 7368, 7591, 7724, 7896, 8002];

% ==================== Fit (same as Q2) ====================
logistic = @(p, t) p(2) ./ (1 + (p(2)/x0 - 1) .* exp(-p(1) * t));
cost = @(p) sum((logistic(p, t_data) - y_data).^2) + ...
            1e6 * max(0, p(1) - gamma)^2 + 1e6 * max(0, K - p(2))^2;
p_opt = fminsearch(cost, [0.01, 8100]);
r_fit = min(p_opt(1), gamma);  K_eff_fit = max(p_opt(2), K);
beta_fit  = gamma / r_fit - 1;  alpha_fit = K_eff_fit / K - 1;

fprintf('========== Q3 STABILITY ==========\n');
fprintf('r=%.6f, K_eff=%.1f, alpha=%.6f, beta=%.6f\n', r_fit, K_eff_fit, alpha_fit, beta_fit);
fprintf('x1*=0 (UNSTABLE), x2*=%.1f (STABLE)\n', K_eff_fit);
fprintf('Structural stability: r>0 always for alpha,beta>=0\n');
fprintf('===================================\n');

t_smooth = linspace(0, 500, 400);
x_fit = logistic(p_opt, t_smooth);
r_min = 0.005;  beta_max = gamma/r_min - 1;

% ==================== Figure 1 ====================
figure('Position', [30, 30, 1800, 1000]);

% 1: Fit
subplot(3, 3, 1); hold on;
r_lo=r_fit*0.9; r_hi=r_fit*1.1;
fill([t_smooth, fliplr(t_smooth)], ...
     [logistic([r_lo,K_eff_fit],t_smooth), fliplr(logistic([r_hi,K_eff_fit],t_smooth))], ...
     [0.85 0.85 0.85], 'EdgeColor','none','FaceAlpha',0.5);
plot(t_smooth, x_fit, 'r-', 'LineWidth', 2.5);
scatter(t_data, y_data, 70, 'b', 'filled');
yline(K_eff_fit, 'r--', 'LineWidth', 1.2); yline(K, 'k:', 'LineWidth', 1.2);
xlabel('t (days)'); ylabel('x(t)');
title(sprintf('Fit: r=%.4f, K_{eff}=%.0f', r_fit, K_eff_fit)); grid on;

% 2: Phase Portrait
subplot(3, 3, 2); hold on;
x_range = linspace(-200, K_eff_fit*1.2, 500);
dxdt = r_fit * x_range .* (1 - x_range/K_eff_fit);
plot(x_range, dxdt, 'b-', 'LineWidth', 2); yline(0,'k-'); xline(0,'k-');
scatter(0,0,120,'r','o','filled','MarkerEdgeColor','k');
scatter(K_eff_fit,0,120,'g','s','filled','MarkerEdgeColor','k');
for xp = linspace(300,K_eff_fit*0.7,4)
    quiver(xp,0,200,0,'r','LineWidth',2,'MaxHeadSize',0.5,'AutoScale','off');
end
for xp = linspace(K_eff_fit+500,K_eff_fit*1.15,3)
    quiver(xp,0,-200,0,'r','LineWidth',2,'MaxHeadSize',0.5,'AutoScale','off');
end
xlabel('x'); ylabel('dx/dt');
title(sprintf('Phase Portrait (r=%.4f>0, stable)', r_fit)); grid on;

% 3: Trajectories
subplot(3, 3, 3); hold on;
t_traj = linspace(0,500,400);
ics = [1000,4000,6314,9000,14000]; colors = lines(length(ics));
for j=1:length(ics)
    xt=zeros(1,length(t_traj)); xt(1)=ics(j);
    for i=2:length(t_traj)
        dt=t_traj(i)-t_traj(i-1);
        xt(i)=xt(i-1)+r_fit*xt(i-1)*(1-xt(i-1)/K_eff_fit)*dt;
    end
    plot(t_traj,xt,'Color',colors(j,:),'LineWidth',1.5,'DisplayName',sprintf('x_0=%d',ics(j)));
end
yline(K_eff_fit,'g--','LineWidth',1.5);
xlabel('t (days)'); ylabel('x(t)');
title('All x_0>0 converge to K_{eff}'); legend('Location','se','FontSize',7); grid on;

% 4: K_eff vs alpha (alpha >= 0 only)
subplot(3, 3, 4); hold on;
alpha_vals = linspace(0, alpha_fit+0.3, 200);
plot(alpha_vals, K*(1+alpha_vals), 'b-', 'LineWidth', 2.5);
yline(K, 'k:', 'LineWidth', 1);
scatter(alpha_fit, K_eff_fit, 120, 'r', '*', 'LineWidth', 1.5);
xlabel('\alpha (\geq 0)'); ylabel('K_{eff}');
title(sprintf('K_{eff}=K(1+\\alpha), \\alpha\\geq0')); grid on;

% 5: r vs beta (beta >= 0 only)
subplot(3, 3, 5); hold on;
beta_vals = linspace(0, max(beta_fit*2.2, beta_max*1.2), 200); r_vals = gamma./(1+beta_vals);
plot(beta_vals, r_vals, 'r-', 'LineWidth', 2.5);
yline(gamma, 'k:', 'LineWidth', 1); yline(r_min, '--', 'Color', [1 0.5 0], 'LineWidth', 1.5);
scatter(beta_fit, r_fit, 120, 'b', '*', 'LineWidth', 1.5);
idx = r_vals>=r_min;
fill([beta_vals(idx), fliplr(beta_vals(idx))], [r_vals(idx), r_min*ones(1,sum(idx))], ...
     'g', 'FaceAlpha', 0.08, 'EdgeColor', 'none');
fill([beta_vals(~idx), fliplr(beta_vals(~idx))], [r_vals(~idx), r_min*ones(1,sum(~idx))], ...
     [1 0.5 0], 'FaceAlpha', 0.08, 'EdgeColor', 'none');
xlabel('\beta (\geq 0)'); ylabel('r');
title(sprintf('r=\\gamma/(1+\\beta), operational: \\beta\\leq%.2f', beta_max)); grid on;

% 6: Safe region
subplot(3, 3, 6); hold on;
[AA,BB] = meshgrid(linspace(0,alpha_fit+0.5,100), linspace(0,max(beta_fit*2,beta_max*1.2),100));
R_grid = gamma./(1+BB);
contourf(AA,BB,R_grid>=r_min, [0 0.5 1], 'FaceAlpha', 0.5);
colormap(gca, [1 0.85 0.8; 0.8 1 0.8]);
contour(AA,BB,R_grid,[r_min r_min],'--','Color',[1 0.5 0],'LineWidth',2);
scatter(alpha_fit,beta_fit,200,'b','*','LineWidth',1.5);
xlabel('\alpha (\geq 0)'); ylabel('\beta (\geq 0)');
title(sprintf('Safe Region: r\\geq%.3f (\\beta\\leq%.2f)', r_min, beta_max)); grid on;

% 7: Decoupled view (spans full row)
subplot(3, 3, [7, 8, 9]); hold on;
yyaxis left;
plot(alpha_vals, K*(1+alpha_vals)/K, 'b-', 'LineWidth', 2);
ylabel('K_{eff}/K'); ylim([0.95, 1.35]);
yyaxis right;
plot(beta_vals, gamma./(1+beta_vals)/gamma, 'r-', 'LineWidth', 2);
ylabel('r/\gamma'); ylim([0, 1.05]);
xlabel('\alpha (blue) / \beta (red)');
title('Decoupled: \alpha->K_{eff}, \beta->r'); grid on;

sgtitle(sprintf(['Q3 Stability: \\alpha=%.4f, \\beta=%.2f, r=%.4f, K_{eff}=%.0f\n' ...
    'Structurally Stable — no bifurcation for \\alpha,\\beta\\geq0'], ...
    alpha_fit, beta_fit, r_fit, K_eff_fit), 'FontSize',14,'FontWeight','bold');
saveas(gcf, 'stability_matlab.png');
fprintf('Saved: stability_matlab.png\n');
