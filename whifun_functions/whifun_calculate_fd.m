function fd = whifun_calculate_fd(motion)
% WHIFUN_CALCULATE_FD Calculates framewise displacement (FD).
%
%   fd = WHIFUN_CALCULATE_FD(motion) computes the framewise displacement (FD)
%   from motion parameters. FD is a measure of head motion between
%   consecutive time points in an fMRI scan.
%
%   This function takes either the path to a motion parameter text file
%   (as a string or `dir` structure) or the motion parameters directly (as
%   a numeric matrix). It then calculates the vector difference between each
%   time point. The rotational parameters are converted to millimeters by
%   assuming a brain radius of 50mm, and the absolute sum of all six
%   derivative parameters is returned as the FD time series.
%
%   This function is a core part of quality control for fMRI data, as high
%   FD values indicate excessive motion that may require subject exclusion
%   or data scrubbing.
%
%   Input Arguments:
%   motion - The path to the motion parameter `.txt` file (string or `dir`
%            structure), or a numeric matrix of motion parameters.
%
%   Output Arguments:
%   fd - A vector of framewise displacement values, where each element
%        corresponds to a time point (starting from the second time point).
%
%   Example:
%      % Assuming 'rp_file.txt' is the motion parameter file
%      % fd_values = whifun_calculate_fd('path_to_rp_file.txt');
%
%      % Or, pass the matrix directly
%      % motion_matrix = load('path_to_rp_file.txt');
%      % fd_values = whifun_calculate_fd(motion_matrix);
%
%   Author: Pratik Jain
%   See also DIR, LOAD, DIFF.
if ~isnumeric(motion)
    if ~isstruct(motion)
        now_txt_path = dir(motion) ;
    else
        now_txt_path = motion;
    end
    rp_rest = load(fullfile(now_txt_path.folder,now_txt_path.name));              % input the text file generated at the Realignment stage
else
    rp_rest = motion;
end

rp_diff_trans = abs(diff(rp_rest(:,1:3)));                      % The first 3 parameters tell the displacement in x,y, and z direction in mm. Here the vector difference operator is used to get the derivative of vector. (framewise difference)
rp_diff_rotat = abs(diff(rp_rest(:,4:6)*50));                   % Converting angles to mm by asuming a 50mm radius circle


fd = sum(rp_diff_trans,2) + sum(rp_diff_rotat,2)  ;