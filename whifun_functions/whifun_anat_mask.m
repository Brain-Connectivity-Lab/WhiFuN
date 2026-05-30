function output = whifun_anat_mask(out_mask_path,anat_path,GM_path,WM_path,CSF_path)
%WHIFUN_ANAT_MASK Generates a binary anatomical brain mask using SPM imcalc.
%
%   output = WHIFUN_ANAT_MASK(out_mask_path, anat_path, GM_path, WM_path, CSF_path)
%   combines Gray Matter (GM), White Matter (WM), and Cerebrospinal Fluid (CSF) 
%   tissue probability maps to create a single binary brain mask. A voxel is 
%   included in the mask if the sum of its GM, WM, and CSF probabilities is 
%   greater than 0.5. The SPM GUI is suppressed during execution.
%
%   Dependencies: 
%       This function requires SPM (Statistical Parametric Mapping) to be 
%       installed and in the MATLAB search path.
%
%   Inputs:
%       out_mask_path - String or char array specifying the full path and 
%                       filename for the resulting mask (e.g., '.nii' or '.img').
%       anat_path     - String or char array path to the base anatomical image 
%                       (loaded as i1 in imcalc).
%       GM_path       - String or char array path to the Gray Matter map (loaded as i2).
%       WM_path       - String or char array path to the White Matter map (loaded as i3).
%       CSF_path      - String or char array path to the CSF map (loaded as i4).
%
%   Outputs:
%       output        - Character array containing the console output generated 
%                       by spm_jobman, captured via evalc.
%
%   Example:
%       log_out = whifun_anat_mask('C:\Data\Sub01_mask.nii', ...
%                                  'C:\Data\T1.nii', ...
%                                  'C:\Data\c1T1.nii', ...
%                                  'C:\Data\c2T1.nii', ...
%                                  'C:\Data\c3T1.nii');
%   Author: Pratik Jain


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