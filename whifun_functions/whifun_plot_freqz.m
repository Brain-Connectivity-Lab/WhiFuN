function whifun_plot_freqz(b,a,Fs)
% WHIFUN_PLOT_FREQZ Plots the frequency response of a digital filter.
%
%   WHIFUN_PLOT_FREQZ(b, a, Fs) generates a two-part plot showing the
%   magnitude and phase response of a digital filter. This function is
%   a utility for visualizing the characteristics of a filter, such as a
%   Butterworth bandpass filter used in fMRI preprocessing.
%
%   The function uses MATLAB's `freqz` function to calculate the frequency
%   response and then plots the magnitude (how much the filter amplifies
%   or attenuates a given frequency) and phase (the phase shift applied
%   to a frequency). The frequency axis is displayed in Hz.
%
%   Input Arguments:
%   b  - The numerator coefficients of the filter transfer function.
%   a  - The denominator coefficients of the filter transfer function.
%   Fs - The sampling frequency in Hz (e.g., 1/TR for fMRI data).
%
%   Author: Pratik Jain
%   See also FREQZ, SUBPLOT, PLOT, GRID ON, XLABEL, YLABEL, TITLE.

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
