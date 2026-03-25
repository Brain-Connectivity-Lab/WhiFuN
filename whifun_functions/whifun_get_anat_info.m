function [Subj_list_1,voxel_anat] = whifun_get_anat_info(now_anat_path,Subj_list_1,output_folder)
% WHIFUN_GET_ANAT_INFO Extracts information from an anatomical NIfTI file.
%
%   [Subj_list_1, voxel_anat] = WHIFUN_GET_ANAT_INFO(now_anat_path, Subj_list_1)
%   reads metadata from an anatomical neuroimaging NIfTI file specified by
%   `now_anat_path`. The function updates a subject structure with the
%   extracted information and returns the voxel dimensions.
%
%   This function is a core part of a neuroimaging pipeline, as it retrieves
%   critical anatomical parameters (like voxel size) that are essential for
%   subsequent preprocessing steps such as coregistration and normalization.
%   It handles cases where metadata might be corrupted or missing.
%
%   Input Arguments:
%   now_anat_path - A `dir` structure (from a call to `dir`) pointing to
%                   the anatomical NIfTI file.
%   Subj_list_1   - A single subject structure, which will be updated
%                   with the file information.
%
%   Output Arguments:
%   Subj_list_1  - The updated subject structure, now containing fields for
%                  the anatomical file path, name, and dimensions (`x_Anat`,
%                  `y_Anat`, `z_Anat`).
%   voxel_anat   - A 1x3 array of the anatomical data's voxel dimensions [x, y, z].
%
%   Author: Pratik Jain
%   See also NIFTIINFO, FULLFILE, DISP.
disp(['Reading anatomical file from ' fullfile(now_anat_path(1).folder,now_anat_path(1).name)])
Subj_list_1.anat_folder = now_anat_path(1).folder;
Subj_list_1.anat_name = now_anat_path(1).name;

try
v_anat = niftiinfo(fullfile(now_anat_path(1).folder,now_anat_path(1).name));

if ~sum(isinf(v_anat.PixelDimensions))
    voxel_anat = v_anat.PixelDimensions(1:3);                                 % voxel size
else
    voxel_anat = [nan,nan,nan];
end

if ~sum(isinf(v_anat.PixelDimensions(1)))
    Subj_list_1.x_Anat = v_anat.PixelDimensions(1);
else
    Subj_list_1.x_Anat = nan;
end

if ~sum(isinf(v_anat.PixelDimensions(2)))
    Subj_list_1.y_Anat = v_anat.PixelDimensions(2);
else
    Subj_list_1.y_Anat = nan;
end

if ~sum(isinf(v_anat.PixelDimensions(3)))
    Subj_list_1.z_Anat = v_anat.PixelDimensions(3);
else
    Subj_list_1.z_Anat = nan;
end

catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Cannot read the nifti file for ' Subj_list_1.name ])
    disp(['trying to read ' fullfile(now_anat_path(1).folder,now_anat_path(1).name) ])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,fullfile(output_folder,'Quality_control'), Subj_list_1.name)                % write error to text file and display  
    voxel_anat = [nan,nan,nan];
end