function a = whifun_convert_nifti_3d_to_4d(folder,filter,TR,out_filename,atlas)
%WHIFUN_CONVERT_NIFTI_3D_TO_4D Combines a series of 3D NIfTI volumes into a
%   single 4D NIfTI file (e.g., creating a functional time series from
%   individual 3D volumes).
%
%   A = WHIFUN_CONVERT_NIFTI_3D_TO_4D(FOLDER, FILTER, TR, OUT_FILENAME, ATLAS)
%
%   This function is useful for aggregating individual 3D image acquisitions
%   (e.g., single time points from a scanner) into the standard 4D time series format.
%
%   Input Arguments:
%   FOLDER      - The directory path containing the 3D NIfTI files.
%   FILTER      - The common filename pattern (wildcard) to match the 3D NIfTI files (e.g., 'f*.nii').
%   TR          - The Temporal Resolution (Repetition Time) in seconds. This
%                 value is written to the 4th dimension of the NIfTI header's
%                 PixelDimensions (voxel size).
%   OUT_FILENAME- (Optional) The full path and filename for the resulting 4D NIfTI file.
%                 Default: `<basename>_4d.nii` in the FOLDER.
%   ATLAS       - (Optional, default 0) A flag to indicate a special conversion mode:
%                 ATLAS = 0: Standard mode. Reads the raw image data (e.g., BOLD signal).
%                 ATLAS = 1: Atlas mode. Reads the binary mask (assumed to be 1s and 0s)
%                            and replaces the 1s with the index 'i' of the file being read.
%                            This can be used to combine multiple binary masks into a
%                            4D volume where each 3D volume is a uniquely labeled mask.
%
%   Output Arguments:
%   A           - The resulting 4D matrix [X x Y x Z x T] containing the combined image data.
%
%   Dependencies: `niftiinfo`, `niftiread`, `niftiwrite` (MATLAB built-in or custom wrappers).
%
%   Author: Pratik Jain

%% Input 
%     folder --> the subject folder that contains all the 3d nifti files
%     filter --> common name of the 3d niftifiles 
%     TR --> Temporal resolution 
%     filename (optional) --> specify the output filename

% Eg. if the 3d niftifiles look 
% f2021-12-22_10-56.nii
% f2021-12-22_10-54.nii

% the filter will be --> 'f202*'
    tic
    files = dir(fullfile(folder,filter));

    if strcmp(files(1).name, '.')                                           % If the first file is '.', then remove it as it is not a subject directory
        files(1) = [];
    end

    if strcmp(files(1).name, '..')                                          % If the first file is '..', then remove it as it is not a subject directory
        files(1) = [];
    end

    if nargin < 4
        out_filename = fullfile(folder,[files(1).name(1:end-4),'_4d.nii']);
        atlas = 0;
    end
    if ~isempty(files)
        header = niftiinfo(fullfile(files(1).folder,files(1).name));
        a = zeros([header.ImageSize(1:3),length(files)]);
        for i = 1:length(files)
            if atlas == 0
                a(:,:,:,i) = (niftiread(fullfile(files(i).folder,files(i).name)));
            else
                a(:,:,:,i) = i.*(niftiread(fullfile(files(i).folder,files(i).name)));
            end
        end
        toc
        header.Filesize = numel(a)*2;
        header.Datatype = class(a);
        header.Filemoddate = char(datetime);
        header.Filename = out_filename;
        header.ImageSize = size(a);
        header.PixelDimensions = [header.PixelDimensions(1:3),TR];
        header.Filesize = [];
        niftiwrite(a,out_filename,header)
    else
        a = 0;
        disp('No files found')
    end

end