function output = whifun_smooth_together(nt,now_func_path,smooth_fwhm,Smooth_pre)
%WHIFUN_SMOOTH_TOGETHER Performs spatial smoothing on a 4D fMRI volume using SPM's
%   'smooth' module.
%
%   OUTPUT = WHIFUN_SMOOTH_TOGETHER(NT, NOW_FUNC_PATH, SMOOTH_FWHM, SMOOTH_PRE)
%
%   This function sets up and runs an SPM job to apply a Gaussian smoothing kernel
%   to all individual volumes (time points) of a 4D NIfTI file. It prepares the
%   job to run non-interactively and captures the SPM output.
%
%   Input Arguments:
%   NT            - The total number of time points (volumes) in the functional image.
%   NOW_FUNC_PATH - A structure (e.g., from `dir` or `fileparts`) or string
%                   containing the path information for the 4D functional NIfTI file.
%                   It must contain the folder and file name for the 4D image.
%   SMOOTH_FWHM   - The Full-Width at Half-Maximum (FWHM) of the Gaussian
%                   kernel in millimeters (e.g., 6). This is applied equally
%                   in the X, Y, and Z dimensions.
%   SMOOTH_PRE    - The prefix (e.g., 's') to be added to the output smoothed
%                   image file name (e.g., 'r_data.nii' becomes 'sr_data.nii').
%
%   Output Arguments:
%   OUTPUT        - A character array containing the text output captured from
%                   the SPM job execution (useful for logging/debugging).
%
%   Dependencies: MATLAB's 'spm' functions (`spm_jobman`, `spm_defaults`, etc.).
%
%   Author: Pratik Jain

% Load Regressed Images

[fold,func_name,ext] = fileparts (fullfile(now_func_path.folder,now_func_path.name));

if strcmp(ext,'.gz')
    gunzip(fullfile(now_func_path.folder,now_func_path.name),fold)
    gz = 1;
    nii_file_path = fullfile(fold,func_name);
    now_func_path = dir(fullfile(fold,func_name));
end

reg_images = cell(nt,1);
for imagei = 1:nt
    reg_images{imagei, 1} = (fullfile(now_func_path.folder,[now_func_path.name,',',num2str(imagei)]));
end
matlabbatch{1}.spm.spatial.smooth.data = reg_images;
matlabbatch{1}.spm.spatial.smooth.fwhm = [smooth_fwhm smooth_fwhm smooth_fwhm];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = Smooth_pre;

%         cfg_util('run',matlabbatch);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");

if gz == 1
    delete(nii_file_path)
    gzip(fullfile(fullfile(fold,[Smooth_pre func_name])),fold)
    delete(fullfile(fullfile(fold,[Smooth_pre func_name])))

end