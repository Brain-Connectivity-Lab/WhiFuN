%% Whifun_QC_plots

output_folder = 'K:\HCP_S1200_denoised_whifun_QC';

Subj_list_func = dir('F:\HCP_S1200_preprocessed_denoised\*\MNINonLinear\Results\rfMRI_REST1_LR\rfMRI_REST1_LR_hp2000_clean.nii.gz');
slover_slices = [-68 -65 -57 -43.2 -26.6 -14.4 -5 5 14.4 26.6 43.2 57 65 72 78];
slover_contour_range = [0 100];
slover_view = 'axial'; % coronal, sagittal 
space_ = 'MNI';
template_path = 'C:\Users\krish\Box\Github_desktop\WhiFuN\Templates\MNI152_T1_2mm_brain.nii';
mkdir(fullfile(output_folder,'i_Normalization',space_,[slover_view '_Slice_View']));
fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)]);
for i = 1:length(Subj_list_func)

    disp([num2str(i) ' out of ' num2str(length(Subj_list_func))])
    name_ = strsplit(Subj_list_func(i).folder,filesep);
    whifun_slover({fullfile(Subj_list_func(i).folder,[Subj_list_func(i).name,',1']),template_path},{'Structural','Contours'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);%
    exportgraphics(fg,(fullfile(output_folder,'i_Normalization',space_,[slover_view '_Slice_View'],[name_{3} '_func_image' '.png'])))
    clf(fg)

end















function [Subj_list,rm] = load_subjects(folder,name,first)
if nargin < 4
    first = 0;
end
try
    opts = detectImportOptions(fullfile(folder,name),'Delimiter',',');
    opts = setvartype(opts, 'char'); % or 'string', depending on your MATLAB version
    T1 = readtable(fullfile(folder,name),opts);

    T = readtable(fullfile(folder,name),'Delimiter',',');

    T.name = T1.name;

    if first
        T.error = zeros(height(T),1);
        T.motion_ex = zeros(height(T),1);
        rm = logical(T.manual_ex);
        Subj_list = table2struct(T(~rm,:));
    else
        rm = (logical(T.error) | logical(T.motion_ex) | logical(T.manual_ex));
        Subj_list = table2struct(T(~rm,:));
    end
catch
    Subj_list = [] ;
end

end