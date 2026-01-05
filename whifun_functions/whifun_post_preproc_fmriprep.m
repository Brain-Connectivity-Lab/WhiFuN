function Subj_list_1 = whifun_post_preproc_fmriprep(quality_control_path, Subj_list_1, varargin)
%WHIFUN_POST_PREPROC_FMRIPREP Post-processing pipeline for fMRIPrep outputs.
%
%   SUBJ_LIST_1 = WHIFUN_POST_PREPROC_FMRIPREP(QC_PATH, SUBJ_STRUCT, 'Name', Value)
%   takes the outputs of an fMRIPrep pipeline and performs additional 
%   processing steps: volume discarding, FD calculation, nuisance 
%   regression (using fMRIPrep's confound TSV), and spatial smoothing.
%
%   INPUTS:
%       quality_control_path - String. Path for logs and QC reports.
%       Subj_list_1          - Struct. Must contain .func_folder, 
%                              .func_name, .anat_folder, and .anat_name.
%
%   OPTIONAL PARAMETERS (Name-Value Pairs):
%       'over_write'   - Logical. If true, existing files are re-created.
%       'n_vol_dis'    - Integer. Initial volumes to discard (Default: 0).
%       'max_fd'       - Numeric. Framewise Displacement threshold (Default: 0.5).
%       'Reg_'         - Logical. Toggle nuisance regression (Default: 0).
%       'Reg_params'   - Cell array. List of confound names from fMRIPrep 
%                        TSV to include (e.g., {'trans_x', 'csf'}).
%       'Smooth_'      - Logical. Toggle spatial smoothing (Default: 0).
%       'smooth_fwhm'  - Numeric. Smoothing kernel size in mm (Default: 4).
%
%   OUTPUTS:
%       Subj_list_1    - Updated struct with paths to regressed and 
%                        smoothed NIfTIs in MNI space.
%
%   EXAMPLE:
%       subj = whifun_post_preproc_fmriprep(qc_path, subj, 'Reg_', 1, ...
%              'Reg_params', {'trans_x', 'trans_y', 'trans_z', 'csf'});
%
%   See also WHIFUN_BIDS_JOIN, WHIFUN_REGRESS_ANY, WHIFUN_PARSE_BIDS_FILENAME.
%% ---- input parser ----
p = inputParser;
p.FunctionName = 'whifun_post_preproc_fmriprep';

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

% nuisance regression
addParameter(p, 'Reg_', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'Reg_pre', 'REG_',@(x) ischar(x) || isstring(x));
addParameter(p, 'Reg_params', {''},@(x) iscell(x));

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

max_fd = params.max_fd;
mean_fd = params.mean_fd;
greater_than_20 = params.greater_than_20;

Reg_ = logical(params.Reg_);
Reg_pre = params.Reg_pre;
Reg_params = params.Reg_params;

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

% regression

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


%% Func files from fmriprep

func_bids_info = whifun_parse_bids_filename(fullfile(Subj_list_1.func_folder,Subj_list_1.func_name));
now_confound_tsv_path = dir(fullfile(Subj_list_1.func_folder,[whifun_bids_join(func_bids_info.sub,func_bids_info.ses,func_bids_info.task,func_bids_info.run), '_desc-confounds_timeseries.tsv']));

in_confound_txt_path = fullfile(now_confound_tsv_path.folder,now_confound_tsv_path.name);
confound_table = readtable(in_confound_txt_path, 'Delimiter', '\t', 'FileType', 'text');
confound_var = confound_table.Properties.VariableNames;
Subj_list_1.func_MNI = fullfile(Subj_list_1.func_folder,[whifun_bids_join(func_bids_info.sub,func_bids_info.ses,func_bids_info.task,func_bids_info.run), '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz']);

%% Anat files from fmriprep

anat_bids_info = whifun_parse_bids_filename(fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name));

gm_prob_mni = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '*_space-MNI152NLin2009cAsym_label-GM_probseg.nii.gz']);
wm_prob_mni = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '*_space-MNI152NLin2009cAsym_label-WM_probseg.nii.gz']);
csf_prob_mni = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '*_space-MNI152NLin2009cAsym_label-CSF_probseg.nii.gz']);

Subj_list_1.GM_MNI = gm_prob_mni;
Subj_list_1.WM_MNI = wm_prob_mni;
Subj_list_1.CSF_MNI = csf_prob_mni;

gm_prob_native = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_label-GM_probseg.nii.gz']);
wm_prob_native = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_label-WM_probseg.nii.gz']);
csf_prob_native = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_label-CSF_probseg.nii.gz']);

