function whifun_plot_freqz(b,a,Fs)

% Frequency response
[H, f] = freqz(b, a, 512, Fs);  % Now 'f' is in Hz

% Plot magnitude and phase
% Magnitude response
subplot(2,1,1);
plot(f, abs(H), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Response');

% Phase response
subplot(2,1,2);
plot(f, angle(H), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');
title('Phase Response');
