function Subj_list = whifun_create_qc

[Subj_list,output_folder] = whifun_create_Subj_list();
quality_control_path = fullfile(output_folder,'Quality_control');
if ~exist("quality_control_path","dir")
    mkdir(quality_control_path);
end
for subji = 1:length(Subj_list)
    if ~whifun_isnan_or_empty(Subj_list(subji),'final_func_MNI')
        [func_folder,func_name,ext] = fileparts(Subj_list(subji).final_func_MNI);
        Subj_list(subji).func_folder = func_folder;
        Subj_list(subji).func_name = [func_name,ext];
    end
    Subj_list(subji).error = 0;
    Subj_list(subji).manual_ex = 0;
    Subj_list(subji).motion_ex = 0;
end

for subji = 1:length(Subj_list)
    if ~whifun_isnan_or_empty(Subj_list(subji),'anat_MNI')
        [anat_folder,anat_name,ext] = fileparts(Subj_list(subji).anat_MNI);
        Subj_list(subji).anat_folder = anat_folder;
        Subj_list(subji).anat_name = [anat_name,ext];
    end
end

[report,n_image,tr,voxel_func,voxel_anat,mis_data] = whifun_check_data(output_folder,Subj_list,'','','','','');
disp(report)
whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)

% if ~only_check_data
% 
%     %%
%     for subji = 1:length(Subj_list)
%         disp('..')
%         disp(['Currently Processing ' Subj_list(subji).name])
% 
%         Subj_list_1 = Subj_list(subji);
%         motion_txt = load(complete_filepath(['C:\Users\jainp\Box\practice_NYU_abide\' Subj_list_1.name '\session_1\rest_1\rp_*.txt']));
%         whifun_qc(quality_control_path,Subj_list_1,'motion_txt',motion_txt);
%     end
% end
