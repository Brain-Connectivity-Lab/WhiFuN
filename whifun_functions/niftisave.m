function niftisave(niftiimage,filename,info,add_offset,multi_scale)
%NIFTISAVE Saves a MATLAB array as a NIfTI-1 file, updating essential header
%   information from a provided info structure.
%
%   NIFTISAVE(NIFTIIMAGE, FILENAME, INFO, ADD_OFFSET, MULTI_SCALE)
%
%   This is a utility wrapper for MATLAB's built-in `niftiwrite` function.
%   It ensures that the NIfTI header information (INFO) is correctly updated
%   to reflect the dimensions, datatype, and name of the image data being saved.
%
%   Input Arguments:
%   NIFTIIMAGE  - The MATLAB array (2D, 3D, or 4D) containing the image data
%                 to be saved as a NIfTI file.
%   FILENAME    - The desired full path and filename (with extension, e.g., '.nii')
%                 for the output NIfTI file.
%   INFO        - A structure, typically obtained from a previous `niftiread`
%                 call, containing the NIfTI header information (metadata)
%                 to use for the new file.
%   ADD_OFFSET  - (Optional) Value to set as the 'AdditiveOffset' (qform/sform
%                 `qoffset_b` or `srow_b`) in the NIfTI header, used for adding offset.
%   MULTI_SCALE - (Optional) Value to set as the 'MultiplicativeScaling'
%                 (sform/qform `qfac` or `srow_a`) in the NIfTI header, used for scaling.
%
%   Output:
%   A NIfTI file is saved to the location specified by FILENAME.
%
%   Author: Pratik Jain

% input -->
% niftiimage --> file to be saved
% info --> info file to be used
% filename --> desired file name

info.Filename = filename;
info.Datatype = class(niftiimage);
info.Filemoddate = char(datetime);
if length(info.ImageSize) == 3 && length(size(niftiimage)) == 4
    info.PixelDimensions = [info.PixelDimensions 0];%size(niftiimage);%info.PixelDimensions(1:length(info.ImageSize));
end
if length(info.ImageSize) == 4 && length(size(niftiimage)) == 3
    info.PixelDimensions = info.PixelDimensions(1:3);
end
info.ImageSize = size(niftiimage);
if exist("add_offset",'var')
    info.AdditiveOffset = add_offset;
end

if exist("multi_scale",'var')
    info.MultiplicativeScaling = multi_scale;
end
%
info.Filesize = [];
niftiwrite(niftiimage,filename,info)
end