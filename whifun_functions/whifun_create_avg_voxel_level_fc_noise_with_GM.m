function [avg_vox_level_FC,wm_group_mask_voxels] = whifun_create_avg_voxel_level_fc_noise_with_GM(cluster_folder,Subj_list,wm_group_mask_path,gm_group_mask_path,sub_sample_choose,over_write,d_flag,d,steps_,tot_steps)
%WHIFUN_CREATE_AVG_VOXEL_LEVEL_FC Creates the group-average Voxel-Level Functional Connectivity (FC) matrix.
%
%   [AVG_VOX_LEVEL_FC, GROUP_MASK_VOXELS] = WHIFUN_CREATE_AVG_VOXEL_LEVEL_FC(CLUSTER_FOLDER, SUBJ_LIST, GROUP_MASK_PATH, SUB_SAMPLE_CHOOSE, WM_OR_GM, FOCUS_REGION_CHECK, FOCUS_REGION_MASK_PATH, OVER_WRITE, ...)
%
%   This function computes the group-average FC matrix between all voxels in a
%   target mask (e.g., WM or GM) and either all or a subsampled subset of
%   those voxels. This average matrix is then used as the input feature matrix
%   for group-level clustering. The function includes memory checks and
%   handles individual subject-specific segmentation masks.
%
%   Input Arguments:
%   CLUSTER_FOLDER      - Output directory for saving the final FC matrix and intermediate files.
%   SUBJ_LIST           - Structure array containing subject information and file paths.
%   GROUP_MASK_PATH     - Full path to the NIfTI file of the group-level target mask (e.g., WM or GM mask).
%   SUB_SAMPLE_CHOOSE   - String flag: 'Subsample' or 'Use entire FC'. Determines if a subsample of voxels is used for features (columns).
%   WM_OR_GM            - String flag: 'WM' or 'GM', used for subsampling density and segmentation checks.
%   FOCUS_REGION_CHECK  - (Optional, default 0) Flag: 1 to exclude a focus region (e.g., Corpus Callosum) from the group mask.
%   FOCUS_REGION_MASK_PATH - (Optional) Path to the NIfTI file of the focus region mask.
%   OVER_WRITE          - (Optional, default 0) Flag: 1 to overwrite existing files, 0 to skip.
%   D_FLAG, D, STEPS_, TOT_STEPS - (Optional) Parameters for progress dialogue box (GUI support).
%
%   Output Arguments:
%   AVG_VOX_LEVEL_FC    - The final group-average FC matrix (N_Voxels_Masked x N_Features).
%   GROUP_MASK_VOXELS   - The linear indices of the remaining valid voxels in the group mask.
%
%   Dependencies: 'whifun_niftiread', 'niftiread', 'whifun_create_file',
%                 'complete_filepath', 'reslice_data'.
%
%   Author: Pratik Jain

if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end


if ~exist("over_write","var")
    over_write = 0;
end
%% loading pre-made group average WM and GM masks (from the script create_average_WM_and_GM_masks.m)
% reading the masks using SPM's functions
%%% input the group white-matter/gray-matter masks
wm_group_mask = niftiread(wm_group_mask_path); %% input the group white-matter mask that excludes callosal voxels
[~, wm_group_mask_name, ~] = fileparts(wm_group_mask_path);
[~, wm_group_mask_name, ~] = fileparts(wm_group_mask_name);

gm_group_mask = niftiread(gm_group_mask_path);
[~, gm_group_mask_name, ~] = fileparts(gm_group_mask_path);
[~, gm_group_mask_name, ~] = fileparts(gm_group_mask_name);
% Excluding Corpus callousum voxels in WM mask if Corpus
% callosum networks are to be found


% finding the locations of white-matter
wm_group_mask_voxels = find(wm_group_mask>0);

gm_group_mask_voxels = find(gm_group_mask>0);


if ~exist(cluster_folder,"dir")
    mkdir(cluster_folder)
end

if ispc
    user = memory;
