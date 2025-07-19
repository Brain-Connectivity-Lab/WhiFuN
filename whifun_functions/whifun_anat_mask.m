function output = whifun_anat_mask(m_file,now_anat_path,name,norm)

if norm == 1
    norm_pre = 'w';
else
    norm_pre = '';
end

matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(m_file.folder, m_file.name) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, [norm_pre 'c1' name])) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, [norm_pre 'c2' name])) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, [norm_pre 'c3' name])) '']};

matlabbatch{1}.spm.util.imcalc.output = [norm_pre 'anat_mask.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {now_anat_path(1).folder};
matlabbatch{1}.spm.util.imcalc.expression = '((i2+i3+i4)>0.5)';
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