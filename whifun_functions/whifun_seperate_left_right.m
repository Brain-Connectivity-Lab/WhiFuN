function whifun_seperate_left_right(FN_file_path,one_image)
if ~exist("one_image","var")
    one_image = 0;
end
[FN_folder,FN_name,ext1] = fileparts(FN_file_path);
[~,FN_name,ext2] = fileparts(FN_name);

[FN,FN_header] = whifun_niftiread(FN_file_path);
levels = unique(FN);
levels(levels == 0);
last_level = max(levels);
Mid_sagittal_slice = round(size(FN,1)/2);

FN_L = FN;
FN_R = FN; % Create a copy for the right side
FN_L(1:Mid_sagittal_slice, :, :) = 0; % Extract left half
FN_R(Mid_sagittal_slice+1:end, :, :) = 0; % Extract right half

if ~one_image
    niftisave(FN_L,fullfile(FN_folder,[FN_name '_L' ext2 ext1]),FN_header);
    niftisave(FN_R,fullfile(FN_folder,[FN_name '_R' ext2 ext1]),FN_header);
else
    FN_R(FN_R>0) = FN_R(FN_R>0) +last_level;
    niftisave(FN_L+FN_R,fullfile(FN_folder,[FN_name '_L_R_seperated' ext2 ext1]),FN_header)
end