end
n_WM_voxels = numel(wm_group_mask_voxels);
n_GM_voxels = numel(gm_group_mask_voxels);
txt_name = 'Subsampling_info.txt';

switch sub_sample_choose
    case 'Subsample'
        if ~ispc
            user.MaxPossibleArrayBytes = inf;
        end
        if (n_WM_voxels*n_GM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling,  looking if the voxel subsampled FC is lesser than 80% of Max possible array size
            text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
            fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
            sub_samp = 1;
            fclose(text_sampling);
        else % the voxel FC is too big
            response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
            switch response_
                case 'Yes'
                    text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                    fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                    sub_samp = 1;
                    warning('May get an Memory error');
                    fclose(text_sampling);
                case 'No'
                    text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                    fprintf(text_sampling, 'WM Networks not formed as the subsampled matrix was too big for the PC.');
                    fclose(text_sampling);
                    return
                otherwise
                    return
            end
        end
    case 'Use entire FC'
        if ~ispc
            user.MaxPossibleArrayBytes = inf;
        end
        if n_WM_voxels*n_GM_voxels*8 < 0.8*user.MaxPossibleArrayBytes  % if the voxel-FC matrix size is lesser than 80% of Max possible array size
            %% Choose entire FC
            text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
            fprintf(text_sampling, 'Choosing the entire FC.');
            sub_samp = 0;
            fclose(text_sampling);
        else
            response_ = questdlg('The entire FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. You may subsample to matrix to compute the WM networks?','Memory low','Subsample','Still Use entire FC','Subsample');
            switch response_
                case 'Subsample'
                    if (n_WM_voxels*n_GM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling
                        text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                        fprintf(text_sampling, ['Choosing the subsampling statergy as the Noise-voxel FC matrix is too big for the PC.', 'Max Memory required for the array = ' num2str(n_WM_voxels*n_WM_voxels*8) ' Available memory in PC = ' num2str(0.8*user.MaxPossibleArrayBytes)]);
                        sub_samp = 1;
                        fclose(text_sampling);
                    else % subsampled voxel FC is too big as well
                        response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
                        switch response_
                            case 'Yes'
                                text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                                fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                                sub_samp = 1;
                                warning('May get an Memory error');
                                fclose(text_sampling);
                            case 'No'
                                text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                                fprintf(text_sampling, 'WM Networks not formed as the subsampled matrix was too big for the PC.');
                                fclose(text_sampling);
                                return
                            otherwise
                                return
                        end
                    end
                case 'Still Use entire FC'
                    text_sampling = fopen(fullfile(cluster_folder,txt_name),'a');
                    fprintf(text_sampling, 'Choosing the entire FC as it was choosen by the user.');
                    sub_samp = 0;
                    warning('May get an Memory error');
                    fclose(text_sampling);
                otherwise
                    return
            end
        end
end

%% Computing the data for clustering from each participant
% this data is a NxM matrix:
% - rows of the matrix correspond to all WM voxels
% - columns of the matrix correspond to a subsampled WM matrix, to aid the
%   next stage of clustering by reducing the number of features
% for example for 12,000 white-matter voxels, the matrix will be 12k x 3k
%
% each matrix cell contains the correlation between the corresponding
% voxels' signals, averaged across participants

% defining a sub-sampling of the mask voxels
if sub_samp == 1
    sub_sample_grid = zeros(size(gm_group_mask));    % defining a grid of 1s and 0s across the image
    sub_sample_grid(2:3:end, 2:3:end, 2:2:end) = 1; sub_sample_grid(1:3:end, 1:3:end, 1:2:end) = 1;   % for gray-matter
else
    sub_sample_grid = ones(size(gm_group_mask));    % defining a grid of 1s and 0s across the image
end
sub_sample_grid = sub_sample_grid(gm_group_mask_voxels);   % choosing only locations of gray-matter voxels
sub_sample_grid = find(sub_sample_grid);    % getting the indices of subsampled voxels in the whole mask
% sub_sample_grid = sub_sample_grid(randperm(length(sub_sample_grid)));     % randomly mixing the voxels' indices

% getting the data from each participant - correlation between all WM voxels and the subsampled WM voxels (num_WM_voxels X num_GM_subsampled_voxels)
avg_vox_level_FC = zeros(length(wm_group_mask_voxels),length(sub_sample_grid));
num_subjs_notnan = zeros(length(wm_group_mask_voxels),length(sub_sample_grid));

disp('Creating the average voxel level FC matrix')
% definition of a file name with functional data - so that other files will be resampled to this file's resolution
func_img1_filename = Subj_list(1).final_func_MNI;%complet

out_mat_path = fullfile(cluster_folder,'avg_vox_level_FC_WM_with_GM.mat');
vox_ts_folder = fullfile(cluster_folder,['Vox_ts_from_' wm_group_mask_name '_WM_with_GM_' gm_group_mask_name]);
if ~exist(vox_ts_folder,'dir')
    mkdir(vox_ts_folder)
end
mat_dir = whifun_create_file(over_write,out_mat_path);
if isempty(mat_dir)
    for subji = 1:length(Subj_list)      % For loop on number of participants
        tic
        if d_flag
            disp(['Currently Processing ' Subj_list(subji).name])
        else
            disp(['Currently Processing ' Subj_list(subji).name ' ' num2str(subji) ' out of ' num2str(length(Subj_list))])
        end

        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Creating Voxel-based Noise with GM FC for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of (Noise with GM)-FN terminated by User')
                return
            end
        end
        
        
        out_voxts_mat_path = fullfile(vox_ts_folder,[Subj_list(subji).name '_vox_ts_from_mask_' wm_group_mask_name '_WM_with_GM_' gm_group_mask_name '.mat']);

        vox_ts_dir = whifun_create_file(over_write,out_voxts_mat_path);
        
        if isempty(vox_ts_dir)
            now_func_path = Subj_list(subji).final_func_MNI;%complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));
            func_data = niftiread(now_func_path);
            all_timecourses = reshape(func_data, [size(func_data,1)*size(func_data,2)*size(func_data,3) size(func_data,4)]); % resampling to 2D - num_WM_voxels X num_timepoints
            wm_vox_ts = double(randn(numel(wm_group_mask_voxels),size(func_data,4)));  % getting the signal across time from all white-matter voxels
            gm_vox_ts = double(all_timecourses(gm_group_mask_voxels,:));  % getting the signal across time from all gray-matter voxels

            clear all_timecourses; clear func_data;

            % loading the segmentation files of all participants, for identification of WM voxels in this specific participant
            current_GM_file = dir(Subj_list(subji).GM_MNI);
            current_WM_file = dir(Subj_list(subji).WM_MNI);
            current_CSF_file = dir(Subj_list(subji).CSF_MNI);

            % resampling the segmentation files to the functional image resolution
            current_GM_mask = reslice_data(fullfile(current_GM_file(1).folder,current_GM_file(1).name), func_img1_filename, 0);
            current_WM_mask = reslice_data(fullfile(current_WM_file(1).folder,current_WM_file(1).name), func_img1_filename, 0);
            current_CSF_mask = reslice_data(fullfile(current_CSF_file(1).folder,current_CSF_file(1).name), func_img1_filename, 0);

            % finding where probability for white-matter is larger than 0.2 and
            % larger than probability for grey-matter or CSF

            wm_current_seg_mask = (current_WM_mask>current_GM_mask) & (current_WM_mask>current_CSF_mask) & (current_WM_mask>0.2);
            gm_current_seg_mask = (current_GM_mask>current_WM_mask) & (current_GM_mask>current_CSF_mask) & (current_GM_mask>0.2);

            % finding and ignoring irrelevant voxels (e.g. not defined as WM in this specific participant, or have NaN values)
            wm_vox_ts_with_data_idx = find(var(wm_vox_ts,[],2)~=0 & ~isnan(var(wm_vox_ts,[],2)) & wm_current_seg_mask(wm_group_mask_voxels)==1);
            % if sub_samp
                gm_vox_ts_sub_sample_with_data_idx = find(var(gm_vox_ts(sub_sample_grid,:),[],2)~=0 & ~isnan(var(gm_vox_ts(sub_sample_grid,:),[],2)) & gm_current_seg_mask(gm_group_mask_voxels(sub_sample_grid))==1);
            % else
                gm_vox_ts_sub_with_data_idx = find(var(gm_vox_ts,[],2)~=0 & ~isnan(var(gm_vox_ts,[],2)) & gm_current_seg_mask(gm_group_mask_voxels)==1);
            % end
           
            save(out_voxts_mat_path,"wm_vox_ts","gm_vox_ts","wm_vox_ts_with_data_idx","sub_sample_grid","gm_vox_ts_sub_sample_with_data_idx",'wm_group_mask_voxels','gm_group_mask_voxels')
        else
            load(out_voxts_mat_path,"wm_vox_ts","gm_vox_ts","wm_vox_ts_with_data_idx","sub_sample_grid","gm_vox_ts_sub_sample_with_data_idx")
        end
        % Calculating correlation matrix of each WM voxel to the subsampled voxels
        switch sub_sample_choose
            case 'Subsample'
                % current_corr = corr(vox_ts(vox_ts_with_data_idx,:)', vox_ts(sub_sample_grid(vox_ts_sub_sample_with_data_idx),:)');
                % adding the current connectivity matrix to the sum of all participants, for later averaging
                avg_vox_level_FC(wm_vox_ts_with_data_idx, gm_vox_ts_sub_sample_with_data_idx) = avg_vox_level_FC(wm_vox_ts_with_data_idx, gm_vox_ts_sub_sample_with_data_idx) + corr(wm_vox_ts(wm_vox_ts_with_data_idx,:)', gm_vox_ts(sub_sample_grid(gm_vox_ts_sub_sample_with_data_idx),:)');
                num_subjs_notnan(wm_vox_ts_with_data_idx, gm_vox_ts_sub_sample_with_data_idx) = num_subjs_notnan(wm_vox_ts_with_data_idx, gm_vox_ts_sub_sample_with_data_idx) + 1;
            case 'Use entire FC'
                % current_corr = corr(vox_ts(vox_ts_with_data_idx,:)', vox_ts(vox_ts_with_data_idx,:)');
                % adding the current connectivity matrix to the sum of all participants, for later averaging
                avg_vox_level_FC(wm_vox_ts_with_data_idx, gm_vox_ts_sub_with_data_idx) = avg_vox_level_FC(wm_vox_ts_with_data_idx, gm_vox_ts_sub_with_data_idx) + corr(wm_vox_ts(wm_vox_ts_with_data_idx,:)', gm_vox_ts(gm_vox_ts_sub_with_data_idx,:)');
                num_subjs_notnan(wm_vox_ts_with_data_idx, gm_vox_ts_sub_with_data_idx) = num_subjs_notnan(wm_vox_ts_with_data_idx, gm_vox_ts_sub_with_data_idx) + 1;
            otherwise
                error('Invalid Subsampling option')
        end
        % clear current_corr;
        clear wm_vox_ts; clear wm_current_seg_mask gm_current_seg_mask; clear wm_vox_ts_with_data_idx; clear gm_vox_ts_sub_sample_with_data_idx;
        toc
    end

    avg_vox_level_FC = avg_vox_level_FC./num_subjs_notnan;
else
    load(out_mat_path) %#ok<LOAD>
end

avg_vox_level_FC(isnan(avg_vox_level_FC))=0;
missing_voxels = find(std(avg_vox_level_FC,[],2)==0);   % finding voxels with no data

wm_group_mask_voxels(missing_voxels) = []; avg_vox_level_FC(missing_voxels,:)=[];

missing_voxels = std(avg_vox_level_FC,[],1)==0;   % finding voxels with no data
avg_vox_level_FC(:,missing_voxels)=[];
sub_sample_grid(missing_voxels) = [];
save(fullfile(cluster_folder,'subsample_grid_idx.mat'),'sub_sample_grid')



