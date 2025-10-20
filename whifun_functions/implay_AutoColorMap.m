function handle = implay_AutoColorMap(image,title,minval,maxval)
%IMPLAY_AUTOCOLORMAP Displays a 2D or 3D image/volume stack using `implay`
%   and automatically sets the colormap and fixed display range (min/max
%   values) for consistent visualization across frames.
%
%   HANDLE = IMPLAY_AUTOCOLORMAP(IMAGE, TITLE, MINVAL, MAXVAL)
%
%   This function is a wrapper for MATLAB's `implay` that overrides the
%   default behavior of scaling the colormap based on the current frame,
%   forcing it to use a user-specified or calculated min/max range across
%   all frames.
%
%   Input Arguments:
%   IMAGE  - The image data. Can be 2D (single image) or 3D/4D (stack of
%            images/video frames). Standard input for `implay`.
%   TITLE  - (Optional, default 'figure') A string to set the title of the `implay` window.
%   MINVAL - (Optional, default min(IMAGE(:))) The minimum data value that
%            will map to the lowest color in the colormap.
%   MAXVAL - (Optional, default max(IMAGE(:))) The maximum data value that
%            will map to the highest color in the colormap.
%
%   Output Arguments:
%   HANDLE - The `implay.player` object handle, allowing further manipulation
%            of the player's properties.
%
%   Author: Pratik Jain

% --- Handle Optional Input Arguments ---
if nargin<4
maxval = max(image(:));  % default value
if nargin<3
minval = min(image(:));  % default value
if nargin<2
title = 'figure';  % default value
end
end
end

handle = implay(image);
set(handle.Parent, 'Name', title) %// set title
handle.Visual.ColorMap.UserRange = 1; 
handle.Visual.ColorMap.MapExpression = 'parula(256)';
handle.Visual.ColorMap.UserRangeMin = minval;%min(image(:)); 
handle.Visual.ColorMap.UserRangeMax = maxval;%max(image(:));