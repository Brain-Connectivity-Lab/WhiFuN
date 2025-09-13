function whifun_qc_coreg_slover(image_1_path,image_2_path,out_image_path,slover_slices,slover_contour_range,slover_view)
% WHIFUN_QC_COREG_SLOVER Creates a quality control image using SLover.
%
%   WHIFUN_QC_COREG_SLOVER(image_1_path, image_2_path, out_image_path, slover_slices, slover_contour_range, slover_view)
%   generates a quality control image to visually inspect the alignment of
%   two neuroimaging files, using a specialized function (`whifun_slover`)
%   for creating overlaid slices.
%
%   This function is an alternative to `spm_check_registration` for creating
%   a quality control image. It sets up an invisible SPM figure, calls a
%   helper function (`whifun_slover`) to perform the visualization with
%   specific parameters, and then exports the resulting figure to a file.
%
%   The visual output will show one image (e.g., anatomical) as a background
%   with a contour of the other image (e.g., functional) overlaid on top,
%   providing a clear way to assess the accuracy of the coregistration.
%
%   Input Arguments:
%   image_1_path         - The full path to the first image (e.g., anatomical).
%   image_2_path         - The full path to the second image (e.g., coregistered functional).
%   out_image_path       - The full path where the output QC image will be saved.
%   slover_slices        - A vector of slice locations to display.
%   slover_contour_range - A two-element vector specifying the min and max
%                          values for the contour display.
%   slover_view          - The view to display the slices in (e.g., 'axial', 'coronal','sagittal).
%
%   Author: Pratik Jain
%   See also SPM_FIGURE, EXPORTGRAPHICS, MKDIR.

[out_folder,~,~] = fileparts(out_image_path);
if ~exist(out_folder, 'dir')
    mkdir(out_folder);
end
% fg = spm_figure('Create','Graphics','Visible','off');
fg = spm_figure('GetWin','Graphics');
% temp = spm('WinSize','Graphics');
% set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
% set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
whifun_slover({image_1_path,image_2_path},{'Contours','Structural'},{gray,gray},slover_slices,slover_contour_range,slover_view,[],fg);
exportgraphics(fg,out_image_path)


