function output = whifun_normalise(in_def_path,in_func_path,in_anat_path,nt,vox,Norm_pre,func_anat)
% WHIFUN_NORMALISE Normalizes images to MNI space using SPM.
%
%   output = WHIFUN_NORMALISE(in_def_path, ..., func_anat) applies a
%   pre-existing deformation field to either a functional or an anatomical
%   image, transforming it from the subject's native space to a standard
%   template space (MNI).
%setenv
%   The function configures and executes the `spm.spatial.normalise.write`
%   job. The process involves:
%   1.  **Inputting Deformation Field**: It takes the deformation field
%       (generated during the segmentation step) as the key input for the
%       transformation.
%   2.  **Resampling**: Based on the `func_anat` flag, it either resamples
%       the entire functional time series or the anatomical image.
%   3.  **Output Voxel Size**: The output image's voxel size is determined by
%       the `vox` input argument, allowing for flexible resolution.
%   4.  **Prefix**: The specified `Norm_pre` is added to the output file's name.
%
%   This is a crucial final step in preprocessing that enables group-level
%   analyses by bringing all subjects' data into a common anatomical space.
%
%   Input Arguments:
%   in_def_path   - The path to the deformation field file (`y_...nii`).
%   in_func_path  - Path to the functional NIfTI file (for functional normalization).
%   in_anat_path  - Path to the anatomical NIfTI file (for anatomical normalization).
%   nt            - The number of time points in the functional image series.
%   vox           - The desired voxel size (in mm) for the output images.
%   Norm_pre      - The prefix for the output normalized files (e.g., 'w').
%   func_anat     - A logical value (0 or 1). If 1, normalizes functional data.
%                   If 0, normalizes anatomical data.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, EVALC, FULLFILE.

now_def_path = dir(in_def_path);
now_anat_path = dir(in_anat_path);
now_func_path = dir(in_func_path);

matlabbatch{1}.spm.spatial.normalise.write.subj.def = {char(fullfile(now_def_path.folder,now_def_path.name))};             %{'/mnt/d/NJIT/Research/Preprocessing/Practice/new/sub-10471/anat/y_sub-10471_T1w.nii'};

if func_anat == 1
    pathlist = cell(nt,1);
    for ii= 1:nt    % Number of timepoints
        pathlist{ii,1} = strcat([fullfile(now_func_path.folder,now_func_path.name),',',num2str(ii)]);
    end
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = (pathlist);
else
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {fullfile(now_anat_path.folder,now_anat_path.name)};
end
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72; 90 90 108]; %[-78 -112 -70;78 76 85];

matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [vox vox vox];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = Norm_pre;
spm('defaults', 'FMRI');                                                      % Run SPM job
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");

