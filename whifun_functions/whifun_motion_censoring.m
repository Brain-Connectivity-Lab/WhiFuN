function [out_censor_path, out_censor_1d] = whifun_motion_censoring(in_func_path, in_motion_txt_path, func_mask, thresh, log_fileID, over_write)

% Initialize output path based on input function path
[fold_,func_name,ext] = fileparts(in_func_path);
out_censor_path = fullfile(fold_,['mc_' func_name ext]);
[~,func_name,~] = fileparts(func_name);

out_censor_1d = fullfile(fold_,['mc_' func_name '.mat']);
out_cencor_file = whifun_create_file(over_write,out_censor_path);

if isempty(out_cencor_file)
    % Get Framewise Displacement
    fd = whifun_calculate_fd(in_motion_txt_path);
    [func_image,func_info] = whifun_niftiread(in_func_path);
    % Apply motion censoring based on the threshold
    censor_timepoints = fd > thresh;
    % Apply motion censoring to the functional image
    % zero_3d = zeros(func_info.ImageSize(1:3));

    % mc_image(:, :, :, censor_timepoints) = 0;
    save(out_censor_1d,"censor_timepoints")
% %% create mask
    warning('this technique for mask creation is only for data that already has background as zeros')
    func_sum = sum(func_image,4);
    func_mask = func_sum>0;
    % func_mask = niftiread(func_mask);
    % func_mask = func_mask>0;
    %%
    func_image = reshape(func_image,prod(func_info.ImageSize(1:3)),[]);
    mc_func = zeros(prod(func_info.ImageSize(1:3)),func_info.ImageSize(4));
    global_mean = mean(func_image(func_mask,~censor_timepoints),2);

    mc_func(func_mask,:) = func_image(func_mask,:) - global_mean;
    mc_func(func_mask,censor_timepoints) = 0;
    mc_func = reshape(mc_func,func_info.ImageSize);
    
    disp([ num2str(nnz(censor_timepoints)/length(censor_timepoints)*100) '% timepoints censored' ])
    % Save the censored functional image
    niftisave(mc_func(:,:,:,10+1:end), out_censor_path, func_info);

    % Log the results if log_fileID is provided
    if log_fileID > 0
        fprintf(log_fileID, 'Motion censoring applied with threshold: %f\n', thresh);
    end
else
    % Handle case when the output file already exists
    disp('Output file already exists. Skipping motion censoring.');
end