function [output_gm, output_wm] = p_smooth_WM_GM_separately_fast(functional_dir, segmentation_dir, output_dir,op_name, gaussian_FWHM, GM_filename_prefix, WM_filename_prefix, over_write)
%
% smooth_WM_GM_separately(functional_dir, segmentation_dir, output_dir, gaussian_FWHM, GM_filename_prefix, WM_filename_prefix)
%
% input:
% functional_dir - directory with functional files (preferably after slice-timing correction, motion correction, covariates regression, filtering)
% segmentation_dir - directory with segmentation results (grey-matter, white-matter)
% output_dir - directory to put the new files in
% gaussian_FWHM - full width at half maximum of the smoothing Gaussian kernel in millimeters (e.g. 4mm, 8mm)
% GM_filename_prefix - the prefix of the grey-matter file in the segmentation directory (e.g. 'c1' for normalized grey-matter from SPM)
% WM_filename_prefix - the prefix of the white-matter file in the segmentation directory (e.g. 'c2' for normalized white-matter from SPM)
%
% Michael Peer, April 2017

if nargin < 8
    over_write = 0;
end

GM_WM_threshold = 0.5;

% Getting the filenames of the segmentation files
GM_filename = dir(fullfile(segmentation_dir,[GM_filename_prefix '*']));
WM_filename = dir(fullfile(segmentation_dir,[WM_filename_prefix '*']));
GM_filename = fullfile(segmentation_dir,GM_filename(1).name);
WM_filename = fullfile(segmentation_dir,WM_filename(1).name);

% loading a functional image for later resampling to that image's resolution
func_image_1 = dir(functional_dir);
func_image_1 = fullfile(func_image_1.folder,func_image_1.name);

func_info = niftiinfo(func_image_1);

% loading the data and reslicing the anatomical images to functional resolution
GM_image = reslice_data(GM_filename, func_image_1, 1);
WM_image = reslice_data(WM_filename, func_image_1, 1);



if over_write == 1
    WM_file = dir(fullfile(output_dir,'WM_func_data.nii'));
    if ~isempty(WM_file)
        delete(fullfile(WM_file.folder,WM_file.name))
        WM_file = [];
    end
    
else
    WM_file = dir(fullfile(output_dir,'WM_func_data.nii'));
end

if isempty(WM_file)

% Creating the output directory if not existing
if ~exist(output_dir,'dir'), mkdir(output_dir); end
 
% loading all of the functional data
func_mat = double(niftiread(func_image_1));

% saving functional images with only the WM voxels and GM voxels separately in the output directory
func_mat = reshape(func_mat,[],func_info.ImageSize(4));
GM_func_mat = func_mat;
WM_func_mat = func_mat;
clear func_mat

WM_func_mat(WM_image<GM_WM_threshold,:) = 0;         % voxel is above threshold for being white-matter 
WM_func_mat(GM_image>=GM_WM_threshold,:) = 0;        % voxel is also below threshold for being gray-matter
GM_func_mat(GM_image<GM_WM_threshold,:) = 0;         % voxel is above threshold for being grey-matter 
GM_func_mat(WM_image>=GM_WM_threshold,:) = 0;        % voxel is also below threshold for being White matter
% GM_func_mat = zeros(size(func_mat)); WM_func_mat = zeros(size(func_mat)); 
% for i=1:size(func_mat,4)    % go over all timepoints (volumes)
%     curr_volume_data = func_mat(:,:,:,i);          % choosing the current time-point (volume)
%     curr_volume_data(GM_image<GM_WM_threshold)=0;  % voxel is above threshold for being grey-matter 
%     curr_volume_data(WM_image>=GM_WM_threshold)=0; % voxel is also below threshold for being White matter
%     GM_func_mat(:,:,:,i) = curr_volume_data;       % taking only the grey-matter from the current functional image
% 
%     curr_volume_data = func_mat(:,:,:,i);          % choosing the current time-point (volume)
%     curr_volume_data(WM_image<GM_WM_threshold)=0;  % voxel is above threshold for being white-matter 
%     curr_volume_data(GM_image>=GM_WM_threshold)=0; % voxel is also below threshold for being gray-matter
%     WM_func_mat(:,:,:,i) = curr_volume_data;       % taking only the white-matter from the current functional image
%     
%     clear current_volume_data;
% end
% saving the images using DPABI's y_Write function
% niftisave(uint16(GM_func_mat),fullfile(output_dir,'GM_func_data.nii'),func_info);
% niftisave(uint16(WM_func_mat),fullfile(output_dir,'WM_func_data.nii'),func_info);
niftisave(reshape(GM_func_mat,func_info.ImageSize),fullfile(output_dir,'GM_func_data.nii'),func_info);
niftisave(reshape(WM_func_mat,func_info.ImageSize),fullfile(output_dir,'WM_func_data.nii'),func_info);

clear GM_func_mat WM_func_mat 
    
end
% applying smoothing using SPM's smooth function

if over_write == 1
    gm_smooth = dir(fullfile(output_dir,'sGM_func_data.nii'));
    if ~isempty(gm_smooth)
        delete(fullfile(gm_smooth.folder),gm_smooth.name)
        gm_smooth = [];
    end
else
    gm_smooth = dir(fullfile(output_dir,'sGM_func_data.nii'));

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
    matlabbatch{1}.spm.spatial.smooth.data = {fullfile(output_dir,'GM_func_data.nii')};   % grey matter smoothing

    spm_jobman('initcfg');

    % Suppress GUI
    spm_get_defaults('cmdline', true);
    output_gm = evalc("spm_jobman('run',matlabbatch)");
    clear matlabbatch
end

if over_write == 1
    wm_smooth = dir(fullfile(output_dir,'sWM_func_data.nii'));
    if ~isempty(wm_smooth)
        delete(fullfile(wm_smooth.folder),wm_smooth.name)
        wm_smooth = [];
    end
else
    wm_smooth = dir(fullfile(output_dir,'sWM_func_data.nii'));
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
    matlabbatch{1}.spm.spatial.smooth.data = {fullfile(output_dir,'WM_func_data.nii')};   % white matter smoothing
    spm_jobman('initcfg');

    % Suppress GUI
    spm_get_defaults('cmdline', true);
    output_wm = evalc("spm_jobman('run',matlabbatch)");

end

% loading thoe new smoothed images, combining them and saving
smoothed_GM_data = niftiread(fullfile(output_dir,'sGM_func_data.nii'));
smoothed_WM_data = niftiread(fullfile(output_dir,'sWM_func_data.nii'));
for i=1:func_info.ImageSize(4)    % go over all timepoints (volumes)
    curr_volume_data = smoothed_GM_data(:,:,:,i);
    curr_volume_data(GM_image<GM_WM_threshold)=0;
    smoothed_GM_data(:,:,:,i) = curr_volume_data;

    curr_volume_data = smoothed_WM_data(:,:,:,i);
    curr_volume_data(WM_image<GM_WM_threshold)=0;
    smoothed_WM_data(:,:,:,i) = curr_volume_data;
end
clear func_ma curr_volume_data WM_image;
final_func_matrix = smoothed_GM_data + smoothed_WM_data;    % combining the GM and WM images
niftisave(final_func_matrix,fullfile(output_dir,op_name),func_info);

% deleting the old WM/GM-only functional files
delete(fullfile(output_dir,'GM_func_data.nii')); delete(fullfile(output_dir,'WM_func_data.nii'));
delete(fullfile(output_dir,'sGM_func_data.nii')); delete(fullfile(output_dir,'sWM_func_data.nii'));


