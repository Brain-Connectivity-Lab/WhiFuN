%% Create Dartel Template

% output_folder = 'C:\Users\jainp\Box\practice_NY_op_home_laptop';
%
% load(fullfile(output_folder,'parameters.mat'));
% Subj_list = load_subjects(output_folder,'Subj_list.csv');

function output = whifun_dartel(Subj_list)
% Anatomical Dartel Imports - Grey Matter & White Matter & CSF
dartel_gm = cell(length(Subj_list),1);
dartel_wm = cell(length(Subj_list),1);
dartel_csf = cell(length(Subj_list),1);

for subji = 1:length(Subj_list)

    anat_file_path = Subj_list(subji).nii_anat_native;
    [anat_folder,anat_name,nii_ext] = fileparts(anat_file_path);
    % Dartel imports
    dartel_gm{subji,1} = fullfile(anat_folder,['rc1' anat_name nii_ext]);
    dartel_wm{subji,1} = fullfile(anat_folder,['rc2' anat_name nii_ext]);
    dartel_csf{subji,1} = fullfile(anat_folder,['rc3' anat_name nii_ext]);
end

clear matlabbatch
matlabbatch{1}.spm.tools.dartel.warp.images = {
    dartel_gm
    dartel_wm
    dartel_csf
    }';
matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

output = evalc("spm_jobman('run',matlabbatch)");


