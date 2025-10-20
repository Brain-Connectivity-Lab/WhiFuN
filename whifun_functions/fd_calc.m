function fd = fd_calc(Y)
%FD_CALC Calculates the Framewise Displacement (FD) from a time series of 
%   rigid-body head motion parameters.
%
%   FD = FD_CALC(Y)
%
%   Framewise Displacement is a scalar quantity summarizing head motion from
%   one time point to the next, typically derived from 6 rigid-body
%   realignment parameters (3 translations and 3 rotations). Rotations are
%   usually converted to displacements on a sphere of a given radius (e.g.,
%   50 mm).
%
%   Input Arguments:
%   Y   - Head motion parameters time series. Expected size:
%         N_TimePoints x N_MotionParameters (where N_MotionParameters is 6,
%         or 12 if including derivatives, but only the 6 primary parameters
%         are used for FD calculation, typically after rotational parameters
%         have been converted to displacement in millimeters).
%
%   Output Arguments:
%   FD  - A column vector of Framewise Displacement values (in mm).
%         Size: (N_TimePoints - 1) x 1.
%
%   Assumptions:
%   1. The input matrix Y contains the 6 motion parameters where all 6 are
%      in the same units (typically mm, assuming rotations have been
%      converted to mm displacements using a standard radius).
%   2. FD is calculated as the Euclidean distance (L2 norm) of the vector of
%      changes in the 6 parameters between successive time points.
%
%   Author: Pratik Jain

% calculate framewise displacement
Y_diff = diff(Y);
multp = Y_diff*Y_diff';
fd = sqrt(diag(multp));
end