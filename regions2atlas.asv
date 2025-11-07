function regions2atlas(folder_path,pattern,out_folder)
% folder_path --> Path of the folder that contains the ROIs to be
%                   converted to atlas of regions
% pattern --> pattern to match

if nargin < 2
    pattern = '';
    out_folder = pwd;
end


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

niftisave(out_image,fullfile(out_folder,'atlasLR.nii'),temp_info)
