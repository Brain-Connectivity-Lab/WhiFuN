function whifun_qc_final_func_MNI(out_folder,final_func_MNI,GM_MNI,WM_MNI,CSF_MNI,template_path,motion_txt,name,slover_slices_mni,slover_contour_range_mni,slover_view,over_write)
% WHIFUN_QC_FINAL_FUNC_MNI Generates final quality control figures for normalized data.
%
%   WHIFUN_QC_FINAL_FUNC_MNI(out_folder, final_func_MNI, GM_MNI, ..., over_write)
%   creates a suite of visual quality control reports to assess the final
%   preprocessed functional data after it has been normalized to MNI space.
%
%   The function performs three main checks:
%   1.  **Orthoslice Alignment**: It generates an SPM `check_registration`
%       plot comparing the first volume of the normalized functional image
%       to a standard MNI template.
%   2.  **SLover Alignment**: It uses `whifun_qc_coreg_slover` to create a
%       more detailed overlay plot, which provides a clear visualization of
%       the normalized functional data on the MNI template.
%   3.  **Voxel Time Series**: If motion parameters are available, it generates
%       a time series plot using `whifun_ts_qc` to show the signal from different
%       tissue types (GM, WM, CSF) and head motion. This confirms that the
%       time series data remains consistent and is not distorted by the
%       normalization process.
%
%   This function is a critical final quality control step in the
%   preprocessing pipeline. The `over_write` flag prevents redundant
%   image generation.
%
%   Input Arguments:
%   out_folder             - The root directory for saving all QC output.
%   final_func_MNI         - The full path to the final normalized functional file.
%   GM_MNI, WM_MNI, CSF_MNI- Paths to the segmented tissue files in MNI space.
%   template_path          - The full path to the MNI template file.
%   motion_txt             - A matrix or path to a text file of motion parameters.
%   name                   - The subject's name.
%   slover_slices_mni      - A vector of slice locations for the SLover plot.
%   slover_contour_range_mni- A two-element vector for the contour range.
%   slover_view            - The view to display slices in (e.g., 'axial').
%   over_write             - A logical value (0 or 1) to force overwriting.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_QC_COREG_ORTHOSLICE, WHIFUN_QC_COREG_SLOVER, WHIFUN_TS_QC, MKDIR.

[~,func_name,~]= fileparts(final_func_MNI);
[~,template_name,~]= fileparts(template_path);
out_image_ortho_path = fullfile(out_folder,'MNI_Space','Orthoslice_View',[name '_func_image' '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_ortho_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_orthoslice([final_func_MNI ',1'],template_path, out_image_ortho_path);
end

out_image_slover_path = fullfile(out_folder,'MNI_Space',[slover_view '_Slice_View'],[name '_underlay-' func_name '_overlay-contour-' template_name '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_slover_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_slover(template_path, [final_func_MNI,',1'], out_image_slover_path, slover_slices_mni, slover_contour_range_mni, slover_view)
end

if ~isempty(motion_txt)
    out_image_path_vox_ts = fullfile(out_folder,'MNI_Space','Vox_ts',[name '_file-' func_name '.png']);
    [out_folder1,~,~] = fileparts(out_image_path_vox_ts);
    if ~exist(out_folder1, 'dir')
        mkdir(out_folder1);
    end
    out_mask_path = fullfile(out_folder,'MNI_Space','Masks_for_Vox_ts');

    norm_file = whifun_create_file(over_write,out_image_path_vox_ts);

    if isempty(norm_file)
        % Quality Control
        % Plot the mean time series after Normalization

        f = gcf;
        clf(f);
        GM_mask_path = GM_MNI;
        WM_mask_path = WM_MNI;
        CSF_mask_path = CSF_MNI;

        num_erosions = 4;
        Par_name = name;
        whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,final_func_MNI,motion_txt,num_erosions,Par_name,over_write,f)
        exportgraphics(f,out_image_path_vox_ts)

        clf(f)
        now_mask_path = dir(WM_mask_path);
        deep_WM_mask_path = fullfile(now_mask_path.folder,['deep_' 'num_er-' num2str(num_erosions) '_' now_mask_path.name]);
        whifun_ts_mask_qc(out_mask_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,final_func_MNI,name,slover_slices_mni,slover_contour_range_mni,slover_view)
    end
end

disp(' ')
disp(['Final Func MNI QC Plots generated for Participant : ' name])
disp(['See : ' fullfile(out_folder,'MNI_Space')])
disp(' ')