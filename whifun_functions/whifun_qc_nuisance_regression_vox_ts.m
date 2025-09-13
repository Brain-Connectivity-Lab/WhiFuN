function whifun_qc_nuisance_regression_vox_ts(out_folder1,Subj_list_1,slover_slices_ss,slover_contour_range_ss,slover_view,over_write)
% WHIFUN_QC_NUISANCE_REGRESSION_VOX_TS Generates quality control figures for nuisance regression.
%
%   WHIFUN_QC_NUISANCE_REGRESSION_VOX_TS(out_folder1, Subj_list_1, ...)
%   creates visual quality control reports to assess the effectiveness of
%   nuisance regression. The function focuses on time series plots and mask
%   visualizations.
%
%   The function performs the following steps:
%   1.  **Check Existence**: It checks if the before- and after-regression
%       time series plots already exist and, based on the `over_write` flag,
%       either skips or generates new ones. It also creates the necessary
%       output directories.
%   2.  **Time Series Plots**: It calls a helper function `whifun_ts_qc` to
%       generate time series plots of key brain regions (GM, WM, CSF) and
%       motion parameters. It generates two separate plots: one for the data
%       *before* regression and one for the data *after* regression. This
%       allows for a direct comparison to see the effect of the regression.
%   3.  **Mask Visualization**: It calls `whifun_ts_mask_qc` to generate a
%       figure that visualizes the GM, WM, CSF, and deep WM masks used for 
%       time series extraction. This is important for verifying that the 
%       masks used for time series extraction are accurate.
%
%   This function is essential for verifying that nuisance regression has
%   effectively removed unwanted signals without affecting the regions of
%   interest.
%
%   Input Arguments:
%   out_folder1            - The root directory for saving all QC output.
%   Subj_list_1            - A single subject structure with necessary fields
%                            like `realigned`, `nuisance_regressed`, and mask paths.
%   slover_slices_ss       - A vector of slice locations for the SLover plot.
%   slover_contour_range_ss- A two-element vector for the contour range.
%   slover_view            - The view to display slices in (e.g., 'axial').
%   over_write             - A logical value (0 or 1) to force overwriting.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_TS_QC, WHIFUN_TS_MASK_QC, MKDIR.
out_image_path_bef = fullfile(out_folder1,'Native_Space','Vox_ts','Before_Nuisance_regression_vox_ts',[Subj_list_1.name '.png']);
[out_folder,~,~] = fileparts(out_image_path_bef);
if ~exist(out_folder, 'dir')
    mkdir(out_folder);
end
reg_qc_file_bef = whifun_create_file(over_write,out_image_path_bef);

out_image_path_aft = fullfile(out_folder1,'Native_Space','Vox_ts','After_Nuisance_regression_vox_ts',[Subj_list_1.name '.png']);
[out_folder,~,~] = fileparts(out_image_path_aft);
if ~exist(out_folder, 'dir')
    mkdir(out_folder);
end
reg_qc_file_aft = whifun_create_file(over_write,out_image_path_aft);

out_mask_path = fullfile(out_folder1,'Native_Space','Vox_ts','Masks_for_Vox_ts');
% Quality Control
% Plot the mean time series before and after regression

if isempty(reg_qc_file_bef) || isempty(reg_qc_file_aft)
    %% Vox TS plots
    f = gcf;
    GM_mask_path = Subj_list_1.GM_native;
    WM_mask_path = Subj_list_1.WM_native;
    CSF_mask_path = Subj_list_1.CSF_native;

    num_erosions = 4;
    Par_name = Subj_list_1.name;
    whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,Subj_list_1.realigned_func_native,Subj_list_1.motion_txt,num_erosions,Par_name,over_write,f)
    exportgraphics(f,out_image_path_bef)

    whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,Subj_list_1.nuisance_regressed_func_native,Subj_list_1.motion_txt,num_erosions,Par_name,over_write,f)
    exportgraphics(f,out_image_path_aft)
    clf(f)
    now_mask_path = dir(WM_mask_path);
    deep_WM_mask_path = fullfile(now_mask_path.folder,['deep_' 'num_er-' num2str(num_erosions) '_' now_mask_path.name]);
    whifun_ts_mask_qc(out_mask_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,Subj_list_1.realigned_func_native,Subj_list_1.name,slover_slices_ss,slover_contour_range_ss,slover_view)
end

disp(['Nuisance Regression qc done for ' Subj_list_1.name])