function fn_path = whifun_create_fn_from_parrcorr_and_ttest(WM_or_GM,pcor_ts_path,mask_path,Subj_list,K,over_write,d_flag,d,wm_steps,tot_wm_steps)

if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    wm_steps = 0;
    tot_wm_steps = 0;
end


if ~exist("over_write","var")
    over_write = 0;
end


[~,mask_name,~] = fileparts(mask_path);
[~,mask_name,~] = fileparts(mask_name);
disp(['Creating ' mask_name ' Networks that have maximal partial correlation with the ' WM_or_GM ' networks'])

if d_flag
    wm_steps = wm_steps + 1;
    d.Value = wm_steps/tot_wm_steps;
    d.Message = ['Creating ' mask_name ' FN that have maximal partial correclation with the ' WM_or_GM ' networks'];

    if d.CancelRequested
        disp('Preprocessing terminated by User')
        return
    end
end
fn_path = fullfile(fileparts(pcor_ts_path),[mask_name '_FN_from_' WM_or_GM '_K' num2str(K) '.nii']);
            
cc_fn_file = whifun_create_file(over_write,fn_path);

if isempty(cc_fn_file)
    load(fullfile(pcor_ts_path,[Subj_list(1).name '_parcorr_result_K',num2str(K),'.mat']),'parcorr_result');
    parcorr_result_all = zeros([size(parcorr_result) length(Subj_list)]);
    for subji = 1:length(Subj_list)
        load(fullfile(pcor_ts_path,[Subj_list(subji).name '_parcorr_result_K',num2str(K),'.mat']),'parcorr_result')
        parcorr_result_all(:,:,subji) = parcorr_result;
    end
    wp = zeros(size(parcorr_result));
    for i = 1:size(parcorr_result,1)  % cc voxel
        for j = 1:size(parcorr_result,2) % wm-networks
            [~,~,~,stat] = ttest(squeeze(parcorr_result_all(i,j,:)));
            wp(i,j) = stat.tstat;
        end
    end

    [~,max_idx] = max(wp,[],2);

    [new_data_mask,head] = whifun_niftiread(mask_path);

    [x,y,z] = size(new_data_mask);
    idx = new_data_mask>0;
    ROI = zeros(x,y,z);
    ROI(idx) = max_idx;

    niftisave(ROI,fn_path,head);

else
    disp([ WM_or_GM '-' mask_name ' FN file found, hence skipping this step. '])
end
disp([mask_name ' FN from ' WM_or_GM '_FN_K' num2str(K) ' Created'])