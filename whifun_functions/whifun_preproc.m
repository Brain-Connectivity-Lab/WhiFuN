function Subj_list_1 = whifun_preproc(quality_control_path, Subj_list_1, varargin)
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
p.FunctionName = 'whifun_preproc';

% required
addRequired(p, 'quality_control_path', @(x) ischar(x) || isstring(x));
addRequired(p, 'Subj_list_1', @isstruct);

% general
addParameter(p, 'over_write', 0, @(x) islogical(x) || (isnumeric(x) && isscalar(x)));

% discard volumes
addParameter(p, 'Cut_pre', 'c_', @(x) ischar(x) || isstring(x));
addParameter(p, 'n_vol_dis', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);

% realignment
addParameter(p, 'Realign_pre', 'r', @(x) ischar(x) || isstring(x));

% framewise displacement
addParameter(p, 'max_fd', 0.5, @isnumeric);
addParameter(p, 'mean_fd', 0.2, @isnumeric);
addParameter(p, 'greater_than_20', 0.2, @isnumeric);

% skull stripping
addParameter(p, 'skull_pre', 'b', @(x) ischar(x) || isstring(x));

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
addParameter(p, 'filter_lp', '0.01',  @(x) ischar(x) || isstring(x));
addParameter(p, 'filter_hp', '0.15',  @(x) ischar(x) || isstring(x));

% smoothing
addParameter(p, 'Smooth_', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'Smooth_pre', 's', @(x) ischar(x) || isstring(x));
addParameter(p, 'WM_GM_seperate', 1, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'smooth_fwhm', 4, @(x) isnumeric(x) && isscalar(x) && x>=0);

% normalization
addParameter(p, 'dartel_', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'Norm_pre', 'w', @(x) ischar(x) || isstring(x));
addParameter(p, 'vox', 3, @isnumeric);

% parse inputs
parse(p, quality_control_path, Subj_list_1, varargin{:});
params = p.Results;

%% ---- Accessing parsed values (examples) ----
% You can refer to any parameter as params.<name>
% e.g.:
qc_path   = params.quality_control_path;   % string
Subj_list_1      = params.Subj_list_1;            % struct

over_write = logical(params.over_write);   % logical
Cut_pre    = char(params.Cut_pre);         % char
n_vol_dis  = params.n_vol_dis;             % numeric scalar

Realign_pre = char(params.Realign_pre);

max_fd = params.max_fd;
mean_fd = params.mean_fd;
greater_than_20 = params.greater_than_20;

skull_pre = char(params.skull_pre);

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

dartel_ = logical(params.dartel_);
Norm_pre = char(params.Norm_pre);
vox = params.vox;  % 1x3 numeric

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
    fprintf('Filtering enabled: lowpass=%g, highpass=%g (prefix %s)\n', filter_lp, filter_hp, f_pre);
    % subj = apply_filter(subj, filter_hp, filter_lp, f_pre);
end

% Smoothing
if Smooth_
    fprintf('Smoothing enabled, FWHM=%g mm (prefix %s)\n', smooth_fwhm, Smooth_pre);
    % subj = smooth_func(subj, smooth_fwhm, Smooth_pre);
end

% Normalization
if ~dartel_
    fprintf('Normalizing to vox size [%d %d %d], prefix %s\n', vox,vox,vox, Norm_pre);
    % subj = normalize_to_mni(subj, vox, Norm_pre);
else
    fprintf('DARTEL pipeline requested (skip standard normalization)\n');
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

temp_path = mfilename('fullpath');                % path of the toolbox
preproc_code_path = fileparts(fileparts(temp_path));

%%     1     Unzipping

now_func_path = dir(fullfile(Subj_list_1.func_folder,Subj_list_1.func_name)) ;
[Subj_list_1,out_func_path] = whifun_gunzip_preproc(now_func_path,Subj_list_1,'functional');

now_anat_path = dir(fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name)) ;
[Subj_list_1,out_anat_path] = whifun_gunzip_preproc(now_anat_path,Subj_list_1,'anatomical');


%% 3  Discarding intial volumes

in_func_path = out_func_path;
now_func_path = dir(in_func_path);
out_func_path = fullfile(now_func_path.folder,[Cut_pre,now_func_path.name]);
Subj_list_1 = whifun_discard_initial_volume_preproc(quality_control_path,Subj_list_1,in_func_path,out_func_path,n_vol_dis,over_write);

%%     4     Realignment

in_func_path = out_func_path;

[Subj_list_1,out_func_path,out_motion_txt_path] = whifun_realignment_preproc(quality_control_path,Subj_list_1,in_func_path,Realign_pre,log_fileID, over_write);
if Subj_list_1.error
    return
