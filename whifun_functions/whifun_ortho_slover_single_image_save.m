function whifun_ortho_slover_single_image_save(image_path,out_image_ortho_path,out_image_slover_path,slover_slices,slover_contour_range,slover_view,caption_)
%WHIFUN_ORTHO_SLOVER_SINGLE_IMAGE_SAVE Generates and saves an orthogonal view and a
%   'Slover' visualization of a single NIfTI image, primarily using SPM routines.
%
%   WHIFUN_ORTHO_SLOVER_SINGLE_IMAGE_SAVE(IMAGE_PATH, OUT_IMAGE_ORTHO_PATH, OUT_IMAGE_SLOVER_PATH, SLICES, CONTOUR_RANGE, VIEW, CAPTION)
%
%   This function is a utility that takes a NIfTI image, displays it in two
%   different visualization formats (SPM's orthogonal view and a custom Slover-like
%   slice view), and saves the resulting figures to disk.
%
%   Input Arguments:
%   IMAGE_PATH            - Full path to the input NIfTI image file. If 4D, the first
%                           volume (',1') is automatically selected.
%   OUT_IMAGE_ORTHO_PATH  - Full path to save the orthogonal (SPM) view graphic.
%                           Can be empty ('') to skip saving this view.
%   OUT_IMAGE_SLOVER_PATH - Full path to save the 'Slover' view graphic.
%                           Can be empty ('') to skip saving this view.
%   SLOVER_SLICES         - Vector of slice coordinates or method string for Slover visualization.
%   SLOVER_CONTOUR_RANGE  - Vector defining the range for image display or contour
%                           thresholding in Slover (e.g., [min max] or a threshold).
%   SLOVER_VIEW           - String defining the view for Slover (e.g., 'axial', 'sagittal', 'coronal').
%   CAPTION_              - (Optional) Character array or string for the caption displayed
%                           on the orthogonal plot. Defaults to the image filename.
%
%   Dependencies:
%   - MATLAB's NIfTI functions (`niftiinfo`).
%   - SPM functions (`spm_check_registration_evalc`, `spm_orthviews`, `spm_figure`).
%   - Custom function (`whifun_slover`).
%
%   Operation:
%   1. Checks if the input image is 4D and modifies the path string to select the first volume.
%   2. Sets a default caption if none is provided.
%   3. Ensures output directories for both visualization types exist.
%   4. If an orthogonal output path is provided:
%      a. Opens an SPM graphics window (`spm_check_registration_evalc`).
%      b. Sets the figure caption (`spm_orthviews('Caption')`).
%      c. Saves the figure to the specified path (`exportgraphics`).
%   5. If a Slover output path is provided:
%      a. Gets the current SPM 'Graphics' figure handle (`spm_figure('GetWin','Graphics')`).
%      b. Calls the custom `whifun_slover` function to render the slice view.
%      c. Saves the figure to the specified path (`exportgraphics`).
%
%   See also: niftiinfo, spm_check_registration, spm_orthviews, exportgraphics.

image_info = niftiinfo(image_path);


if length(image_info.ImageSize) == 4
   image_path = [image_path,',1'] ;
end
[~,name,ext] = fileparts(image_path);

if ~exist("caption_",'var')
    caption_ = [name,ext]; % Assign a default caption if not provided
end

if ~isempty(out_image_ortho_path)
    fold = fileparts(out_image_ortho_path);
    if ~exist(fold, 'dir')
        mkdir(fold); % Create the output directory if it does not exist
    end
end

if ~isempty(out_image_slover_path)
    fold = fileparts(out_image_slover_path);
    if ~exist(fold, 'dir')
        mkdir(fold); % Create the output directory if it does not exist
    end
end

if ~isempty(out_image_ortho_path)
    [~,fg] = spm_check_registration_evalc(char(image_path));
    spm_orthviews('Caption', 1,caption_);
    exportgraphics(fg,out_image_ortho_path)
end

if ~isempty(out_image_slover_path)
    fg = spm_figure('GetWin','Graphics');
    % temp = spm('WinSize','Graphics');
    % set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
    % set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
    whifun_slover({image_path},{'Structural'},{gray},slover_slices,slover_contour_range,slover_view,[],fg);
    exportgraphics(fg,out_image_slover_path)
end
