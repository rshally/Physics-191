function ind_data = get_independent_data
data_folder = 'More Data';
all_files = dir([data_folder,'/*.xlsx']);

ind_data = [];
for n = 1:length(all_files)

    file = fullfile(data_folder, all_files(n).name);
    [~,~,raw] = xlsread(file);

    nanvals = cellfun(@(C) any(isnan(C(:))), raw);
    raw1 = cellfun(@(in) regexprep(string(in),' ', ''), raw, 'un', 0);

    % Remove missing elements
    raw1(nanvals(:,1) | nanvals(:,2) , :) = [];

    % Convert to numbers
    ind_data = vertcat(ind_data, str2double(raw1));
end