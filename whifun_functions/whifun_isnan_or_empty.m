function y = whifun_isnan_or_empty(x,field)
if isfield(x,field)
    x = x.(field);
    y = isempty(x) || (isnumeric(x) && isnan(x));
else
    y = true;
end