function [locs, pks, f] = calc_peaks(filename, pathname)
% PURPOSE: reads in data from a chosen file and analyzes T1 or T2
% INPUTS: (varargin) - can input a filename for direct calculation

% Parse out filename to determine what to do
% General format: 1_2_3_4
% 1: T1 or T2
% 2: Date in format MMDD
% 3: Measurement operations (choices: CP (carr-purcell), MG (Meiboom-Gill),
% D (Discrete, i.e. for T1 usually), S (signal analysis)
% 4: Sample name (LMO, Fluor, DW)
C = strsplit(filename,'_');
T = C{1};
date = C{2};
method = C{3};
sample = C{4};

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% TO DO:
% Flipping values for T1 measurements? How to determine when a value is on
% the left side or the right side of the y=0 point intersection.....
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%



%% Reading in file
if isdir(filename)
    number = 'multi';
else
    number = 'single';
end
[t,V] = read_data(filename, pathname, number);

% dt and Sample Rate
dt = t(2) - t(1);
Fs = 1/dt;

% Find peaks
minD = .9e-3; % for smallest tau of 1msec
minH = 0.5;
[pks, locs] = findpeaks(V, t, 'MinPeakDistance', minD, 'MinPeakHeight', minH);

% First peak at t = 0 + tau
tau_1 = 1e-4; % First pulse tau (i.e. this long has passed before first peak)
[~, t0idx] = min(abs(t - (locs(1) - tau_1)));
locs = locs - t(t0idx);
t = t - t(t0idx);


%% Step 3: Use the exponential to calculate T1 or T2
switch T
    case 'T1' % Case 1: Calculate T1
        T1 = 1/f.b;
        fprintf('T1 = %.4f sec\n',T1)
    case 'T2' % Case 2: Calculate T2
        T2 = 1/f.b;
        fprintf('T2 = %.4f sec\n',T2)
end


% Fitting based on T1 or T2 measurement
switch T
    case 'T1' % T1 Calculation
        % Calculate exponential fit and plot on top
        fops = fitoptions;
        ft = fittype('a*abs(1-2*exp(b*x))');
        f = fit(ttot, yupper, ft);
        plot(f)
        T1 = 1/f.b;
        fprintf('T1 = %.4f sec\n',T1)
    case 'T2' % T2 Calculation
        
        % Throw away certain peaks
        % % %         pks(2:2:end) = [];
        % % %         locs(2:2:end) = [];
        pks(1) = [];
        locs(1) = [];
        
        % Generating Fit
        ft = fittype('a*exp(b*x)');
        f = fit(locs, pks, ft);
        
        % Plotting voltage function with peaks
        figure
        plot(f,locs,pks)
        hold on
        plot(t,V)
        title('Voltage Plot with Peak Voltages Identified')
        xlabel('time (s)')
        ylabel('Voltage (V)')

        % Calculate T2 Value
        T2 = 1/f.b;
        fprintf('T2 = %.4f sec\n',T2)
end



end



