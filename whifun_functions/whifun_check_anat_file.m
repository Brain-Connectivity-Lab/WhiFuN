function [now_anat_path,report] = whifun_check_anat_file(Subj_list_1,comm_sess_name,anat_folder_name,anat_data_name)
% WHIFUN_CHECK_ANAT_FILE Verifies the existence of an anatomical data file.
%
%   [now_anat_path, report] = WHIFUN_CHECK_ANAT_FILE(Subj_list_1, comm_sess_name, anat_folder_name)
%   searches for an anatomical neuroimaging data file (`.nii` or `.nii.gz`)
%   for a given subject. It constructs the expected file path and checks if
%   the file exists.
%
%   The function first uses the path information from the subject structure
%   and checks for a NIfTI file with a `.nii*` extension. If the file is
%   not found, it generates a detailed error report, including which part of
%   the path (session folder, anatomical folder, or the file itself) is
%   missing.
%
%   This function is essential for robust preprocessing pipelines, ensuring
%   that the anatomical data for each subject is in the expected location
%   before processing begins.
%
%   Input Arguments:
%   Subj_list_1      - A single subject structure, which must contain
%                      `anat_folder` and `anat_name` fields.
%   comm_sess_name   - The common session folder name (e.g., 'ses-01').
%   anat_folder_name - The name of the anatomical data subfolder (e.g., 'anat').
%
%   Output Arguments:
%   now_anat_path - A `dir` structure if the file is found, otherwise empty.
%   report        - A string containing an error message if the file is not
%                   found, otherwise an empty string.
%
%   Author: Pratik Jain
%   See also DIR, FULLFILE, ISEMPTY, ISFOLDER, STRCHR.
now_anat_path = dir(fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name)) ;


if isempty(now_anat_path)
    msg = ['No anat data found for participant: ' Subj_list_1.name];
    report = msg;
    disp([msg 'trying to open: ' fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name)])
    if strcmp(Subj_list_1.anat_folder,fullfile(Subj_list_1.folder, Subj_list_1.name,comm_sess_name, anat_folder_name))
        if ~isfolder(complete_filepath(Subj_list_1.folder, Subj_list_1.name,comm_sess_name))
            msg = ['The intermediate folder name "' char(comm_sess_name) '" not found'];
            report = msg;
        elseif ~isfolder(complete_filepath(Subj_list_1.folder, Subj_list_1.name,comm_sess_name,anat_folder_name))
            msg = ['The anat folder name "' char(anat_folder_name) '" not found.'];
            report = msg;
        else
            msg = ['The anat image name "' char(anat_data_name) '.nii*' '" not found'];
            report = msg;
        end
    end
end
if ~exist('report','var')
    report = '';
end