Subj_list_1.GM_native = gm_prob_native;
Subj_list_1.WM_native = wm_prob_native;
Subj_list_1.CSF_native = csf_prob_native;

anat_mask_mni = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz']);
Subj_list_1.anat_mask_MNI = anat_mask_mni;
anat_mask_native = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_desc-brain_mask.nii.gz']);
Subj_list_1.anat_mask_native = anat_mask_native;

Subj_list_1.nii_anat_native = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_desc-preproc_T1w.nii.gz']);
Subj_list_1.anat_MNI = complete_filepath(Subj_list_1.anat_folder,[whifun_bids_join(anat_bids_info.sub,anat_bids_info.ses,anat_bids_info.task,anat_bids_info.run), '_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz']);

%%  Discarding intial volumes

in_func_path = fullfile(Subj_list_1.func_folder,Subj_list_1.func_name);
now_func_path = dir(in_func_path);
out_func_path = fullfile(now_func_path.folder,func_preproc_dir,[Cut_pre,now_func_path.name]);
Subj_list_1 = whifun_discard_initial_volume_preproc(quality_control_path,Subj_list_1,in_func_path,out_func_path,n_vol_dis,over_write);

if n_vol_dis == 0
    out_func_path = fullfile(now_func_path.folder,func_preproc_dir, [Cut_pre, now_func_path.name]);  % Output path for realigned data
else
    out_func_path = fullfile(now_func_path.folder, [Cut_pre, now_func_path.name]);  % Output path for realigned data
end

%% 5 Framewise displacement

if n_vol_dis ~= 0
    in_func_path = out_func_path;  % Input for mcflirt
end
% [~,func_name,~] = fileparts(in_func_path);

now_func_path = dir(in_func_path);  
motion_par = [confound_table.trans_x, confound_table.trans_y, confound_table.trans_z, confound_table.rot_x,confound_table.rot_y, confound_table.rot_z];
motion_par(isnan(motion_par)) = 0;
writematrix(motion_par,fullfile(now_func_path.folder,func_preproc_dir,[now_func_path.name '_spm_format.txt']), 'Delimiter', ' ');
out_motion_txt_path = fullfile(now_func_path.folder,func_preproc_dir,[now_func_path.name '_spm_format.txt']);
Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,motion_par,max_fd,mean_fd,greater_than_20);
Subj_list_1.motion_txt = out_motion_txt_path;
if Subj_list_1.motion_ex
    fclose(log_fileID);
    return
end

if Reg_ == 1
%%               Nuisance REGRESSION

    in_anat_mask_path = anat_mask_mni;
    now_func_path = dir(in_func_path);

    if n_vol_dis ~=0
        out_func_path = fullfile(now_func_path.folder,[Reg_pre now_func_path.name]);
    else
        out_func_path = fullfile(now_func_path.folder,func_preproc_dir, [Reg_pre now_func_path.name]);  % Output path for registered data
    end

    out_func_file = whifun_create_file(over_write,out_func_path);

    if isempty(out_func_file)
        idx_all = whifun_select_confound_vars(confound_var, Reg_params);

        confound_matrix = table2array(confound_table(:,idx_all));
        confound_matrix(isnan(confound_matrix)) = 0;
        func_mask_path = whifun_regress_any(in_func_path,in_anat_mask_path,confound_matrix,out_func_path);
        % [Subj_list_1,out_func_path,func_mask] = whifun_regress_any(quality_control_path,Subj_list_1,in_func_path,in_anat_mask_path,Reg_pre,n_pca,in_csf_mat_path,in_confound_txt_path,log_fileID,over_write);
        Subj_list_1.nuisance_regressed_func_native = out_func_path;
        Subj_list_1.func_mask_MNI = func_mask_path;
        if Subj_list_1.error
            fclose(log_fileID);
            return
        end
    else
        disp('Nuisance Regression Skipped as file already created')
        func_mask_path = fullfile(now_func_path.folder,['func_mask_' now_func_path.name]);
        Subj_list_1.nuisance_regressed_func_native = out_func_path;
        Subj_list_1.func_mask_MNI = func_mask_path;
    end
else
    disp('Nuisance Regression Skipped')
end

%%    13     Smoothing

if Smooth_ == 1
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_smooth_preproc(quality_control_path,Subj_list_1,in_func_path,gm_prob_mni,wm_prob_mni,WM_GM_seperate,smooth_fwhm,Smooth_pre,log_fileID,over_write);
    if Subj_list_1.error
        fclose(log_fileID);
        return
    end
    Subj_list_1.final_func_MNI = out_func_path;
else
    disp('No smoothing is selected hence skipping this step')
end
disp(['Smoothing is done for ' Subj_list_1.name])
