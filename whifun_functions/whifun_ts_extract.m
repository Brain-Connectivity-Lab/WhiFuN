function [all_ts,n_gm,n_wm,n_deep_wm,n_csf] = whifun_ts_extract(GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,func_path,over_write,thresh_gm,thresh_wm,thresh_deep_wm,thresh_csf)
% WHIFUN_TS_EXTRACT Extracts time series from multiple brain tissue masks.
%
%   [all_ts, n_gm, n_wm, n_deep_wm, n_csf] = WHIFUN_TS_EXTRACT(...) extracts
%   the time series of all voxels within four predefined brain tissue masks:
%   Gray Matter (GM), Superficial White Matter (WM), Deep White Matter (WM),
%   and Cerebrospinal Fluid (CSF).
%
%   The function first uses a helper function `whifun_create_mask` to
%   generate binary masks for each tissue type at a specified threshold,
%   resliced to the functional space. It then reads the functional data and
%   extracts the time series for all voxels within each of these masks.
%
%   The function separates the WM time series into superficial and deep
%   components, providing more detailed quality control. It returns a
%   concatenated matrix of all time series and the number of voxels
%   extracted from each mask.
%
%   Input Arguments:
%   GM_mask_path      - Path to the Gray Matter segmented file.
%   WM_mask_path      - Path to the White Matter segmented file.
%   deep_WM_mask_path - Path to the eroded deep White Matter mask.
%   CSF_mask_path     - Path to the CSF segmented file.
%   func_path         - Path to the functional NIfTI file.
%   over_write        - Logical flag to force mask recreation.
%   thresh_gm         - (Optional) Threshold for GM mask creation.
%   thresh_wm         - (Optional) Threshold for WM mask creation.
%   thresh_deep_wm    - (Optional) Threshold for deep WM mask creation.
%   thresh_csf        - (Optional) Threshold for CSF mask creation.
%
%   Output Arguments:
%   all_ts      - A matrix of all extracted time series (voxels x time points).
%   n_gm        - Number of GM voxels.
%   n_wm        - Number of superficial WM voxels.
%   n_deep_wm   - Number of deep WM voxels.
%   n_csf       - Number of CSF voxels.
%
%   Author: Pratik Jain
%   See also NIFTIREAD, RESHAPE, WHIFUN_CREATE_MASK, WHIFUN_ERODE.

if ~exist("thresh_gm",'var')
    thresh_gm = 0.5;
end

if ~exist("thresh_wm",'var')
    thresh_wm = 0.5;
end

if ~exist("thresh_deep_wm",'var')
    thresh_deep_wm = 0.5;
end

if ~exist("thresh_csf",'var')
    thresh_csf = 0.5;
end

[~,GM_mask_name,~] = fileparts(GM_mask_path);
[~,WM_mask_name,~] = fileparts(WM_mask_path);
[~,CSF_mask_name,~] = fileparts(CSF_mask_path);



if create_mask(over_write,func_path,[GM_mask_name '_for_vox_ts_qc'],thresh_gm)
    whifun_create_mask(GM_mask_path,func_path,thresh_gm,[GM_mask_name '_for_vox_ts_qc']);
end
if create_mask(over_write,func_path,[WM_mask_name '_for_vox_ts_qc'],thresh_wm)
    whifun_create_mask(WM_mask_path,func_path,thresh_wm,[WM_mask_name '_for_vox_ts_qc']);
end
if create_mask(over_write,func_path,['deep_' WM_mask_name '_for_vox_ts_qc'],thresh_deep_wm)
    whifun_create_mask(deep_WM_mask_path,func_path,thresh_deep_wm,['deep_' WM_mask_name '_for_vox_ts_qc']);
end
if create_mask(over_write,func_path,[CSF_mask_name '_for_vox_ts_qc'],thresh_csf)
    whifun_create_mask(CSF_mask_path,func_path,thresh_csf,[CSF_mask_name '_for_vox_ts_qc']);
