% Main file for calculating envelopes, T1, and T2


%% Step 0: Static set up of all file inputs for automatic processing
pathname = 'All Data';
filename = cell;

%%%%%%%%%%%%
% First: LMO Data
% 1a - T1
filename{1} = 'T1_0914_D_LMO';
% 1b - T2 CP
filename{end+1} = 'T2_0914_CP_LMO.csv';
% 1b - T2 MG
filename{end+1} = 'T2_0914_MG_LMO.csv';

%%%%%%%%%%%%
% Second: Distilled Water


%%%%%%%%%%%%
% Third: Fluorine
filename{end+1} = 'T2_0921_S_Fluor.csv';




% % % % % %% Step 1: Determine which files to run analysis
% % % % % datafldr = 'Mineral Light Data';
% % % % % [filename, pathname] = uigetfile(strcat(datafldr,'/*.csv'),'MultiSelect','on');
% % % % % filename = cellstr(filename);


%% Step 2: Find envelope signals in these files and return exponential fit
% T = 'T1';
T = 'T2';

% Run with different options based on number of files selected
if length(filename)==1
    [locs, pks, f] = calc_peaks(filename{1}, pathname, 'single', T);
else
    [t, V, f] = calc_peaks(filename, pathname, 'multi', T);
end


%% Step 3: Use the exponential to calculate T1 or T2
switch T
    case 'T1' % Case 1: Calculate T1
        T1 = 1/f.b;
        fprintf('T1 = %.4f sec\n',T1)
    case 'T2' % Case 2: Calculate T2
        T2 = 1/f.b;
        fprintf('T2 = %.4f sec\n',T2)
end


