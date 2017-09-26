function [t,V] = read_data(filename, pathname, method)

% Reads in data
switch method
    case 'single' % For pulse sequences
        % Reads in csv of chosen file, data in CSV files is from (A22,B22 : Aend,Bend)
        M = csvread(fullfile(pathname, filename), 21, 0);
        t = M(:,1); V = M(:,2);

        % Determine domain manually and save this selection value
        [~, name, ~] = fileparts(filename);
    case 'multi' % For discrete pulses
        % Split path name by '/' and choose last one
        name = filename;
        
        fnames = dir(['All Data/',filename,'/*.csv']);
        fnames = {fnames.name};
        for n = 1:length(fnames)
            % Reads in csv of chosen file, data in CSV files is from (A22,B22 : Aend,Bend)
            M = csvread(fullfile(pathname, filename, fnames{n}), 21, 0);

            minD = .9e-3; % for smallest tau of 1msec
            minH = 0.5;
            
            % Superimpose each voltage profile on top of the previous
% % %             if n==1
% % %                 t = M(:,1); V = M(:,2);
% % %             else
                % Find the peak of the additional pulse plot
                [pks_org, locs_org] = findpeaks(M(100:end,2), M(100:end,1), 'MinPeakDistance', minD, 'MinPeakHeight', minH);
                pks = max(pks_org);
                locs = locs_org(pks_org==pks);
                [~, idx] = min(abs(t-locs));
                V(idx) = pks;
% % %             end
                
            
% %                 
% %                 
% %                 t2 = M(:,1);
% %                 V2 = M(:,2);
% %                 t(t<t2) = t2(t<t2);
% %                 V(V<V2) = V2(V<V2);
        end
end

% Selection of data via ginput
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

