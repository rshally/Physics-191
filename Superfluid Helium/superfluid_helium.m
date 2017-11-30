% Main file to perform superfluid helium calculations
data_folder = 'Superfluid Helium Data';

%% Germanium Resistor Calibration
T_fun = germ_resis(data_folder);


%% Heat Capacity Measurements
% Script to analyze heat capacity data

% Load Data
fname = fullfile(data_folder, 'addendum_1.txt');
data = dlmread(fname);
% Col 1: voltage
% Col 2: not needed
% Col 3: time

