function output = whifun_segment(now_anat_path,spm_path)

matlabbatch{1}.spm.spatial.preproc.channel.vols = {fullfile(now_anat_path.folder,now_anat_path.name)};  % Select Volumes for processing
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];                                               % save bias corrected images
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spm_path,'tpm','TPM.nii,1')};              % Gray Matter Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];                                            % save segmented images in MNI space
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spm_path,'tpm','TPM.nii,2')};              % White Matter Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];                                            % save segmented images in MNI space
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spm_path,'tpm','TPM.nii,3')};              % CSF Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1];                                            % save segmented images in MNI space
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spm_path,'tpm','TPM.nii,4')};              % skull Tissue Probability map (TPM) (not required for our analysis)
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spm_path,'tpm','TPM.nii,5')};              % other than skull Tissue Probability map (TPM) (not required for our analysis)
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spm_path,'tpm','TPM.nii,6')};              % Background Tissue Probability map (TPM) (not required for our analysis)
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];                                                  % save inverse and forward deformation field maps
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");