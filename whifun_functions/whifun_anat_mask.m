function output = whifun_anat_mask(out_mask_path,anat_path,GM_path,WM_path,CSF_path)
% WHIFUN_WANAT_MASK Creates a brain mask from segmented anatomical images in MNI space using SPM.
%
%   output = WHIFUN_ANAT_MASK(m_file, now_anat_path, norm) creates a binary
%   brain mask by combining the segmented Gray Matter (GM), White Matter
%   (WM), and Cerebrospinal Fluid (CSF) images.
%
%   This function configures and runs the `imcalc` module in SPM to perform a
%   simple logical operation. It sums the segmented GM, WM, and CSF images
%   and creates a binary mask where any voxel with a combined probability
%   greater than 0.5 is set to 1 (brain tissue), and all other voxels are
%   set to 0.
%
%   The function can create the mask in either native or MNI space, based on
%   the `norm` input argument. This is a crucial step for subsequent
%   preprocessing, such as skull stripping or calculating average signal.
%
%   Input Arguments:
%   now_anat_path - A `dir` structure pointing to the original anatomical file,
%                   used for path and name information.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, FULLFILE, EVALC.

matlabbatch{1}.spm.util.imcalc.input = {
    anat_path
    GM_path
    WM_path
    CSF_path};
[fold,name,ext] = fileparts(out_mask_path);
matlabbatch{1}.spm.util.imcalc.output = [name,ext];
matlabbatch{1}.spm.util.imcalc.outdir = {fold};
matlabbatch{1}.spm.util.imcalc.expression = '((i2+i3+i4)>0.5)';
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