function output = spm_check_registration_evalc(a,b) %#ok<INUSD> 
if nargin == 1
    output = evalc('spm_check_registration(a)');  % Plot the two images using Check Registration
elseif nargin == 2
    output = evalc('spm_check_registration(a,b)');  % Plot the two images using Check Registration
end