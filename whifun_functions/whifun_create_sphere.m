function vox_list = whifun_create_sphere(center_vox, radius_mm, vox_dim, vol_size)
% WHIFUN_CREATE_SPHERE Generates a list of voxel coordinates within a sphere.
%
%   vox_list = WHIFUN_CREATE_SPHERE(center_vox, radius_mm, vox_dim, vol_size)
%   creates a list of 1-based voxel coordinates that fall inside a sphere
%   of a given radius. This function is a core utility for defining
%   spherical regions of interest (ROIs) in neuroimaging analysis.
%
%   The function first calculates a cubic grid of candidate voxels around the
%   center point. It then filters this grid, keeping only the voxels whose
%   Euclidean distance from the center (in millimeters) is less than or
%   equal to the specified radius. Finally, it clips the list of voxels to
%   ensure they are all within the bounds of the image volume.
%
%   Input Arguments:
%   center_vox - A 1x3 vector `[i j k]` representing the center voxel of the
%                sphere in 1-based indices.
%   radius_mm  - A scalar representing the radius of the sphere in millimeters.
%   vox_dim    - A 1x3 vector `[dx dy dz]` of the voxel dimensions in millimeters.
%   vol_size   - A 1x3 vector `[nx ny nz]` of the image dimensions.
%
%   Output Arguments:
%   vox_list   - An Nx3 array where each row contains the `[i j k]` 1-based
%                coordinates of a voxel inside the sphere.
%
%   Author: Pratik Jain
%   See also NDGRID, BSXFUN.

% Compute max search radius in voxels along each axis
rad_vox = ceil(radius_mm ./ vox_dim);

% Create grid of candidate voxels around center
[X, Y, Z] = ndgrid(-rad_vox(1):rad_vox(1), ...
    -rad_vox(2):rad_vox(2), ...
    -rad_vox(3):rad_vox(3));
offsets = [X(:), Y(:), Z(:)];

% Convert offsets to mm distances
d_mm = sqrt( (offsets(:,1)*vox_dim(1)).^2 + ...
    (offsets(:,2)*vox_dim(2)).^2 + ...
    (offsets(:,3)*vox_dim(3)).^2 );

% Keep only those within radius
inside = d_mm <= radius_mm;

% Convert to absolute voxel coordinates
vox_list = offsets(inside,:) + center_vox;

% keep only voxels inside volume
valid = all(bsxfun(@ge, vox_list, [1 1 1]), 2) & ...
    (vox_list(:,1) <= vol_size(1)) & ...
    (vox_list(:,2) <= vol_size(2)) & ...
    (vox_list(:,3) <= vol_size(3));
vox_list = vox_list(valid,:);

end
