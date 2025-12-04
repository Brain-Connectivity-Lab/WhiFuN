function [group_mask_WM_path,group_mask_GM_path,d] = whifun_create_group_mask(out_analysis_path,Subj_list,grp_WM_mask_name,indi_thres_wm,grp_thres_wm,grp_GM_mask_name,indi_thres_gm,grp_thres_gm,over_write,d_flag,d,steps_,tot_steps)
%WHIFUN_CREATE_GROUP_MASK Creates group-level White Matter (WM) and Gray Matter (GM) masks.
%
%   [GROUP_MASK_WM_PATH, GROUP_MASK_GM_PATH, D] = WHIFUN_CREATE_GROUP_MASK(OUT_ANALYSIS_PATH, SUBJ_LIST, GRP_WM_MASK_NAME, INDI_THRES_WM, GRP_THRES_WM, GRP_GM_MASK_NAME, INDI_THRES_GM, GRP_THRES_GM, OVER_WRITE, D_FLAG, D, STEPS_, TOT_STEPS)
%
%   This function creates group-level WM and GM masks based on individual
%   segmentation maps (e.g., from SPM/CAT) and functional data coverage.
%
%   Input Arguments:
%   OUT_ANALYSIS_PATH   - Main output directory where 'Group_Masks' folder will be created.
%   SUBJ_LIST           - Structure array containing subject information, including
%                         paths to individual WM ('WM_MNI'), GM ('GM_MNI')
%                         segmentation maps in MNI space, and final functional
%                         images ('final_func_MNI').
%   GRP_WM_MASK_NAME    - Filename for the output group WM mask (e.g., 'group_wm_mask.nii').
%   INDI_THRES_WM       - Individual-level WM probability threshold (e.g., 0.8).
%   GRP_THRES_WM        - Group-level WM consensus threshold (0-100%) for final inclusion.
%                         A voxel is included if its WM probability (from INDI_THRES_WM
%                         step) is above this threshold in a GRP_THRES_WM percentage of subjects.
%   GRP_GM_MASK_NAME    - Filename for the output group GM mask (e.g., 'group_gm_mask.nii').
%   INDI_THRES_GM       - Individual-level GM probability threshold (e.g., 0.6) for initial count.
%   GRP_THRES_GM        - Group-level GM consensus threshold (0-100%) for final inclusion.
%   OVER_WRITE          - Boolean (0 or 1) indicating whether to overwrite existing group masks.
%   D_FLAG, D, STEPS_, TOT_STEPS - (Optional) Parameters for progress dialogue box
%                                  (typically used in a GUI environment).
%
%   Output Arguments:
%   GROUP_MASK_WM_PATH  - Full path to the created or existing group WM mask file.
%   GROUP_MASK_GM_PATH  - Full path to the created or existing group GM mask file.
%   D                   - Updated progress dialogue handle.
%
%   Process Steps:
%   1. **Initialization:** Checks for optional arguments and creates the output directory.
%   2. **Consensus Mask Creation:** For each subject, counts voxels where WM/GM
%      probability is above `INDI_THRES_WM`/`INDI_THRES_GM`.
%   3. **Normalization:** Converts voxel counts to a probability (proportion of subjects).
%   4. **Subcortical Removal:** Removes voxels corresponding to subcortical structures
%      (Putamen, GP, etc.) from the WM mask (and assigns them to GM) using the
%      Harvard-Oxford Atlas to address segmentation artifacts.
%   5. **Group Thresholding:** Applies the `GRP_THRES_WM`/`GRP_THRES_GM` to finalize
%      the WM and GM masks. The GM mask is also constrained to be non-overlapping
%      with the WM mask.
%   6. **Functional Data Coverage Check:** Removes WM/GM voxels where functional data
%      is not present (non-NaN/non-zero) in less than 80% of participants to exclude
%      regions like the spinal cord.
%   7. **Saving:** The final group masks are saved as NIfTI files.
%
%   Requires: 'whifun_create_file', 'reslice_data', 'niftiread', 'niftiinfo', 'niftisave'
%             functions from the WhiFuN toolbox and compatible NIfTI handling.
%
%   Author: Pratik Jain
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end

