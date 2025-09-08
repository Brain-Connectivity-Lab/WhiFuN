function whifun_extract_csf_ts(in_csf_mask_func_path,now_func_path,pca_for_temp_reg,n_pca)
% WHIFUN_EXTRACT_CSF_TS Extracts the CSF time series from a functional scan.
%
%   WHIFUN_EXTRACT_CSF_TS(in_csf_mask_func_path, now_func_path, pca_for_temp_reg, n_pca)
%   extracts the time series of all voxels within a Cerebrospinal Fluid (CSF)
%   mask from a functional neuroimaging data file.
%
%   The function first reads the binary CSF mask and the functional data. It
%   then reshapes both to a voxel x time points matrix to efficiently extract
%   all the CSF time series. The function handles two methods for summarizing
%   the time series:
%   1.  **Principal Component Analysis (PCA)**: If `pca_for_temp_reg` is true,
%       the function performs PCA on the CSF time series and saves the first
%       `n_pca` principal components. This is a common method for reducing
%       the dimensionality of the nuisance signal.
%   2.  **Mean Time Series**: If `pca_for_temp_reg` is false, the function
%       calculates the mean time series across all CSF voxels.
%
%   The extracted time series (either the PCA components or the mean) is
%   saved to a `.mat` file in the same directory as the functional data.
%   The function includes a check to handle cases where the CSF mask is
%   empty, throwing a clear error to the user.
%
%   Input Arguments:
%   in_csf_mask_func_path - The full path to the CSF binary mask file.
%   now_func_path         - A `dir` structure pointing to the functional file.
%   pca_for_temp_reg      - A logical value (0 or 1). If 1, PCA is performed.
%   n_pca                 - The number of principal components to extract
%                           if `pca_for_temp_reg` is 1.
%
%   Author: Pratik Jain
%   See also SPM_VOL, SPM_READ_VOLS, NIFTIREAD, RESHAPE, PCA.



now_csf_mask_func_path = dir(in_csf_mask_func_path) ;
[~,name,~] = fileparts(now_csf_mask_func_path.name);
CSF_MASK = spm_vol(in_csf_mask_func_path);                                         % Read the CSF mask info
CSF_files  = spm_read_vols(CSF_MASK);                                                      % Read the CSF mask
image_dim = CSF_MASK.dim;                                                                  % get the dimentions
CSF_Files_RS  = reshape(CSF_files,image_dim(1)*image_dim(2)*image_dim(3),1);               % resize to voxels x 1
clear image_dim CSF_files

%%

REST_files = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));         % Read the func file to extract the WM and CSF time series
image_dim2 = size(REST_files);                                                             % Get the dimensions of image
REST_RS = reshape(REST_files,image_dim2(1)*image_dim2(2)*image_dim2(3),image_dim2(4));     % resize to voxels x timepoints

CSF_REST = REST_RS(CSF_Files_RS > 0.5,:);                                            % Extract all the CSF timeseries
%%
if isempty(CSF_REST)                                                   % If
    error('CSF mask empty')
end

% look for any nan of inf values and remove them
aa = mean(CSF_REST,2);
CSF_REST = CSF_REST(isfinite(aa),:);

if pca_for_temp_reg == 1                                        % If PCA was choosen

    [~,s_CSF] = pca(CSF_REST');                                 % PCA for CSF

    pca_CSF = s_CSF(:,1:n_pca);                                 % Choose 1st n_pca Principal components
    VARname1 = fullfile(now_func_path.folder,['covariance_csf_' name '.mat']) ;
    save (VARname1,'pca_CSF');                                  % Save

else                                                            % If PCA not choosen do Mean

    MEAN_CSF = mean(CSF_REST);                                  % Mean CSF timeseries

    MEAN_CSF_REST = MEAN_CSF';
    VARname1 = fullfile(now_func_path.folder,['covariance_csf_' name '.mat']) ;
    save (VARname1,'MEAN_CSF_REST');            % Save
end
