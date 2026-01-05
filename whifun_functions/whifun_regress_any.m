function func_mask_path = whifun_regress_any(in_func_path,in_anat_mask,confounds_matrix,out_func_path)
%WHIFUN_REGRESS_ANY Performs voxel-wise nuisance regression on a 4D NIfTI.
%
%   FUNC_MASK_PATH = WHIFUN_REGRESS_ANY(IN_FUNC_PATH, IN_ANAT_MASK, ...
%   CONFOUNDS_MATRIX, OUT_FUNC_PATH) reads a functional NIfTI file, 
%   removes signals defined in the confounds matrix using linear 
%   regression, adds the mean signal back, and saves the result.
%
%   INPUTS:
%       in_func_path     - String. Path to the input 4D functional NIfTI.
%       in_anat_mask     - String. Path to the anatomical mask NIfTI.
%       confounds_matrix - Matrix (T x N). Nuisance regressors (e.g., 
%                          motion parameters, CSF signal) where T matches 
%                          the number of timepoints.
%       out_func_path    - String. Path where the regressed NIfTI will 
%                          be saved.
%
%   OUTPUTS:
%       func_mask_path   - String. Path to the generated functional mask.
%
%   NOTES:
%       - The confounds are z-scored before regression.
%       - The mean image is added back to the residuals to maintain 
%         the original signal's baseline intensity.
%       - The output is re-scaled to match the original NIfTI's 
%         MultiplicativeScaling and AdditiveOffset.
%
%   See also REGRESS, ZSCORE, WHIFUN_NIFTIREAD.
disp(['Functional image to be nuisance regressed is : ' in_func_path])
now_func_path = dir(in_func_path);
[y_image_func,func_info] = whifun_niftiread(fullfile(now_func_path.folder,now_func_path.name));
image_dim_REST = func_info.ImageSize;                                                                        % number of timepoints
nt = image_dim_REST(4);

% Creating REST_MASK from the Anat mask

[REST_MASK1,func_mask_path] = whifun_create_rest_mask(fullfile(now_func_path.folder,now_func_path.name),in_anat_mask);
REST_MASK = zeros(size(REST_MASK1));
REST_MASK(REST_MASK1>0.5) = 1;

mean_image_REST = mean(y_image_func,4);   % calculate mean across time for all voxels | can be added back after regression to improve ICA performance

b_init = zscore(confounds_matrix);

y_image_func_regressed = zeros(size(y_image_func));
X = image_dim_REST(2);
Y = image_dim_REST(3);
for vi = 1:image_dim_REST(1)
    for vj = 1:X
        for vk = 1:Y
            if REST_MASK(vi,vj,vk)==0

                y_image_func_regressed(vi,vj,vk,:) = zeros(1,1,1,nt);

            else
                [~,~,y_image_func_regressed(vi,vj,vk,:)] = regress(shiftdim(y_image_func(vi,vj,vk,:),3),b_init);
                y_image_func_regressed(vi,vj,vk,:) = y_image_func_regressed(vi,vj,vk,:) + mean_image_REST(vi,vj,vk);  
            end
        end

    end
end
y_image_func_regressed = cast((y_image_func_regressed-func_info.AdditiveOffset)./func_info.MultiplicativeScaling,func_info.Datatype);

niftisave((y_image_func_regressed),out_func_path,func_info);