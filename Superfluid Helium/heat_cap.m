function [hc_data, varargout] = heat_cap(data_folder, data_type, T_fun_log, I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Function to return to the heat capacity measurements for each of
% the addendum and full measurements made

% INPUTS: type --> 'addendum' or 'heat_cap'
%         I    --> current used as input for pulse 
% OUTPUTS: hc_data --> resulting heat capacity measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Determine threshold characteristics based on type input
switch data_type
    case 'addendum'
        criteria_len = 5;
        criteria_thresh = .0006;
    case 'heat_cap'
        criteria_len = 6;
        criteria_thresh = .0006;  
    otherwise
        error('Incorrect file name input')
end

% Calculate Resistance of the heater
Rcurrent = [1249.1, 132.75];
Rvoltage = [1249.6, 133.02];
Rheater = 1000; % How do I do this?????

% Load data on pulse power transmitted
[num, txt, raw] = xlsread(fullfile(data_folder, 'pulse_power_data.xlsx'));

% Loop through all of the data file names:
fnames = dir(fullfile(data_folder, [data_type,'*.txt']));
for n = 1:length(fnames)
    name = fnames(n).name;
    % Load Data
    data = dlmread(fullfile(data_folder, name));

    % First plot of data:
    % Step 1: Convert voltage to resistance
    R = data(:,1)./I;

    % Step 2: Convert resistance to temperature
    T_vals = exp(polyval(T_fun_log,log(R)));

    % Step 3: Trim bad data
    idx_bad = find(abs(diff(data(:,3)))>1);
    if isempty(idx_bad); idx_bad = 1; end
    T_vals = T_vals(max(idx_bad):end);
    time = data(max(idx_bad):end, 3);

    % Step 4: Pick out step points --> want points right before a large step
    % Find where 5 derivatives in a row are large
    T_diff_smooth = diff(smooth(T_vals));
    i = 1;
    jump_idx = [];
    while i<=length(T_diff_smooth)-criteria_len
        if all(T_diff_smooth(i+1:i+criteria_len) > criteria_thresh)
            jump_idx(end+1) = i;
            i = i+20;
        end
        i = i+1;
    end

    % Plot the step functions with circles at pre-jump locations
    figure
    plot(time, T_vals,'b', time(jump_idx), T_vals(jump_idx), 'ro')
    title(sprintf('Temperature vs. Time\nFile: %s',name), 'Interpreter', 'none')
    
    % Take the differences between adjacent points for temperature steps
    T_steps = diff(T_vals(jump_idx));
    
    % Compute the power data
    row = strcmp(raw(:,1), regexprep(name, '.txt',''));
    
    P = [];
    E = [];
    % Store values for P and E
    for j = 1:length(find(row))
        row_now = find(row);
        row_now = row_now(j);
        % Determine how long this went
        if ischar(raw{row_now,4})
            len = length(jump_idx);
           
        else
            time = raw{row_now,4};
            [~, len] = min(abs(data(jump_idx, 3) - time));
        end
        
        % Store P and E calculations according to the length of time they
        % were used in the pulsing
        Pnew = repmat(num(row_now - 1,1).^2 / Rheater, [1, len - length(P)]);
        P = [P, Pnew];
        E = [E, Pnew*num(row_now - 1,2)];        
    end
    
    % Compute heat capacity after E calculation
    E = reshape(E, [], 1);
    T_steps = reshape(T_steps, [], 1);
    Ts{n,1} = T_vals(jump_idx(2:end));
    C{n,1} = E(2:end)./T_steps; 
    
    % Plot heat capacity data (full)
    figure
    plot(Ts{n}, C{n})
    title('Heat Capacity Versus Temperature')
    xlabel('T [K]')
    ylabel('C [J/K]')
    
end


% For the addendum, create a model and calculate Debye temperature
if strcmp(data_type, 'addendum')
    massAd = 14.8; %grams
    molesCu = massAd/63.55; % grams / grams per mole
    R = 0.082057; % L atm mol^-1 K^-1
    
    Tdeb_est = zeros(1, numel(C));
    % Fit a model to data according to Debye theory
    for m = 1:numel(C)
        ft = fittype('a*x^3 + b');
        [CvDeb{m}, gof] = fit(Ts{m}, C{m}, ft,'StartPoint',[0,0]);
        
        % Calculate Debye Temperature estimate for carbon from this data
        Tdeb_est(m) = (molesCu*R*12*pi^4/(5*CvDeb{m}.a))^(1/3);
    end
    % Plot both models and the data
    figure
    p1 = plot(CvDeb{1}, 'b', Ts{1}, C{1}, 'bo');
    set(p1, 'LineWidth',2)
    hold on
    p2 = plot(CvDeb{2}, 'r', Ts{2}, C{2}, 'ro');
    set(p2, 'LineWidth',2)
    title('Addendum Heat Capacity Plot')
    xlabel('T [K]')
    ylabel('C [J/K]')
    
    % Pass output parameters
    varargout{1} = CvDeb;
    varargout{2} = Tdeb_est;

end


hc_data.C = C;
hc_data.T = Ts;

% Col 1: voltage
% Col 2: not needed
% Col 3: time

