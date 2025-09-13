% output_folder = 'G:\TRACK2-selected\whifun_v3_op';
output_folder = 'G:\TRACK2-selected\healthy_vs_TBI';
quality_control_path = fullfile(output_folder,'Quality_control');
if ~exist("quality_control_path","dir")
    mkdir(quality_control_path);
end
% [report,n_image,tr,voxel_func,voxel_anat,mis_data] = whifun_check_data(output_folder,Subj_list,'','','','','');
% disp(report)
% whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)
% Subj_list = whifun_create_fields_preproc(Subj_list);
Subj_list = load_subjects_all(output_folder,'Subj_list.csv');
Subj_list = whifun_create_fields_preproc(Subj_list);
%%
motion_reg = 1;
n_pca = 0;
over_write = 0;
for subji = 1:length(Subj_list)
    
        [log_fileID,errmsg] = fopen(fullfile(quality_control_path,'logs',[Subj_list(subji).name '_log_info.txt']),'a');

        if log_fileID == -1
            error(errmsg)
        end
        disp('..')
        disp(['Currently Processing ' Subj_list(subji).name])

        Subj_list(subji) = Subj_list(subji);
        % motion_txt = load(complete_filepath(['C:\Users\jainp\Box\practice_NYU_abide\' Subj_list(subji).name '\session_1\rest(subji)\rp_*.txt']));
        %% Saving motion in WhiFuN format
        motion_file = fullfile(Subj_list(subji).folder,Subj_list(subji).name,'ses-1','func',[Subj_list(subji).name '_ses-1_task-rest_run-1_desc-confounds_timeseries.tsv']);

        motion_file_tsv = readtable(motion_file, "FileType","text",'Delimiter', '\t');
        motion_txt = [motion_file_tsv.trans_x, motion_file_tsv.trans_y,motion_file_tsv.trans_z,motion_file_tsv.rot_x,motion_file_tsv.rot_y,motion_file_tsv.rot_z];
        func_fold = fileparts(Subj_list(subji).final_func_MNI);
        out_motion_txt_path = fullfile(func_fold,['rp_' Subj_list(subji).name '.txt']);
        disp(out_motion_txt_path)
        % save(out_motion_txt_path, 'motion_txt', '-ascii', '-double', '-tabs');

        Subj_list(subji).motion_txt = out_motion_txt_path;

        %% Saving CSF timeseries in whifun format
        MEAN_CSF_REST = motion_file_tsv.csf;
        
        out_csf_mat_path = fullfile(func_fold,['covariance_csf_' Subj_list(subji).name '.mat']) ;
        disp(out_csf_mat_path)
        % save(out_csf_mat_path,'MEAN_CSF_REST');            % Save
        Subj_list(subji).nuisance_regression_csf_covariates = out_csf_mat_path;
        %% Nuisance regression 

        in_func_path = Subj_list(subji).final_func_MNI;
        in_anat_mask_subj_space_path = Subj_list(subji).anat_mask_MNI; % Define the anatomical mask path
        Reg_pre = 'Reg_'; % Set default regression parameters
        in_csf_mat_path = out_csf_mat_path; % Path for CSF data
        in_motion_txt_path = out_motion_txt_path;
        [Subj_list(subji),out_func_path,out_func_mask_path] = whifun_nuisance_regress_preproc(quality_control_path,Subj_list(subji),in_func_path,in_anat_mask_subj_space_path,motion_reg,Reg_pre,n_pca,in_csf_mat_path,in_motion_txt_path,log_fileID,over_write);
        disp(out_func_path)
        % func_mask_now = complete_filepath(fullfile(func_fold,'func_mask*.nii'));
        % gzip(func_mask_now)
        % delete(func_mask_now)
        Subj_list(subji).coregistered_func_native = Subj_list(subji).final_func_MNI;
        Subj_list(subji).realigned_func_native = Subj_list(subji).final_func_MNI;
        Subj_list(subji).initial_func_native = Subj_list(subji).final_func_MNI;
        Subj_list(subji).func_MNI = Subj_list(subji).final_func_MNI;
        Subj_list(subji).final_func_MNI = out_func_path;
        Subj_list(subji).func_mask_MNI = out_func_mask_path;
        Subj_list(subji).func_mask_native = out_func_mask_path;
        Subj_list(subji).GM_native = Subj_list(subji).GM_MNI;
        Subj_list(subji).WM_native = Subj_list(subji).WM_MNI;
        Subj_list(subji).CSF_native = Subj_list(subji).CSF_MNI;
        Subj_list(subji).skull_stripped_anat_native = Subj_list(subji).anat_MNI;
        
        % Subj_list(subji) = Subj_list(subji);
        % try
        %     whifun_qc(quality_control_path,Subj_list(subji),'template_path','D:\Atlases\mni_icbm152_nlin_asym_09c_nifti\mni_icbm152_nlin_asym_09c\mni_icbm152_gm_tal_nlin_asym_09c.nii','slover_contour_range_final_mni',[0 0.01],'Reg_',1);
        % catch ex
        %     disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        %     disp(['Preprocessing has encountered errors in QC_plots for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
        %     disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        % 
        %     write_error(ex,quality_control_path, Subj_list_1.name)                % write error to text file and display
        %     Subj_list_1.error = 1;  % Remove participant from further preprocessing
        % end

end

my_writetable(struct2table(Subj_list),fullfile(quality_control_path,'Subj_list.csv'))
