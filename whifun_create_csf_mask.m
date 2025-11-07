function output = whifun_create_csf_mask(name,now_func_path,now_anat_path,CSF_thres)
c3 = dir(fullfile(now_anat_path.folder,['c3' name]));
matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(now_func_path.folder,now_func_path.name),',1']
    fullfile(c3.folder,c3.name)
    };
matlabbatch{1}.spm.util.imcalc.output = ['CSF_MASK' char(CSF_thres) '.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {now_anat_path(1).folder};
matlabbatch{1}.spm.util.imcalc.expression = ['i2>' char(CSF_thres)];
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Suppress GUI
spm_get_defaults('cmdline', true);
output = evalc("spm_jobman('run',matlabbatch)");