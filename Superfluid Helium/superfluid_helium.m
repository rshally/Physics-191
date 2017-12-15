%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main file to perform superfluid helium calculations
set(0,'defaultAxesFontSize',20)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_folder = 'Superfluid Helium Data';

%% Germanium Resistor Calibration
[I, T_fun_log] = germ_resis(data_folder);


%% Heat Capacity Measurements
% Script to analyze heat capacity data
[hc_data_addendum, addendum_model, Td] = heat_cap(data_folder, 'addendum', T_fun_log, I);
hc_data_full = heat_cap(data_folder, 'heat_cap', T_fun_log, I);

% Extract only helium component
hc_data_He = hc_he_extract(hc_data_full, addendum_model);

% Calculate lambda point and plot combination of HC data for He
[lambda] = calc_lambdas(hc_data_He);

% Plot the heat capacity data along with models:
plot_hc_data(lambda, hc_data_He)

% Copper model:
A0 = 0.69142;
A1 = 0.047807;
A2 = 2.9721*10^-6;
A3 = 8.9189*10^-8;
coeff = [A3, 0, A2, 0, A1, 0, A0, 0];



