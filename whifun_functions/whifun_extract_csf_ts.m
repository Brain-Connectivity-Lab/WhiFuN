function whifun_extract_csf_ts(now_anat_path,now_func_path,CSF_thres,pca_for_temp_reg,n_pca)
cd(now_anat_path(1).folder)
CSF_MASK = spm_vol(['CSF_MASK' CSF_thres '.nii']);                                         % Read the CSF mask info
CSF_files  = spm_read_vols(CSF_MASK);                                                      % Read the CSF mask
image_dim = CSF_MASK.dim;                                                                  % get the dimentions
CSF_Files_RS  = reshape(CSF_files,image_dim(1)*image_dim(2)*image_dim(3),1);               % resize to voxels x 1
clear image_dim CSF_files

clear WM_REST CSF_REST REST_list REST_files image_dim2 REST_RS
%%


REST_files = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));         % Read the func file to extract the WM and CSF time series
image_dim2 = size(REST_files);                                                             % Get the dimensions of image
REST_RS = reshape(REST_files,image_dim2(1)*image_dim2(2)*image_dim2(3),image_dim2(4));     % resize to voxels x timepoints

CSF_REST = REST_RS(CSF_Files_RS > 0.5,:);                                            % Extract all the CSF timeseries
%%
if isempty(CSF_REST)                                                   % If
    error('CSF mask empty')
end
clear MEAN_CSF_REST VARname1 z*

% look for any nan of inf values and remove them
aa = mean(CSF_REST,2);
CSF_REST = CSF_REST(isfinite(aa),:);

if pca_for_temp_reg == 1                                        % If PCA was choosen

    [~,s_CSF] = pca(CSF_REST');                                 % PCA for CSF

    pca_CSF = s_CSF(:,1:n_pca);                                 % Choose 1st n_pca Principal components
    VARname1 = fullfile(now_func_path.folder,'covariance_csf_REST.mat') ;
    save (VARname1,'pca_CSF');                                  % Save

else                                                            % If PCA not choosen do Mean

    MEAN_CSF = mean(CSF_REST);                                  % Mean CSF timeseries

    MEAN_CSF_REST = MEAN_CSF';
    VARname1 = fullfile(now_func_path.folder,'covariance_csf_REST.mat') ;
    save (VARname1,'MEAN_CSF_REST');            % Save
end
