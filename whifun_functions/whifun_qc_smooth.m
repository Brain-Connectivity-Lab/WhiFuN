function whifun_qc_smooth(out_folder,func_image,name,slover_slices_ss,slover_contour_range_ss,slover_view,over_write)

% WHIFUN_QC_SMOOTH Generates a quality control image for spatial smoothing.
%
%   WHIFUN_QC_SMOOTH(out_folder, func_image, slover_slices_ss, slover_contour_range_ss, slover_view, over_write)
%   creates a visual quality control report to assess the effect of spatial
%   smoothing on a functional image.
%
%   The function performs the following steps:
%   1.  **File Management**: It checks for the existence of previous quality
%       control images (both orthoslice and slover views). Based on the
%       `over_write` flag, it determines whether to generate new plots. It
%       also creates the necessary output directories if they don't exist.
%   2.  **Plotting**: It calls a helper function, `whifun_ortho_slover_single_image_save`,
%       to generate the plots. This helper function is assumed to create a
%       figure of the smoothed functional image. The purpose is to visually
%       inspect the blurring effect of the smoothing kernel.
%   3.  **Export**: The resulting plots are saved as PNG files in a dedicated
%       quality control directory.
%
%   This function is a simple but important quality control step to ensure
%   that the spatial smoothing has been applied correctly and with the
%   desired FWHM.
%
%   Input Arguments:
%   out_folder             - The path to the quality control directory for saving the figure.
%   func_image             - The full path to the smoothed functional image.
%   slover_slices_ss       - A vector of slice locations for the SLover plot.
%   slover_contour_range_ss- A two-element vector for the contour range of the SLover plot.
%   slover_view            - The view to display slices in (e.g., 'axial').
%   over_write             - A logical value (0 or 1) to force overwriting existing
%                            QC images.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_ORTHO_SLOVER_SINGLE_IMAGE_SAVE.


out_ortho_image_path = fullfile(out_folder,'Orthoslice_View',[name '.png']);
out_slover_image_path = fullfile(out_folder,[slover_view '_View'],[name '.png']);

out_ortho_image_1_path = whifun_create_file(over_write,out_ortho_image_path);
out_slover_image_1_path = whifun_create_file(over_write,out_slover_image_path);

if isempty(out_ortho_image_1_path)
    out_ortho_image_1_path = out_ortho_image_path;
else
    out_ortho_image_1_path = [];
end

if isempty(out_slover_image_1_path)
    out_slover_image_1_path = out_slover_image_path;
else
    out_slover_image_1_path = [];
end

whifun_ortho_slover_single_image_save(func_image,out_ortho_image_1_path,out_slover_image_1_path,slover_slices_ss,slover_contour_range_ss,slover_view)

end