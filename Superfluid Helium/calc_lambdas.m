function [ lambda ] = calc_lambdas( hc_data_He )
% Calculate the lambda point temperature
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
lambda_min = zeros(1,length(hc_data_He.C));
lambda_max = zeros(1,length(hc_data_He.C));
for idx = 1:length(hc_data_He.C)
    % Pick out the lambda point
    cutoff_T = 3;
    [~, cutoff_idx] = min(abs(hc_data_He.T{idx} - cutoff_T));
    [~, max_idx] = max(hc_data_He.C{idx}(1:cutoff_idx));
    lambda_min(idx) = hc_data_He.T{idx}(max_idx);
    lambda_max(idx) = hc_data_He.T{idx}(max_idx + 1);
end

% Calculate mean and standard deviation
lambda.mean = mean([lambda_min, lambda_max]);
lambda.std = std([lambda_min, lambda_max]);
fprintf('\nMean lambda temperature: %.3f K\nStandard Deviation: %.3f K\n\n',...
    lambda.mean, lambda.std)


end