if ~exist('over_write','var')
    over_write = 0;
end
output_folder = fullfile(out_analysis_path,'Group_Masks');

if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

%% 1 Create Group Masks

grp_thres_wm = grp_thres_wm/100; % Convert to a number between 0 and 1;
grp_thres_gm = grp_thres_gm/100; % Convert to a number between 0 and 1;

disp('##########################################################################################')
disp('Creating the group WM masks ')
temp_path = mfilename('fullpath');                                                 % path of the toolbox
preproc_code_path = fileparts(fileparts(temp_path));                                          % path where the code is stored
addpath(fullfile(preproc_code_path,'BrainNetViewer_20191031'))                     % Add path to the WhiFuN compatible BrainNet toolbox
HO_atlas_filename = fullfile(preproc_code_path,'Atlases','HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii.gz'); %%% choose the HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii from the mask file

addpath(fullfile(preproc_code_path,'whifun_functions'))

group_mask_WM_path = fullfile(output_folder,grp_WM_mask_name);
group_mask_GM_path = fullfile(output_folder,grp_GM_mask_name);

grp_wm_mask_dir = whifun_create_file(over_write,group_mask_WM_path);
grp_gm_mask_dir = whifun_create_file(over_write,group_mask_GM_path);


if isempty(grp_wm_mask_dir) || isempty(grp_gm_mask_dir)

    func_img1_filename = Subj_list(1).final_func_MNI; % get one func file for the nifti header
    func_img1_filename_info = niftiinfo(func_img1_filename);
    size_image = func_img1_filename_info.ImageSize;
    WMmask_full = zeros(size_image(1:3));                         % Initializing the WM Mask
    GMmask_full = zeros(size_image(1:3));                           % Initializing the GM Mask
    disp(['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres_wm) ' for every participant'])
    disp(['Collecting all the voxels that have GM Probability greater than ' num2str(indi_thres_gm) ' for every participant'])
    for subji = 1:length(Subj_list)      % For loop on number of participants
        if d_flag
            disp(['Currently Processing ' Subj_list(subji).name])
        else
            disp(['Currently Processing ' Subj_list(subji).name ' ' num2str(subji) ' out of ' num2str(length(Subj_list))])
        end
        % getting the current participant's segmentation directory

        current_WM_mask = reslice_data(Subj_list(subji).WM_MNI, func_img1_filename, 0);      % resize to func space
        current_GM_mask = reslice_data(Subj_list(subji).GM_MNI, func_img1_filename, 0);
        WMmask_full(current_WM_mask>=indi_thres_wm) = WMmask_full(current_WM_mask>=indi_thres_wm) + 1; % Count of every voxel with prob greater than indi_thresh across all participants
        GMmask_full(current_GM_mask>=indi_thres_gm) = GMmask_full(current_GM_mask>=indi_thres_gm) + 1;
        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres_wm) ' and that have GM probability greater than ' num2str(indi_thres_gm) ' for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of WM-FN terminated by User')
                return
            end
        end
    end
    GMmask_full = GMmask_full./length(Subj_list);
    WMmask_full = WMmask_full./length(Subj_list);                        % Probability of every voxel having WM prob greater than indi_thres across participants
    %% Optional stage - remove subcortical structures from the white-matter mask
    % these structures (putamen, globus pallidus) are erroneously identified in SPM as
    % white-matter due to their high iron content (see Lorio et al. 2016, NeuroImage).
    % We used here the Harvard-Oxford Atlas (obtained from DPABI toolbox) to delineate these subcortical structures,
    % and then remove them from the WM mask (and add them to the GM mask).

    % reading the Harvard-Oxford atlas and resampling it to the functional image's resolution
    HO_atlas = reslice_data(HO_atlas_filename, func_img1_filename, 0);
    delete(fullfile(fileparts(HO_atlas_filename),'HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'))
    % find the voxels defined as subcortical structures
    indices_subcortical = [find(HO_atlas==2010);	find(HO_atlas==2049);	find(HO_atlas==3011);	find(HO_atlas==3050);	find(HO_atlas==4012);	find(HO_atlas==4051);	find(HO_atlas==5013);	find(HO_atlas==5052);	find(HO_atlas==8026);	find(HO_atlas==8058);];

    % Remove these voxels from the white-matter mask and add them to the grey-matter mask
    WMmask_full(indices_subcortical)=0;
    GMmask_full(indices_subcortical)=1;

    %% Thresholding to find voxels defined as WM or GM in a big enough percent of the participants
    WMmask = WMmask_full >= grp_thres_wm;               % threshold for WM mask - >60% probability of identification as white-matter
    WM_voxels = find(WMmask>0);
    GMmask = GMmask_full > grp_thres_gm & ~WMmask;     % threshold for GM mask is more relaxed (20% probability of being GM, and not recognized as WM), for regions with very thin GM such as the top of the brain (otherwise we'll have holes in the mask)
    GM_voxels = find(GMmask>0);

    %% 2 Removal of parts of the mask for which functional data exists only in <80% of participants, such as the spinal cord
    threshold_notnan = 0.8;     % 80% of voxels need to be not NaN for each voxel to be included in the mask

    % defining the directory with average functional data of all participants,
    % arranged in separate directories for each participant

    % reading these files and counting how many participants have data in each voxel
    disp('Removal of parts of the mask for which functional data exists only in <80% of participants')
    num_subjs_notnan_WM = zeros(length(WM_voxels),1);
    num_subjs_notnan_GM = zeros(length(GM_voxels),1);

    for subji = 1:length(Subj_list)      % For loop on number of participants
        if d_flag
            disp(['Currently Processing ' Subj_list(subji).name])
        else
            disp(['Currently Processing ' Subj_list(subji).name ' ' num2str(subji) ' out of ' num2str(length(Subj_list))])
        end

        now_func_path = Subj_list(subji).final_func_MNI;%fullfile( Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]) ;

        % reading the current participant's mean functional file
        if ~isempty(now_func_path)
            curr_filename = dir(now_func_path);
        else
            disp('No average functional image found!')
            break;
        end
        curr_mean_func = mean(niftiread(fullfile(curr_filename.folder,curr_filename.name)),4);  % loading the participants' mean functional image

        % current participant - finding voxels which are not zero or NaN
        WM_voxels_with_data = find(curr_mean_func(WM_voxels)~=0 & ~isnan(curr_mean_func(WM_voxels)));
        % current participant - finding voxels which are not zero or NaN
        GM_voxels_with_data = find(curr_mean_func(GM_voxels)~=0 & ~isnan(curr_mean_func(GM_voxels)));
        % counting, for each voxel, in how many participants it is "good"

        num_subjs_notnan_WM(WM_voxels_with_data) = num_subjs_notnan_WM(WM_voxels_with_data) + 1;
        num_subjs_notnan_GM(GM_voxels_with_data) = num_subjs_notnan_GM(GM_voxels_with_data) + 1;

        clear curr_mean_func;
        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Removing parts of the mask for which functional data exists only in <80% for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of WM-FN terminated by User')
                return
            end
        end
    end

    % Removing voxels with <80% participants in which they are not NaN
    WM_voxels(num_subjs_notnan_WM < threshold_notnan*length(Subj_list)) = [];
    WMmask = zeros(size(WMmask)); WMmask(WM_voxels) = 1;
    GM_voxels(num_subjs_notnan_GM < threshold_notnan*length(Subj_list)) = [];
    GMmask = zeros(size(GMmask)); GMmask(GM_voxels) = 1;

    %% Saving the resulting masks
    niftisave(WMmask,fullfile(output_folder,grp_WM_mask_name),func_img1_filename_info);
    niftisave(GMmask,fullfile(output_folder,grp_GM_mask_name),func_img1_filename_info);
else
    if d_flag
        steps_ = steps_ + length(Subj_list)*2;
        d.Value = steps_/tot_steps;
    end
    disp('Group WM mask is found hence skipping this step')

end

disp('Group WM mask is done')
disp('##########################################################################################')
