function [Subj_list_1,voxel_anat,no_anat,report] = whifun_check_data_anat(Subj_list_1,comm_sess_name,anat_folder_name,anat_data_name,report)
%WHIFUN_CHECK_DATA_ANAT Checks for the existence and retrieves metadata of the anatomical NIfTI file for a single subject.
%
%   [SUBJ_LIST_1, VOXEL_ANAT, NO_ANAT, REPORT] = WHIFUN_CHECK_DATA_ANAT(SUBJ_LIST_1, COMM_SESS_NAME, ANAT_FOLDER_NAME, ANAT_DATA_NAME, REPORT)
%
%   This is a helper function for the initial data quality check process. It
%   locates the anatomical file, handles cases where multiple files are
%   found, and records the file's metadata and status.
%
%   Input Arguments:
%   SUBJ_LIST_1      - A single-element structure from the subject list, containing the subject's name and path information.
%   COMM_SESS_NAME   - Common session name/pattern for anatomical data (e.g., 'ses-01').
%   ANAT_FOLDER_NAME - Name of the anatomical data subdirectory (e.g., 'anat').
%   ANAT_DATA_NAME   - Pattern or name of the anatomical data file (e.g., 'T1w.nii').
%   REPORT           - (Optional) A string array containing previous report messages.
%
%   Output Arguments:
%   SUBJ_LIST_1      - The updated subject structure, including anatomical file path and metadata.
%   VOXEL_ANAT       - A 1x3 vector containing the anatomical voxel dimensions [X, Y, Z].
%   NO_ANAT          - A flag: 0 if the anatomical file was found, 1 if it was missing.
%   REPORT           - The updated report string array, including any new warnings or errors.
%
%   Dependencies:
%   - `whifun_check_anat_file`
%   - `whifun_get_anat_info` 
%
%   Author: Pratik Jain

if ~exist('report','var')
    report = "";
    p = 1;
elseif strlength(report) == 0
    p = 1; % Initialize p if report is empty
else
    p = length(report) + 1;
end

[now_anat_path,report(p)] = whifun_check_anat_file(Subj_list_1,comm_sess_name,anat_folder_name,anat_data_name);

if length(now_anat_path)>1  % If more than one anat files found choose the one that was created the first

    [~,idx] = sort([now_anat_path.datenum]);
    now_anat_path = now_anat_path(idx);
    now_anat_path(2:end) = [];
    warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
end
if ~isempty(now_anat_path)
    [Subj_list_1,voxel_anat] = whifun_get_anat_info(now_anat_path,Subj_list_1);
    no_anat = 0;
else
    no_anat = 1;
    Subj_list_1.error = 1;
    voxel_anat = [nan,nan,nan];
end