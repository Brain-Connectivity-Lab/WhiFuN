%% Dartel - Normalize and Smooth

% output_folder = 'C:\Users\jainp\Box\practice_NY_op_home_laptop';
% 
% load(fullfile(output_folder,'parameters.mat'));
% Subj_list = load_subjects(output_folder,'Subj_list.csv');
% 
% Cut_pre = 'c_';                                                             % Prefix for the Discarding Initial volumes File
% Realign_pre = 'r';                                                          % Prefix for the Realignment File
% skull_pre = 'b';                                                            % Prefix for the Skull Stripped File
% Reg_pre = 'REG_';                                                           % Prefix for the Regressed File
% 
% vox = 3;                         % Voxel Size of the Normalized (MNI) space

% f_pre = 'f';                                                                % prefix for filtered file
% Norm_pre = 'w';                                                             % Prefix for the Normalized File
% Smooth_pre = 's';                                                           % Prefix for the Smoothed File
function output = whifun_dartel_normalize_smooth(Subj_list,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,vox)
matlabbatch{1}.spm.tools.dartel.mni_norm.template = {fullfile(output_folder,'Dartel_group_template','Template_6.nii')};% {[path 'sub-' Subj_list{1} '/ses-' session '/anat/prepro_breathhold/Template_6.nii']};

for subji = 1:length(Subj_list)
    % Define functional folders
    [~,name,ext] = fileparts(Subj_list(subji).anat_name);
    now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,['u_rc1' name '_Template' ext]));
    now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre,f_pre,Reg_pre,Realign_pre Cut_pre Subj_list(subji).func_name])) ;

    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(subji).flowfield = {fullfile(now_anat_path.folder,now_anat_path.name)};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(subji).images = {fullfile(now_func_path.folder,now_func_path.name)};
end

matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [vox vox vox];
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [-90 -126 -72
    90 90 108];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0]; % Smooths images

spm_jobman('run',matlabbatch)   %"); output = evalc("