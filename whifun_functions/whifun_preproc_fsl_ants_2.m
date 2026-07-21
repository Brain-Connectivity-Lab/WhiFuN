function Subj_list_1 = whifun_preproc_fsl_ants_2(quality_control_path, Subj_list_1, varargin)
% WHIFUN_PREPROC Orchestrates a comprehensive fMRI preprocessing pipeline.
%
%   Subj_list_1 = WHIFUN_PREPROC(quality_control_path, Subj_list_1, varargin)
%   is a master function that executes a sequence of fMRI preprocessing steps
%   on a single subject. This function uses MATLAB's `inputParser` to
%   handle a wide range of optional parameters in a clear and structured way.
%
%   The function manages the flow of data through each step, passing the output
%   of one function as the input to the next. It includes checks to skip
%   steps that have already been completed, based on the `over_write` flag.
%   Crucially, it incorporates robust error handling: if any step fails, the
%   function catches the error, logs it to a file, and stops the processing
%   for that subject.
%
%   The preprocessing steps include:
%   1. Unzipping data files.
%   2. Discarding initial volumes.
%   3. Realignment (motion correction).
%   4. Quality control checks for framewise displacement.
%   5. Segmentation of anatomical data.
%   6. Skull stripping and anatomical mask creation.
%   7. Coregistration of functional to anatomical data.
%   8. Nuisance regression (optional).
%   9. Filtering (optional).
%   10. Smoothing (optional, with separate WM/GM option).
%   11. Normalization to MNI space (optional, can be skipped for DARTEL).
%
%   Input Arguments (Name-Value Pairs):
%   - **FSLDIR** (string): Path to fsl. Default: getenv('FSLDIR')
%   - **over_write** (logical): Force overwriting of existing files. Default: 0.
%   - **Cut_pre** (string): Prefix for files after discarding volumes. Default: 'c_'.
%   - **n_vol_dis** (numeric): Number of initial volumes to discard. Default: 0.
%   - **Realign_pre** (string): Prefix for realigned files. Default: 'r'.
%   - **max_fd** (numeric): Maximum FD threshold for QC. Default: 0.5.
%   - **mean_fd** (numeric): Mean FD threshold for QC. Default: 0.2.
%   - **greater_than_20** (numeric): FD threshold for percentage of excluded volumes. Default: 0.2.
%   - **skull_pre** (string): Prefix for skull-stripped files. Default: 'b'.
%   - **Reg_** (logical): Flag to perform nuisance regression. Default: 0.
%   - **CSF_thres** (string): Threshold for CSF mask creation. Default: '0.95'.
%   - **pca_for_temp_reg** (logical): Flag to use PCA for CSF signal. Default: 0.
%   - **n_pca** (numeric): Number of PCA components. Default: 5.
%   - **Reg_pre** (string): Prefix for regressed files. Default: 'REG_'.
%   - **motion_reg** (logical): Flag to include motion regressors. Default: 0.
%   - **filter_check** (logical): Flag to perform filtering. Default: 0.
%   - **f_pre** (string): Prefix for filtered files. Default: 'f'.
%   - **filter_lp** (string): Low-pass filter cutoff frequency. Default: '0.01'.
%   - **filter_hp** (string): High-pass filter cutoff frequency. Default: '0.15'.
%   - **Smooth_** (logical): Flag to perform smoothing. Default: 0.
%   - **Smooth_pre** (string): Prefix for smoothed files. Default: 's'.
%   - **WM_GM_seperate** (logical): Flag for separate WM/GM smoothing. Default: 1.
%   - **smooth_fwhm** (numeric): FWHM of the smoothing kernel. Default: 4.
%   - **dartel_** (logical): Flag to skip normalization (for DARTEL). Default: 0.
%   - **Norm_pre** (string): Prefix for normalized files. Default: 'w'.
%   - **vox** (numeric): Voxel size for normalized output. Default: 3.

%% ---- input parser ----
p = inputParser;
p.FunctionName = 'whifun_preproc_fsl';

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

% realignment
addParameter(p, 'Realign_pre', 'r', @(x) ischar(x) || isstring(x));

% framewise displacement
addParameter(p, 'max_fd', 0.5, @isnumeric);
addParameter(p, 'mean_fd', 0.2, @isnumeric);
addParameter(p, 'greater_than_20', 0.2, @isnumeric);

% CSF mask / PCA
addParameter(p, 'Reg_CSF', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'CSF_thres','0.95', @(x) ischar(x) || isstring(x));
addParameter(p, 'pca_for_temp_reg', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'n_pca', 5, @(x) isnumeric(x) && isscalar(x) && x>=0);

