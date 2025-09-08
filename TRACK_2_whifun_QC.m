%% Whifun QC for TRACK-2

Subj_list_all = load_subjects_all('G:\TRACK2-selected\WhiFuN_op','Subj_list.csv');
final_func_files = dir('G:\TRACK2-selected\preproc_fmriprep_for_whifun\sub-*\ses-1\func\wREG_rc_sub-*_ses-1_task-rest_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz');
Subj_list_all = whifun_create_fields_preproc(Subj_list_all);
GM_files = dir('G:\TRACK2-selected\preproc_fmriprep_for_whifun\sub-*\ses-1\anat\wc1*.nii.gz');
WM_files = dir('G:\TRACK2-selected\preproc_fmriprep_for_whifun\sub-*\ses-1\anat\wc2*.nii.gz');
CSF_files = dir('G:\TRACK2-selected\preproc_fmriprep_for_whifun\sub-*\ses-1\anat\wc3*.nii.gz');


for i = 1:length(Subj_list_all)
    Subj_list_all(subji).final_func = fullfile(final_func_files(subji).folder,final_func_files(subji).name);
    Subj_list_all(subji).GM_MNI = fullfile(GM_files(subji).folder, GM_files(subji).name);
    Subj_list_all(subji).WM_MNI = fullfile(WM_files(subji).folder, WM_files(subji).name);
    Subj_list_all(subji).CSF_MNI = fullfile(CSF_files(subji).folder, CSF_files(subji).name);
    motion_file = fullfile(Subj_list(i).folder,Subj_list(i).name,'ses-1','func',[Subj_list(i).name '_ses-1_task-rest_run-1_desc-confounds_timeseries.tsv']);

    motion_file_tsv = readtable(motion_file, "FileType","text",'Delimiter', '\t');

    motion_txt = [motion_file_tsv.trans_x, motion_file_tsv.trans_y,motion_file_tsv.trans_z,motion_file_tsv.rot_x,motion_file_tsv.rot_y,motion_file_tsv.rot_z];
    Subj_list_all(subji) = whifun_qc('G:\TRACK2-selected\WhiFuN_op\quality_Quality_control',Subj_list_all(subji),...
        'motion_txt',motion_txt);
end