% Define your patterns
myDir = 'M:\TRACK2-selected\Data';%'/media/biswal5090pc/Expansion1/NKI_all_data/data';
fPat  = 'sub-*_ses-*_task-rest_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold_3mm.nii.gz';%'sub*_acq-1400_bold.nii.gz';
aPat  = 'sub-*_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz';%'sub*_T1w.nii.gz';
% whifun_count_file_patterns
% Run the function
stats = whifun_get_datastructure_info(myDir, fPat, aPat);

% To see exactly which subjects are missing anatomical:
missingAnat = stats(stats.Has_Func & ~stats.Has_Anat, :);
disp(missingAnat);

missingFunc = stats(~stats.Has_Func & stats.Has_Anat, :);
disp(missingFunc);