end

%% 5 Framewise displacement
in_motion_txt_path = out_motion_txt_path;
Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,in_motion_txt_path,max_fd,mean_fd,greater_than_20);
if Subj_list_1.motion_ex
    return
end
%                 disp('___________________________________________________________________________________________')
%%     6     Segmentation
in_anat_path = out_anat_path;

[Subj_list_1,out_def_path,GM_native_space_path,WM_native_space_path,CSF_native_space_path,GM_MNI_path,WM_MNI_path,CSF_MNI_path] = whifun_segment_preproc(quality_control_path,Subj_list_1,in_anat_path,log_fileID,over_write);
if Subj_list_1.error
    return
end

%%     7     Skull Stripping

[Subj_list_1,out_anat_path,out_anat_mask_native_space_path] = whifun_skull_strip_and_anat_mask_preproc(quality_control_path,Subj_list_1,in_anat_path,skull_pre,GM_native_space_path,WM_native_space_path,CSF_native_space_path,log_fileID,over_write);
if Subj_list_1.error
    return
end


%% 8 COREGISTRATION REST
% Coregister anatomical image to the functional image
in_func_path_bef = in_func_path;                           % Input to realignment
in_func_path_after = out_func_path;                        % Output to realignment (That has to be co-registered)
in_anat_path = out_anat_path;
Subj_list_1  = whifun_coreg_preproc(quality_control_path,Subj_list_1,in_func_path_bef,in_func_path_after,in_anat_path,log_fileID,over_write);
if Subj_list_1.error
    return
end

%%     9     Making CSF_MASK for REST And 10 Extracting CSF time-series
if Reg_CSF == 1
    in_func_path = out_func_path;
    in_csf_tpm_path = CSF_native_space_path;
    
    [Subj_list_1,out_csf_mask_func_path] = whifun_csf_mask_extraction_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_tpm_path,CSF_thres,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
else
    disp('Since No Regression is Specified, CSF Mask will not be created')
end

if Reg_CSF == 1
    in_csf_mask_func_path = out_csf_mask_func_path;
    [Subj_list_1,out_csf_mat_path] = whifun_extract_csf_ts_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_mask_func_path,pca_for_temp_reg,n_pca,log_fileID,over_write);
    if Subj_list_1.error
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
    in_anat_mask_native_space_path = out_anat_mask_native_space_path;
    in_func_path = out_func_path;
    if motion_reg == 1
        in_motion_txt_path = out_motion_txt_path;
    else
        in_motion_txt_path = [];
    end
    
    [Subj_list_1,out_func_path,out_func_mask_path] = whifun_nuisance_regress_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_mask_native_space_path,Reg_pre,n_pca,in_csf_mat_path,in_motion_txt_path,log_fileID,over_write);

    if Subj_list_1.error
        return
    end
else
    disp('Nuisance Regression Skipped')
    if filter_check
        in_func_path = out_func_path;
        in_anat_mask_native_space_path = out_anat_mask_native_space_path;
        now_func_path = dir(in_func_path);
        if ~exist(fullfile(now_func_path.folder,['func_mask_' now_func_path.name]),'file') || over_write == 1
            [~,out_func_mask_path] = whifun_create_rest_mask(in_func_path,in_anat_mask_native_space_path);
            Subj_list_1.func_mask_native = out_func_mask_path;
        end
    end
end
%                  disp('___________________________________________________________________________________________')
%%     12     Filtering
if filter_check
    in_func_mask_path = out_func_mask_path;
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_filter_preproc(quality_control_path,Subj_list_1,in_func_path,in_func_mask_path,filter_lp,filter_hp,f_pre,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
end

%%    13     Smoothing

if Smooth_ == 1
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_smooth_preproc(quality_control_path,Subj_list_1,in_func_path,GM_native_space_path,WM_native_space_path,WM_GM_seperate,smooth_fwhm,Smooth_pre,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
else
    disp('No smoothing is selected hence skipping this step')
end
disp(['Smoothing is done for ' Subj_list_1.name])

if ~dartel_
    %%    14     Normalization
    in_func_path = out_func_path;
    in_def_path = out_def_path;
    [Subj_list_1,out_func_path] = whifun_normalise_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_path,in_def_path,vox,Norm_pre,GM_MNI_path,WM_MNI_path,CSF_MNI_path,log_fileID,over_write);
    if Subj_list_1.error
        return
    end

    Subj_list_1.final_func_MNI = out_func_path;
    Subj_list_1.MNI_template = fullfile(preproc_code_path,'Templates','MNI152_T1_2mm_brain.nii');

end
fclose(log_fileID);