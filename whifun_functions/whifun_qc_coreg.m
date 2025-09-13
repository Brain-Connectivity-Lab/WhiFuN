function whifun_qc_coreg(out_folder,func_image_path,anat_image_path,name,slover_slices_ss,slover_contour_range_ss,slover_view,over_write)

% WHIFUN_QC_COREG Generates quality control images for coregistration.
%
%   WHIFUN_QC_COREG(out_folder, func_image_path, anat_image_path, name, slover_slices_ss, slover_contour_range_ss, slover_view, over_write)
%   creates visual quality control reports to assess the alignment of a
%   subject's functional data to their anatomical data after coregistration.
%
%   The function generates two types of plots to check the alignment:
%   1.  **SPM Orthoslice Plot**: It calls `whifun_qc_coreg_orthoslice` to
%       generate a plot using SPM's `check_registration`. The skull-stripped
%       anatomical image is used as the underlay, and the first volume of
%       the realigned functional image is used as an overlay. This plot
%       allows for a quick visual check of the alignment across three
%       orthogonal planes.
%   2.  **SLover Plot**: It calls `whifun_qc_coreg_slover` to create a
%       specialized overlay plot, which provides an alternative and often
%       clearer visualization of the alignment.
%
%   This function is a crucial quality control step to ensure that the
%   functional data is accurately mapped to the anatomical brain structures.
%   The `over_write` flag prevents redundant image generation.
%
%   Input Arguments:
%   out_folder             - The root directory for saving all QC output.
%   func_image_path        - The full path to the functional image.
%   anat_image_path        - The full path to the anatomical image.
%   name                   - The subject's name.
%   slover_slices_ss       - A vector of slice locations for the SLover plot.
%   slover_contour_range_ss- A two-element vector for the contour range of the SLover plot.
%   slover_view            - The view to display slices in (e.g., 'axial').
%   over_write             - A logical value (0 or 1) to force overwriting of
%                            existing QC images.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_QC_COREG_ORTHOSLICE, WHIFUN_QC_COREG_SLOVER, FILEPARTS.


[~,underlay_name,~] =  fileparts(func_image_path);
[~,overlay_contour_name,~] =  fileparts(anat_image_path);
out_image_path = fullfile(out_folder,'Native_Space','Orthoslice_View',[name '_underlay-' underlay_name '_overlay_contour-' overlay_contour_name '.png']);
out_coreg_orthoslice_path = whifun_create_file(over_write,out_image_path);
if isempty(out_coreg_orthoslice_path)
    whifun_qc_coreg_orthoslice(anat_image_path,[func_image_path ',1'],out_image_path);
end

out_image_path = fullfile(out_folder,'Native_Space',[slover_view '_Slice_View'],[name '_underlay-' underlay_name '_overlay_contour-' overlay_contour_name '.png']);
out_coreg_slover_path = whifun_create_file(over_write,out_image_path);
if isempty(out_coreg_slover_path)
    whifun_qc_coreg_slover(anat_image_path,[func_image_path ',1'],out_image_path,slover_slices_ss,slover_contour_range_ss,slover_view);
end
disp(' ')
disp(['Co-registeration QC plot generated for ' name])
disp(['See : ' fullfile(out_folder,'Native_Space')])
disp(' ')
