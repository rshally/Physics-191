function make_new_figs(f, x, y, t, V, main_title)
%%%%%%%%%%%%
% First: LMO
% 1 - 'T1_0914_D_LMO';
% 2 - 'T2_0914_CP_LMO.csv';
% 3 - 'T2_0914_MG_LMO.csv';

%%%%%%%%%%%%
% Second: Distilled Water
% 4 - 'T1_0919_D_H2O';
% 5 - 'T2_0919_MG_H2O_tau1.csv';
% 6 - 'T2_0919_MG_H2O_tau2.csv';
% 
% %%%%%%%%%%%%
% % Third: Fluorine
% 7 - 'T2_0921_S_Fluor.csv';
% 8 - 'T1_0921_D_Fluor';
% 9 - 'T2_0921_MG_Fluor_tau1.csv';
% 10 - 'T2_0921_MG_Fluor_tau2.csv';

% Make subplot of T1 data
generate_subplots([1,4,8], f,x,y,t,V,main_title)

% Make subplots of T2 data
generate_subplots([3,5,9], f,x,y,t,V,main_title)

% Make subplots of different tau data
generate_subplots([5,6], f,x,y,t,V,main_title)


function generate_subplots(ns, f, x, y, t, V, main_title)

figure
for n = 1:length(ns)
    % Figure 1: subplots of 3 T1 values 
    %%%%%
    nfile = ns(n);
    subplot(length(ns),1,n)
    plot(f{nfile},x{nfile},y{nfile})
    hold on
    plot(t{nfile},V{nfile}) % Plot H2O
    title(main_title{nfile})
    xlabel('time (s)')
    ylabel(sprintf('EMF in x-y Plane (Volts)\nFID Amplitude'))
    legend('Peak Voltage','Exp. Fit','Voltage','Location','best')
end