% nuisance regression
addParameter(p, 'Reg_pre', 'REG_', @(x) ischar(x) || isstring(x));
addParameter(p, 'motion_reg', 0, @(x) islogical(x) || isnumeric(x));

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
addParameter(p, 'Norm_pre', 'w', @(x) ischar(x) || isstring(x));

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

Realign_pre = char(params.Realign_pre);

max_fd = params.max_fd;
mean_fd = params.mean_fd;
greater_than_20 = params.greater_than_20;

Reg_CSF = logical(params.Reg_CSF);
CSF_thres = params.CSF_thres;
pca_for_temp_reg = logical(params.pca_for_temp_reg);
n_pca = params.n_pca;

Reg_pre = char(params.Reg_pre);
motion_reg = logical(params.motion_reg);

filter_check = logical(params.filter_check);
f_pre = char(params.f_pre);
filter_lp = params.filter_lp;
filter_hp = params.filter_hp;

Smooth_ = logical(params.Smooth_);
Smooth_pre = char(params.Smooth_pre);
WM_GM_seperate = logical(params.WM_GM_seperate);
smooth_fwhm = params.smooth_fwhm;

Norm_pre = char(params.Norm_pre);
motion_censor = 1;
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
%% Realignment (mcflirt)
if n_vol_dis ~= 0
    in_func_path = out_func_path;  % Input for mcflirt
end
now_func_path = dir(in_func_path);  % Input for mcflirt

if n_vol_dis == 0
    out_func_path = fullfile(now_func_path.folder,func_preproc_dir, [Realign_pre,Cut_pre, now_func_path.name]);  % Output path for realigned data
else
    out_func_path = fullfile(now_func_path.folder, [Realign_pre,Cut_pre, now_func_path.name]);  % Output path for realigned data
end
out_func_file = whifun_create_file(over_write,out_func_path);

if isempty(out_func_file)
    cmd = sprintf('mcflirt -in %s -out %s -plots -refvol 0 -rmsrel -rmsabs -report', in_func_path, out_func_path);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'Realignment Mcflirt\n');
    fprintf(log_fileID,'%s',  sprintf('[CMD] %s\n', cmd));
    [s,w] = system(cmd);
    if s~=0
        error('Command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end
    Subj_list_1.realigned_func_native = out_func_path;
else
    disp('motion corrected file found')
    Subj_list_1.realigned_func_native = out_func_path;
end

%% 5 Framewise displacement
in_func_path = out_func_path;
% [~,func_name,~] = fileparts(in_func_path);

now_func_path = dir(in_func_path);  % Input for mcflirt
in_motion_txt_path = fullfile(now_func_path.folder,[now_func_path.name '.par']);
rp = load(in_motion_txt_path);
motion_par = [rp(:,4:6),rp(:,1:3)];
writematrix(motion_par,fullfile(now_func_path.folder,[now_func_path.name '_spm_format.txt']), 'Delimiter', ' ');
out_motion_txt_path = fullfile(now_func_path.folder,[now_func_path.name '_spm_format.txt']);
Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,motion_par,max_fd,mean_fd,greater_than_20);
Subj_list_1.motion_txt = out_motion_txt_path;
if Subj_list_1.motion_ex
    fclose(log_fileID);
    return
end

%% Slice time correction using FSL
slice_pre = 'a';
tcustom_path = fullfile(fileparts(in_func_path),'tcustom.txt');
tcustom_file = whifun_create_file(over_write,tcustom_path);

if isempty(tcustom_file)
    [~,or_func_name,~] = fileparts(Subj_list_1.func_name);
    [~,or_func_name_without_ex,~] = fileparts(or_func_name);
    json_ = jsondecode(fileread(fullfile(Subj_list_1.func_folder,[or_func_name_without_ex '.json'])));
    writematrix(json_.SliceTiming,tcustom_path);
end


out_func_path = fullfile(now_func_path.folder,[slice_pre, now_func_path.name]);
out_func_file = whifun_create_file(over_write,out_func_path);

