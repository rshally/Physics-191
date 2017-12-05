function [ lambda ] = calc_lambdas( hc_data_full, addendum_model )
% Subtract the addendum heat capacity from the full measurements
md = 1; % Choice of addendum model
% NOTE: I am only using the first model at this point

% THOUGHTS: 
% 1. Should I be removing the constant term from the heat capacity?
% maybe not because it is not an ideal sample of copper, so maybe it is
% necessary to keep it
% 2. How to I incorporate multiple models for the addendum data?
% 3. How can I analyze the He HC data to compare it to literature other
% than by just looking at the lambda point?


%% Main Code

% Loop over all sets of heat capacity data
colors = ['b','r','g','y','k'];
lamdba = zeros(1,length(hc_data_full.C));
figure
for idx = 1:length(hc_data_full.C)
    mdl = addendum_model{md};
    % Subtract the addendum data from the full model
    hc_data_He.C{idx} = hc_data_full.C{idx} - mdl(hc_data_full.T{idx});
    hc_data_He.T{idx} = hc_data_full.T{idx};
    
    % Pick out the lambda point
    cutoff_T = 3;
    [~, cutoff_idx] = min(abs(hc_data_He.T{idx} - cutoff_T));
    [~, max_idx] = max(hc_data_He.C{idx}(1:cutoff_idx));
    lambda(idx) = hc_data_He.T{idx}(max_idx);
    
    % Plot the results
    plot(hc_data_He.T{idx}, hc_data_He.C{idx}, colors(idx))
    hold on
    title('Helium Heat Capacity')
    xlabel('T [K]')
    ylabel('C [J/K]')
end

fprintf('Lambda point temperatures (K):\n')
disp(lambda)

end

