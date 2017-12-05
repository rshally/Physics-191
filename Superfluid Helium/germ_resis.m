function [I, T_fun_log] = germ_resis(data_folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns the temperature dependence on resistance of the germanium resistor
% Inputs: - datafolder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load in data for P and V
PVdata = dlmread(fullfile(data_folder,'Ge_Resistor.txt'));
% col 1: Pressure
% col 2: Voltage

% Convert P to T
T = P_to_T(data_folder, PVdata(:,1))';

% Find current applied:
V10k = 10.257e-3;
R10k = 10e3;
I = V10k/R10k;

% Covert voltage measurement to resistance:
R = PVdata(:,2)/I;

% Create Polynomial fit according to White P. 111
m = round(size(PVdata,1)/4);
T_fun_log = polyfit(log(R),log(T),m);

% Evaluate polynomial fit:
R_vals = linspace(min(R), max(R), 1000);
T_vals = exp(polyval(T_fun_log,log(R_vals)));

% Plot T vs. R with fit
figure
plot(R/1000, T,'bo')
hold on
plot(R_vals/1000, T_vals,'r')
xlim([0, max(R/1000)])
title('Resistance vs. Temperature')
xlabel('Resistance of Ge Resistor (kilo-Ohms)')
ylabel('Temperature (K)')
legend('Data','Fit')

%%%% Need to do:
% 1. Determine relationship between pressure and temperature of the helium gas
% 2. Convert voltage measurement to resistance measurements
% 3. Determine relationship between resistance and temperature

% Ge --> p. 106



end

