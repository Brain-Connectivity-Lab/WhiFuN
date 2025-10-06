function [mask_analysis_folder_path,mask_subj_ts_folder,mask_name] = whifun_get_ts_from_mask(out_analysis_path,mask_path,Subj_list,resample_mask,over_write,d_flag,d,steps_,tot_steps)

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