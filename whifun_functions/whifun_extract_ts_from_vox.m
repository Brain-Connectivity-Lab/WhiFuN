function vox_ts = whifun_extract_ts_from_vox(func_img,vox_list)
% WHIFUN_EXTRACT_TS_FROM_VOX Extracts time series data from a list of voxels.
%
%   vox_ts = WHIFUN_EXTRACT_TS_FROM_VOX(func_img, vox_list) extracts the
%   time series data for a specified set of voxels from a 4D functional
%   neuroimaging image volume.
%
%   The function first reshapes the 4D image data into a 2D matrix where
%   each row represents a voxel and each column represents a time point.
%   It then uses a list of voxel coordinates to extract the corresponding
%   time series. This is an efficient way to get the data for a region
%   of interest (ROI) without having to loop through each voxel.
%
%   Input Arguments:
%   func_img - A 4D matrix of functional image data `[nx ny nz nt]`.
%   vox_list - An Nx3 array of voxel coordinates `[x y z]` where N is the
%              number of voxels in the ROI.
%
%   Output Arguments:
%   vox_ts   - An NxT matrix where N is the number of voxels in the ROI
%              and T is the number of time points. Each row is the time
%              series for a single voxel.
%
%   Author: Pratik Jain
%   See also SUB2IND, RESHAPE.

[x,y,z,nt] = size(func_img);

lin_idx = sub2ind([x,y,z], vox_list(:,1), vox_list(:,2), vox_list(:,3));

vox_ts = reshape(func_img, [], nt);  % reshape 4D to 2D [nx*ny*nz x nt]
vox_ts = vox_ts(lin_idx, :);      % select rows corresponding to ROI voxels