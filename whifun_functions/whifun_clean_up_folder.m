function whifun_clean_up_folder(folder_,log_file_id)
%WHIFUN_CLEAN_UP_FOLDER Compresses all NIfTI (.nii) files in a specified folder
%   into gzipped format (.nii.gz) and removes redundant uncompressed copies.
%
%   WHIFUN_CLEAN_UP_FOLDER(FOLDER_, LOG_FILE_ID)
%
%   This utility function performs two main tasks:
%   1. **Removes Duplicates:** It identifies and deletes any uncompressed
%      NIfTI files (`.nii`) that already have a compressed counterpart
%      (`.<file>.nii.gz`) present in the same folder.
%   2. **Compresses Remaining Files:** It then compresses all remaining
%      uncompressed `.nii` files into `.nii.gz` format and deletes the
%      original uncompressed `.nii` files.
%   All actions are logged to the specified file handle and the command window.
%
%   Input Arguments:
%   FOLDER_     - The full path to the directory to be cleaned up.
%   LOG_FILE_ID - A file ID handle (obtained via `fopen`) for the log file
%                 where operations will be recorded.
%
%   Dependencies: `gzip` (MATLAB built-in function).
%
%   Author: Pratik Jain

nii_files = dir(fullfile(folder_,'*.nii'));
nii_gz_files = dir(fullfile(folder_,'*.nii.gz'));

com_files = intersect(cellfun(@(x) x(1:end-3), {nii_gz_files.name}, 'UniformOutput', false),{nii_files.name});

for i = 1:length(com_files)
    delete(fullfile(nii_files(i).folder,com_files{i}));
    % Log the number of files deleted
    fprintf(log_file_id,'Deleted %s from %s\n', com_files{i}, folder_);
    fprintf('Deleted %s from %s\n', com_files{i}, folder_);
end

nii_files = dir(fullfile(folder_,'*.nii'));

for i = 1:length(nii_files)
    gzip(fullfile(nii_files(i).folder,nii_files(i).name));
    fprintf(log_file_id,'Gunzipped %s from %s\n', nii_files(i).name, nii_files(i).folder);
    fprintf('Gunzipped %s from %s\n', nii_files(i).name, nii_files(i).folder);

    delete(fullfile(nii_files(i).folder,nii_files(i).name));
    fprintf(log_file_id,'Deleted the nifti %s from %s\n', nii_files(i).name, nii_files(i).folder);
    fprintf('Deleted the nifti %s from %s\n', nii_files(i).name, nii_files(i).folder);
end



end