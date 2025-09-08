output_folder = 'G:\TRACK2-selected\whifun_v3_op';
quality_control_path = fullfile(output_folder,'Quality_control');
if ~exist("quality_control_path","dir")
    mkdir(quality_control_path);
end
[report,n_image,tr,voxel_func,voxel_anat,mis_data] = whifun_check_data(output_folder,Subj_list,'','','','','');
disp(report)
whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)

%%
for subji = 1:length(Subj_list)
    disp('..')
    disp(['Currently Processing ' Subj_list(subji).name])

    Subj_list_1 = Subj_list(subji);
    % motion_txt = load(complete_filepath(['C:\Users\jainp\Box\practice_NYU_abide\' Subj_list_1.name '\session_1\rest_1\rp_*.txt']));
    motion_file = fullfile(Subj_list(subji).folder,Subj_list(subji).name,'ses-1','func',[Subj_list(subji).name '_ses-1_task-rest_run-1_desc-confounds_timeseries.tsv']);

    motion_file_tsv = readtable(motion_file, "FileType","text",'Delimiter', '\t');

    motion_txt = [motion_file_tsv.trans_x, motion_file_tsv.trans_y,motion_file_tsv.trans_z,motion_file_tsv.rot_x,motion_file_tsv.rot_y,motion_file_tsv.rot_z];
    whifun_qc(quality_control_path,Subj_list_1,'motion_txt',motion_txt,'template_path','D:\Atlases\mni_icbm152_nlin_asym_09c_nifti\mni_icbm152_nlin_asym_09c\mni_icbm152_gm_tal_nlin_asym_09c.nii','slover_contour_range_final_mni',[0 0.01]);
end
