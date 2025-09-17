function output = whifun_coreg(now_anat_path,now_func_path,mean_func,nt)
% WHIFUN_COREG Performs coregistration using SPM.
%
%   output = WHIFUN_COREG(now_anat_path, now_func_path, mean_func, nt)
%   aligns a subject's functional images to their anatomical image. This is a
%   critical step in fMRI preprocessing to ensure that functional data can
%   be accurately localized to anatomical structures.
%
%   The function configures and runs the SPM coregistration job. The
%   anatomical image is set as the reference, and a mean functional image
%   is set as the source. All functional volumes are included as "other"
%   images, ensuring that the same transformation is applied to the entire
%   time series.
%
%   Key parameters are set for the job:
%   - **Cost Function**: Normalized Mutual Information (`'nmi'`) is used to
%     find the optimal alignment.
%   - **Sampling and Smoothing**: The sampling separation and histogram
%     smoothing parameters are set to ensure an accurate and robust
%     estimation.
%
%   The function suppresses the SPM GUI and returns the command-line output
%   of the job.
%
%   Input Arguments:
%   now_anat_path - A `dir` structure pointing to the anatomical file.
%   now_func_path - A `dir` structure pointing to the functional file.
%   mean_func     - A `dir` structure pointing to the mean functional image.
%   nt            - The number of time points in the functional image series.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, EVALC, FULLFILE.
start = 1;
if isempty(mean_func)
    mean_func = now_func_path;
    start = 2;
end


matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[fullfile(now_anat_path.folder,now_anat_path.name),',1']};   % Reference image (this does not change) (Here its the anatomical image)


matlabbatch{1}.spm.spatial.coreg.estimate.source = {[fullfile(mean_func.folder,mean_func.name),',1']};        % Source image (This will change) (here its the functional image)
pathlist = cell(nt,1);
for ii= start:nt    % Number of timepoints
    pathlist{ii,1} = strcat([fullfile(now_func_path.folder,now_func_path.name),',',num2str(ii)]);
end

if start==2
    pathlist(1) = [];
end

matlabbatch{1}.spm.spatial.coreg.estimate.other = (pathlist);         % These are any images that need to remain in alignment with the moved image

matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';  % Cost function is normalized mutual information
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];       % The average distance between sampled points (in mm).
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]; % Iterations  stop  when differences between successive estimates are less than the required tolerance.
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [5 5];      % Histogram smoothing by Gaussian smoothing to apply to the 256x256 joint histogram.
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");