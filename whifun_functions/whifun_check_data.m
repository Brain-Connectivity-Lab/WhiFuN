function [report,n_image,tr,voxel_func,voxel_anat,mis_data] =  whifun_check_data(output_folder,Subj_list_all,comm_sess_name,func_folder_name,func_data_name,anat_folder_name,anat_data_name,d)
%WHIFUN_CHECK_DATA Performs an initial, comprehensive check on fMRI and anatomical
%   data files for all subjects in a list, recording key metadata and flagging
%   missing files.
%
%   [REPORT, N_IMAGE, TR, VOXEL_FUNC, VOXEL_ANAT, MIS_DATA, SUBJ_LIST_ALL] = ...
%       WHIFUN_CHECK_DATA(OUTPUT_FOLDER, SUBJ_LIST_ALL, COMM_SESS_NAME, FUNC_FOLDER_NAME, FUNC_DATA_NAME, ANAT_FOLDER_NAME, ANAT_DATA_NAME, D)
%
%   This is typically the first step in a neuroimaging pipeline, ensuring all
%   required files exist and have consistent properties before processing begins.
%
%   Input Arguments:
%   OUTPUT_FOLDER       - Path to the directory where the updated subject list CSV will be saved.
%   SUBJ_LIST_ALL       - The master structure array containing subject names and metadata.
%   COMM_SESS_NAME      - Common session name/pattern for functional data (e.g., 'ses-01').
%   FUNC_FOLDER_NAME    - Name of the functional data subdirectory (e.g., 'func').
%   FUNC_DATA_NAME      - Pattern or name of the functional data file (e.g., 'bold.nii').
%   ANAT_FOLDER_NAME    - Name of the anatomical data subdirectory (e.g., 'anat').
%   ANAT_DATA_NAME      - Pattern or name of the anatomical data file (e.g., 'T1w.nii').
%   D                   - (Optional) Handle for a progress dialogue box (used in GUIs).
%
%   Output Arguments:
%   REPORT              - A string array containing status messages and any errors/warnings.
%   N_IMAGE             - Vector of the number of time points (N) for each subject's functional data.
%   TR                  - Vector of the Repetition Time (TR) for each subject's functional data.
%   VOXEL_FUNC          - Matrix (N x 3) of functional voxel dimensions for each subject.
%   VOXEL_ANAT          - Matrix (N x 3) of anatomical voxel dimensions for each subject.
%   MIS_DATA            - Flag: 1 if any functional or anatomical files were missing and subjects were removed; 0 otherwise.
%   SUBJ_LIST_ALL       - The updated master structure array, including new fields and exclusion flags.
%
%   Dependencies:
%   - `whifun_create_fields`, `whifun_initialise_manual_motion_error_fields`
%   - `whifun_check_data_func`, `whifun_check_data_anat` (assumed to read NIfTI info and update subject list)
%   - `whifun_isnan_or_empty`, `my_writetable`
%   - `msgbox` (for displaying missing file summaries)
%
%   Author: Pratik Jain

if exist('d','var')
    d_exists = 1;
else
    d_exists = 0;
end
%%          Data initial Check
disp('##########################################################################################')
disp('Initial Data Check started')
report = "";
p = 1;
% Read image information for every participant
n_image = inf(length(Subj_list_all),1);
tr = inf(length(Subj_list_all),1);
voxel_func = inf(length(Subj_list_all),3);
voxel_anat = inf(length(Subj_list_all),3);
no_func = inf(length(Subj_list_all),1);
no_anat = inf(length(Subj_list_all),1);

Subj_list_all = whifun_create_fields(Subj_list_all);
for subji=1:length(Subj_list_all)
    if d_exists
        if d.CancelRequested
            msg = 'Initial check canceled by the User';
            report(p) = msg;
            return
        end
        d.Value = subji/length(Subj_list_all);
        d.Message = ['Currently Checking ' Subj_list_all(subji).name];
    else
        disp(['Currently Checking ' Subj_list_all(subji).name])
    end

    Subj_list_all(subji) = whifun_initialise_manual_motion_error_fields(Subj_list_all(subji));
    if ~Subj_list_all(subji).manual_ex
        [Subj_list_all(subji),voxel_func(subji,:),n_image(subji),tr(subji),no_func(subji),report] = whifun_check_data_func(Subj_list_all(subji),comm_sess_name,func_folder_name,func_data_name,output_folder,report);
        if strlength(report) ~= 0
            p = length(report)+1;
        end
        
        if ~whifun_isnan_or_empty(Subj_list_all,'anat_folder') && ~whifun_isnan_or_empty(Subj_list_all,'anat_name')
            [Subj_list_all(subji),voxel_anat(subji,:),no_anat(subji),report] = whifun_check_data_anat(Subj_list_all(subji),comm_sess_name,anat_folder_name,anat_data_name,output_folder,report);
            if strlength(report) ~= 0
                p = length(report)+1;
            end
        else
            no_anat = 1;
            voxel_anat = [nan,nan,nan];
        end
    end

end

my_writetable(struct2table(Subj_list_all), fullfile(output_folder,"Subj_list.csv"))
n_image(isinf(n_image)) = [];
tr(isinf(tr)) = [];
voxel_func(isinf(voxel_func(:,1)),:) = [];
voxel_anat(isinf(voxel_anat(:,1)),:) = [];
no_func(isinf(no_func)) = [];
no_anat(isinf(no_anat)) = [];

if nnz(no_func)
    msg_test = ['Total Number of participants found in the participant folder was ' num2str(length(Subj_list_all)) ' but ' num2str(nnz(no_func)) ' were removed as they did not have func files.'];
    msgbox(msg_test,'Missing func images')
    mis_data = 1;
end

if nnz(no_anat)
    msg_test = ['Total Number of participants found in the participant folder was ' num2str(length(Subj_list_all)) ' but ' num2str(nnz(no_anat)) ' were removed as they did not have anat files'];
    msgbox(msg_test,'Missing anat images')
    mis_data = 1;
end

if ~exist('mis_data','var')
    mis_data = 0;
end
disp('Initial Data Check ended')
disp('##########################################################################################')

if p == 1
    report(p) = 'Data check completed Sucessfully';
end