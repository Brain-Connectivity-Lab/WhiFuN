function [mask_analysis_folder_path,mask_subj_ts_folder,mask_name] = whifun_get_ts_from_mask(out_analysis_path,mask_path,Subj_list,resample_mask,over_write,d_flag,d,steps_,tot_steps)
%WHIFUN_GET_TS_FROM_MASK Extracts time series data for each subject from voxels
%   defined by a specified NIfTI mask file.
%
%   [MASK_ANALYSIS_FOLDER_PATH, MASK_SUBJ_TS_FOLDER, MASK_NAME] = WHIFUN_GET_TS_FROM_MASK(OUT_ANALYSIS_PATH, MASK_PATH, SUBJ_LIST, RESAMPLE_MASK, OVER_WRITE, ...)
%
%   This function prepares an analysis folder structure, optionally resamples
%   the input mask, and then iterates through all subjects to extract the
%   functional time series for the voxels defined by the mask.
%
%   Input Arguments:
%   OUT_ANALYSIS_PATH   - The root directory where all analysis results for the
%                         entire study will be stored.
%   MASK_PATH           - Full path to the NIfTI file used as the mask (e.g., an ROI or atlas).
%   SUBJ_LIST           - Structure array containing subject information,
%                         including the path to the final preprocessed functional data
%                         (SUBJ_LIST(i).final_func_MNI).
%   RESAMPLE_MASK       - (Optional, default 1) Flag to resample the mask:
%                         RESAMPLE_MASK = 1: Resamples the mask to the functional resolution of the first subject.
%                         RESAMPLE_MASK = 0: Copies the mask without resampling.
%   OVER_WRITE          - (Optional, default 0) Flag: 1 to overwrite existing subject time series files.
%   D_FLAG, D, STEPS_, TOT_STEPS - (Optional) Parameters for progress dialogue box (GUI support).
%
%   Output Arguments:
%   MASK_ANALYSIS_FOLDER_PATH - Full path to the copied/resampled mask file in the analysis folder.
%   MASK_SUBJ_TS_FOLDER       - Full path to the directory where subject time series files are saved.
%   MASK_NAME                 - The clean name of the mask file (without extension).
%
%   Dependencies: 'whifun_niftiread', 'whifun_create_file', 'reslice_data', 'y_Read' (assumed external function).
%
%   Author: Pratik Jain

if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end

if ~exist("resample_mask","var")
    resample_mask = 1; % Default value for resample_mask if not provided
end

if ~exist("over_write","var")
    over_write = 0;
end


[~,mask_name,ext_1] = fileparts(mask_path);
[~,mask_name,ext_2] = fileparts(mask_name);

out_folder = fullfile(out_analysis_path,mask_name);
if ~exist(out_folder,"dir")
    mkdir(out_folder);
end

mask_analysis_folder_path = fullfile(out_folder,[mask_name,ext_2,ext_1]);

if resample_mask
    reslice_data(mask_path,Subj_list(1).final_func_MNI,0,1,mask_analysis_folder_path,1);
else
    copyfile(mask_path,mask_analysis_folder_path);
end




mask_subj_ts_folder = fullfile(out_folder,['Participant_ts_from_' mask_name]);

if ~exist(mask_subj_ts_folder,"dir")
    mkdir(mask_subj_ts_folder);
end

mask_ = whifun_niftiread(mask_analysis_folder_path);
idx = mask_~=0;

for subji = 1:length(Subj_list)

    
    cc_signals_mat_path = fullfile(mask_subj_ts_folder,[Subj_list(subji).name '_' mask_name '_ts' '.mat']);
    cc_signals_file = whifun_create_file(over_write,cc_signals_mat_path);

    if isempty(cc_signals_file)
        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Getting voxel timeseries from ' mask_name ' for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Preprocessing terminated by User')
                return
            end
        end
        func_path = Subj_list(subji).final_func_MNI;
        [func_image,~]=y_Read(func_path);
        roi1=isnan(func_image);func_image(roi1)=0;[x,y,z,t]=size(func_image);
        func_image=reshape(func_image,x*y*z,t);
        vox_ts_from_mask = func_image(idx,:);
        Subj = Subj_list(subji);
        % Save the time series data extracted from the mask
        save(cc_signals_mat_path, 'vox_ts_from_mask','Subj','-v7.3');
    else
        disp([ mask_name 'timeseries file found for Participant: ' Subj_list(subji).name ' hence skipping this step'])
        steps_ = steps_ + 1;
    end


end