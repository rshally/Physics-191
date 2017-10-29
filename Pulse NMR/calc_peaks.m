function [T, adjr2, T_ci, varargout] = calc_peaks(filename, pathname)
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

use_tau_vals = 1;

set(0,'DefaultAxesFontSize',14) 


%% Reading in file
if isdir(['All Data/',filename])
    number = 'multi';
else
    number = 'single';
end
[t,V, tau, num_B] = read_data(filename, pathname, number);
tau = tau/1000;

% dt and Sample Rate
dt = t(2) - t(1);

% Find peaks for T2
if strcmp(T,'T2')
    
    % Find first time voltage is above a threshold
    idx = find(V>2, 1);
    % Find global max around some region near this point
    
    % Use find peaks algorithm to start
    [pks, locs] = find_my_peaks(filename, V, t);
    
    % Beginning of t should be tau before the first peak
    [~, t0idx] = min(abs(t - locs(1)));
    locs = locs - t(t0idx);
    t = t - t(t0idx);
    
    % Use tau vals to manually extract later peaks
    if use_tau_vals
        pks2 = [];
        locs2 = [];
        for n = 1:num_B
            neigh = 100; % Neighbors to search around for max
            
            % Find time of next peak
            next_tau = (n-1)*2*tau;
            if next_tau>max(t)
                break
            end
            
            [~, next_idx] = min(abs(t - next_tau));
            
            % Extract max from a range around that point
            dom = next_idx-neigh:next_idx+neigh;
            
            % Find max point in this domain range
            [pks2(end+1), idx] = max(V(dom));
            locs2(end+1) = t(dom(idx));
        end
        pks = pks2';
        locs = locs2';
    end
    
else % Peaks for T1 already found
    pks = V;
    locs = t;
end


%% Step 3: Use the exponential to calculate T1 or T2
% Show shifted peaks

% Fitting based on T1 or T2 measurement
switch T
    case 'T1' % T1 Calculation
        % Manually setting the zero point
        V = V - min(V);
        flip_t = t(V==0);
        
        % Flip values at t<flip_t
        V(t<flip_t) = -1*V(t<flip_t);
        
        % Generating Fit and Plot
        ft = fittype('a*(1-2*exp(b*x))');
        [f, adjr2, ci_T, varargout{1}, varargout{2}, varargout{3},...
            varargout{4}, varargout{5}, varargout{6}] = fit_and_plot(t', V', ft, filename);

        % Calculating T1
        T1 = 1/f.b;
        fprintf('T1 = %.4f sec\n\n',T1)
        T_ci = 1./ci_T;
        T = T1;
        
    case 'T2' % T2 Calculation
        % Manually setting the zero point
        zero_V = pks(end);
        V = V - zero_V;
        pks = pks - zero_V;
        
% %       Skip even peaks
%         pks(2:2:end) = [];
%         locs(2:2:end) = [];
%             
        
        % Eliminate the first peak
        pks(1) = [];
        locs(1) = [];
        
        % Fit and Plot
        ft = fittype('a*exp(b*x)');
        [f, adjr2, ci_T, varargout{1}, varargout{2}, varargout{3},...
            varargout{4}, varargout{5}, varargout{6}] = fit_and_plot(locs, pks, ft, filename, t, V);

        % Calculate T2 Value
        T2 = 1/f.b;
        fprintf('T2 = %.4f sec\n\n',T2)
        T_ci = 1./ci_T;
        T = T2;
end


function [pks, locs] = find_my_peaks(filename, V, t)
dt = t(2) - t(1);
    % Determine smallest tau
    switch filename
        case 'T2_0914_CP_LMO.csv'
            minD = 0.9e-3;
            minH = 0.75;
            
        case 'T2_0914_MG_LMO.csv'
            minD = 0.9e-3;
            minH = 0.75;
            
        case 'T2_0921_MG_Fluor_tau1.csv'
            minD = 2*0.4e-3;
            minH = 0.3;
            
        case 'T2_0921_MG_Fluor_tau2.csv'
            minD = 2*0.8e-3;
            minH = 0.3;
            
        otherwise
            minD = 4.4e-3; % for smallest tau of 1msec
            minH = 0.75;
    end
    
    % Pad with a zero at the end
    V(end+1) = 0;
    t(end+1) = t(end) + dt;
    [pks, locs] = findpeaks(V, t, 'MinPeakDistance', minD, 'MinPeakHeight', minH);
    
