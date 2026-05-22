clear

%% Addpaths if not already added 

spm_path = 'D:\toolboxes\spm_25.01.02\spm\'; % Paste SPM toolbox path
addpath(spm_path)

whifun_path = 'D:\Github_desktop\WhiFuN\';
addpath(whifun_path);

%% Input Paths

output_folder = 'D:\Github_desktop\WhiFuN\Data\Whifun_op'; % Specify WhiFuN output folder

%% White Matter FN parameters
over_write = 0;

create_group_masks = 1; % Do you want to create Group masks using Whifun

if create_group_masks
    grp_thres_wm  = 0.9;             % Group threshold on WM
    indi_thres_wm = 0.6;   % Inidividual threshold on WM tissue prob
    grp_thres_gm  = 0.2;             % Group threshold on WM
    indi_thres_gm = 0.6;   % Inidividual threshold on WM tissue prob
else
    group_mask_path = ''; %#ok<UNRCH> % Path to the binary mask that you want to use.
end

K_range_l = 4;
K_range_h = 16;
CV_folds = 4;
Corpus_check = 0;
sub_sample_choose = 'Subsample'; % Options : 'Subsample', 'Use entire FC'
num_replicates = 10;
size_chunk = 100;
WM_or_GM = 'WM';

%% Dont change the following
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

whifun('cite')
whifun_func_path = which('whifun.m');
whifun_path = fileparts(whifun_func_path);

addpath(fullfile(whifun_path,'whifun_functions'))

% load(fullfile(output_folder,'parameters.mat'))                           % % load parameters saved during initial data check, if they were changed after initial data check, the change will be applied later in the code.
Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv');
Subj_list = load_subjects(output_folder,'Subj_list.csv');
%% Create Group Masks
if create_group_masks
    grp_WM_mask_name = 'WMmask_allsubjs.nii.gz';
    grp_GM_mask_name = 'GMmask_allsubjs.nii.gz';
    out_analysis_path = fullfile(output_folder,'Analysis');
    whifun_create_group_mask(out_analysis_path,Subj_list,grp_WM_mask_name,indi_thres_wm,grp_thres_wm,grp_GM_mask_name,indi_thres_gm,grp_thres_gm,over_write)
    if strcmp(WM_or_GM,'WM')
        group_mask_path = fullfile(out_analysis_path,'Group_Masks',grp_WM_mask_name);
    elseif strcmp(WM_or_GM,'GM') %#ok<UNRCH>
        group_mask_path = fullfile(out_analysis_path,'Group_Masks',grp_GM_mask_name);
    end
end

%% Create White Matter Functional Networks

wm_steps = 0;
d_flag = 1;

if Corpus_check
    cc_mask_path = fullfile(whifun_path,'Templates','Original_corpus_callosum.nii');     %#ok<UNRCH> % % Get the CC mask path
    resample_mask = 1;
else
    cc_mask_path = 0; 
    resample_mask = 0;
end

whifun_create_FN_Kmeans(output_folder,WM_or_GM,K_range_l,K_range_h,group_mask_path,...
    'sub_sample_choose',sub_sample_choose,...
    'CV_folds',CV_folds,...
    'focus_check',Corpus_check,...
    'focus_mask',cc_mask_path,...
    'Resample_focus_mask',resample_mask,...
    'num_replicates',num_replicates,...
    'size_chunk',size_chunk,...
    'over_write',over_write...
    )
