function whifun_qc_seed_corr(out_folder,final_func_MNI,name,thresh,rad,slover_slices_mni,slover_view,over_write,func_mask_MNI)
% WHIFUN_QC_SEED_CORR Generates quality control images for seed-based functional connectivity.
%
%   WHIFUN_QC_SEED_CORR(out_folder, final_func_MNI, name, thresh, rad, slover_slices_mni, slover_view, over_write, func_mask_MNI)
%   creates a visual quality control report to assess the quality of a subject's
%   functional data by performing a simple seed-to-voxel correlation.
%
%   The function calculates the correlation map for three standard
%   functional networks:
%   1.  **Default Mode Network (DMN)**: Seeded in the left Posterior Cingulate Cortex (PCC).
%   2.  **Visual Network**: Seeded in the right visual cortex.
%   3.  **Auditory Network**: Seeded in the left auditory cortex.
%
%   For each network, the function performs the following steps:
%   -   **Checks Existence**: It checks if the output plot already exists and,
%       based on the `over_write` flag, either skips or proceeds.
%   -   **Calculates Correlation**: It calls `whifun_seed_corr_qc_plot` to
%       calculate the seed-to-voxel correlation map and save the result.
%   -   **Generates Plot**: It creates a SLover plot visualizing the
%       correlation map, allowing for a visual assessment of the expected
%       network activity. A healthy and clean dataset should show a
%       well-defined network.
%
%   This function is a valuable final check of the preprocessing pipeline,
%   confirming that the data is clean and ready for functional connectivity
%   analysis.
%
%   Input Arguments:
%   out_folder           - The root directory for saving all QC output.
%   final_func_MNI       - The full path to the final normalized functional file.
%   name                 - The subject's name.
%   thresh               - A 1x2 vector with the negative and positive correlation thresholds.
%   rad                  - The radius of the spherical seed in mm.
%   slover_slices_mni    - A vector of slice locations for the SLover plot.
%   slover_view          - The view to display slices in (e.g., 'axial').
%   over_write           - A logical value (0 or 1) to force overwriting existing
%                          QC images.
%   func_mask_MNI        - (Optional) The path to the functional mask in MNI space.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_SEED_CORR_QC_PLOT, MKDIR.


%% Seed Corr plots
norm_dir = dir(final_func_MNI) ;
[~,func_name,~] = fileparts(final_func_MNI);
% name = name;
% thresh = 0.1;
% slover_view_array = {'sagittal','axial'};
% rad = 6;
if ~exist("func_mask_MNI",'var') 
    func_mask_MNI = [];
end
% Default mode
seed_corr_qc_output_path = fullfile(out_folder,'Default_Mode_Seed_lh_pcc_5_-49_40',[slover_view '_Slice_View'],[name '_file-' func_name 'Seed-lh_pcc_5_-49_40' '_thresh_neg-' num2str(thresh(1)) '_thresh_pos-' num2str(thresh(2)) '.png']);
if ~exist(fileparts(seed_corr_qc_output_path),'dir')
        mkdir(fileparts(seed_corr_qc_output_path))
end
seed_cor_output_path = fullfile(norm_dir.folder,['seed_corr_map_Seed_lh_pcc_5_-49_40_' norm_dir.name]);
seed = [5 -49 40];
seed_qc_dir = whifun_create_file(over_write,seed_corr_qc_output_path);

if isempty(seed_qc_dir)
    whifun_seed_corr_qc_plot(seed_corr_qc_output_path,final_func_MNI,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,func_mask_MNI)
end

% Visual
seed_corr_qc_output_path = fullfile(out_folder,"Visual_Seed_rh_cort_vis_-4_-91_-3",[slover_view '_Slice_View'],[name '_file-' func_name 'Seed-rh_cort_vis_-4_-91_-3' '_thresh_neg-' num2str(thresh(1)) '_thresh_pos-' num2str(thresh(2)) '.png']);
if ~exist(fileparts(seed_corr_qc_output_path),'dir')
        mkdir(fileparts(seed_corr_qc_output_path))
end
seed_cor_output_path = fullfile(norm_dir.folder,['seed_corr_map_Seed_rh_cort_vis_-4_-91_-3' norm_dir.name]);
seed = [-4 -91 -3];
seed_qc_dir = whifun_create_file(over_write,seed_corr_qc_output_path);

if isempty(seed_qc_dir)
    whifun_seed_corr_qc_plot(seed_corr_qc_output_path,final_func_MNI,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,func_mask_MNI)
end

% Auditory
seed_corr_qc_output_path = fullfile(out_folder,"Auditory_Seed_lh_cort_aud_64_-12_2",[slover_view '_Slice_View'],[name '_file-' func_name 'Seed-lh_cort_aud_64_-12_2' '_thresh_neg-' num2str(thresh(1)) '_thresh_pos-' num2str(thresh(2)) '.png']);
if ~exist(fileparts(seed_corr_qc_output_path),'dir')
        mkdir(fileparts(seed_corr_qc_output_path))
end
seed_cor_output_path = fullfile(norm_dir.folder,['seed_corr_map_Seed_lh_cort_aud_64_-12_2' norm_dir.name]);
seed = [64 -12 2];

seed_qc_dir = whifun_create_file(over_write,seed_corr_qc_output_path);

if isempty(seed_qc_dir)
    whifun_seed_corr_qc_plot(seed_corr_qc_output_path,final_func_MNI,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,func_mask_MNI)
end

disp(' ')
disp(['Seed based Correlation QC plots generated for Participant : ' name])
disp(['See : ' char(fullfile(out_folder))])
disp(' ')