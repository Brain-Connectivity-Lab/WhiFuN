function Subj_list_1 = whifun_post_proc_hcp_dev(quality_control_path, Subj_list_1, varargin)

%% ---- input parser ----
p = inputParser;
p.FunctionName = 'whifun_post_proc_hcp';

% required
addRequired(p, 'quality_control_path', @(x) ischar(x) || isstring(x));
addRequired(p, 'Subj_list_1', @isstruct);

% general
addParameter(p, 'over_write', 0, @(x) islogical(x) || (isnumeric(x) && isscalar(x)));
addParameter(p,'FSLDIR',getenv('FSLDIR'));
addParameter(p,'func_preproc_dir','func_preproc.func');
addParameter(p,'anat_preproc_dir','anat_preproc');

% discard volumes
addParameter(p, 'Cut_pre', 'c_', @(x) ischar(x) || isstring(x));
addParameter(p, 'n_vol_dis', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);

% framewise displacement
addParameter(p, 'max_fd', 0.5, @isnumeric);
addParameter(p, 'mean_fd', 0.2, @isnumeric);
addParameter(p, 'greater_than_20', 0.2, @isnumeric);

% filtering
addParameter(p, 'filter_check', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'f_pre', 'f', @(x) ischar(x) || isstring(x));
addParameter(p, 'filter_lp', 0.01);
addParameter(p, 'filter_hp', 0.15);

% smoothing
addParameter(p, 'Smooth_', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'Smooth_pre', 's', @(x) ischar(x) || isstring(x));
addParameter(p, 'WM_GM_seperate', 1, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'smooth_fwhm', 4, @(x) isnumeric(x) && isscalar(x) && x>=0);

% parse inputs
parse(p, quality_control_path, Subj_list_1, varargin{:});
params = p.Results;

%% ---- Accessing parsed values (examples) ----
% You can refer to any parameter as params.<name>
% e.g.:
qc_path   = params.quality_control_path;   % string
Subj_list_1      = params.Subj_list_1;            % struct

over_write = logical(params.over_write);   % logical
FSLDIR = params.FSLDIR;
func_preproc_dir = params.func_preproc_dir;
anat_preproc_dir = params.anat_preproc_dir;


Cut_pre    = char(params.Cut_pre);         % char
n_vol_dis  = params.n_vol_dis;             % numeric scalar

max_fd = params.max_fd;
mean_fd = params.mean_fd;
greater_than_20 = params.greater_than_20;

filter_check = logical(params.filter_check);
f_pre = char(params.f_pre);
filter_lp = params.filter_lp;
filter_hp = params.filter_hp;

Smooth_ = logical(params.Smooth_);
Smooth_pre = char(params.Smooth_pre);
WM_GM_seperate = logical(params.WM_GM_seperate);
smooth_fwhm = params.smooth_fwhm;

%% ---- Example usage snippets inside the pipeline ----
% (place these where appropriate in your pipeline)
fprintf('QC folder: %s\n', qc_path);
if over_write
    fprintf('Overwriting enabled.\n');
end

% Discarding volumes
if n_vol_dis > 0
    % example: call your discard function
    % subj = discard_initial_volumes(subj, n_vol_dis, Cut_pre);
    fprintf('Will discard %d initial volumes (prefix %s)\n', n_vol_dis, Cut_pre);
end

% Framewise displacement check
if max_fd > 0
    fprintf('FD thresholds: max=%g, mean=%g, pct>%g\n', max_fd, mean_fd, greater_than_20);
end

% Filtering
if filter_check
    fprintf('Filtering enabled: lowpass=%d, highpass=%d (prefix %s)\n', filter_lp, filter_hp, f_pre);
    % subj = apply_filter(subj, filter_hp, filter_lp, f_pre);
end

% Smoothing
if Smooth_
    fprintf('Smoothing enabled, FWHM=%g mm (prefix %s)\n', smooth_fwhm, Smooth_pre);
    % subj = smooth_func(subj, smooth_fwhm, Smooth_pre);
end

if ~exist(fullfile(quality_control_path,'logs'),'dir')
    mkdir(fullfile(quality_control_path,'logs'))
end

[log_fileID,errmsg] = fopen(fullfile(quality_control_path,'logs',[Subj_list_1.name '_log_info.txt']),'a');

