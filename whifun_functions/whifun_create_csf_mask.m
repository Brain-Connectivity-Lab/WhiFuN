function output = whifun_create_csf_mask(csf_tpm_path,now_func_path,CSF_thres)

% WHIFUN_CREATE_CSF_MASK Creates a CSF mask using SPM's imcalc.
%
%   output = WHIFUN_CREATE_CSF_MASK(csf_tpm_path, now_func_path, CSF_thres)
%   generates a binary mask of the Cerebrospinal Fluid (CSF) in the
%   functional image's native space. This mask is based on a CSF tissue
%   probability map (TPM).
%
%   The function uses SPM's `imcalc` to apply a threshold to the CSF TPM (Output of Segmentation).
%   The functional image is included as a reference to define the output
%   image's dimensions and header information, ensuring the mask is in the
%   correct space.
%
%   The process involves the following steps:
%   1. **Input Selection**: The CSF TPM and the first volume of the
%      functional image are provided as inputs to `imcalc`.
%   2. **Expression**: A logical expression (`'i2>CSF_thres'`) is used to
%      create a binary mask. Any voxel in the CSF TPM (`i2`) with a
%      probability greater than `CSF_thres` is set to 1, and all others are
%      set to 0.
%   3. **Output**: The resulting mask is saved in the same directory as the
%      functional data, with a name that includes the threshold value.
%
%   Input Arguments:
%   csf_tpm_path  - The path to the CSF tissue probability map file.
%   now_func_path - A `dir` structure pointing to the functional file.
%   CSF_thres     - The probability threshold (numeric, e.g., 0.5) to
%                   apply to the CSF TPM to create the binary mask.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, EVALC, FULLFILE.



c3 = dir(csf_tpm_path);

[~,name,ext] = fileparts(c3.name);

if strcmp(ext,'.gz')
    gunzip(fullfile(c3.folder,c3.name))
    c3.name = name;
    g_un_c3 = 1;
else
    g_un_c3 = 0; % Set flag for unzipped file
end

[~,f_name,f_ext] = fileparts(now_func_path.name);

if strcmp(f_ext,'.gz')
    gunzip(fullfile(now_func_path.folder,now_func_path.name))
    now_func_path.name = f_name;
    g_un_f = 1;
else
    g_un_f = 0; % Set flag for unzipped file
end

matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(now_func_path.folder,now_func_path.name),',1']
    fullfile(c3.folder,c3.name)
    };
matlabbatch{1}.spm.util.imcalc.output = ['CSF_MASK_' char(CSF_thres) '_' now_func_path.name];
matlabbatch{1}.spm.util.imcalc.outdir = {now_func_path.folder};
matlabbatch{1}.spm.util.imcalc.expression = ['i2>' char(CSF_thres)];
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

if g_un_c3
    delete(fullfile(c3.folder, c3.name)); % Remove the unzipped file if it was created
end

if g_un_f
    delete(fullfile(now_func_path.folder, now_func_path.name)); % Remove the unzipped file if it was created
    gzip(fullfile(now_func_path.folder,['CSF_MASK_' char(CSF_thres) '_' now_func_path.name]))
    delete(fullfile(now_func_path.folder,['CSF_MASK_' char(CSF_thres) '_' now_func_path.name]))
end