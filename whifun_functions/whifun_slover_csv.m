function whifun_slover_csv(csv_file,out_folder,space_,slover_slices,slover_contour_range,slover_view,norm,template_path)
if isempty(which('spm'))
    error('SPM path not found. Please add SPM path and Try again')
end
if isstring(csv_file) || ischar(csv_file)
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
quality_control_path = fullfile(out_folder, 'Quality_control');
if ~exist(fullfile(out_folder, 'Quality_control','d_Co_registeration',space_,[slover_view '_Slice_View']),'dir')
    mkdir(fullfile(out_folder, 'Quality_control','d_Co_registeration',space_,[slover_view '_Slice_View']));
end
if norm
    mkdir(fullfile(out_folder, 'Quality_control', 'i_Normalization', space_, [slover_view '_Slice_View']));
end
for i = 1:height(T)
    fg = spm_figure('Create','Graphics','Visible','off');
    temp = spm('WinSize','Graphics');
    set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
    set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)]);
    whifun_slover({T.final_anat_file_path{i},T.final_func_file_path{i}},{'Contours','Structural'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);
    exportgraphics(fg,(fullfile(quality_control_path,'d_Co_registeration',space_,[slover_view '_Slice_View'],[T.name{i} '.png'])))
    pause(1)
    if norm
        fg = spm_figure('Create','Graphics','Visible','off');
        temp = spm('WinSize','Graphics');
        set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
        set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
        whifun_slover({T.final_func_file_path{i},template_path},{'Structural','Contours'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);%
        exportgraphics(fg,(fullfile(quality_control_path,'i_Normalization',space_,[slover_view '_Slice_View'],[T.name{i} '_func_image' '.png'])))
        pause(1)
    end

end

end