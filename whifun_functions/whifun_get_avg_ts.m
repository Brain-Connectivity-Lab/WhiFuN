function avg_ts_path = whifun_get_avg_ts(out_folder,ROI_path,Subj_list,over_write,d_flag,d,steps_,tot_steps)
%% Obtaining averaged time series from ROI
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end
if ~exist("over_write","var")
    over_write = 0;
end

ROI = niftiread(ROI_path); 
index=unique(ROI);index(index==0)=[];

[~,ROI_name,~] = fileparts(ROI_path);
[~,ROI_name,~] = fileparts(ROI_name);

avg_ts_path = fullfile(out_folder,['Participant_' ROI_name '_avg_ts']);

if ~exist(avg_ts_path,'dir')
    mkdir(avg_ts_path);
end
avg_ts_dir = dir(avg_ts_path);

disp('##########################################################################################')
disp(['Getting average timeseries from ' ROI_name])

for subji = 1:length(Subj_list)      % For loop on number of participants
    disp(['Currently Processing ' Subj_list(subji).name])
    nt = Subj_list(subji).nt_dis;
    avg_ts = zeros(nt,numel(index));

    out_mat_path = fullfile(avg_ts_dir(1).folder, [Subj_list(subji).name '_' ROI_name '.mat']);
    wmfn_file = whifun_create_file(over_write,out_mat_path);

    if isempty(wmfn_file)

        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Obtaining averaged time series of ' ROI_name ' for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of average timeseries terminated by User')
                return
            end
        end
        func_path = Subj_list(subji).final_func_MNI;

        [data,~]=whifun_niftiread(func_path);
        roi1=isnan(data);
        data(roi1)=0;
        [x,y,z,t]=size(data);
        new_data=reshape(data,x*y*z,t);
        Subj = Subj_list(subji);
        for k=1:length(index)
            roi=ROI==k;
            result=mean(new_data(roi,:));
            avg_ts(:,k)=result;

            save(out_mat_path,'avg_ts','Subj','-v7.3');
            clear result
        end

    else
        disp(['Average time series file for ' ROI_name ' found for Subject ' Subj_list(subji).name ', hence skipping this step. '])

        if d_flag
            steps_ = steps_ + 1;
        end
    end

end


