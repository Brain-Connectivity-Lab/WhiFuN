function whifun_coreg_qc(name_,now_anat_path,now_func_path,slover_slices,slover_contour_range,slover_view,ss,quality_control_path)
% WHIFUN_COREG_QC Generates automated QC images for Coregistration.
%
%   Author: Pratik Jain
%
%   This function creates two types of visual checks:
%   1. Orthoslice View: A standard SPM-style three-pane check with contours.
%   2. Slice View: A detailed multi-slice layout using the 'slover' engine.
%
%   INPUTS:
%       name_                - String. Subject ID or session name.
%       now_anat_path        - Struct. Anatomical file info (from dir()).
%       now_func_path        - Struct. Functional file info (from dir()).
%       slover_slices        - Vector. Indices of slices to display.
%       slover_contour_range - Vector. Range for contour levels (e.g., [0.5 0.5]).
%       slover_view          - String. 'axial', 'sagittal', or 'coronal'.
%       ss                   - Boolean. Space toggle (1 = Subject, 0 = MNI).
%       quality_control_path - String. Root folder for QC output.
%
%   DEPENDENCIES:
%       SPM (Statistical Parametric Mapping), exportgraphics, whifun_slover.

% Determine folder naming based on space
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


