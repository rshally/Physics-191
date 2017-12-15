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


%% Determine threshold characteristics based on type input
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

% Zero-point pressures (do we need these?)
large_gauge = 8; %mmHg
small_gauge = 0; %mmHg

% Calculate Resistance of the heater
Rcurrent = [1249.1, 132.75];
Rvoltage = [1249.6, 133.02];
Rheater = mean(-[diff(Rcurrent), diff(Rvoltage)]);

% Load data on pulse power transmitted
[num, txt, raw] = xlsread(fullfile(data_folder, 'pulse_power_data.xlsx'));

%% Loop through all of the data file names:
fnames = dir(fullfile(data_folder, [data_type,'*.txt']));
f = figure;
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
    %subplot(1,length(fnames),n)
    plot(time, T_vals,'b', time(jump_idx), T_vals(jump_idx), 'ro')
    title('Temperature Change Given Heat Pulse')
    xlabel('Time (s)')
    ylabel('Temperature (K)')
    
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
end

%% For the addendum, create a model
if strcmp(data_type, 'addendum')
    massAd = 14.8; %grams
    molesCu = massAd/63.55; % grams / grams per mole
    R = 0.082057; % L atm mol^-1 K^-1
    
% % % %     % Fit a model to data according to the paper
% % % %     for m = 1:numel(C)
% % % %         % Compute my own model based on the structure
% % % %         ft = fittype('A1*x + A2*x^3 + A3*x^5 + A4*x^7 + A5*x^9 + A6*x^11');
% % % %         [Cp{m}, gof1] = fit(Ts{m}, C{m}, ft,'StartPoint',[0,0,0,0,0,0]);
% % % %         [Cp_specific{m}, gof2] = fit(Ts{m}, C{m}/molesCu, ft,'StartPoint',[0,0,0,0,0,0]);
% % % % 
% % % %         
% % % %         % Compare this model to the model theorized in the papers
% % % %         A1 = 6.9434e-1;
% % % %         A2 = 4.7548e-2;
% % % %         A3 = 1.6314e-6;
% % % %         A4 = 9.4786e-8;
% % % %         A5 = -1.3639e-10;
% % % %         A6 = 5.3898e-14;
% % % %         coeff = [A6, 0, A5, 0, A4, 0, A3, 0, A2, 0, A1, 0];
% % % %         Cp_predicted{m} = 1/1000 * polyval(coeff, Ts{m});
% % % %     end
    
    % Create one model for both sets of data:
    ft = fittype('A1*x + A2*x^3 + A3*x^5 + A4*x^7 + A5*x^9 + A6*x^11');
    [Cp_all_model, gof2] = fit(vertcat(Ts{:}), vertcat(C{:}), ft,'StartPoint',[0,0,0,0,0,0]);

    % Plotting models on top of HC data
    h = figure;
    h1 = plot(Ts{1}, C{1}, 'bo', Ts{2}, C{2}, 'ro');
    hold on
    h2 = plot(Cp_all_model, 'predfunc', .95);
    set(h2, 'LineWidth', 1.5)
    set(h2, 'color', 'k')
    hold on
    legend('Trial 1', 'Trial 2', 'Non-Linear Model')
    title('Heat Capacity of Cu Addendum')
    xlabel('T [K]')
    ylabel('C [J/K]')

    % Save Figure:
    fig_file = 'Saved_Figures/HC_Cu_Fit.eps';
    saveas(gcf, fig_file,'epsc')
    fig_file = 'Saved_Figures/JPEG/HC_Cu_Fit.jpeg';
    saveas(gcf, fig_file,'jpeg')

% % % %     % Plot both models and the data
% % % %     figure
% % % %     p1 = plot(Cp{1}, 'b', Ts{1}, C{1}, 'bo');
% % % %     set(p1, 'LineWidth',2)
% % % %     hold on
% % % %     p2 = plot(Cp{2}, 'r', Ts{2}, C{2}, 'ro');
% % % %     set(p2, 'LineWidth',2)
% % % %     title('Addendum Heat Capacity Plot')
% % % %     xlabel('T [K]')
% % % %     ylabel('C [J/K]')
% % % %     legend('Trial 1','Non-Linear Model', 'Trial 2', 'Non-Linear Model')
    
    
    % Pass output parameters
    varargout{1} = Cp_all_model;
    varargout{2} = 0;
end

% Save data for output
hc_data.C = C;
hc_data.T = Ts;

% Col 1: voltage
% Col 2: not needed
% Col 3: time

