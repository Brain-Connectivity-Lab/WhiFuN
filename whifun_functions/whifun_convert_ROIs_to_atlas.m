function whifun_convert_ROIs_to_atlas(folder_path,pattern,out_path)
%WHIFUN_CONVERT_ROIS_TO_ATLAS Combines multiple binary NIfTI ROI masks into a single
%   labeled NIfTI atlas volume.
%
%   WHIFUN_CONVERT_ROIS_TO_ATLAS(FOLDER_PATH, PATTERN, OUT_FOLDER)
%
%   This function reads a collection of NIfTI files, where each file
%   represents a binary Region of Interest (ROI) mask. It then assigns a
%   unique integer label to the voxels belonging to each ROI and saves the
%   result as a single NIfTI atlas file.
%
%   Input Arguments:
%   FOLDER_PATH - Full path to the directory containing the NIfTI ROI mask files.
%   PATTERN     - (Optional, default '') A wildcard pattern (e.g., '*.nii' or 'ROI_*.nii')
%                 to match the files to be included as ROIs. If empty, all files
%                 in the folder are considered.
%   OUT_FOLDER  - (Optional, default current working directory) The directory
%                 where the resulting atlas NIfTI file will be saved.
%
%   Output File:
%   An atlas NIfTI file named 'atlasLR.nii' 
%   is saved in OUT_FOLDER. Voxel values in this atlas correspond to the
%   index (1, 2, 3, ...) of the input ROI files in the sorted list.
%
%   Dependencies: 'niftiinfo', 'niftiread', and 'niftisave' functions.
%
%   Author: Pratik Jain

if nargin < 2
    pattern = '';
    out_path = fullfile(pwd,'atlasLR.nii');
end

[fold,name,ext1] = fileparts(out_path);
[~,name,ext2] = fileparts(name);
regions_path = dir(fullfile(folder_path,pattern));
if strcmp(regions_path(1).name, '.')                                           % If the first file is '.', then remove it as it is not a subject directory
    regions_path(1) = [];
end

if strcmp(regions_path(1).name, '..')                                          % If the first file is '..', then remove it as it is not a subject directory
    regions_path(1) = [];
end

temp_info = niftiinfo(fullfile(regions_path(1).folder,regions_path(1).name));

out_image = zeros(temp_info.ImageSize);
for i = 1:length(regions_path)
    temp = niftiread(fullfile(regions_path(i).folder,regions_path(i).name));
    
    out_image(temp==1) = i;

end

niftisave(out_image,fullfile(fold,[name ext2  ext1]),temp_info)
