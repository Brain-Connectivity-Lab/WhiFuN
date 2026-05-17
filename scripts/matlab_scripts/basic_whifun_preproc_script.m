%% This code written by Pratik Jain.
%% This code was written with the help of different preprocessing scripts given by
%% Dr. Xin Di, Dr. Rakibul Hafeez, Dr. Wang Pan, Donna Chen and Wonbum Sohn
%% Under guidance of Dr Andrew Micheal and Dr. Bharat Biswal.

%Make sure you have run the Initial Data check script before running this

%%          Defining Important paths and Creating Output whifun_directories
output_folder = 'D:\Github_desktop\WhiFuN\Data\Whifun_op';

load(fullfile(output_folder,'parameters.mat'))                           % % load parameters saved during initial data check, if they were changed after initial data check, the change will be applied later in the code.
Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv');
Subj_list = load_subjects(output_folder,'Subj_list.csv');

n_tot = length(Subj_list);
n_vol_dis = 0;

% head motion control parameters
max_fd = 5;
mean_fd = 0.5;
greater_than_20 = 0.5;

%Segmentation Parameters
Seg_dartel_drop = 'No Dartel'; %options : 'No Dartel', 'Dartel'

CSF_thres = '0.95';
Reg_drop = 'Mean CSF'; %Options :'Mean CSF', 'PCA CSF', 'No CSF Regression'
motion_reg = 1;
pca_for_temp_reg = 0;
n_pca = 5;

smooth_drop = 'WM-GM Seperate'; %Options:'WM-GM Seperate' 'All Together' 'No Smoothing'
smooth_fwhm = 4;

filter_check = 0;
filter_lp = 0.01;
filter_hp = 0.15;

vox = 3;

par_on = 0;
n_workers = 0; 

% Ignore any previous results
% -> 1 If previous preprocessing files exist (WhiFuN will delete them and rerun)
% -> 0 If previous preprocessing files exits (Keep them and skip)
over_write = 0;

whifun_preproc_all(output_folder, ...
        'over_write',over_write,...                                                                        General Inputs
        'n_vol_dis',n_vol_dis,...                                                       Discard Volumes
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...                           Framewise Displacement
        'Seg_dartel_drop',Seg_dartel_drop,...
        'Reg_drop',Reg_drop,'CSF_thres',CSF_thres,...                                                             CSF MASK func
        'pca_for_temp_reg',pca_for_temp_reg,'n_pca',n_pca,'motion_reg',motion_reg,... Nuisance Regression                                            CSF Timeseries extraction
        'filter_check',filter_check,'filter_lp',filter_lp,'filter_hp',filter_hp,...         Filtering
        'smooth_drop',smooth_drop,'smooth_fwhm',smooth_fwhm,...    Smoothing
        'vox',vox,...                                                Normalization
        'par_on',par_on,'n_workers',n_workers...                    parellel processing
        );
% optional
%'Cut_pre',Cut_pre,
%        'Realign_pre',Realign_pre,...                                                                     Realignment
%        'skull_pre',skull_pre,...                                                                         Skull stripping
%'Reg_pre',Reg_pre,
%'f_pre',f_pre,
%'Smooth_pre',Smooth_pre,
%'Norm_pre',Norm_pre,