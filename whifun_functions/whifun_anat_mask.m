function output = whifun_anat_mask(m_file,now_anat_path,norm)
% WHIFUN_ANAT_MASK Creates a brain mask from segmented anatomical images using SPM.
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
%   m_file        - A `dir` structure pointing to the bias-corrected anatomical file.
%   now_anat_path - A `dir` structure pointing to the original anatomical file,
%                   used for path and name information.
%   norm          - A logical value (0 or 1). If 1, the function uses the
%                   normalized (`w` prefixed) segmented images to create a
%                   mask in MNI space. If 0, it uses the native-space
%                   segmented images.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, FULLFILE, EVALC.

if norm == 1
    norm_pre = 'w';
else
    norm_pre = '';
end

matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(m_file.folder, m_file.name) '']
    [complete_filepath(fullfile(now_anat_path.folder, [norm_pre 'c1' now_anat_path.name])) '']
    [complete_filepath(fullfile(now_anat_path.folder, [norm_pre 'c2' now_anat_path.name])) '']
    [complete_filepath(fullfile(now_anat_path.folder, [norm_pre 'c3' now_anat_path.name])) '']};

matlabbatch{1}.spm.util.imcalc.output = [norm_pre 'anat_mask_' now_anat_path.name];
matlabbatch{1}.spm.util.imcalc.outdir = {now_anat_path.folder};
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