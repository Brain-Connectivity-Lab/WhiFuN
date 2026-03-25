function [Subj_list_1,voxel_func,n_image,tr,no_func,report] = whifun_check_data_func(Subj_list_1,comm_sess_name,func_folder_name,func_data_name,output_folder,report)
% WHIFUN_CHECK_DATA_FUNC Checks for functional data and extracts its properties.
%
%   [Subj_list_1, voxel_func, n_image, tr, no_func, report] = WHIFUN_CHECK_DATA_FUNC(...)
%   is a high-level function that orchestrates the process of finding a
%   subject's functional neuroimaging data file, resolving potential
%   ambiguities, and extracting key parameters like voxel size, number of
%   volumes, and TR.
%
%   The function first calls `whifun_check_func_file` to find the file. If
%   multiple files are found, it sorts them by creation date and selects
%   the oldest one. It then calls `whifun_get_func_info` and
%   `whifun_get_func_TR` to extract the metadata.
%
%   If no functional data file is found, the function sets a flag (`no_func`)
%   to 1, sets the subject's `error` flag to 1, and initializes all output
%   parameters to `NaN`. This allows a calling script to gracefully handle
%   missing data.
%
%   Input Arguments:
%   Subj_list_1      - A single subject structure.
%   comm_sess_name   - The common session folder name (e.g., 'ses-01').
%   func_folder_name - The name of the functional data subfolder (e.g., 'func').
%   func_data_name   - The base name of the functional data file (e.g., 'task-rest_bold').
%   report           - (Optional) A string array for accumulating report messages.
%
%   Output Arguments:
%   Subj_list_1  - The updated subject structure with functional file info.
%   voxel_func   - A 1x3 array of the functional data's voxel dimensions, or NaN.
%   n_image      - The number of images (time points), or NaN.
%   tr           - The repetition time (TR), or NaN.
%   no_func      - A flag: 0 if data found, 1 if not.
%   report       - A string array with any warning or error messages.
%
%   Author: Pratik Jain
%   See also WHIFUN_CHECK_FUNC_FILE, WHIFUN_GET_FUNC_INFO, WHIFUN_GET_FUNC_TR.
if ~exist('report','var')
    report = "";
    p = 1;
elseif strlength(report) == 0
    p = 1; % Initialize p if report is empty
else
    p = length(report) + 1;
end

[now_func_path,report(p)] = whifun_check_func_file(Subj_list_1,comm_sess_name,func_folder_name,func_data_name);
if strlength(report) ~= 0
    p = p+1;
end
if length(now_func_path)>1  % If more than one func files found choose the one that was created the first

    [~,idx] = sort([now_func_path.datenum]);
    now_func_path = now_func_path(idx);
    now_func_path(2:end) = [];
    warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first.']);
end
if ~isempty(now_func_path)
    [Subj_list_1,voxel_func,n_image] = whifun_get_func_info(now_func_path,Subj_list_1,output_folder);
    [Subj_list_1,tr,report(p)] = whifun_get_func_TR(now_func_path,Subj_list_1);
    no_func = 0;
else
    no_func = 1;
    Subj_list_1.error = 1;
    voxel_func = [nan,nan,nan];
    n_image = nan;
    tr = nan;
end