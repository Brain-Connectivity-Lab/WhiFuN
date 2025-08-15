function whifun_coreg_qc(name_,now_anat_path,now_func_path,slover_slices,slover_contour_range,slover_view,ss,quality_control_path)

if ss
    space_ = 'Subject_Space';
else
    space_ = 'MNI_Space';
end
[~,fg] = spm_check_registration_evalc(char(fullfile(now_anat_path.folder,now_anat_path.name),[fullfile(now_func_path.folder,now_func_path.name),',1']));
spm_orthviews('Caption', 1, name_);

spm_orthviews('contour','display',1,2);
exportgraphics(fg,(fullfile(quality_control_path,'d_Co_registeration',space_,'Orthoslice_View',[name_ '.png'])))

fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
whifun_slover({fullfile(now_anat_path.folder,now_anat_path.name),[fullfile(now_func_path.folder,now_func_path.name),',1']},{'Contours','Structural'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);%
exportgraphics(fg,(fullfile(quality_control_path,'d_Co_registeration',space_,[slover_view '_Slice_View'],[name_ '.png'])))


