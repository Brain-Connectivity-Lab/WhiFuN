function whifun_create_vox_ts_fr(out_path)

out_path_folder = fileparts(out_path);
%% Getting the Corpus callousum signals
mkdir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K)],'CC_voxel_ts'));
cc_vox_ts_path = fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K)],'CC_voxel_ts');

disp('Getting Corpus callosum voxel timeseries')
h
new_data_mask = niftiread(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));


index=unique(new_data_mask);index(index==0)=[];

for subji = 1:length(Subj_list)      % For loop on number of participants
    now_func_path_temp = Subj_list(subji).final_func_MNI;%complete_filepath(fullfile(Subj_list(1).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name]));
    temp_info = niftiinfo(now_func_path_temp);
    cc_all_vox_ts = zeros(length(index),temp_info.ImageSize(4));
    disp('..')
    disp(['Currently Processing ' Subj_list(subji).name])

    if over_write == 1
        cc_net_file = dir(fullfile(cc_vox_ts_path,[Subj_list(subji).name '_cc_signals.mat']));
        if ~isempty(cc_net_file)
            delete(fullfile(cc_vox_ts_path,[Subj_list(subji).name '_cc_signals.mat']));
            cc_net_file = [];
        end
    else
        cc_net_file = dir(fullfile(cc_vox_ts_path,[Subj_list(subji).name '_cc_signals.mat']));


    end

    if isempty(cc_net_file)
        wm_steps = wm_steps + 1;
        d.Value = wm_steps/tot_wm_steps;
        d.Message = ['Getting Corpus callosum voxel timeseries for participant: ' Subj_list(subji).name];

        if d.CancelRequested
            disp('Preprocessing terminated by User')
            return
        end
        now_func_path = Subj_list(subji).final_func_MNI;%complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));

        [data,~]=y_Read(now_func_path);
        roi1=isnan(data);data(roi1)=0;[x,y,z,t]=size(data);
        new_data=reshape(data,x*y*z,t);

        for k=1:length(index)
            roi=new_data_mask==k;
            result = new_data(roi,:);
            cc_all_vox_ts(k,:)=result;

            clear result
        end
        Subj = Subj_list(subji);
        save(fullfile(cc_vox_ts_path,[Subj_list(subji).name '_cc_signals.mat']),'cc_all_vox_ts','Subj','-v7.3');
    else
        disp('Corpus callosum voxel timeseries file found hence skipping this step')
        wm_steps = wm_steps + 1;
    end

end


disp('Corpus callosum voxel timeseries acquired')