function whifun_unzip_all_in_folder(folder_)

nii_gz_files = dir(fullfile(folder_,'*.nii.gz'));

for i = 1:length(nii_gz_files)

    gunzip(fullfile(nii_gz_files(i).folder,nii_gz_files(i).name))

end