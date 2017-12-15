function [ hc_data_He ] = hc_he_extract( hc_data_full, addendum_model )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify cutoff value for temperature
T_cut = 3.5;

% Compute the mass of gas in chamber: PV = nRT
R = 0.082057; % L atm mol^-1 K^-1
Troom = 298; % K
P1 = .2 * 0.068046; % psi to atm
P2 = -10 * 0.0334211; % inches Hg to atm
moleHe = (P1 - P2)/(R*Troom);
massHe = moleHe * 4; % convert moles to grams

% Subtract copper heat capacity
hc_data_He.C = cellfun( @(x_C, x_T) x_C(x_T<T_cut) - addendum_model{1}(x_T(x_T<T_cut)) , hc_data_full.C, hc_data_full.T, 'un', 0);
hc_data_He.T = cellfun( @(x_T) x_T(x_T<T_cut), hc_data_full.T, 'un', 0);

% Convert heat capacity to specific heat
hc_data_He.Cs = cellfun(@(x) x/moleHe, hc_data_He.C, 'un', 0);

end

