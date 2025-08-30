function vox_ts = whifun_extract_ts_from_vox(func_img,vox_list)

[x,y,z,nt] = size(func_img);

lin_idx = sub2ind([x,y,z], vox_list(:,1), vox_list(:,2), vox_list(:,3));

vox_ts = reshape(func_img, [], nt);  % reshape 4D to 2D [nx*ny*nz x nt]
vox_ts = vox_ts(lin_idx, :);      % select rows corresponding to ROI voxels