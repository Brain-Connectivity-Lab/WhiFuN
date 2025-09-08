function Subj_list_1 = whifun_preproc(quality_control_path,Subj_list_1,preproc_code_path,over_write,...    General Inputs 
                                        Cut_pre,n_vol_dis,...                              Discard Volumes
                                        Realign_pre,...                                    Realignment
                                        max_fd,mean_fd,greater_than_20,...                 Framewise Displacement
                                        skull_pre,...                                      Skull stripping
                                        Reg_,CSF_thres,...                                 CSF MASK func
                                        pca_for_temp_reg,n_pca,...                         CSF Timeseries extraction
                                        Reg_pre,motion_reg,...                             Nuisance Regression
                                        filter_check,f_pre,filter_lp,filter_hp,...         Filtering
                                        Smooth_,Smooth_pre,WM_GM,smooth_fwhm,...           Smoothing
                                        dartel_,Norm_pre,vox...                            Normalization
                                        )

% WHIFUN_PREPROC Orchestrates a comprehensive fMRI preprocessing pipeline.
%
%   Subj_list_1 = WHIFUN_PREPROC(...) is a master function that executes a
%   sequence of fMRI preprocessing steps on a single subject. This includes
%   unzipping, volume discarding, realignment, quality control, segmentation,
%   skull stripping, coregistration, nuisance regression, filtering, smoothing,
%   and normalization.
%
%   The function manages the flow of data through each step, passing the output
%   of one function as the input to the next. It incorporates checks to skip
%   steps that have already been completed, based on the `over_write` flag.
%   Crucially, it includes robust error handling: if any step fails, the
%   function catches the error, logs it to a file, and stops the processing
%   for that subject.
%
%   Input Arguments:
%   quality_control_path - Path to the directory for quality control and logs.
%   Subj_list_1          - A single subject structure to be processed.
%   over_write           - A logical value to force overwriting of existing files.
%   Cut_pre              - Prefix for discarded volumes file.
%   n_vol_dis            - Number of initial volumes to discard.
%   Realign_pre          - Prefix for realigned file.
%   max_fd               - Maximum framewise displacement threshold.
%   mean_fd              - Mean framewise displacement threshold.
%   greater_than_20      - FD threshold for percentage of excluded volumes.
%   skull_pre            - Prefix for skull-stripped file.
%   Reg_                 - Logical flag for nuisance regression.
%   CSF_thres            - Threshold for CSF mask creation.
%   pca_for_temp_reg     - Logical flag for PCA on CSF signal.
%   n_pca                - Number of PCA components.
%   Reg_pre              - Prefix for regressed file.
%   motion_reg           - Logical flag to include motion regressors.
%   filter_check         - Logical flag for filtering.
%   f_pre                - Prefix for filtered file.
%   filter_lp            - Low-pass filter cutoff frequency.
%   filter_hp            - High-pass filter cutoff frequency.
%   Smooth_              - Logical flag for smoothing.
%   Smooth_pre           - Prefix for smoothed file.
%   WM_GM                - Logical flag for separate WM/GM smoothing.
%   smooth_fwhm          - FWHM of the smoothing kernel.
%   dartel_              - Logical flag to skip normalization (for DARTEL).
%   Norm_pre             - Prefix for normalized files.
%   vox                  - Voxel size for normalized output.
%
%   Output Arguments:
%   Subj_list_1 - The updated subject structure containing paths to all
%                 generated files and flags for errors or exclusions.
%
%   Author: Pratik Jain
%   See also FOPEN, DISP, TRY, CATCH.

[log_fileID,errmsg] = fopen(fullfile(quality_control_path,'logs',[Subj_list_1.name '_log_info.txt']),'a');

if log_fileID == -1
    error(errmsg)
end

disp(' ')
disp(['Currently Processing ' Subj_list_1.name])

%%     1     Unzipping

now_func_path = dir(fullfile(Subj_list_1.func_folder,Subj_list_1.func_name)) ;
[Subj_list_1,out_func_path] = whifun_gunzip_preproc(now_func_path,Subj_list_1,'functional');

now_anat_path = dir(fullfile(Subj_list_1.anat_folder,Subj_list_1.anat_name)) ;
[Subj_list_1,out_anat_path] = whifun_gunzip_preproc(now_anat_path,Subj_list_1,'anatomical');


%% 3  Discarding intial volumes

in_func_path = out_func_path;
now_func_path = dir(in_func_path);
out_func_path = fullfile(now_func_path.folder,[Cut_pre,now_func_path.name]);
Subj_list_1 = whifun_discard_initial_volume_preproc(quality_control_path,Subj_list_1,in_func_path,out_func_path,n_vol_dis,over_write);

%%     4     Realignment

in_func_path = out_func_path;

