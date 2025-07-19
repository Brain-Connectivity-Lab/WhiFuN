function output = whifun_smooth_together(nt,now_func_path,smooth_fwhm,Smooth_pre)
% Load Regressed Images
reg_images = cell(nt,1);
for imagei = 1:nt
    reg_images{imagei, 1} = (fullfile(now_func_path.folder,[now_func_path.name,',',num2str(imagei)]));
end
matlabbatch{1}.spm.spatial.smooth.data = reg_images;
matlabbatch{1}.spm.spatial.smooth.fwhm = [smooth_fwhm smooth_fwhm smooth_fwhm];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = Smooth_pre;

%         cfg_util('run',matlabbatch);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");