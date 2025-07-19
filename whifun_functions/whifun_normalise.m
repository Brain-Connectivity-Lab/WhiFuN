function output = whifun_normalise(now_anat_path,now_func_path,name,nt,vox,Norm_pre,skull_pre,func_anat)


matlabbatch{1}.spm.spatial.normalise.write.subj.def = {char(fullfile(now_anat_path.folder,now_anat_path.name))};%{'/mnt/d/NJIT/Research/Preprocessing/Practice/new/sub-10471/anat/y_sub-10471_T1w.nii'};

if func_anat == 1
    pathlist = cell(nt,1);
    for ii= 1:nt    % Number of timepoints
        pathlist{ii,1} = strcat([fullfile(now_func_path.folder,now_func_path.name),',',num2str(ii)]);
    end
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = (pathlist);
else
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {complete_filepath(fullfile(now_anat_path.folder,[skull_pre name]))};
end
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72; 90 90 108]; %[-78 -112 -70;78 76 85];

matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [vox vox vox];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = Norm_pre;
spm('defaults', 'FMRI');                                                      % Run SPM job
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");

