function output = whifun_realignment(now_func_path,Realign_pre,nt)
% nt = Subj_list(subji).nt_dis;                                                  % Just extract the number of timepoints
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
