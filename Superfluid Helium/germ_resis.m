function T_fun = germ_resis(data_folder)
% Returns the temperature dependence on voltage over the germanium resistor

% Load in data for P and V
PVdata = dlmread(fullfile(data_folder,'Ge_Resistor.txt'));
% col 1: Pressure
% col 2: Voltage


% Temporarily plot P vs. V
figure
plot(PVdata(:,1), PVdata(:,2),'bo')
title('Voltage of Ge Resistor over Pressures')
xlabel('Pressure (mmHg)')
ylabel('Voltage over Ge Resistor (V)')

% Create Model --> 1/T model
ft = fittype('a/x');
[f, gof] = fit(x,y,ft)



end

