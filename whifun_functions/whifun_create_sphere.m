function vox_list = whifun_create_sphere(center_vox, radius_mm, vox_dim, vol_size)
% sphere_voxels  Return voxel coordinates inside a sphere
%
%   vox_list = sphere_voxels(center_vox, radius_mm, vox_dim, vol_size)
%
% Inputs:
%   center_vox : [i j k] center voxel (1x3, 1-based indices)
%   radius_mm  : scalar, sphere radius in millimeters
%   vox_dim    : [dx dy dz] voxel dimensions in mm
%   vol_size   : [nx ny nz] image dimensions (optional, to clip to image)
%
% Output:
%   vox_list   : Nx3 array of voxel indices (1-based)

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
