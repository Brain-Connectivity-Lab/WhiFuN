function output = whifun_segment(now_anat_path,spm_path)
% WHIFUN_SEGMENT Performs SPM-based segmentation and normalization.
%
%   output = WHIFUN_SEGMENT(now_anat_path, spm_path) runs the SPM
%   segmentation and normalization routine on a subject's anatomical image.
%
%   This function configures and executes the `spm_jobman` for the
%   `spm.spatial.preproc` module. The batch job is set up to:
%   - **Bias Correct** the anatomical image and save the output.
%   - **Segment** the image into six tissue types (Gray Matter, White Matter,
%     CSF, skull, etc.) using the default Tissue Probability Map (TPM).
%   - **Save** the native-space and MNI-normalized versions of the GM, WM, and
%     CSF segments.
%   - **Save** the forward and inverse deformation field maps, which are
%     essential for normalizing other images (like functional data).
%   - **Suppress** the SPM GUI for silent execution.
%
%   This function is a core step in many preprocessing pipelines, as it
%   generates the files needed for coregistration and normalization.
%
%   Input Arguments:
%   now_anat_path - A `dir` structure pointing to the anatomical NIfTI file.
%   spm_path      - The path to the SPM installation directory.
%
%   Output Arguments:
%   output - A string containing the log output from the SPM jobman.
%
%   Author: Pratik Jain
%   See also SPM_JOBMAN, NIFTIINFO, FULLFILE, EVALC.

matlabbatch{1}.spm.spatial.preproc.channel.vols = {fullfile(now_anat_path.folder,now_anat_path.name)};  % Select Volumes for processing
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];                                               % save bias corrected images
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spm_path,'tpm','TPM.nii,1')};              % Gray Matter Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];                                            % save segmented images in MNI space
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spm_path,'tpm','TPM.nii,2')};              % White Matter Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];                                            % save segmented images in MNI space
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spm_path,'tpm','TPM.nii,3')};              % CSF Tissue probability map (TPM)
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
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

