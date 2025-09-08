function [now_func_path,report] = whifun_check_func_file(Subj_list_1,comm_sess_name,func_folder_name,func_data_name)
% WHIFUN_CHECK_FUNC_FILE Verifies the existence of a functional data file.
%
%   [now_func_path, report] = WHIFUN_CHECK_FUNC_FILE(Subj_list_1, comm_sess_name, func_folder_name, func_data_name)
%   searches for a functional neuroimaging data file (`.nii` or `.nii.gz`)
%   for a given subject. It constructs the expected file path and checks
%   if the file exists.
%
%   The function first tries to find the file using the path stored in the
%   subject structure. If that fails, it tries a common alternative with an
%   added '.nii*' extension. If the file is still not found, it generates a
%   detailed error report, including which part of the path (session folder,
%   functional folder, or the file itself) is missing.
%
%   This function is critical for robust preprocessing pipelines, ensuring
%   that the data for each subject is in the expected location before
%   processing begins.
%
%   Input Arguments:
%   Subj_list_1      - A single subject structure, which must contain
%                      `func_folder` and `func_name` fields.
%   comm_sess_name   - The common session folder name (e.g., 'ses-01').
%   func_folder_name - The name of the functional data subfolder (e.g., 'func').
%   func_data_name   - The base name of the functional data file (e.g., 'task-rest_bold').
%
%   Output Arguments:
%   now_func_path - A `dir` structure if the file is found, otherwise empty.
%   report        - A string containing an error message if the file is not
%                   found, otherwise an empty string.
%
%   Author: Pratik Jain
%   See also DIR, FULLFILE, ISEMPTY, ISFOLDER, STRCHR.

now_func_path = dir(fullfile(Subj_list_1.func_folder,Subj_list_1.func_name)) ;


if isempty(now_func_path)
    msg = ['No func data found for participant: ' Subj_list_1.name];
    report = msg;
    disp([msg 'trying to open: ' fullfile(Subj_list_1.func_folder,Subj_list_1.func_name)])
    if strcmp(Subj_list_1.func_folder,fullfile(Subj_list_1.folder, Subj_list_1.name,comm_sess_name, func_folder_name))
        if ~isfolder(complete_filepath(Subj_list_1.folder, Subj_list_1.name,comm_sess_name))
            msg = ['The intermediate folder name "' char(comm_sess_name) '" not found'];
            report = msg;
        elseif ~isfolder(complete_filepath(Subj_list_1.folder, Subj_list_1.name,comm_sess_name,func_folder_name))
            msg = ['The func folder name "' char(func_folder_name) '" not found.'];
            report = msg;
        else
            msg = ['The func image name "' char(func_data_name) '.nii*' '" not found'];
            report = msg;
        end

    end
end

if ~exist('report','var')
    report = '';
end