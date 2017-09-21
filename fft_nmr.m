function P1 = fft_nmr(filename, pathname)
% Computes FFT of input signal and shows outputs
% % % filename = 'tek0083CH2.csv';
% % % pathname = '/Users/Spencer/Documents/MATLAB/Physics 191/T2_0921_S_Fluor/';
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
plot(t,V)
title('FC-770 FID Pulse Signal')
xlabel('time')
ylabel('Voltage (V)')
subplot(1,2,2)
plot(f,P1)
title('Single-Sided Amplitude Spectrum of S(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')


end
