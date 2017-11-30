function T_fun = germ_resis(data_folder)
% Returns the temperature dependence on voltage over the germanium resistor

% Load in data for P and V
PVdata = dlmread(fullfile(data_folder,'Ge_Resistor.txt'));
% col 1: Pressure
% col 2: Voltage


% Find current applied:
V10k = 10.257e-3;
R10k = 10e3;
I = V10k/R10k;

% Covert voltage measurement to resistance:
Resis = PVdata(:,2)/I;

% Create Model --> 1/T model
ft = fittype('a/x + b');
[f, gof] = fit(PVdata(:,1),Resis,ft);

% Plot P vs. V with fit
figure
plot(PVdata(:,1), PVdata(:,2),'bo')
hold on
plot(f,'r')
title('Voltage of Ge Resistor over Pressures')
xlabel('Pressure (mmHg)')
ylabel('Voltage over Ge Resistor (V)')
legend('Data','Fit')

%%%% Need to do:
% 1. Determine relationship between pressure and temperature of the helium gas
% 2. Convert voltage measurement to resistance measurements
% 3. Determine relationship between resistance and temperature

% Ge --> p. 106



end