if log_fileID == -1
    error(errmsg)
end

disp(' ')
disp(['Currently Processing ' Subj_list_1.name])

% temp_path = mfilename('fullpath');                % path of the toolbox
% preproc_code_path = fileparts(fileparts(temp_path));
if ~exist(fullfile(Subj_list_1.func_folder,func_preproc_dir),'dir')
    mkdir(fullfile(Subj_list_1.func_folder, func_preproc_dir));
end
%%  Discarding intial volumes

in_func_path = fullfile(Subj_list_1.func_folder,Subj_list_1.func_name);
now_func_path = dir(in_func_path);
out_func_path = fullfile(now_func_path.folder,func_preproc_dir,[Cut_pre,now_func_path.name]);
Subj_list_1 = whifun_discard_initial_volume_preproc(quality_control_path,Subj_list_1,in_func_path,out_func_path,n_vol_dis,over_write);

%% 5 Framewise displacement
if n_vol_dis ~= 0
    in_func_path = out_func_path;
end
% [~,func_name,~] = fileparts(in_func_path);

now_func_path = dir(in_func_path);  % Input for mcflirt
in_motion_txt_path = fullfile(Subj_list_1.func_folder,'Movement_Regressors.txt');
rp = load(in_motion_txt_path);
% motion_par = [rp(:,4:6),rp(:,1:3)];
motion_par = [rp(:,1:3), rp(:,4:6)*pi/180];
writematrix(motion_par,fullfile(now_func_path.folder,[now_func_path.name '_spm_format.txt']), 'Delimiter', ' ');
out_motion_txt_path = fullfile(now_func_path.folder,[now_func_path.name '_spm_format.txt']);
Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,motion_par,max_fd,mean_fd,greater_than_20);
Subj_list_1.motion_txt = out_motion_txt_path;
if Subj_list_1.motion_ex
    fclose(log_fileID);
    return
end

%% fsl Segmentation

in_anat_path = fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name);
Subj_list_1.anat_MNI = in_anat_path;

Subj_list_1.GM_MNI = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1w_restore_brain_pve_1.nii.gz');
Subj_list_1.WM_MNI = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1w_restore_brain_pve_2.nii.gz');
Subj_list_1.CSF_MNI = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1w_restore_brain_pve_0.nii.gz');

if whifun_isnan_or_empty(Subj_list_1,'GM_MNI') && whifun_isnan_or_empty(Subj_list_1,'WM_MNI') && whifun_isnan_or_empty(Subj_list_1,'CSF_MNI')
    [gm_prob_path, wm_prob_path, csf_prob_path] = whifun_fsl_fast_seg(Subj_list_1.anat_MNI,[],false);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'Segmentation using FSL FAST');
    fprintf(log_fileID,'%s',  out_fsl_fst);




    Subj_list_1.GM_MNI = gm_prob_path;
    Subj_list_1.WM_MNI = wm_prob_path;
    Subj_list_1.CSF_MNI = csf_prob_path;
else
    % gm_prob_path = Subj_list_1.GM_MNI;
    % wm_prob_path = Subj_list_1.WM_MNI;
    % csf_prob_path = Subj_list_1.CSF_MNI;

end
t1_brain_mask = fullfile(fileparts(in_anat_path),'brainmask_fs.nii.gz');
Subj_list_1.anat_mask_MNI = t1_brain_mask;
%%    13     Smoothing

if Smooth_ == 1
    if n_vol_dis ~= 0
        in_func_path = out_func_path;  % Input for smooth
    else
        in_func_path = fullfile(Subj_list_1.func_folder,Subj_list_1.func_name);
    end
    gm_prob_path = Subj_list_1.GM_MNI;
    wm_prob_path = Subj_list_1.WM_MNI;
    [Subj_list_1,out_func_path] = whifun_smooth_preproc_MNI(quality_control_path,Subj_list_1,in_func_path,gm_prob_path,wm_prob_path,WM_GM_seperate,smooth_fwhm,Smooth_pre,log_fileID,over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
    Subj_list_1.final_func_MNI = out_func_path;
else
    disp('No smoothing is selected hence skipping this step')
end
disp(['Smoothing is done for ' Subj_list_1.name])
fclose(log_fileID);