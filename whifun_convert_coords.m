function coord_out = whifun_convert_coords(M, coord_in, mode,mat_py)
% whifun_convert_coords  Convert between MNI/world and voxel coordinates
%
%   coord_out = convert_coords(M, coord_in, mode)
%
% Inputs:
%   M        - 4x4 affine transformation matrix (e.g. from NIfTI header)
%   coord_in - 1x3 or Nx3 matrix of coordinates
%              (MNI/world if mode='mni2vox', voxel if mode='vox2mni')
%   mode     - 'mni2vox' or 'vox2mni'
%   mat_py   - 1 or 0
%              If 1 it knows th voxel co-ordinates come from matlab
%
%
% Output:
%   coord_out - transformed coordinates
%
% Notes:
%   - Voxel indices returned are 0-based (like in FSL). For MATLAB array
%     indexing (1-based), add +1 to each component.
%   - Works for multiple points at once (Nx3 input).
if ~exist("mat_py",'var')
    mat_py = 1;
end
if mat_py
    coord_in = coord_in - 1; % Adjust for MATLAB's 1-based indexing if converting from voxel to MNI
end
if size(coord_in,2) ~= 3
    error('coord_in must be Nx3 (x,y,z).');
end
M = M';
% Homogeneous coordinates
coord_in_h = [coord_in, ones(size(coord_in,1),1)];

switch lower(mode)
    case 'mni2vox'
        % Voxel = inv(M) * MNI
        vox_h = (inv(M) * coord_in_h')';
        coord_out = round(vox_h(:,1:3));

        if mat_py
            coord_out = coord_out + 1;
        end
    case 'vox2mni'
        % MNI = M * Voxel
        mni_h = (M * coord_in_h')';
        coord_out = mni_h(:,1:3);
    otherwise
        error('Mode must be ''mni2vox'' or ''vox2mni''.');
end
end
