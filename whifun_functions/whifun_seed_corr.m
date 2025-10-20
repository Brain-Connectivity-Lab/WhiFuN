function [out_map,matlab_cor,thresh] = whifun_seed_corr(func_image_path,seed,radius,output_path,thresh,mask)
%WHIFUN_SEED_CORR Performs Seed-Based Functional Connectivity (FC) Analysis.
%
%   [OUT_MAP, MATLAB_COR, THRESH] = WHIFUN_SEED_CORR(FUNC_IMAGE_PATH, SEED, RADIUS, OUTPUT_PATH, THRESH, MASK)
%
%   This function calculates the Pearson correlation map between the mean time
%   series of a spherical seed region (defined in MNI coordinates) and the time
%   series of every other voxel in the brain. It saves the resulting correlation
%   map and optionally saves two thresholded maps (positive and negative correlations).
%
%   Input Arguments:
%   FUNC_IMAGE_PATH - Full path to the 4D NIfTI file of the functional image.
%   SEED            - 3-element vector [x, y, z] in MNI space defining the center
%                     of the spherical seed region (e.g., [-4 58 20]).
%   RADIUS          - The radius of the spherical seed region in mm.
%   OUTPUT_PATH     - Full path to save the unthresholded correlation map NIfTI file.
%   THRESH          - (Optional) 2-element vector [negative_threshold, positive_threshold]
%                     used to create and save two thresholded output maps.
%                     e.g., [-0.3 0.3]. If not provided, no thresholding is done.
%   MASK            - (Optional) Path to a NIfTI file or a 3D numeric volume to
%                     mask the resulting correlation map. Can be NaN to skip masking.
%
%   Output Arguments:
%   OUT_MAP         - The 3D volume of unthresholded correlation values (Fisher Z-transformed if the input was).
%   MATLAB_COR      - The 3-element vector [x, y, z] of the seed center in voxel coordinates.
%   THRESH          - The input threshold vector (unchanged, but returned for consistency).
%
%   Dependencies: 'whifun_niftiread', 'whifun_convert_coords', 'whifun_create_sphere',
%                 'whifun_extract_ts_from_vox', 'niftisave'.
%
%   Author: Pratik Jain
[func_image,func_image_info] = whifun_niftiread(func_image_path);
[x,y,z,nt] = size(func_image);
func_image = zscore(func_image,0,4);

matlab_cor = whifun_convert_coords(func_image_info.Transform.T, [seed(1) seed(2) seed(3)], 'mni2vox');
vox_size = func_image_info.PixelDimensions(1:3);
vox_list = whifun_create_sphere(matlab_cor, radius, vox_size, [x,y,z]);
vox_ts = whifun_extract_ts_from_vox(func_image,vox_list);
mean_ts = mean(vox_ts,1);
func_image = reshape(func_image,[],nt);
dot_prod = func_image * mean_ts(:);  % nVox x 1
out_map = reshape(dot_prod,x,y,z)/nt;

if exist("mask",'var')
    if ~isnan(mask)
        if~isnumeric(mask)
            mask = whifun_niftiread(mask);
        end
        out_map = out_map .* mask;  % Apply the mask to the output map
    end
end

if exist("output_path",'var')
    niftisave(out_map,output_path,func_image_info,0,1); % here force setting the add offset and multiplicative scalin as we are not saving in the datatype of the header provided
end

if exist("thresh",'var')

    [fold,file,ext] = fileparts(output_path);
    [~,file_nii,ext2] = fileparts(file);
    out_map_thresh = out_map;
    out_map_thresh(out_map<thresh(2)) = 0;
    nan_vox = isnan(out_map_thresh);
    out_map_thresh(nan_vox) = 0;
    if nnz(out_map_thresh) == 0
        warning([func_image_path ' has no correlations above ' num2str(thresh(2))]) % ', changing the threshold to 0'
        % thresh(2) = 0;
        % out_map_thresh = out_map;
        % out_map_thresh(out_map<thresh(2)) = 0;
    end
    out_map_thresh(nan_vox) = nan;
    niftisave(out_map_thresh,fullfile(fold,[file_nii '_thresh-' num2str(thresh(2)) ext2 ext]),func_image_info,0,1); % here force setting the add offset and multiplicative scalin as we are not saving in the datatype of the header provided

    out_map_thresh = out_map;
    out_map_thresh(out_map>thresh(1)) = 0;
    nan_vox = isnan(out_map_thresh);
    out_map_thresh(nan_vox) = 0;
     if nnz(out_map_thresh) == 0
        warning([func_image_path ' has no correlations below ' num2str(thresh(1))])
        % thresh(1) = 0;
        % out_map_thresh = out_map;
        % out_map_thresh(out_map>thresh(1)) = 0;
     end
    out_map_thresh(nan_vox) = nan;
    niftisave(out_map_thresh,fullfile(fold,[file_nii '_thresh-' num2str(thresh(1)) ext2 ext]),func_image_info,0,1); % here force setting the add offset and multiplicative scalin as we are not saving in the datatype of the header provided


end
end

