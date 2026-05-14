function whifun_create_FN_Kmeans_WM_GM(output_folder,WM_or_GM,K_range_l,K_range_h,group_mask_path_wm,group_mask_path_gm,varargin)
% WHIFUN_CREATE_FN_KMEANS Creates WM/GM Functional Networks using K-means clustering
%
%   whifun_create_FN_Kmeans(...) performs K-means clustering on the
%   average voxel-level functional connectivity matrix across subjects
%   and generates functional networks (FNs). It also saves BrainNet images
%   and average time series for each FN.
%
%   Required Inputs:
%       output_folder    - Path to output folder
%       WM_or_GM         - 'WM-GM' or 'GM-WM'
%       K_range_l        - Lower bound for K (clusters)
%       K_range_h        - Upper bound for K
%       group_mask_path  - Path to group-level brain mask (NIfTI)
%
%   Optional Inputs:
%       sub_sample_choose- Subsample flag/strategy (default: 'Sub sample')
%       CV_folds         - Number of cross-validation folds (default: 4)
%       focus_check      - Apply focus mask (default: 0)
%       focus_mask_path  - Focus mask path or 0 if unused (default: 0)
%       num_replicates   - Replicates for K-means (default: 10)
%       size_chunk       - Chunk size for computation (default: 100)
%       over_write       - Overwrite existing files (default: 0)
%       d                - Progress bar handle (default: 0)
%       d_flag           - Display flag for progress bar (default: 0)
%       steps_           - Current pipeline step (default: 0)
%       tot_steps        - Total steps in pipeline (default: 0)
%
%   Example:
%       whifun_create_FN_Kmeans('output_folder','/path/out',...
%           'WM_or_GM','WM','K_range_l',2,'K_range_h',10,...
%           'group_mask_path','mask.nii');
%
%   Author: Pratik Jain

%% ---------------- Input Parser ----------------
p = inputParser;
p.FunctionName = 'whifun_create_FN_Kmeans';

% Optional with defaults
addParameter(p,'sub_sample_choose','Subsample');
addParameter(p,'CV_folds',4,@(x) isnumeric(x) && isscalar(x));

addParameter(p,'num_replicates',10,@(x) isnumeric(x) && isscalar(x));
addParameter(p,'size_chunk',100,@(x) isnumeric(x) && isscalar(x));

addParameter(p,'over_write',0,@(x) islogical(x) || isnumeric(x));
addParameter(p,'d',0);
addParameter(p,'d_flag',0,@(x) isnumeric(x) || islogical(x));
addParameter(p,'steps_',0,@(x) isnumeric(x));
addParameter(p,'tot_steps',0,@(x) isnumeric(x));

parse(p,varargin{:});

% Assign parsed inputs
sub_sample_choose= p.Results.sub_sample_choose;
CV_folds         = p.Results.CV_folds;

num_replicates   = p.Results.num_replicates;
size_chunk       = p.Results.size_chunk;

over_write       = p.Results.over_write;
d                = p.Results.d;
d_flag           = p.Results.d_flag;
steps_           = p.Results.steps_;
tot_steps        = p.Results.tot_steps;

%% ---------------- Clustering Functional Networks ----------------

if K_range_l > K_range_h
    error('K_range_l must be less than K_range_h. Found %d > %d.',K_range_l,K_range_h);
end

Subj_list = load_subjects(output_folder,'Subj_list.csv');  % Load participants

out_analysis_path = fullfile(output_folder,'Analysis');
if ~exist(out_analysis_path,'dir')
    mkdir(out_analysis_path)
end

FN_folder = fullfile(out_analysis_path,[WM_or_GM '_FN']);
[build_net,K] = whifun_build_net(FN_folder,[WM_or_GM '_FN_K*' filesep WM_or_GM '_FN_K*' '.nii'],over_write);

if build_net == 1
    %% K-means clustering of mean connectivity matrix
    disp('##########################################################################################')
    disp(['Creating Average ' WM_or_GM '_FN using K-Means'])
    if strcmp(WM_or_GM,'WM-GM')
        [avg_vox_level_FC,group_mask_voxels] = whifun_create_avg_voxel_level_fc_WM_with_GM( ...
            FN_folder,Subj_list,group_mask_path_wm,group_mask_path_gm,sub_sample_choose, ...
            over_write,d_flag,d,steps_,tot_steps);
    elseif strcmp(WM_or_GM,'GM-WM')
        [avg_vox_level_FC,group_mask_voxels] = whifun_create_avg_voxel_level_fc_GM_with_WM( ...
            FN_folder,Subj_list,group_mask_path_wm,group_mask_path_gm,sub_sample_choose, ...
            over_write,d_flag,d,steps_,tot_steps);
    elseif strcmp(WM_or_GM,'GM-noise')
        [avg_vox_level_FC,group_mask_voxels] = whifun_create_avg_voxel_level_fc_GM_with_noise( ...
            FN_folder,Subj_list,group_mask_path_wm,group_mask_path_gm,sub_sample_choose, ...
            over_write,d_flag,d,steps_,tot_steps);
    elseif strcmp(WM_or_GM,'Noise-GM')
        [avg_vox_level_FC,group_mask_voxels] = whifun_create_avg_voxel_level_fc_noise_with_GM( ...
            FN_folder,Subj_list,group_mask_path_wm,group_mask_path_gm,sub_sample_choose, ...
            over_write,d_flag,d,steps_,tot_steps);
    end
    out_folder = fullfile(FN_folder,['K_grid_search_dice_corficient_elbow_' WM_or_GM '.png']);
    K = whifun_get_best_k(out_folder,avg_vox_level_FC,K_range_l,K_range_h,CV_folds,num_replicates,size_chunk,d_flag,d,steps_,tot_steps);
    
    
    out_path = fullfile(FN_folder,[ WM_or_GM '_FN_K' num2str(K)],[ WM_or_GM '_FN_K' num2str(K) '.nii']);

    if strcmp(WM_or_GM,'WM-GM') || strcmp(WM_or_GM,'Noise-GM')
        whifun_get_FN_kmeans(out_path,K,avg_vox_level_FC,group_mask_voxels,niftiinfo(group_mask_path_wm),over_write,d_flag,d,steps_,tot_steps);
    elseif strcmp(WM_or_GM,'GM-WM') || strcmp(WM_or_GM,'GM-noise')
        whifun_get_FN_kmeans(out_path,K,avg_vox_level_FC,group_mask_voxels,niftiinfo(group_mask_path_gm),over_write,d_flag,d,steps_,tot_steps);
    end
else
    if d_flag
        % Update progress if skipping
        steps_ = steps_ + (K_range_h-K_range_l) + 1;
        d.Value = steps_/tot_steps;
        if d.CancelRequested
            disp(['Creation of ' WM_or_GM '-FN terminated by User'])
            return
        end
    end
end

%% ---------------- Create BrainNet Images ----------------
FN_folder = fullfile(out_analysis_path,[WM_or_GM '_FN'],[WM_or_GM '_FN_K' num2str(K)]);
ROI_path = fullfile(FN_folder,[WM_or_GM '_FN_K' num2str(K) '.nii']);
out_path = fullfile(FN_folder,[WM_or_GM '_FN_K',num2str(K),'_BrainNet_images']);
whifun_create_brainnet_images(out_path,ROI_path,over_write)

%% ---------------- Average Time Series Extraction ----------------
out_path = FN_folder;
QC_plots = 0;
whifun_create_avg_ts(out_path,ROI_path,Subj_list,'final_func_MNI',[],QC_plots,over_write,d_flag,d,steps_,tot_steps);

end
