%% Whifun_QC_plots

output_folder = '/home/biswal5090pc/Downloads/TRACK2-selected/WhiFuN_op';

Subj_list = load_subjects(output_folder,'Subj_list.csv');                      % Load the good participants using the CSV file
csv_file = table("name","a","b",'VariableNames',["name","final_func_file_path","final_anat_file_path"]);
for i = 1:length(Subj_list)
    csv_file.final_func_file_path(i) = fullfile(Subj_list(i).func_folder,[Subj_list(i).func_name,',1']);
    csv_file.final_anat_file_path(i) = fullfile(Subj_list(i).anat_folder,Subj_list(i).anat_name);
    csv_file.name(i) = fullfile(Subj_list(i).name);
end
    slover_slices = [-68 -65 -57 -43.2 -26.6 -14.4 -5 5 14.4 26.6 43.2 57 65 72 78];
    slover_contour_range = [0 100];
slover_view = 'coronal';%'axial','coronal','sagittal'
whifun_slover_csv(csv_file,output_folder,'MNI',slover_slices,slover_contour_range,slover_view,1,'/home/biswal5090pc/Downloads/mni_icbm152_nlin_asym_09c_nifti/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii');

