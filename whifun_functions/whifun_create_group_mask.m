function [group_mask_path,d] = whifun_create_group_mask(out_analysis_path,Subj_list,grp_mask_name,indi_thres,grp_thres,over_write,d_flag,d,steps_,tot_steps)
% WHIFUN_CREATE_GROUP_MASK Creates a group-level White Matter (WM) mask.
%
%   [group_mask_path, d] = WHIFUN_CREATE_GROUP_MASK(out_analysis_path, Subj_list, ...)
%   generates a group-level WM mask by combining the individual WM masks
%   from all subjects. This process ensures that the final mask is robust
%   and represents the most consistently identified WM regions across the
%   group.
%
%   The function performs the following steps:
%   1.  **Individual Mask Thresholding**: For each subject, it identifies
%       voxels that have a WM probability greater than `indi_thres`
%       (individual threshold). It counts how many subjects meet this
%       criterion for each voxel.
%   2.  **Subcortical Structures Removal**: It removes voxels corresponding
%       to subcortical structures (e.g., putamen) from the WM mask, as they
%       are often misclassified in SPM segmentation. This is done by referencing
%       a standard atlas (e.g., Harvard-Oxford).
%   3.  **Group-Level Thresholding**: It applies a group-level threshold
%       (`grp_thres`) to the voxel count. A voxel is included in the final
%       group mask only if it was identified as WM in a `grp_thres` percentage
%       of subjects.
%   4.  **Functional Data Check**: It removes any voxels from the mask that
%       do not contain valid functional data (i.e., are zero or NaN) in
%       80% percentage of subjects. This prevents the
%       inclusion of voxels that have no data.
%   5.  **Save Mask**: The final group mask is saved as a NIfTI file.
%
%   This function is a critical step for preparing data for group-level
%   analyses, such as functional network connectivity or group-level seed-based
%   correlations, by creating a common mask for all subjects.
%
%   Input Arguments:
%   out_analysis_path - The directory to save the final group mask.
%   Subj_list         - A structure array of all subjects.
%   grp_mask_name     - The name of the output group mask file.
%   indi_thres        - The individual-level probability threshold for WM.
%   grp_thres         - The group-level percentage threshold for WM.
%   over_write        - A logical flag to force overwriting of an existing mask.
%   d_flag            - (Optional) A flag for GUI progress updates.
%   d, wm_steps, tot_wm_steps - (Optional) Parameters for GUI progress bar.
%
%   Output Arguments:
%   group_mask_path - The full path to the created group mask file.
%   d               - The updated GUI progress bar handle.
%
%   Author: Pratik Jain
%   See also RESLICE_DATA, NIFTIINFO, NIFTIREAD, FIND, MKDIR, WARNING.


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

%% 1 Create Group WM Mask

grp_thres = grp_thres/100; % Convert to a number between 0 and 1;

disp('##########################################################################################')
disp('Creating the group WM masks ')
temp_path = mfilename('fullpath');                                                 % path of the toolbox
preproc_code_path = fileparts(fileparts(temp_path));                                          % path where the code is stored
addpath(fullfile(preproc_code_path,'BrainNetViewer_20191031'))                     % Add path to the WhiFuN compatible BrainNet toolbox
HO_atlas_filename = fullfile(preproc_code_path,'Atlases','HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii.gz'); %%% choose the HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii from the mask file

addpath(fullfile(preproc_code_path,'whifun_functions'))

group_mask_path = fullfile(output_folder,grp_mask_name);
grp_mask_dir = whifun_create_file(over_write,group_mask_path);


if isempty(grp_mask_dir)

    func_img1_filename = Subj_list(1).final_func_MNI; % get one func file for the nifti header
    func_img1_filename_info = niftiinfo(func_img1_filename);
    size_image = func_img1_filename_info.ImageSize;
    WMmask_full = zeros(size_image(1:3));                         % Initializing the WM Mask
    disp(['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres) ' for every participant'])
    for subji = 1:length(Subj_list)      % For loop on number of participants
        if d_flag
            disp(['Currently Processing ' Subj_list(subji).name])
        else
            disp(['Currently Processing ' Subj_list(subji).name ' ' num2str(subji) ' out of ' num2str(length(Subj_list))])
        end
        % getting the current participant's segmentation directory

        current_WM_mask = reslice_data(Subj_list(subji).WM_MNI, func_img1_filename, 0);      % resize to func space
        WMmask_full(current_WM_mask>=indi_thres) = WMmask_full(current_WM_mask>=indi_thres) + 1; % Count of every voxel with prob greater than indi_thresh across all participants
        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres) ' for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of WM-FN terminated by User')
                return
            end
        end
    end

    WMmask_full = WMmask_full./length(Subj_list);                        % Probability of every voxel having WM prob greater than indi_thres across participants
    %% Optional stage - remove subcortical structures from the white-matter mask
    % these structures (putamen, globus pallidus) are erroneously identified in SPM as
    % white-matter due to their high iron content (see Lorio et al. 2016, NeuroImage).
    % We used here the Harvard-Oxford Atlas (obtained from DPABI toolbox) to delineate these subcortical structures,
    % and then remove them from the WM mask (and add them to the GM mask).

    % reading the Harvard-Oxford atlas and resampling it to the functional image's resolution
    HO_atlas = reslice_data(HO_atlas_filename, func_img1_filename, 0);

    % find the voxels defined as subcortical structures
    indices_subcortical = [find(HO_atlas==2010);	find(HO_atlas==2049);	find(HO_atlas==3011);	find(HO_atlas==3050);	find(HO_atlas==4012);	find(HO_atlas==4051);	find(HO_atlas==5013);	find(HO_atlas==5052);	find(HO_atlas==8026);	find(HO_atlas==8058);];

    % Remove these voxels from the white-matter mask and add them to the grey-matter mask
    WMmask_full(indices_subcortical)=0;

    %% Thresholding to find voxels defined as WM or GM in a big enough percent of the participants
    WMmask = WMmask_full >= grp_thres;               % threshold for WM mask - >60% probability of identification as white-matter
    WM_voxels = find(WMmask>0);

    %% 2 Removal of parts of the mask for which functional data exists only in <80% of participants, such as the spinal cord
    threshold_notnan = 0.8;     % 80% of voxels need to be not NaN for each voxel to be included in the mask

    % defining the directory with average functional data of all participants,
    % arranged in separate directories for each participant

    % reading these files and counting how many participants have data in each voxel
    disp('Removal of parts of the mask for which functional data exists only in <80% of participants')
    num_subjs_notnan_WM = zeros(length(WM_voxels),1);
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

        % counting, for each voxel, in how many participants it is "good"
        num_subjs_notnan_WM(WM_voxels_with_data) = num_subjs_notnan_WM(WM_voxels_with_data) + 1;
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

    %% Saving the resulting masks
    niftisave(WMmask,fullfile(output_folder,grp_mask_name),func_img1_filename_info);
    % save_mat_to_nifti(func_img1_filename, WMmask, fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'));
else
    if d_flag
        steps_ = steps_ + length(Subj_list)*2;
        d.Value = steps_/tot_steps;
    end
    disp('Group WM mask is found hence skipping this step')

end

disp('Group WM mask is done')
disp('##########################################################################################')
