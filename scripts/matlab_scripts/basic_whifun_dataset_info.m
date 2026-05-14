% Define your patterns
myDir = '/media/biswal5090pc/Expansion1/NKI_all_data/data';
fPat  = 'sub*_acq-1400_bold.nii.gz';
aPat  = 'sub*_T1w.nii.gz';

% Run the function
stats = whifun_get_datastructure_info(myDir, fPat, aPat);

% To see exactly which subjects are missing anatomical:
missingAnat = stats(stats.Has_Func & ~stats.Has_Anat, :);
disp(missingAnat);

missingFunc = stats(~stats.Has_Func & stats.Has_Anat, :);
disp(missingFunc);