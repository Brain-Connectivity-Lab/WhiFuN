function Subj_list_1 = whifun_ants_native_to_mni(Subj_list_1,anat_preproc_dir,FSLDIR,Norm_pre,log_fileID,over_write)

% if whifun_isnan_or_empty(Subj_list_1,'MNI_template')
    Subj_list_1.MNI_template  = fullfile(FSLDIR,'data','standard','MNI152_T1_1mm_brain.nii.gz');
    mni_template = Subj_list_1.MNI_template;
% else
%     mni_template = Subj_list_1.MNI_template;
% end


%% ANTs registeration to MNI space

in_anat_path = fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name);
if ~exist(fullfile(fileparts(in_anat_path),anat_preproc_dir),'dir')
    mkdir(fullfile(fileparts(in_anat_path),anat_preproc_dir))
end
out_anat_path = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_Warped.nii.gz');
out_anat_file = whifun_create_file(over_write,out_anat_path);
cd(fullfile(fileparts(in_anat_path),anat_preproc_dir))
if isempty(out_anat_file)
    cmd = sprintf('antsRegistrationSyN.sh -d 3 -f %s -m %s -o T1_to_MNI_',mni_template, in_anat_path);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'ANTs Standard Space Registeration\n');
    fprintf(log_fileID, '[CMD] %s\n', cmd);
    [s, w] = system(cmd);
    if s ~= 0
        error('ANTs Registration command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end
    Subj_list_1.anat_MNI = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_Warped.nii.gz');
    Subj_list_1.deformation_field = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_1Warp.nii.gz');
else
    Subj_list_1.anat_MNI = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_Warped.nii.gz');
    Subj_list_1.deformation_field = fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_1Warp.nii.gz');
end

% ---------- 2) mean functional ----------

in_func_path = Subj_list_1.realigned_func_native;
now_func_path = dir(in_func_path);
meanfunc = fullfile(now_func_path.folder,['mean_' now_func_path.name]);

out_func_file = whifun_create_file(over_write,meanfunc);

if isempty(out_func_file)

    cmd = sprintf('fslmaths %s -Tmean %s', in_func_path, meanfunc);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'mean functional file\n');
    fprintf(log_fileID,'%s',  sprintf('[CMD] %s\n', cmd));
    [s,w] = system(cmd);
    if s~=0
        error('Command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end

end

%% Getting the ANTs func to anat space


out_func_path = fullfile(now_func_path.folder,'func_to_anat_Warped.nii.gz');%%%

out_func_to_anat_warp_ants = fullfile(now_func_path.folder,'func_to_anat_0GenericAffine.mat');

out_func_warp_file = whifun_create_file(over_write,out_func_to_anat_warp_ants);
cd(now_func_path.folder)
if isempty(out_func_warp_file)
    cmd = sprintf('antsRegistrationSyN.sh -d 3 -f %s -m %s -t r -o func_to_anat_',in_anat_path,meanfunc);
    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'function 2 Anat ANTs (Done to get the ANTs warping Matrix)\n');
    fprintf(log_fileID,'%s',  sprintf('[CMD] %s\n', cmd));
    [s,w] = system(cmd);
    if s~=0
        error('Command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end
    Subj_list_1.coregistered_func_native = out_func_path;

end

%% MNI tranform of the func file

out_func_path = fullfile(now_func_path.folder,[Norm_pre now_func_path.name]);

out_func_file = whifun_create_file(over_write,out_func_path);

if isempty(out_func_file)
    cmd = sprintf('antsApplyTransforms -d 3 -e 3 -i %s -r %s -o %s -n LanczosWindowedSinc -t %s -t %s -t %s', in_func_path, mni_template,out_func_path,fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_1Warp.nii.gz'),fullfile(fileparts(in_anat_path),anat_preproc_dir,'T1_to_MNI_0GenericAffine.mat'),out_func_to_anat_warp_ants );
    %  antsApplyTransforms -d 3 -e 3 -i sub-A00008326_ses-BAS1_task-rest_acq-1400_bold.nii.gz -r MNI152_T1_2mm.nii.gz -o func_mni.nii.gz -n LanczosWindowedSinc -t sub2mni1Warp.nii.gz -t sub2mni0GenericAffine.mat -t func2fsl0GenericAffine.mat 

    fprintf(log_fileID,'#####################################################################################################################\n \n');
    fprintf(log_fileID, 'function 2 MNI applywarp\n');
    fprintf(log_fileID,'%s',  sprintf('[CMD] %s\n', cmd));
    [s,w] = system(cmd);
    if s~=0
        error('Command failed (exit %d): %s\nOutput:\n%s', s, cmd, w);
    end
    Subj_list_1.func_MNI = out_func_path;
else
    Subj_list_1.func_MNI = out_func_path;
end