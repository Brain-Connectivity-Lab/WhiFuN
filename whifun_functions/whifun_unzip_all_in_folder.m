function whifun_unzip_all_in_folder(folder_)
%WHIFUN_UNZIP_ALL_IN_FOLDER Unzips all .nii.gz files located directly within a specified folder.
%
%   WHIFUN_UNZIP_ALL_IN_FOLDER(FOLDER_)
%
%   This utility function is commonly used in neuroimaging pipelines to
%   decompress gzipped NIfTI files (.nii.gz) into standard NIfTI files (.nii)
%   before processing steps that require the uncompressed format.
%
%   Input Arguments:
%   FOLDER_ - A character array or string specifying the path to the folder
%             containing the .nii.gz files to be unzipped.
%
%   Dependencies: MATLAB's built-in `gunzip` and `dir` functions.
%
%   Author: Pratik Jain

nii_gz_files = dir(fullfile(folder_,'*.nii.gz'));

for i = 1:length(nii_gz_files)

    gunzip(fullfile(nii_gz_files(i).folder,nii_gz_files(i).name))

end