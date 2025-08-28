function output = whifun_coreg_afni(now_anat_path,now_func_path)

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


