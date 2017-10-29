% Main file for calculating envelopes, T1, and T2


%% Step 0: Static set up of all file inputs for automatic processing
pathname = 'All Data';
filename = [];
T_ci = [];

% Suppress figure output
sup = 0;
if sup
   set(0,'DefaultFigureVisible','off') 
else
   set(0,'DefaultFigureVisible','on')
end

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
% 1b - T1
filename{end+1} = 'T1_0919_D_H2O';
% % 2b - T2, tau = 
filename{end+1} = 'T2_0919_MG_H2O_tau1.csv';
% % 2c - T2, tau = 
filename{end+1} = 'T2_0919_MG_H2O_tau2.csv';
% 
% %%%%%%%%%%%%
% % Third: Fluorine
% % 3a - Frequency
filename{end+1} = 'T2_0921_S_Fluor.csv';
% % 3b - T1
filename{end+1} = 'T1_0921_D_Fluor';
% % 3c - T2, tau = 
filename{end+1} = 'T2_0921_MG_Fluor_tau1.csv';
% % % 3d - T2, tau = 
filename{end+1} = 'T2_0921_MG_Fluor_tau2.csv';


%% Step 2: Find envelope signals in these files and return exponential fit
for n = 1:length(filename)
    fprintf('File: %s\n',filename{n})
    C = strsplit(filename{n},'_');
    method = C{3};
    switch method
        case 'S' % Signal Analysis
            [P1] = fft_nmr(filename{n}, pathname);
        otherwise
            [T{n}, adjr2{n}, T_ci(n,:), f{n}, x{n}, y{n}, t{n}, V{n},...
                main_title{n}] = calc_peaks(filename{n}, pathname);
    end
    %pause(2)
end
new_figs = 1;
if new_figs
    make_new_figs(f, x, y, t, V, main_title)
end
    
        
% Generate table of results
% Restrict to 4 decimal places
filename = regexprep(filename,'.csv','');
TAB = table(filename(:), T(:), T_ci(:,1), T_ci(:,2), 'VariableNames', {'Filename','T_Value','CI_Lower', 'CI_Upper'})

