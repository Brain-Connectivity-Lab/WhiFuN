function [output,fg] = spm_check_registration_evalc(a,b) %#ok<INUSD> 
% fg = spm_figure('Create','Graphics','Visible','off');
fg = spm_figure('GetWin','Graphics');
if nargin == 1
    output = evalc('spm_check_registration(a)');  % Plot the two images using Check Registration
elseif nargin == 2
    output = evalc('spm_check_registration(a,b)');  % Plot the two images using Check Registration
end