if isempty(out_func_file)

    cmd = sprintf('slicetimer -i %s -o %s --tcustom=%s', in_func_path, out_func_path,tcustom_path);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'Slice Time correction slicetimer\n');
    fprintf(log_fileID, 'Slice time correction command: %s\n', cmd);
    [s, w] = system(cmd);
    if s~=0
        error('Command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end
    Subj_list_1.realigned_func_native = out_func_path;
else
    disp('slice time corrected file found')
    Subj_list_1.realigned_func_native = out_func_path;
end
%% ants fsl Anat func preprocessing

Subj_list_1 = whifun_ants_native_to_mni(Subj_list_1,anat_preproc_dir,FSLDIR,Norm_pre,log_fileID,over_write);

out_func_path = Subj_list_1.func_MNI;
%% Segmentation in MNI

disp(['Currently Processing ' Subj_list_1.name])
in_anat_path = Subj_list_1.anat_MNI;
out_anat_path = fullfile(fileparts(in_anat_path),'T1_to_MNI_Warped_pve_1.nii.gz');

out_anat_file = whifun_create_file(over_write,out_anat_path);
if isempty(out_anat_file)
    [gm_prob_path, wm_prob_path, csf_prob_path,t1_brain_mask] = whifun_fsl_fast_seg(in_anat_path,fileparts(in_anat_path),false);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'Segmentation anat MNI using FSL FAST');
    % fprintf(log_fileID,'%s',  out_fsl_fst);

    Subj_list_1.GM_MNI = gm_prob_path;
    Subj_list_1.WM_MNI = wm_prob_path;
    Subj_list_1.CSF_MNI = csf_prob_path;
    Subj_list_1.anat_mask_MNI = t1_brain_mask;
else
    gm_prob_path = fullfile(fileparts(in_anat_path),'T1_to_MNI_Warped_pve_1.nii.gz');
    wm_prob_path = fullfile(fileparts(in_anat_path),'T1_to_MNI_Warped_pve_2.nii.gz');
    csf_prob_path = fullfile(fileparts(in_anat_path),'T1_to_MNI_Warped_pve_0.nii.gz');
    t1_brain_mask = fullfile(fileparts(in_anat_path),'T1_to_MNI_Warped_mask.nii.gz');
    Subj_list_1.GM_MNI = gm_prob_path;
    Subj_list_1.WM_MNI = wm_prob_path;
    Subj_list_1.CSF_MNI = csf_prob_path;
    Subj_list_1.anat_mask_MNI = t1_brain_mask;
end

if Reg_CSF == 1
    in_func_path = out_func_path;
    in_csf_tpm_path = csf_prob_path;
    
    [Subj_list_1,out_csf_mask_func_path] = whifun_csf_mask_extraction_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_tpm_path,CSF_thres,log_fileID,over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
else
    disp('Since No Regression is Specified, CSF Mask will not be created')
end

if Reg_CSF == 1
    in_csf_mask_func_path = out_csf_mask_func_path;
    [Subj_list_1,out_csf_mat_path] = whifun_extract_csf_ts_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_mask_func_path,pca_for_temp_reg,n_pca,log_fileID,over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
end

if motion_reg == 1 || Reg_CSF == 1
    if Reg_CSF == 1
        in_csf_mat_path = out_csf_mat_path;
    else
        in_csf_mat_path = [];
    end
%%               Nuisance REGRESSION

    in_anat_mask_path = t1_brain_mask;
    in_func_path = out_func_path;
    if motion_reg == 1
        in_motion_txt_path = out_motion_txt_path;

    else
        in_motion_txt_path = [];
    end
    
    [Subj_list_1,out_func_path,func_mask] = whifun_nuisance_regress_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_mask_path,Reg_pre,n_pca,in_csf_mat_path,in_motion_txt_path,log_fileID,over_write);
    Subj_list_1.func_mask_MNI = func_mask;
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
else
    disp('Nuisance Regression Skipped')
    if filter_check
        in_func_path = out_func_path;
        in_anat_mask_path = out_anat_mask_native_space_path;
        now_func_path = dir(in_func_path);
        if ~exist(fullfile(now_func_path.folder,['func_mask_' now_func_path.name]),'file') || over_write == 1
            [~,out_func_mask_path] = whifun_create_rest_mask(in_func_path,in_anat_mask_path);
            Subj_list_1.func_mask_native = out_func_mask_path;
        end
        if Subj_list_1.error
            fclose(log_fileID);
            return
        end
    end
end

%%    13     Smoothing

if Smooth_ == 1
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_smooth_preproc(quality_control_path,Subj_list_1,in_func_path,gm_prob_path,wm_prob_path,WM_GM_seperate,smooth_fwhm,Smooth_pre,log_fileID,over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
    Subj_list_1.final_func_MNI = out_func_path;
else
    disp('No smoothing is selected hence skipping this step')
    % Subj_list_1.final_func_MNI = out_func_path;
end
disp(['Smoothing is done for ' Subj_list_1.name])

%% motion censoring

% Perform motion censoring if specified
if motion_censor == 1
    in_func_path = Subj_list_1.final_func_MNI;%out_func_path;
    func_mask = Subj_list_1.func_mask_MNI;
    [out_censor_path, ~] = whifun_motion_censoring(in_func_path, in_motion_txt_path,func_mask, 0.25, log_fileID, over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
    Subj_list_1.func_MNI = in_func_path;
    Subj_list_1.final_func_MNI = out_censor_path;

else
    disp('Motion censoring skipped');
end
fclose(log_fileID);
