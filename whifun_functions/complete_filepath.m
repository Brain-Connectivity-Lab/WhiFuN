function out_path = complete_filepath(varargin)
% input -->
% path = path with patterns
% if path contains more than one file, function will return the folder
% where the files are

if length(varargin) > 1
    path = '';
    for i = 1:nargin
        path = fullfile(path,varargin{i});
    end
elseif length(varargin)  == 1
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