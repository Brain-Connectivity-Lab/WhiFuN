clear

%% Addpaths if not already added 

spm_path = 'D:\toolboxes\spm_25.01.02\spm\'; % Paste SPM toolbox path
addpath(spm_path)

whifun_path = 'D:\Github_desktop\WhiFuN\';
addpath(whifun_path);

%% Input Paths

data_path = '/home/projects/mindset/7T_Projects/7T_Psychiatry/derivatives/conn/';
output_folder = '/home/projects/mindset/7T_Projects/7T_Psychiatry/WhiFuN_op'; % Specify an empty folder where you want to store whifun outputs

%% Preproccessed file paths
% Give patterns for the following 

final_func_MNI = 'ses-7T*/func/wau*';
GM_MNI  = 'ses-7T*/anat/wc1*'; % GM tissue probability map
WM_MNI  = 'ses-7T*/anat/wc2*'; % WM tissue probability map
CSF_MNI = 'ses-7T*/anat/wc3*'; % CSF tissue probability map

% Following is optional (mostly used for QC that we arent doing in this script)
motion_txt = ''; % SPM rp_ motion file
anat_mask_MNI = ''; % If anat mask was created
func_MNI = ''; % Func in MNI space (maybe an intermediate step)
anat_MNI = ''; % Anat in MNI space 
func_mask_MNI = ''; % If func_mask was created
MNI_template = ''; 

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
spm_path = which('spm.m');
if isempty(spm_path)
    error('SPM toolbox not found. Please check the SPM path. Add path to the folder that contains spm.m file');
end

whifun_func_path = which('whifun.m');
if isempty(whifun_func_path)
    error('Whifun toolbox not found. Please check the Whifun path. Add path to the folder that contains whifun.m file');
end
whifun_path = fileparts(whifun_func_path);

addpath(fullfile(whifun_path,'whifun_functions'))
finalData = whifun_create_preproc_files_cell(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI,...
    'motion_txt',motion_txt,...
    'anat_mask_MNI',anat_mask_MNI, ...
    'func_MNI',func_MNI,...
    'anat_MNI',anat_MNI,...
    'func_mask_MNI',func_mask_MNI,...
    'MNI_template',MNI_template);

[Subj_list_all,output_folder] = whifun_create_Subj_list(output_folder,data_path,'All',finalData);
whifun_save_parameters(output_folder,'parameters.mat',...
                                data_path,output_folder,0,...
                                '','','','','','',...
                                0,5,0.2,0.2,0,0.95,'Mean CSF',0,1,0,0.01,0.15,'WM-GM Seperate',"4","3")
if isempty(Subj_list_all)
    error('No Subject files found, Please check the ''Preproccessed file paths'' ')

end
Subj_list = whifun_create_fields(Subj_list_all);
for i = 1:length(Subj_list)
    Subj_list(i).error = 0;
    Subj_list(i).manual_ex = 0;
    Subj_list(i).motion_ex = 0;
end
my_writetable(struct2table(Subj_list),fullfile(output_folder,"Subj_list.csv"))
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
    cc_mask_path = fullfile(whifun_path,'Templates','Original_corpus_callosum.nii');     %#ok<UNRCH> % Get the CC mask path
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
