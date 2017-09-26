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
if isdir(['All Data/',filename])
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

% Pad with a zero at the end
V(end+1) = 0;
t(end+1) = t(end) + dt;
[pks, locs] = findpeaks(V, t, 'MinPeakDistance', minD, 'MinPeakHeight', minH);

% First peak at t = 0 + tau
tau_1 = 1e-4; % First pulse tau (i.e. this long has passed before first peak)
[~, t0idx] = min(abs(t - (locs(1) - tau_1)));
locs = locs - t(t0idx);
t = t - t(t0idx);


%% Step 3: Use the exponential to calculate T1 or T2
% Show shifted peaks

% Fitting based on T1 or T2 measurement
switch T
    case 'T1' % T1 Calculation
        
        switch filename
            case 'T1_0914_D_LMO'
                flip_t = 0.0325;
            otherwise
                flip_t = 0;
        end
                
        % Flip values at t<flip_t
        V(t<flip_t) = -1*V(t<flip_t);
        pks(locs<flip_t) = -1*pks(locs<flip_t);
        
        % Generating Fit
        ft = fittype('a*(1-2*exp(b*x))');
        f = fit(locs, pks, ft);
        
        % Plotting fit
        % Plotting voltage function with peaks
        figure
        plot(f,locs,pks)
        hold on
        plot(t,V)
        title('Voltage Plot with Peak Voltages Identified')
        xlabel('time (s)')
        ylabel('Voltage (V)')
        
        % Calculating T1
        T1 = 1/f.b;
        fprintf('T1 = %.4f sec\n',T1)
        
    case 'T2' % T2 Calculation
        % Manually setting the zero point
        zero_V = pks(end);
        V = V - zero_V;
        pks = pks - zero_V;
        
        % Skipping odd/even
        switch filename
            case 'T2_0914_MG_LMO.csv'
                pks(2:2:end) = [];
                locs(2:2:end) = [];
            otherwise
                % Do Nothing
        end
        
        % Eliminate the first peak
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



