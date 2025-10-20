function output = whifun_coreg_afni(now_anat_path,now_func_path)
%WHIFUN_COREG_AFNI Performs T2*-to-T1 coregistration using AFNI's `align_epi_anat.py` and cleans up intermediate files.
%
%   OUTPUT = WHIFUN_COREG_AFNI(NOW_ANAT_PATH, NOW_FUNC_PATH)
%
%   This function executes a coregistration step, aligning the functional
%   EPI image (T2*) to the anatomical image (T1) using the AFNI (Analysis
%   of Functional NeuroImages) tool `align_epi_anat.py`. It is designed to
%   be used within a MATLAB pipeline, capturing command line output and
%   managing temporary files.
%
%   Input Arguments:
%   NOW_ANAT_PATH - A structure array (e.g., from `dir` or custom function)
%                   pointing to the anatomical (T1) NIfTI file. Must contain
%                   fields `folder` and `name`.
%   NOW_FUNC_PATH - A structure array (must contain one entry) pointing to
%                   the functional (EPI) NIfTI file. Must contain fields
%                   `folder` and `name`. The output coregistered functional
%                   image will replace this file (due to overwrite).
%
%   Output Arguments:
%   OUTPUT        - A string concatenating the command window output from
%                   both AFNI commands (`align_epi_anat.py` and `3dcopy`).
%
%   Dependencies: Requires the AFNI software suite to be installed and accessible
%                 from the system path.
%
%   Workflow:
%   1. Change directory to the functional data folder.
%   2. Execute `align_epi_anat.py` to calculate the transformation and apply
%      it to the EPI image, creating an AFNI-native file (e.g., `rc_*_al+orig.BRIK.gz`).
%   3. Execute `3dcopy` to convert the coregistered AFNI file back to the
%      original NIfTI filename, overwriting the original functional file.
%   4. Delete the temporary AFNI BRIK/HEAD files.
%
%   Author: Pratik Jain

cd(now_func_path(1).folder)
cmd_1 = ['align_epi_anat.py -anat ' fullfile(now_anat_path.folder,now_anat_path.name) ' -anat_has_skull yes -epi ' fullfile(now_func_path.folder,now_func_path.name) ' -epi2anat -epi_base 0 ' '-epi_strip 3dAutomask -cost lpc+ZZ -giant_move -suffix _al -overwrite']; %#ok<NASGU>

output_1 = evalc('system(cmd_1);');

cmd_2 = ['3dcopy ' 'rc_*_al+orig.BRIK.gz ' fullfile(now_func_path.folder,now_func_path.name) ' -overwrite']; %#ok<NASGU>

output_2 = evalc('system(cmd_2);');
brik_head = dir(fullfile(now_func_path(1).folder,'rc_*_al+orig.*'));

for i = 1:2
    delete(fullfile(brik_head(i).folder,brik_head(i).name))
end
output = [output_1, output_2];
end


