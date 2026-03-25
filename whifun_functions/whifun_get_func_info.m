
function [Subj_list_1,voxel_func,n_image] = whifun_get_func_info(now_func_path,Subj_list_1,output_folder)
% WHIFUN_GET_FUNC_INFO Extracts information from a functional NIfTI file.
%
%   [Subj_list_1, voxel_func, n_image] = WHIFUN_GET_FUNC_INFO(now_func_path, Subj_list_1)
%   reads metadata from a functional neuroimaging NIfTI file specified by
%   `now_func_path`. The function updates a subject structure with the
%   extracted information and returns the voxel dimensions and number of
%   time points.
%
%   This is a core function in a neuroimaging pipeline, as it retrieves
%   critical parameters (like voxel size and number of volumes) that are
%   essential for subsequent preprocessing steps. It handles cases where
%   metadata might be corrupted or missing.
%
%   Input Arguments:
%   now_func_path - A `dir` structure (from a call to `dir`) pointing to
%                   the functional NIfTI file.
%   Subj_list_1   - A single subject structure, which will be updated
%                   with the file information.
%
%   Output Arguments:
%   Subj_list_1  - The updated subject structure, now containing fields for
%                  the functional file path, name, dimensions (`x_func`, `y_func`,
%                  `z_func`), and number of time points (`nt`).
%   voxel_func   - A 1x3 array of the functional data's voxel dimensions [x, y, z].
%   n_image      - The number of images (time points) in the functional file.
%
%   Author: Pratik Jain
%   See also NIFTIINFO, FULLFILE, DISP.
disp(['Reading functional file from ' fullfile(now_func_path(1).folder,now_func_path(1).name)])
Subj_list_1.func_folder = now_func_path(1).folder;
Subj_list_1.func_name = now_func_path(1).name;
try
v_func = niftiinfo(fullfile(now_func_path(1).folder,now_func_path(1).name));% Get info of the functional file

if ~sum(isinf(v_func.PixelDimensions))
    voxel_func = v_func.PixelDimensions(1:3);                                 % voxel size
else
    voxel_func = [nan,nan,nan];
end

if ~sum(isinf(v_func.ImageSize(4)))
    n_image = v_func.ImageSize(4);                                  % number of images (time points)
    Subj_list_1.nt = v_func.ImageSize(4);
else
    n_image = nan;
    Subj_list_1.nt = nan;
end

if ~sum(isinf(v_func.PixelDimensions(1)))
    Subj_list_1.x_func = v_func.PixelDimensions(1);
else
    Subj_list_1.x_func = nan;
end

if ~sum(isinf(v_func.PixelDimensions(2)))
    Subj_list_1.y_func = v_func.PixelDimensions(2);
else
    Subj_list_1.y_func = nan;
end

if ~sum(isinf(v_func.PixelDimensions(3)))
    Subj_list_1.z_func = v_func.PixelDimensions(3);
else
    Subj_list_1.z_func = nan;
end

catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Cannot read the nifti file for ' Subj_list_1.name ])
    disp(['trying to read ' fullfile(now_func_path(1).folder,now_func_path(1).name) ])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,fullfile(output_folder,'Quality_control'), Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
    voxel_func = [nan,nan,nan];
    n_image = nan;
    Subj_list_1.nt = nan;
end