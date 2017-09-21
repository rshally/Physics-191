% Main file for calculating envelopes, T1, and T2


%% Step 0: Static set up of all file inputs for automatic processing
pathname = 'All Data';
filename = [];

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
for n = 1:length(filename)
    C = strsplit(filename{n},'_');
    method = C{3};
    switch method
        case 'S' % Signal Analysis
            [P1] = fft_nmr(filename{n}, pathname);
        otherwise
            [locs,pks,f] = calc_peaks(filename{n}, pathname);
    end
end