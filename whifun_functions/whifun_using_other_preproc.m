function whifun_using_other_preproc(output_folder,only_data_check)
% WHIFUN_USING_OTHER_PREPROC Runs QC on data preprocessed by other software.
%
%   WHIFUN_USING_OTHER_PREPROC(output_folder) provides a streamlined workflow
%   for performing quality control checks on fMRI data that has been not
%   been preprocessed using WhiFuN.
%
%   This function guides the user through the process of creating a subject
%   list and then generating a series of quality control plots. It is
%   designed to be a flexible entry point for users who want to leverage
%   the QC capabilities of this toolbox without running the entire
%   preprocessing pipeline.
%
%   The function performs the following steps:
%   1. **Create Subject List**: It calls `whifun_create_Subj_list` to
%      interactively generate a structured subject list. This list links
%      each subject to their preprocessed functional and anatomical files.
%   2. **Data Check**: It validates the existence of the specified files
%      and extracts key metadata like the number of volumes (n_image) and
%      voxel dimensions. It then generates a summary report and plots.
%   3. **Run QC**: It iterates through each subject in the list and calls
%      the `whifun_qc` function to generate a full suite of quality control
%      plots. These plots cover various aspects of the data, such as motion,
%      normalization, and functional connectivity sanity checks.
%
%   This workflow is ideal for users who want to verify the quality of their
%   preprocessed data before proceeding with advanced analysis.
%
%   Input Arguments:
%   output_folder   - (Optional) The directory to save all output. If not
%                     provided, a dialog box prompts the user to select one.
%   only_data_check - (Optional) A flag to only run the initial data check
%                     without generating all the QC plots. Defaults to 1.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_SUBJ_LIST, WHIFUN_CHECK_DATA, WHIFUN_PLOT_DATA_CHECK_FIGURES, WHIFUN_QC.


if nargin == 1

    if ~exist(fullfile(output_folder,'Subj_list.csv'),'file')
        Subj_list = whifun_create_Subj_list(output_folder);
    else
        Subj_list = load_subjects(output_folder,'Subj_list.csv',1);
    end
    only_data_check = 1;
elseif nargin == 0
    [Subj_list,output_folder] = whifun_create_Subj_list;
    only_data_check = 1;
end

quality_control_path = fullfile(output_folder,'Quality_control');

if ~exist("quality_control_path","dir")
    mkdir(quality_control_path);
end

for subji = 1:length(Subj_list)
    if ~isempty(Subj_list(subji).final_func_MNI)
        [func_fold,func_name,ext] = fileparts(Subj_list(subji).final_func_MNI);
        Subj_list(subji).func_folder = func_fold;
        Subj_list(subji).func_name = [func_name ext];
    else
        Subj_list(subji).func_folder = '';
        Subj_list(subji).func_name = '';
        warning(['No final func MNI found for Participant: ' Subj_list(subji).name '. Func QC plots wont be created for this Participant'])
    end

    if ~isempty(Subj_list(subji).anat_MNI)
        [anat_fold,anat_name,ext] = fileparts(Subj_list(subji).anat_MNI);
        Subj_list(subji).anat_folder = anat_fold;
        Subj_list(subji).anat_name = [anat_name ext];
    else
        Subj_list(subji).anat_folder = '';
        Subj_list(subji).anat_name = '';
        warning(['No Anat func MNI found for Participant: ' Subj_list(subji).name '. Anat QC plots wont be created for this Participant'])
    end
end


[report,n_image,tr,voxel_func,voxel_anat,mis_data] = whifun_check_data(output_folder,Subj_list,'','','','','');
disp(report)
whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)
Subj_list = load_subjects_all(output_folder,'Subj_list.csv');

if only_data_check

    for subji = 1:length(Subj_list)
        disp('..')
        disp(['Currently Processing ' Subj_list(subji).name])

        whifun_qc(quality_control_path,Subj_list(subji));
    end

    disp(['WhiFuN has created the Quality check plots. Please check the : ' quality_control_path])
end

disp('WhiFuN has created the output folder which can be loaded into the GUI for further analysis.')