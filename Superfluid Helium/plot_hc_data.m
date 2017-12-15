function plot_hc_data(lambda, hc_data_He)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tlam = 2.17;
%Tlam = lambda.mean;


%% Plot my heat capacity data and create model
T_all = vertcat(hc_data_He.T{:});
Cs_all = vertcat(hc_data_He.Cs{:});

% Plot original heat capacity data
figure; cla; hold on
cellfun(@(T, C) plot(T, C), hc_data_He.T, hc_data_He.Cs)
title('Specific Heat of Helium II')
xlabel('Temperature [K]')
ylabel('C_p   [J mol^{-1} K^{-1}]')
xlim([min(T_all) - .2, max(T_all)+.2])

% Create models on either side of Tlam
ft = fittype('(A/alpha)*abs(x)^(-alpha) - 1 + B + D*x*log(abs(x)) + E*x');
[Cp_1_mdl, gof1] = fit(T_all(T_all<=Tlam)/Tlam - 1, Cs_all(T_all<=Tlam), ft,'StartPoint',[1,1,1,1,1]);
[Cp_2_mdl, gof2] = fit(T_all(T_all>=Tlam)/Tlam - 1, Cs_all(T_all>=Tlam), ft,'StartPoint',[1,1,1,1,1]);

% Plotting models on top of HC data
h = figure;
h1 = plot(Cp_1_mdl, T_all(T_all<Tlam)/Tlam -1 , Cs_all(T_all<Tlam),'predfunc', .95);
set(h1,'LineWidth', 1.5)
set(h1, 'MarkerSize', 10)
hold on
h2 = plot(Cp_2_mdl, T_all(T_all>Tlam)/Tlam -1 , Cs_all(T_all>Tlam), 'predfunc', .95);
set(h2,'LineWidth', 1.5)
set(h2, 'MarkerSize', 10)
legend('Exp. Data', 'Logarithmic Model')
title('Specific Heat of Helium II')
xlabel('T/T_{\lambda} - 1')
ylabel('C_p   [J mol^{-1} K^{-1}]')

fig_file = 'Saved_Figures/HC_He_Fit.eps';
saveas(gcf, fig_file,'epsc')
fig_file = 'Saved_Figures/JPEG/HC_He_Fit.jpeg';
saveas(gcf, fig_file,'jpeg')

%% Model from Ahlers paper near lambda temperature
% Plot the theoretical model for heat capacity
eps_1 = linspace(-1e-2,1e-6,100);
eps_2 = linspace(0,1e-2,10000);

% Model parameters:
alpha = [0, -0.02];
A = [5.355, 6.081];
B = [-7.773, 11.345];

md1_func = @(x) (A(2)/alpha(2))*(abs(x).^(-alpha(2)) - 1) + B(2);
md2_func = @(x) -A(1)*log(abs(x)) + B(1);

md1 = (A(2)/alpha(2))*(abs(eps_1).^(-alpha(2)) - 1) + B(2);
md2 = -A(1)*log(abs(eps_2)) + B(1);

% Plot Ahlers model
figure
plot(eps_1, Cp_1_mdl(eps_1), 'b', eps_1, md1, 'r', 'LineWidth',2)
hold on
plot(eps_2(2:end), Cp_2_mdl(eps_2(2:end)), 'b', eps_2, md2, 'r', 'LineWidth',2)
title('Specific Heat of Helium II Near T_{\lambda}')
xlabel('T/T_{\lambda} - 1')
ylabel('C_p [J mol^{-1} K^{-1}]')
legend('Our Work','Ahlers (1970)')

fig_file = 'Saved_Figures/HC_Ahlers_Fit.eps';
saveas(gcf, fig_file, 'epsc')
fig_file = 'Saved_Figures/JPEG/HC_Ahlers_Fit.jpeg';
saveas(gcf, fig_file, 'jpeg')


%% Do an analysis of the two models near the lambda point
% Compute standard errors?
Cps_data = [Cp_1_mdl(eps_1); Cp_2_mdl(eps_2)];
ahlers_data = [md1, md2]';

% Remove NaN data
ahlers_data(isnan(Cps_data)) = [];
Cps_data(isnan(Cps_data))= [];

% Calculate standard error
mse = immse(Cps_data, ahlers_data);

% Root mean square error
rmse = sqrt(mse);
fprintf('RMSE of our model against Ahlers: %.4f\n', rmse)

%% Get independent data and comput performance:
ind_data = get_independent_data;

T_ind = ind_data(:,1);
C_ind = ind_data(:,2);

% Get their own Tlam value
[~, maxIdx] = max(C_ind);
Tlam_ind = T_ind(maxIdx);
fprintf('Lambda Point for Reference Model:\n')
disp(Tlam_ind)

% Convert temperature value:
T_ind2 = T_ind/Tlam_ind - 1;

% Remove points close to lambda point
C_ind(abs(T_ind2) < 1e-4) = [];
T_ind2(abs(T_ind2) < 1e-4) = [];

T_ind_L = T_ind2(T_ind2<0);
C_ind_L = C_ind(T_ind2<0);

T_ind_R = T_ind2(T_ind2>0);
C_ind_R = C_ind(T_ind2>0);


data_full_ind = [C_ind_L;C_ind_R];
% Get out our prediction on these temperatures
Cps_data_ind = [Cp_1_mdl(T_ind_L); Cp_2_mdl(T_ind_R)];
CPS_mse = immse(Cps_data_ind, data_full_ind);
rmse1 = sqrt(CPS_mse);
[R1, p1] = corrcoef(Cps_data_ind, data_full_ind);
R1sq = R1(1,2)^2;
fprintf('My model RMSE from the reference data set: %.4f\n', rmse1)
fprintf('My model R Squared from reference: %.4f\n', R1sq)

% Get ahlers predictions on this data
ah_data_ind = [md1_func(T_ind_L); md2_func(T_ind_R)];
AH_mse = immse(ah_data_ind, data_full_ind);
rmse2 = sqrt(AH_mse);
[R2, p2] = corrcoef(ah_data_ind, data_full_ind);
R2sq = R2(1,2)^2;
fprintf('Ahlers model RMSE from the reference data set: %.4f\n', rmse2)
fprintf('Ahlers model R Squared from reference: %.4f\n', R2sq)


end

