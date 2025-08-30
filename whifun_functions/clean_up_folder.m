function clean_up_folder(folder_,log_file_id)

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