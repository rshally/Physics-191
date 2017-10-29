function [t, V, varargout] = read_data(filename, pathname, method)

% Reads in tau value file
[tau_data_num, tau_data_text, tau_data_raw] = xlsread('tau_values.xlsx');

% Initialize varargout
varargout{1} = [];
varargout{2} = [];

% Reads in data
switch method
    case 'single' % For pulse sequences
        % Reads in csv of chosen file, data in CSV files is from (A22,B22 : Aend,Bend)
        M = csvread(fullfile(pathname, filename), 21, 0);
        t = M(:,1); V = M(:,2);
        
        % Determine domain manually and save this selection value
        [~, name, ~] = fileparts(filename);
        
        % Extract tau value for single experiments
        tau_val = tau_data_num(find(strcmp(tau_data_text(:,2), regexprep(filename,'.csv',''))) - 1, 1);
        num_B = tau_data_num(find(strcmp(tau_data_text(:,2), regexprep(filename,'.csv',''))) - 1, 3);
        
        % Set this as optional outputs
        varargout{1} = tau_val;
        varargout{2} = num_B;
        
    case 'multi' % For discrete pulses
        % Split path name by '/' and choose last one
        name = filename;
        
        % Get all filenames
        fnames = dir(['All Data/',filename,'/*.csv']);
        fnames = {fnames.name};
        
        t = [];
        V = [];
        % Loop over all filenames
        for n = 1:length(fnames)
            % Reads in csv of chosen file, data in CSV files is from (A22,B22 : Aend,Bend)
            M = csvread(fullfile(pathname, filename, fnames{n}), 21, 0);
            
            % Find the peak of the additional pulse plot by looking around
            % tau
            str_idx = strfind(fnames{n},'tek');
            num = str2double(fnames{n}((str_idx+3):(str_idx+6)));
            
            % Extract tau value
            tau_val = tau_data_num(tau_data_num(:,2)==num,1)/1000;
            
            M(M(:,2)==inf,2)=0;
            
            % Extract voltage values around this tau
            [~, tidx] = min(abs(M(:,1)-tau_val));
            neighbor = 1500;
            tidxes = tidx-neighbor:tidx+neighbor;
            [V(end+1), loc] = max(M(tidxes,2));
            t(end+1) = M(tidxes(loc),1);

        end
end

% Selection of data via ginput for non-T1 only
if ~strcmp(method,'multi')
   
    if ~exist(sprintf('ginput_values/%s',strcat(name,'_ginput.mat')),'file')
        % 2 Rounds of ginputs
        tdomain = [1, length(t)];
        h = figure(100);
        for n = 1:2
            fprintf('Specify signal domain for analysis\n')
            plot(t(tdomain(1):tdomain(2)),V(tdomain(1):tdomain(2)))
            [x, ~] = ginput(2);
            [~,tdomain(1)] = min(abs(t-x(1)));
            [~,tdomain(2)] = min(abs(t-x(2)));
            if tdomain(1)>tdomain(2)
                error('T Domain Specification seems reversed...')
            end
        end
        
        % Set domain limits on t and V
        t = t(tdomain(1):tdomain(2)); V = V(tdomain(1):tdomain(2));
        
        % Save domain selection
        if ~exist('ginput_values','dir'); mkdir('ginput_values'); end
        save(sprintf('ginput_values/%s',strcat(name,'_ginput')), 'tdomain')
        close(h)
        
    else
        % Load presaved domain selection
        load(sprintf('ginput_values/%s',strcat(name,'_ginput')))
        
        % Set domain limits on t and V
        t = t(tdomain(1):tdomain(2)); V = V(tdomain(1):tdomain(2));
    end
end



end

