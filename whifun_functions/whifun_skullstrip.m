function output = whifun_skullstrip(m_file,now_anat_path,name,skull_pre)

matlabbatch{1}.spm.util.imcalc.input = {
    [fullfile(m_file.folder, m_file.name) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, ['c1' name])) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, ['c2' name])) '']
    [complete_filepath(fullfile(now_anat_path(1).folder, ['c3' name])) '']};

matlabbatch{1}.spm.util.imcalc.output = [skull_pre now_anat_path(1).name];
matlabbatch{1}.spm.util.imcalc.outdir = {now_anat_path(1).folder};
matlabbatch{1}.spm.util.imcalc.expression = 'i1.*((i2+i3+i4)>0.5)';
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