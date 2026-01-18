function out_path = complete_filepath(varargin)
%COMPLETE_FILEPATH Resolves a full file path from segments or wildcards.
%
%   OUT_PATH = COMPLETE_FILEPATH(DIR, SUBDIR, FILENAME) joins the input 
%   segments using the system's file separator and attempts to resolve 
%   the final path. If wildcards are used, it returns the first match.
%
%   INPUTS:
%       varargin - Any number of string or character array segments 
%                  representing a path (e.g., 'C:', 'Data', 'sub-*_T1w.nii').
%
%   OUTPUTS:
%       out_path - A single string of the resolved path. Returns an empty 
%                  string if the path cannot be found.
%
%   NOTES:
%       - If multiple files match a wildcard, the function currently returns 
%         the folder path if multiple matches exist, or the full filename 
%         if only one match exists.
%       - If the path is not found, a warning is displayed in the console.
%
%   EXAMPLE:
%       % Find a specific BIDS file using a wildcard
%       path = complete_filepath('/data/project', 'sub-01', 'ses-*', '*_bold.nii.gz');
%
%   See also FULLFILE, DIR, STRING.

% 1. Construct the path from input segments

if length(varargin) > 1
    path = '';
    for i = 1:nargin
        path = fullfile(path,varargin{i});
    end
elseif isscalar(varargin)
    path = string(varargin);
end
try
temp = dir(path);

if length(temp) > 1
    out_path = temp(1).folder;
else
    out_path = fullfile(temp.folder,temp.name); 
end

catch
    disp('Path Not found')
    disp('Trying to open')
    disp(path)
    
    out_path = '';
end