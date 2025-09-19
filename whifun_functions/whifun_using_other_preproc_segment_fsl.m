function whifun_using_other_preproc_segment_fsl(output_folder,only_data_check)
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
    Subj_list = whifun_create_Subj_list(output_folder);
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
Smooth_pre = 's';
if only_data_check
    

    for subji = 1:length(Subj_list)
        if ~exist(fullfile(quality_control_path,'logs'),'dir')
            mkdir(fullfile(quality_control_path,'logs'))
        end
        [log_fileID,errmsg] = fopen(fullfile(quality_control_path,'logs',[Subj_list(subji).name '_log_info.txt']),'a');

        if log_fileID == -1
            error(errmsg)
        end

        disp('..')
        disp(['Currently Processing ' Subj_list(subji).name])
        if ~whifun_isnan_or_empty(Subj_list_1,'GM_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'WM_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'CSF_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'anat_MNI')
            out_fsl_fst = evalc('[gm_prob_path, wm_prob_path, csf_prob_path] = whifun_fsl_fast_seg(Subj_list(subji).anat_MNI)');
        end

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Segmentation using FSL FAST');
        fprintf(log_fileID,'%s',  out_fsl_fst);


        Subj_list(subji).GM_MNI = gm_prob_path;
        Subj_list(subji).WM_MNI = wm_prob_path;
        Subj_list(subji).CSF_MNI = csf_prob_path;
        

        in_func_path = Subj_list(subji).final_func_MNI;
        now_func_path = dir(in_func_path);
        out_func_path = fullfile(now_func_path.folder,[Smooth_pre now_func_path.name]);

        smooth_path = whifun_create_file(over_write,out_func_path);
        
        if isempty(smooth_path)
            [smooth_op_gm, smooth_op_wm] = whifun_smooth_WM_GM_separately_fast(in_func_path, gm_prob_path, wm_prob_path ,Smooth_pre, 4, 0);
        end

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Smoothing White Matter and Gray Matter seperately\n');
        fprintf(log_fileID,'Gray Matter Smoothing\n');
        fprintf(log_fileID,'%s',  smooth_op_gm);
        fprintf(log_fileID,'White Matter Smoothing\n');
        fprintf(log_fileID,'%s',  smooth_op_wm);

        fclose(log_fileID);

        Subj_list(subji).func_MNI = in_func_path;

        Subj_list(subji).final_func_MNI = out_func_path;
        whifun_qc(quality_control_path,Subj_list(subji));
    end

    disp(['WhiFuN has created the Quality check plots. Please check the : ' quality_control_path])
end

disp('WhiFuN has created the output folder which can be loaded into the GUI for further analysis.')

my_writetable(struct2table(Subj_list),fullfile(output_folder,'Subj_list.csv'))