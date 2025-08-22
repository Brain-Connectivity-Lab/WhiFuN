function whifun_slover_csv(csv_file,out_folder,space_,slover_slices,slover_contour_range,slover_view,norm,template_path)
if isempty(which('spm'))
    error('SPM path not found. Please add SPM path and Try again')
end
if ~isstring(csv_file)
    T = readtable(csv_file);
else
    T = csv_file;
end

if ~exist("space_",'var')
    space_ = 'MNI_Space'; % Assign a default value to space_ if not provided
end
if ~exist("slover_slices",'var')
    slover_slices = [-68 -65 -57 -43.2 -26.6 -14.4 -5 5 14.4 26.6 43.2 57 65 72 78];
end
if ~exist('slover_contour_range','var')
    slover_contour_range = [0 100];
end
if ~exist("slover_view",'var')
    slover_view = 'axial'; % Assign a default value to slover_view if not provided
end
if ~exist("norm",'var')
    norm = false; % Assign a default value to norm if not provided
end
quality_control_path = fullfile(out_folder, 'Quality_Control');
if ~exist(quality_control_path, 'dir')
    mkdir(quality_control_path);
    mkdir(fullfile(out_folder, 'Quality_Control','d_Co_registeration',space_,[slover_view '_Slice_View']));
    if norm
        mkdir(fullfile(out_folder, 'Quality_Control', 'i_Normalization', space_, [slover_view '_Slice_View']));
    end
end
for i = 1:length(T)
    fg = spm_figure('Create','Graphics','Visible','off');
    temp = spm('WinSize','Graphics');
    set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
    set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
    whifun_slover({T.final_anat_file_path{1},T.final_func_file_path{1}},{'Contours','Structural'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg)
    exportgraphics(fg,(fullfile(quality_control_path,'d_Co_registeration',space_,[slover_view '_Slice_View'],[name_ '.png'])))
    if norm
        fg = spm_figure('Create','Graphics','Visible','off');
        temp = spm('WinSize','Graphics');
        set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
        set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
        whifun_slover({T.final_func_file_path{1},template_path},{'Structural','Contours'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);%
        exportgraphics(fg,(fullfile(quality_control_path,'i_Normalization',space_,[slover_view '_Slice_View'],[Subj_list(subji).name '_func_image' '.png'])))
    end

end

end