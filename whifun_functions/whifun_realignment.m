function output = whifun_realignment(now_func_path,Realign_pre,nt)
% WHIFUN_REALIGNMENT Performs motion correction (realignment) using SPM.
%
%   output = WHIFUN_REALIGNMENT(now_func_path, Realign_pre, nt)
%   configures and executes the SPM realignment job to correct for head motion
%   in a time series of functional images.
%
%   This function creates an SPM batch job to:
%   - **Estimate and Write**: Estimates the motion parameters and applies
%     the transformations to create a new, realigned image series.
%   - **Quality Settings**: Uses a high-quality estimation (`quality = 0.9`),
%     a default separation, and a FWHM smoothing kernel of 5mm.
%   - **Reference Image**: Registers all images to the first image in the
%     series (`rtm = 0`).
%   - **Interpolation**: Uses 2nd-degree B-spline for estimation and
%     4th-degree B-spline for writing the resliced images.
%   - **Masking**: Applies a mask to set out-of-bounds voxels to zero
%     to handle interpolation artifacts from motion.
%   - **Prefix**: Adds a specified prefix (`Realign_pre`) to the output
%     realigned files.
%
%   The function suppresses the SPM GUI and returns the log output.
%
%   Input Arguments:
%   now_func_path - A `dir` structure pointing to the functional NIfTI file.
%   Realign_pre   - The prefix to use for the output realigned file (e.g., 'r').
%   nt            - The number of time points in the functional image series.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, EVALC, FULLFILE.
pathlist = cell(nt,1);
for ii = 1:nt                                                                  % loop on the number of timepoints
    pathlist{ii,1} = [char(fullfile(now_func_path.folder,now_func_path.name)),',',num2str(ii)];
end

matlabbatch{1}.spm.spatial.realign.estwrite.data = {pathlist}';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;           % Quality 1--> max quality
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;                 % separation (in mm) between the points sampled in the reference image. Smaller speration gives more accurate results, but will be slower.
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;                % FWHM Gaussian smothing kernel parameter in mm
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;                 % Register to First Image
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;              % The method by which the images are sampled when estimating the optimum transformation. 2nd degree bspline
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];          % Directions in the volumes the values should wrap around in.
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';             % Optional weighting image to weight each voxel of the reference image differently when estimating the realignment parameters.
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];           % Resliced images
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;              % 4th degree bspline
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];          % no wraping
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;                % Because  of  subject  motion,  different images are likely to have different patterns of zeros from where it was not possible to sample data. With masking enabled, the program searches through the whole time series looking for voxels which need to be sampled from outside the original images. Where this occurs, that voxel is set to zero for the whole set of images (unless the image format can represent NaN, in which case NaNs are used where possible).
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = Realign_pre;    % prefix
spm('defaults', 'FMRI');                                                      % Run SPM job
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");
