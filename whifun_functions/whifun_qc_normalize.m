function whifun_qc_normalize(out_folder,Subj_list_1,template_path,slover_slices_mni,slover_contour_range_mni,slover_view,over_write)
% WHIFUN_QC_NORMALIZE Generates quality control figures for normalization.
%
%   WHIFUN_QC_NORMALIZE(out_folder, Subj_list_1, template_path, slover_slices_mni, slover_contour_range_mni, slover_view, over_write)
%   creates a visual report to assess the quality of spatial normalization.
%   The function checks if the subject's functional data has been
%   accurately warped into a standard template space (e.g., MNI).
%
%   The function performs three main checks:
%   1.  **Orthoslice Alignment**: It generates an SPM `check_registration`
%       plot. It uses the first volume of the normalized functional image
%       as the underlay and a standard MNI template as the overlay. This
%       provides a quick visual check of the alignment.
%   2.  **SLover Alignment**: It uses `whifun_qc_coreg_slover` to create a
%       more detailed overlay plot, which provides a clear visualization of
%       the normalized functional data on the MNI template.
%   3.  **Voxel Time Series**: It generates a time series plot from a
%       pre-existing function, `whifun_ts_qc`, to show the signal from
%       different tissue types (GM, WM, CSF) and head motion. This confirms
%       that the time series data remains consistent and is not distorted
%       by the normalization process.
%
%   This function is a critical final quality control step in the
%   preprocessing pipeline. The `over_write` flag prevents redundant
%   image generation.
%
%   Input Arguments:
%   out_folder             - The root directory for saving all QC output.
%   Subj_list_1            - A single subject structure with `func_MNI`,
%                            `motion_txt`, and MNI-space mask paths.
%   template_path          - The full path to the MNI template file.
%   slover_slices_mni      - A vector of slice locations for the SLover plot.
%   slover_contour_range_mni- A two-element vector for the contour range.
%   slover_view            - The view to display slices in (e.g., 'axial').
%   over_write             - A logical value (0 or 1) to force overwriting.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_QC_COREG_ORTHOSLICE, WHIFUN_QC_COREG_SLOVER, WHIFUN_TS_QC, MKDIR.

out_image_ortho_path = fullfile(out_folder,'MNI_Space','Orthoslice_View',[Subj_list_1.name '_func_image' '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_ortho_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_orthoslice([Subj_list_1.func_MNI ',1'],template_path, out_image_ortho_path);
end

out_image_slover_path = fullfile(out_folder,'MNI_Space',[slover_view '_Slice_View'],[Subj_list_1.name '_func_image' '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_slover_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_slover(template_path, [Subj_list_1.func_MNI,',1'], out_image_slover_path, slover_slices_mni, slover_contour_range_mni, slover_view)
end

out_image_path_vox_ts = fullfile(out_folder,'MNI_Space','Vox_ts',[Subj_list_1.name '.png']);
[out_folder1,~,~] = fileparts(out_image_path_vox_ts);
if ~exist(out_folder1, 'dir')
    mkdir(out_folder1);
end
out_mask_path = fullfile(out_folder,'MNI_Space','Masks_for_Vox_ts');

norm_file = whifun_create_file(over_write,out_image_path_vox_ts);

if isempty(norm_file)
    % Quality Control
    % Plot the mean time series after Normalization

    f = figure('visible','off');
    GM_mask_path = Subj_list_1.GM_MNI;
    WM_mask_path = Subj_list_1.WM_MNI;
    CSF_mask_path = Subj_list_1.CSF_MNI;

    num_erosions = 4;
    Par_name = Subj_list_1.name;
    whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,Subj_list_1.func_MNI,Subj_list_1.motion_txt,num_erosions,Par_name,over_write,f)
    exportgraphics(f,out_image_path_vox_ts)

    clf(f)
    now_mask_path = dir(WM_mask_path);
    deep_WM_mask_path = fullfile(now_mask_path.folder,['deep_' 'num_er-' num2str(num_erosions) '_' now_mask_path.name]);
    whifun_ts_mask_qc(out_mask_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,Subj_list_1.func_MNI,Subj_list_1.name,slover_slices_mni,slover_contour_range_mni,slover_view)
end



