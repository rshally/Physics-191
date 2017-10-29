function P1 = fft_nmr(filename, pathname)
% Computes FFT of input signal and shows outputs
% % % filename = 'tek0083CH2.csv';
% % % pathname = '/Users/Spencer/Documents/MATLAB/Physics 191/T2_0921_S_Fluor/';
set(0,'DefaultAxesFontSize',14) 

[t,V] = read_data(filename, pathname, 'single');

% Set up constants
L = length(V);
if mod(L,2) % remove last point if odd
    V = V(1:end-1);
    t = t(1:end-1);
    L = length(V);
end

% Compute FFT
Y = fft(V);
dt = t(2) - t(1);
Fs = 1/dt;
f = Fs*(0:(L/2))/L;

% Compute single-sided power spectrum
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Plotting results
figure
subplot(1,2,1)
plot(1000*t,V)
title('FC-770 EMF Signal After MG Pulse Sequence')
xlabel('time (ms)')
ylabel(sprintf('EMF in x-y Plane (Volts)\nFID Amplitude'))
subplot(1,2,2)
plot(f/1000,P1)
title('Single-Sided Amplitude Spectrum of S(t)')
xlabel('f (kHz)')
ylabel('|P1(f)|')

% Print out peak frequency signal values
[pks, locs] = findpeaks(P1,'MinPeakHeight',.001);
pk_freq = f(locs);
fprintf('Peak Frequencies:\n')
disp(pk_freq)



end