end

% output = [output_gm,output_wm,output_deep_wm,output_csf];

%% Extract TS
func_image = niftiread(func_path);

[~,~,~,T] = size(func_image);

func_image = reshape(func_image,[],T);
now_func_path = dir(func_path);
[gm_ts, n_gm] = extract_ts(func_image,fullfile(now_func_path.folder,[GM_mask_name '_for_vox_ts_qc' '_' num2str(thresh_gm) '.nii']));%[pre_ 'WM_Mask_for_ts_qc'  '_' num2str(thresh_wm) '.nii']  [pre_ 'deep_WM_Mask_for_ts_qc' '_' num2str(thresh_deep_wm) '.nii'])
[wm_ts,n_wm,n_deep_wm] = extract_ts_wm(func_image,fullfile(now_func_path.folder,[WM_mask_name '_for_vox_ts_qc' '_' num2str(thresh_wm) '.nii']),fullfile(now_func_path.folder,['deep_' WM_mask_name '_for_vox_ts_qc' '_' num2str(thresh_deep_wm) '.nii']));
[csf_ts,n_csf] = extract_ts(func_image,fullfile(now_func_path.folder,[CSF_mask_name '_for_vox_ts_qc' '_' num2str(thresh_csf) '.nii']));%[pre_ 'CSF_Mask_for_ts_qc' '_' num2str(thresh_csf) '.nii']

all_ts =    [gm_ts
             wm_ts
             csf_ts];

end


function output = whifun_create_mask(mask,func_path,thresh_,mask_name)
gz_mask = 0;
gz_func = 0;

[fold_,name,ext] = fileparts(mask);

if strcmp(ext,'.gz')
    gz_mask = 1;
    gunzip(mask);
    mask = fullfile(fold_,name);
end

[fold_,name,ext] = fileparts(func_path);

if strcmp(ext,'.gz')
    gz_func = 1;

    gunzip(func_path);
    func_path = fullfile(fold_,name);
end
now_mask_path = dir(mask);
now_func_path = dir(func_path);

matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(now_func_path.folder,now_func_path.name),',1']
    fullfile(now_mask_path.folder,now_mask_path.name)
    };
matlabbatch{1}.spm.util.imcalc.output = [mask_name '_' num2str(thresh_) '.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {now_func_path(1).folder};
matlabbatch{1}.spm.util.imcalc.expression = ['i2>' num2str(thresh_)];
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");
if gz_mask
    delete(mask)
end
if gz_func
    delete(func_path)
end
% reslice_data(mask,func_path,1,1,fullfile(fileparts(func_path),[mask_name '_' num2str(thresh_) '.nii']),0);
end

function [ts,n] = extract_ts(func_image,mask_path)

mask_image = niftiread(mask_path);
mask_image = reshape(mask_image, [], 1);
ts = func_image(mask_image > 0, :);
n = size(ts,1);
end

function [wm_ts, n_wm, n_deep_wm] = extract_ts_wm(func_image,wm_mask_path,deep_wm_mask_path)
    wm_mask_image = logical(niftiread(wm_mask_path));
    deep_wm_image = logical(niftiread(deep_wm_mask_path));
    other_wm = wm_mask_image & ~deep_wm_image;

    other_wm_ts = func_image(other_wm > 0,:);
    deep_wm_ts = func_image(deep_wm_image>0,:);

    n_wm = size(other_wm_ts,1);
    n_deep_wm = size(deep_wm_ts,1);
    wm_ts = [other_wm_ts; deep_wm_ts]; % Combine time series from other WM regions
end

function out = create_mask(over_write,func_path,mask_name,thresh_)

if over_write
    out = [];
else
    now_func_path = dir(func_path);
    out = dir(fullfile(now_func_path.folder,[mask_name '_' num2str(thresh_) '.nii']));
end
if ~isempty(out)
    out = 0;
else
    out = 1;
end
end