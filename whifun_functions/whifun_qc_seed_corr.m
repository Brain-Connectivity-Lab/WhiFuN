function whifun_qc_seed_corr(out_folder,final_func_MNI,name,thresh,rad,slover_slices_mni,slover_view,over_write,func_mask_MNI)
%% Seed Corr plots
norm_dir = dir(final_func_MNI) ;
% name = name;
% thresh = 0.1;
% slover_view_array = {'sagittal','axial'};
% rad = 6;
if ~exist("func_mask_MNI",'var') 
    func_mask_MNI = [];
end
% Default mode
seed_corr_qc_output_path = fullfile(out_folder,'Default_Mode_Seed_lh_pcc_5_-49_40',[slover_view '_Slice_View'],[name '.png']);
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
seed_corr_qc_output_path = fullfile(out_folder,"Visual_Seed_rh_cort_vis_-4_-91_-3",[slover_view '_Slice_View'],[name '.png']);
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
seed_corr_qc_output_path = fullfile(out_folder,"Auditory_Seed_lh_cort_aud_64_-12_2",[slover_view '_Slice_View'],[name '.png']);
if ~exist(fileparts(seed_corr_qc_output_path),'dir')
        mkdir(fileparts(seed_corr_qc_output_path))
end
seed_cor_output_path = fullfile(norm_dir.folder,['seed_corr_map_Seed_lh_cort_aud_64_-12_2' norm_dir.name]);
seed = [64 -12 2];

seed_qc_dir = whifun_create_file(over_write,seed_corr_qc_output_path);

if isempty(seed_qc_dir)
    whifun_seed_corr_qc_plot(seed_corr_qc_output_path,final_func_MNI,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,func_mask_MNI)
end