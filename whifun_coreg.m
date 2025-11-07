function output = whifun_coreg(now_anat_path,now_func_path,mean_func,nt)

matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[fullfile(now_anat_path.folder,now_anat_path.name),',1']};   % Reference image (this does not change) (Here its the anatomical image)


matlabbatch{1}.spm.spatial.coreg.estimate.source = {[fullfile(mean_func.folder,mean_func.name),',1']};        % Source image (This will change) (here its the functional image)
pathlist = cell(nt,1);
for ii= 1:nt    % Number of timepoints
    pathlist{ii,1} = strcat([fullfile(now_func_path.folder,now_func_path.name),',',num2str(ii)]);
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