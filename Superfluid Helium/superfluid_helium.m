% Main file to perform superfluid helium calculations
data_folder = 'Superfluid Helium Data';

%% Germanium Resistor Calibration
[I, T_fun_log] = germ_resis(data_folder);


%% Heat Capacity Measurements
% Script to analyze heat capacity data
[hc_data_addendum, addendum_model, Td] = heat_cap(data_folder, 'addendum', T_fun_log, I);
hc_data_full = heat_cap(data_folder, 'heat_cap', T_fun_log, I);

% Calculate lambda point and plot combination of HC data for He
lambda = calc_lambdas(hc_data_full, addendum_model);

% Compute the mass of gas in chamber: PV = nRT
R = 0.082057; % L atm mol^-1 K^-1
Troom = 298; % K
P1 = .2 * 0.068046; % psi to atm
P2 = -10 * 0.0334211; % inches Hg to atm
delN = (P1 - P2)/(R*Troom);
massHe = delN * 4; % convert moles to grams

% Convert heat capacity to specific heat




