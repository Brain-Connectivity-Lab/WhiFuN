function [output_gm, output_wm] = whifun_smooth_WM_GM_separately_fast(in_func_path, GM_file_path, WM_file_path ,smooth_pre, gaussian_FWHM, over_write)

if ~exist('over_write','var')
    over_write = 0;
end

GM_WM_threshold = 0.5;

% loading the data and reslicing the anatomical images to functional resolution
GM_image = reslice_data(GM_file_path, in_func_path, 1);
WM_image = reslice_data(WM_file_path, in_func_path, 1);

% loading all of the functional data
now_func_path = dir(in_func_path);
% func_info = niftiinfo(in_func_path);
[func_mat,func_info] = whifun_niftiread(in_func_path);

func_mat = reshape(func_mat,[],func_info.ImageSize(4));

out_GM_file_path = fullfile(now_func_path.folder,'GM_func_data.nii');
GM_file_path =  whifun_create_file(over_write,out_GM_file_path);
if isempty(GM_file_path)
    GM_func_mat = func_mat;
    GM_func_mat(GM_image<GM_WM_threshold,:) = 0;         % voxel is above threshold for being grey-matter
    GM_func_mat(WM_image>=GM_WM_threshold,:) = 0;        % voxel is also below threshold for being White matter
    niftisave((reshape(GM_func_mat,func_info.ImageSize)-func_info.AdditiveOffset)/func_info.MultiplicativeScaling,fullfile(now_func_path.folder,'GM_func_data.nii'),func_info);
    clear GM_func_mat
end

% saving functional images with only the WM voxels and GM voxels separately in the output directory
out_WM_file_path = fullfile(now_func_path.folder,'WM_func_data.nii');
WM_file_path =  whifun_create_file(over_write,out_WM_file_path);
if isempty(WM_file_path)
    WM_func_mat = func_mat;
    WM_func_mat(WM_image<GM_WM_threshold,:) = 0;         % voxel is above threshold for being white-matter
    WM_func_mat(GM_image>=GM_WM_threshold,:) = 0;        % voxel is also below threshold for being gray-matter
    niftisave((reshape(WM_func_mat,func_info.ImageSize)-func_info.AdditiveOffset)/func_info.MultiplicativeScaling,fullfile(now_func_path.folder,'WM_func_data.nii'),func_info);
    clear WM_func_mat
end

% applying smoothing using SPM's smooth function
if over_write == 1
    gm_smooth = dir(fullfile(now_func_path.folder,'sGM_func_data.nii'));
    if ~isempty(gm_smooth)
        delete(fullfile(gm_smooth.folder),gm_smooth.name)
        gm_smooth = [];
    end
else
    gm_smooth = dir(fullfile(now_func_path.folder,'sGM_func_data.nii'));
    if ~isempty(gm_smooth)
        temp_info = niftiinfo(fullfile(gm_smooth.folder,gm_smooth.name));

        if temp_info.ImageSize(4) ~= func_info.ImageSize(4)
            gm_smooth = [];
        end

    end
end

if isempty(gm_smooth)
    spm('defaults','fmri'); spm_jobman('initcfg');      % initializing SPM's jobman
    matlabbatch={struct('spm',struct('spatial',struct('smooth',struct('data','','dtype',0,'fwhm',[gaussian_FWHM gaussian_FWHM gaussian_FWHM],'im',0,'prefix','s'))))};
    matlabbatch{1}.spm.spatial.smooth.data = {fullfile(now_func_path.folder,'GM_func_data.nii')};   % grey matter smoothing
    spm_jobman('initcfg');

    % Suppress GUI
    spm_get_defaults('cmdline', true);
    output_gm = evalc("spm_jobman('run',matlabbatch)");
    clear matlabbatch
end

if over_write == 1
    wm_smooth = dir(fullfile(now_func_path.folder,'sWM_func_data.nii'));
    if ~isempty(wm_smooth)
        delete(fullfile(wm_smooth.folder),wm_smooth.name)
        wm_smooth = [];
    end
else
    wm_smooth = dir(fullfile(now_func_path.folder,'sWM_func_data.nii'));
    if ~isempty(wm_smooth)
        temp_info = niftiinfo(fullfile(wm_smooth.folder,wm_smooth.name));

        if temp_info.ImageSize(4) ~= func_info.ImageSize(4)
            wm_smooth = [];
        end

    end
end

if isempty(wm_smooth)

    spm('defaults','fmri'); spm_jobman('initcfg');      % initializing SPM's jobman
    matlabbatch={struct('spm',struct('spatial',struct('smooth',struct('data','','dtype',0,'fwhm',[gaussian_FWHM gaussian_FWHM gaussian_FWHM],'im',0,'prefix','s'))))};
    matlabbatch{1}.spm.spatial.smooth.data = {fullfile(now_func_path.folder,'WM_func_data.nii')};   % white matter smoothing
    spm_jobman('initcfg');

    % Suppress GUI
    spm_get_defaults('cmdline', true);
    output_wm = evalc("spm_jobman('run',matlabbatch)");

end

% loading thoe new smoothed images, combining them and saving
smoothed_GM_data = whifun_niftiread(fullfile(now_func_path.folder,'sGM_func_data.nii'));
smoothed_WM_data = whifun_niftiread(fullfile(now_func_path.folder,'sWM_func_data.nii'));
% func_mat = reshape(func_mat,func_info.ImageSize);
for i=1:func_info.ImageSize(4)    % go over all timepoints (volumes)
    curr_volume_data = smoothed_GM_data(:,:,:,i);
    curr_volume_data(GM_image<GM_WM_threshold)=0;
    smoothed_GM_data(:,:,:,i) = curr_volume_data;

    curr_volume_data = smoothed_WM_data(:,:,:,i);
    curr_volume_data(WM_image<GM_WM_threshold)=0;
    smoothed_WM_data(:,:,:,i) = curr_volume_data;
end
clear func_ma curr_volume_data WM_image;
final_func_matrix = cast(((smoothed_GM_data + smoothed_WM_data)-func_info.AdditiveOffset)/func_info.MultiplicativeScaling,func_info.Datatype);    % combining the GM and WM images
niftisave(final_func_matrix,fullfile(now_func_path.folder,[smooth_pre now_func_path.name]),func_info);

% deleting the old WM/GM-only functional files
delete(fullfile(now_func_path.folder,'GM_func_data.nii')); delete(fullfile(now_func_path.folder,'WM_func_data.nii'));
delete(fullfile(now_func_path.folder,'sGM_func_data.nii')); delete(fullfile(now_func_path.folder,'sWM_func_data.nii'));


