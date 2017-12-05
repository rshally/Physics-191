function T = P_to_T(data_folder, P_data)
%%%%%
% Inputs:
% data_folder - the folder where the He_P_to_T file is stored
% P_data - pressure data in units of mmHg or Torr
%%%%%

% Converts pressure to temperature values based on model fit:
PTdata = csvread(fullfile(data_folder,'He_P_to_T.csv'));
ft = fittype('a/x + b*log(x) + c');
[f, gof] = fit(PTdata(:,2), log(PTdata(:,1)), ft, 'StartPoint',[-10 1, 4] );

% Determine T value for given P value
T = zeros(1, length(P_data));
for n = 1:length(P_data)
    objective = @(x) f(x) - log(P_data(n));
    T(n) = fzero(objective, 3);
end

