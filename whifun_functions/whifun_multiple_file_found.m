function now_file_path = whifun_multiple_file_found(now_file_path,anat_func)

% WHIFUN_MULTIPLE_FILE_FOUND Resolves multiple file ambiguities.
%
%   now_file_path = WHIFUN_MULTIPLE_FILE_FOUND(now_file_path, anat_func)
%   is a utility function to handle cases where `dir` returns more than one
%   file, for example, due to duplicates or different file extensions (`.nii`
%   and `.nii.gz`).
%
%   The function sorts the list of files by their creation date and keeps
%   only the oldest one, which is typically the original data file. It also
%   displays a warning message to inform the user of the resolution. This
%   ensures that the preprocessing pipeline consistently uses a single,
%   correct file for each subject.
%
%   Input Arguments:
%   now_file_path - A `dir` structure array containing multiple file entries.
%   anat_func     - (Optional) A string to identify the type of file (e.g.,
%                   'anatomical' or 'functional') for a more descriptive
%                   warning message. Defaults to an empty string.
%
%   Output Arguments:
%   now_file_path - A single-element `dir` structure representing the oldest
%                   file found.
%
%   Author: Pratik Jain
%   See also DIR, SORT, WARNING.

if ~exist("anat_func",'var')
    anat_func = '';
end
if length(now_file_path) > 1
    [~,idx] = sort([now_file_path.datenum]);
    now_file_path = now_file_path(idx);
    now_file_path(2:end) = [];
    warning(['More than one ' anat_func ' files found. Choosing the file ' ,char(now_file_path(1).name), ' as it was created the first.']);
else

    warning(['No ' anat_func ' files found, Structure empty.']);
end