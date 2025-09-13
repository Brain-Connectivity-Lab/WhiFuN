function func_mask_path = whifun_regress(in_func_path,in_anat_mask_subj_space_path,in_csf_mat_path,in_motion_txt_path,out_func_path,n_pca)
% WHIFUN_REGRESS Performs nuisance regression on functional data.
%
%   func_mask_path = WHIFUN_REGRESS(in_func_path, ..., n_pca) performs
%   nuisance regression on a functional neuroimaging time series. This process
%   removes signals from non-neuronal sources, such as head motion and
%   physiological noise.
%
%   The function first loads the functional data and creates a brain mask
%   by reslicing an anatomical mask into functional space. It then constructs
%   a design matrix (`b_init`) of nuisance regressors, which can include:
%   - **CSF Signal**: Loaded from `in_csf_mat_path`. The signal can be either
%     the mean CSF time series or a set of PCA components.
%   - **Motion Parameters**: Loaded from `in_motion_txt_path`. If `motion_reg`
%     is true, it includes the 6 rigid body motion parameters, their squares,
%     and their first derivatives and squared derivatives (a total of 24
%     regressors, often referred to as "Friston-24").
%
%   Finally, the function performs a voxel-wise linear regression. For each
%   voxel, the nuisance regressors are fit to the time series, and the
%   residuals (the signal that is not explained by the regressors) are
%   saved. The mean of the original time series is added back to preserve
%   signal magnitude.
%
%   Input Arguments:
%   in_func_path                 - The path to the input functional file.
%   in_anat_mask_subj_space_path - Path to the anatomical brain mask in subject space.
%   in_csf_mat_path              - Path to the `.mat` file containing the CSF time series.
%   in_motion_txt_path           - Path to the motion parameter `.txt` file.
%   out_func_path                - The desired path for the output regressed file.
%   motion_reg                   - A logical value (0 or 1) to include motion
%                                  parameters as regressors.
%   n_pca                        - The number of PCA components for CSF regression.
%
%   Output Arguments:
%   func_mask_path - The path to the created functional mask.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_REST_MASK, NIFTIINFO, NIFTIREAD, NIFTISAVE, REGRESS.

disp(['Functional image to be nuisance regressed is : ' in_func_path])
now_func_path = dir(in_func_path);
func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));                           % Get Func file info
image_dim_REST = func_info.ImageSize;                                                                        % number of timepoints
nt = image_dim_REST(4);
% disp(['Loading rest mask for ' name]);

% Creating REST_MASK from the Anat mask

[REST_MASK1,func_mask_path] = whifun_create_rest_mask(fullfile(now_func_path.folder,now_func_path.name),in_anat_mask_subj_space_path);
REST_MASK = zeros(size(REST_MASK1));
REST_MASK(REST_MASK1>0.5) = 1;

% Loading Time Series realigned rest file

y_image_func = whifun_niftiread(fullfile(now_func_path.folder,now_func_path.name));
mean_image_REST = mean(y_image_func,4);   % calculate mean across time for all voxels | can be added back after regression to improve ICA performance

if ~isempty(in_motion_txt_path) || ~isempty(in_csf_mat_path)
    if ~isempty(in_motion_txt_path)
        % Loading the motion parameters
        disp(['Obtained the motion parameters from : ' in_motion_txt_path])
        rp=load(in_motion_txt_path);
        rp_temp = rp(1:nt,:);
        rp = zscore(rp_temp);
        rp_previous = [0 0 0 0 0 0; rp(1:end-1,:)];
        rp_auto = [rp rp.^2 rp_previous rp_previous.^2];
    else
        rp_auto = [];
    end

    if ~isempty(in_csf_mat_path)
        disp(['Obtained csf timeseries from : ' in_csf_mat_path])
        load(in_csf_mat_path); %#ok<LOAD>
        if exist("pca_CSF",'var')
            b_init = zscore([pca_CSF(:,1:n_pca) rp_auto]); %#ok<USENS>
        else
            b_init = zscore([MEAN_CSF_REST rp_auto]);
        end
    else
        b_init = zscore(rp_auto);
    end
else
    warning('No Motion or CSF regressors specified. Skipping Nuisance Regression')
    return
end

y_image_func_regressed = zeros(size(y_image_func));
X = image_dim_REST(2);
Y = image_dim_REST(3);
for vi = 1:image_dim_REST(1)
    for vj = 1:X
        for vk = 1:Y
            if REST_MASK(vi,vj,vk)==0

                y_image_func_regressed(vi,vj,vk,:) = zeros(1,1,1,nt);

            else

                % CSF, MOTION Regressors

                [~,~,y_image_func_regressed(vi,vj,vk,:)] = regress(shiftdim(y_image_func(vi,vj,vk,:),3),[b_init ones(nt,1)]);
                y_image_func_regressed(vi,vj,vk,:) = y_image_func_regressed(vi,vj,vk,:) + mean_image_REST(vi,vj,vk);  
            end
        end

    end
end
y_image_func_regressed = cast((y_image_func_regressed-func_info.AdditiveOffset)./func_info.MultiplicativeScaling,func_info.Datatype);

niftisave((y_image_func_regressed),out_func_path,func_info);