[Subj_list_1,out_func_path,out_motion_txt_path] = whifun_realignment_preproc(quality_control_path,Subj_list_1,in_func_path,Realign_pre,log_fileID, over_write);
if Subj_list_1.error
    return
end

%% 5 Framewise displacement
in_motion_txt_path = out_motion_txt_path;
Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,in_motion_txt_path,max_fd,mean_fd,greater_than_20);
if Subj_list_1.motion_ex
    return
end
%                 disp('___________________________________________________________________________________________')
%%     6     Segmentation
in_anat_path = out_anat_path;

[Subj_list_1,out_def_path,GM_native_space_path,WM_native_space_path,CSF_native_space_path] = whifun_segment_preproc(quality_control_path,Subj_list_1,in_anat_path,log_fileID,over_write);
if Subj_list_1.error
    return
end

%%     7     Skull Stripping

[Subj_list_1,out_anat_path,out_anat_mask_native_space_path,out_wanat_mask_MNI_path] = whifun_skull_strip_and_anat_mask_preproc(quality_control_path,Subj_list_1,in_anat_path,skull_pre,log_fileID,over_write);
if Subj_list_1.error
    return
end


%% 8 COREGISTRATION REST
% Coregister anatomical image to the functional image
in_func_path_bef = in_func_path;                           % Input to realignment
in_func_path_after = out_func_path;                        % Output to realignment (That has to be co-registered)
in_anat_path = out_anat_path;
Subj_list_1  = whifun_coreg_preproc(quality_control_path,Subj_list_1,in_func_path_bef,in_func_path_after,in_anat_path,log_fileID,over_write);
if Subj_list_1.error
    return
end

%%     9     Making CSF_MASK for REST And 10 Extracting CSF time-series
if Reg_ == 1
    in_csf_tpm_path = CSF_native_space_path;
    in_func_path = out_func_path;
    [Subj_list_1,out_csf_mask_func_path] = whifun_csf_mask_extraction_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_tpm_path,CSF_thres,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
else
    disp('Since No Regression is Specified, CSF Mask will not be created')
end

if Reg_ == 1
    in_csf_mask_func_path = out_csf_mask_func_path;
    [Subj_list_1,out_csf_mat_path] = whifun_extract_csf_ts_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_mask_func_path,pca_for_temp_reg,n_pca,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
    %%               Nuisance REGRESSION
    in_anat_mask_native_space_path = out_anat_mask_native_space_path;
    in_csf_mat_path = out_csf_mat_path;
    in_motion_txt_path = out_motion_txt_path;
    [Subj_list_1,out_func_path,out_func_mask_path] = whifun_nuisance_regress_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_mask_native_space_path,motion_reg,Reg_pre,n_pca,in_csf_mat_path,in_motion_txt_path,log_fileID,over_write);

    if Subj_list_1.error
        return
    end

else
    disp('Nuisance Regression Skipped')
    if filter_check
        in_func_path = out_func_path;
        in_anat_mask_native_space_path = out_anat_mask_native_space_path;
        now_func_path = dir(in_func_path);
        if ~exist(fullfile(now_func_path.folder,['func_mask_' now_func_path.name]),'file') || over_write == 1
            [~,out_func_mask_path] = whifun_create_rest_mask(in_func_path,in_anat_mask_native_space_path);
            Subj_list_1.func_mask_native = out_func_mask_path;
        end
    end
end
%                  disp('___________________________________________________________________________________________')
%%     12     Filtering
if filter_check
    in_func_mask_path = out_func_mask_path;
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_filter_preproc(quality_control_path,Subj_list_1,in_func_path,in_func_mask_path,filter_lp,filter_hp,f_pre,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
end

%%    13     Smoothing

if Smooth_ == 1
    in_func_path = out_func_path;
    [Subj_list_1,out_func_path] = whifun_smooth_preproc(quality_control_path,Subj_list_1,in_func_path,GM_native_space_path,WM_native_space_path,WM_GM,smooth_fwhm,Smooth_pre,log_fileID,over_write);
    if Subj_list_1.error
        return
    end
else
    disp('No smoothing is selected hence skipping this step')
end
disp(['Smoothing is done for ' Subj_list_1.name])

if ~dartel_
    %%    14     Normalization
    in_func_path = out_func_path;
    in_def_path = out_def_path;
    in_wanat_mask_MNI_path = out_wanat_mask_MNI_path;
    [Subj_list_1,out_func_path] = whifun_normalise_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_path,in_def_path,vox,Norm_pre,in_wanat_mask_MNI_path,log_fileID,over_write);
    if Subj_list_1.error
        return
    end

    Subj_list_1.final_func_MNI = out_func_path;
    Subj_list_1.MNI_template = fullfile(preproc_code_path,'Templates','MNI152_T1_2mm_brain.nii');
end
fclose(log_fileID);