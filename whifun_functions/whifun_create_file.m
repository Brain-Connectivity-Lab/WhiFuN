function file_dir = whifun_create_file(over_write,file_path)
% WHIFUN_CREATE_FILE Manages file existence and overwriting.
%
%   file_dir = WHIFUN_CREATE_FILE(over_write, file_path) checks for the
%   existence of a file and handles overwriting based on a flag.
%
%   This is a utility function for ensuring a clean workspace. If the
%   `over_write` flag is set to true (1), the function will delete any
%   existing file at `file_path` before proceeding. If the flag is false
%   (0), it simply returns the directory information if the file exists.
%
%   Input Arguments:
%   over_write - A logical value (0 or 1). If 1, any existing file will be
%                deleted.
%   file_path  - The full path to the file to be checked.
%
%   Output Arguments:
%   file_dir - A `dir` structure of the file if it exists and `over_write`
%              is 0, or an empty `dir` structure if the file was deleted or
%              did not exist.
%
%   Example:
%       % Check for a file without overwriting
%       % file_info = whifun_create_file(0, 'C:\data\report.txt');
%
%       % Delete a file if it exists and create a new one
%       % file_info = whifun_create_file(1, 'C:\data\report.txt');
%
%   Author: Pratik Jain
%   See also DIR, DELETE, FULLFILE, WARNING.
if over_write == 1 % if overwrite is 1, even if the file already exists delete it and create a new one

    file_dir = dir(file_path) ;
    if ~isempty(file_dir)
        delete(fullfile(file_dir.folder,file_dir.name))
        warning(['Deleted ' fullfile(file_dir.folder,file_dir.name) ' as over_write was on.'])
    end
    file_dir = [];

else

    file_dir = dir(file_path) ;
end
