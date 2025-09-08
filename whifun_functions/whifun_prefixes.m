function [Cut_pre,Realign_pre,skull_pre,Reg_pre,f_pre,Smooth_pre,Norm_pre] = whifun_prefixes(Cut_pre,Realign_pre,skull_pre,Reg_pre,f_pre,Smooth_pre,Norm_pre)
% WHIFUN_PREFIXES Defines or retrieves standard prefixes for a preprocessing pipeline.
%
%   [Cut_pre, ..., Norm_pre] = WHIFUN_PREFIXES() returns the default
%   prefixes used to label files after each preprocessing step.
%
%   [Cut_pre, ..., Norm_pre] = WHIFUN_PREFIXES(Cut_pre, ..., Norm_pre)
%   allows the user to override the default prefixes. This is useful for
%   customizing the file naming convention.
%
%   This function serves as a central point for managing the consistent
%   naming of output files throughout a neuroimaging preprocessing workflow.
%   If no input arguments are provided, it initializes all prefixes to their
%   default values.
%
%   Output Arguments:
%   Cut_pre    - Prefix for the file after discarding initial volumes ('c_').
%   Realign_pre - Prefix for the realigned file ('r').
%   skull_pre   - Prefix for the skull-stripped file ('b').
%   Reg_pre     - Prefix for the regressed file ('REG_').
%   f_pre       - Prefix for the filtered file ('f').
%   Smooth_pre  - Prefix for the smoothed file ('s').
%   Norm_pre    - Prefix for the normalized file ('w').
%
%   Example:
%       % Get the default prefixes
%       [cut, realign, skull, reg, filt, smooth, norm] = whifun_prefixes();
%
%       % Override the smoothing prefix
%       [~, ~, ~, ~, ~, custom_smooth] = whifun_prefixes([],[],[],[],[],'my_s');
%       % custom_smooth will be 'my_s'
%
%   Author: Pratik Jain
%   See also NARGIN.

if nargin == 0
    Cut_pre = 'c_';                                                             % Prefix for the Discarding Initial volumes File
    Realign_pre = 'r';                                                          % Prefix for the Realignment File
    skull_pre = 'b';                                                            % Prefix for the Skull Stripped File
    Reg_pre = 'REG_';                                                           % Prefix for the Regressed File
    f_pre = 'f';                                                                % prefix for filtered file
    Smooth_pre = 's';                                                           % Prefix for the Smoothed File
    Norm_pre = 'w';                                                             % Prefix for the Normalized File
end