function y = whifun_isnan_or_empty(x,field)
%WHIFUN_ISNAN_OR_EMPTY Checks if a specific field in a structure is missing, empty, or NaN.
%
%   Y = WHIFUN_ISNAN_OR_EMPTY(X, FIELD)
%
%   This utility function provides a robust check for the existence and
%   validity of a specified field within a MATLAB structure. It is commonly
%   used in programs to validate configuration settings or subject data fields.
%
%   Input Arguments:
%   X     - The input MATLAB structure (struct).
%   FIELD - A character vector or string specifying the name of the field to check
%           (e.g., 'data_path').
%
%   Output Arguments:
%   Y     - A logical scalar (true or false).
%           Y = true if:
%             1. The field does not exist in the structure X (as determined by `isfield`).
%             2. The field exists but its value is an empty array (`isempty(x)`).
%             3. The field exists and its value is a NaN (Not-a-Number) and numeric.
%           Y = false otherwise (field exists and contains non-empty, non-NaN data).
%
%   Author: Pratik Jain

if isfield(x,field)
    x = x.(field);
    y = isempty(x) || (isnumeric(x) && isnan(x));
else
    y = true;
end