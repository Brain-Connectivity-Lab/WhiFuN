function whifun_check_filter_parameters(filter_lp,filter_hp)
% Written by Pratik Jain
% WHIFUN_CHECK_FILTER_PARAMETERS Checks if filter cutoffs are correctly ordered.
%
%   WHIFUN_CHECK_FILTER_PARAMETERS(filter_lp, filter_hp) checks if the
%   low-pass filter cutoff frequency (`filter_lp`) is less than or equal to
%   the high-pass filter cutoff frequency (`filter_hp`).
%
%   If the condition `filter_lp > filter_hp` is met, the function throws
%   an error with a descriptive message, halting script execution.
%   This is a useful utility function for validating user input in signal
%   processing scripts.
%
%   Input Arguments:
%   filter_lp - The low-pass filter cutoff frequency (e.g., 0.1).
%   filter_hp - The high-pass filter cutoff frequency (e.g., 0.01).
%
%   Example:
%      % This will pass without error
%      whifun_check_filter_parameters(0.01, 0.1);
%
%      % This will throw an error
%      % whifun_check_filter_parameters(0.1, 0.01);
%
%   See also SPRINTF, ERROR.

if filter_lp > filter_hp
    error(sprintf('Please check the filter cutoffs, lower_cutoff should be less than higher cutoff, \nbut found otherwise\n'))
end