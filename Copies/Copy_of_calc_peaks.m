function [locs, pks, f] = calc_peaks(filename, pathname, method, T)
% PURPOSE: reads in data from a chosen file and analyzes T1 or T2
% INPUTS: (varargin) - can input a filename for direct calculation

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% TO DO:
% Curve fitting to peaks

% Flipping values for T1 measurements? How to determine when a value is on
% the left side or the right side of the y=0 point intersection.....
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%



%% Reading in file
[t,V] = read_data(filename, pathname, method);

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

% % % %Creating envelope functions
% % % [yupper, ~] = envelope(V,5000,'peak');
% % % % Cut off envelope at the maximum value:
% % % [~,loc] = max(V(:));
% % % yupper = yupper(loc:end);
% % % ttot = t(loc:end);
% % % % Plot envelope and original
% % % figure
% % % plot(t,V,ttot,yupper)
% % % hold on

% Fitting based on T1 or T2 measurement
switch T
    case 'T1' % T1 Calculation
        % Calculate exponential fit and plot on top
        fops = fitoptions;
        ft = fittype('a*abs(1-2*exp(b*x))');
        f = fit(ttot, yupper, ft);
        plot(f)
        
    case 'T2' % T2 Calculation

        % Throw away certain peaks
% % %         pks(2:2:end) = [];
% % %         locs(2:2:end) = [];
        pks(1) = [];
        locs(1) = [];

        ft = fittype('a*exp(b*x)');
        f = fit(locs, pks, ft);

        % Plotting voltage function with peaks
        figure
        plot(f,locs,pks)
        hold on
        plot(t,V)
%         findpeaks(V, t, 'MinPeakDistance', minD, 'MinPeakHeight', minH);
        title('Voltage Plot with Peak Voltages Identified')
        xlabel('time (s)')
        ylabel('Voltage (V)')
end



