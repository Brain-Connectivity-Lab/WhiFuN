function [] = implay_AutoColorMap(image,title,minval,maxval)

% if nargin < 2
%     title = 'figure';
% end

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