function [f, adjr2, ci_T, varargout]  = fit_and_plot(x, y, ft, title_name, varargin)
% Process inputs
if ~isempty(varargin) % T2 measurements pass in t and V
    t = varargin{1};
    V = varargin{2};
else % Fill t and V with appropriate delta functions
    t = linspace(min(x),max(x),500);
    V = zeros(1,length(t));
    for n = 1:length(x)
        [~,t_idx] = min(abs(t-x(n)));
        V(t_idx) = y(n);
    end
end

% Generate the fit and plot the output
[f, gof] = fit(x, y, ft, 'StartPoint',[1 -1]);
adjr2 = gof.adjrsquare;
ci = confint(f);
ci_T = ci(:,2)';

resid = 0;

title_name = regexprep(title_name,'.csv','');
C = strsplit(title_name,'_');
T_name = C{1};

switch C{4}
    case 'LMO'
        S_name = 'Mineral Oil Sample ';
    case 'H2O'
        S_name = 'H2O Sample ';
    case 'Fluor'
        S_name = 'FC-770 Sample ';
    otherwise
        error('Name does not match')
end

if strcmp(T_name,'T2')
    switch C{4}
        case 'LMO'
            tau = '800\mus';
            S_name = [S_name, '\tau = ',tau];
        case 'H2O'
            switch C{5}
                case 'tau1'
                    tau = '5ms';
                case 'tau2'
                    tau = '8.5ms';
            end
            S_name = [S_name,'\tau = ',tau];

        case 'Fluor'
            switch C{5}
                case 'tau1'
                    tau = '600\mus';
                case 'tau2'
                    tau = '1ms';
            end
            S_name = [S_name, '\tau = ',tau];
        otherwise
            error('Name does not match predefined list')
    end
end
    
    
switch resid
    case 0 % Plot without residuals:
        figure
        title_name = regexprep(title_name,'_',' ');
        title_name = regexprep(title_name,'.csv','');
        %suptitle(sprintf([title_name,'\n']))
        % Plot the original peaks/voltages
        plot(f,x,y)
        hold on
        plot(t,V)
        legend('Peak Voltage','Exp. Fit','Voltage','Location','best')
        main_title = sprintf('EMF Plot of %s Measurement\n%s',T_name,S_name);
        title(main_title)
        xlabel('time (s)')
        ylabel(sprintf('EMF in x-y Plane (Volts)\nFID Amplitude'))
        
        % Pass all of these out
        varargout{1} = f;
        varargout{2} = x;
        varargout{3} = y;
        varargout{4} = t;
        varargout{5} = V;
        varargout{6} = main_title;
        
        % Save figure if it doesn't exist already
        if ~exist('Figures','dir')
            mkdir('Figures')
        end
        
        fig_file = ['Figures/',regexprep(title_name,' ','_'),'.eps'];
        if ~exist(fig_file, 'file')
            print(fig_file,'-depsc')
            %saveas(gcf,fig_file)
            fprintf('Figure Saved\n')
        else
            fprintf('Saved Figure Already Exists\n')
        end
        
        
    case 1 % Plot with residuals:
        figure
        title_name = regexprep(title_name,'_',' ');
        title_name = regexprep(title_name,'.csv','');
        suptitle(sprintf([title_name,'\n']))
        % Plot the original peaks/voltages
        subplot(1,2,1)
        plot(f,x,y)
        hold on
        plot(t,V)
        title('Voltage Plot with Peak Voltages Identified')
        xlabel('time (s)')
        ylabel('Voltage (V)')

        % Plot the residuals
        subplot(1,2,2)
        plot(f,x,y,'residuals')
        title('Residual Voltage Plot')
        xlabel('time (s)')
        ylabel('Residual Voltage (V)')
end








