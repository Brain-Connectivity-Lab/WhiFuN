function pcor_ts_path = whifun_partial_corr(WM_or_GM,mask_subj_ts_folder,avg_ts_path,fr_mask_path,Subj_list,K,over_write,d_flag,d,steps,tot_steps)
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps = 0;
    tot_steps = 0;
end
if ~exist("over_write","var")
    over_write = 0;
end


[~,fr_mask_name,~] = fileparts(fr_mask_path);
[~,fr_mask_name,~] = fileparts(fr_mask_name);

disp(['Partial correlation between the ' fr_mask_name ' Voxels timeseries and ' WM_or_GM ' Network Average timseries'])
pcor_ts_path = fullfile(fileparts(mask_subj_ts_folder),[fr_mask_name '_FN_from_' WM_or_GM '_K' num2str(K)],[fr_mask_name '_par_cor_WM']);
if ~exist(pcor_ts_path,'dir')
    mkdir(pcor_ts_path)
end

parcorr_result = zeros(nnz(niftiread(fr_mask_path)),K);
for subji = 1:length(Subj_list)      % For loop on number of participants
    par_corr_mat_path = fullfile(pcor_ts_path,[Subj_list(subji).name '_parcorr_result_K',num2str(K),'.mat']);
    par_corr_mat_file = whifun_create_file(over_write,par_corr_mat_path);

    if isempty(par_corr_mat_file)
        load(fullfile(mask_subj_ts_folder,[Subj_list(subji).name '_' fr_mask_name '_ts' '.mat']),'vox_ts_from_mask')
        load(fullfile(avg_ts_path, [Subj_list(subji).name '_' WM_or_GM '_FN_K' num2str(K) '.mat']),'avg_ts');
        
        if d_flag
            steps = steps + 1;
            d.Value = steps/tot_steps;
            d.Message = ['Computing Partial Correlations between ' fr_mask_name ' Voxels and ' WM_or_GM '-FNs'];

            if d.CancelRequested
                disp('Preprocessing terminated by User')
                return
            end
        end
        for j=1:size(avg_ts,2)  %%% the number of white-matter functional networks
            disp(['Computing Partial Correlation between ' WM_or_GM '-FN ' num2str(j) ' and ' fr_mask_name ' voxels for ' Subj_list(subji).name])
            net=(avg_ts(:,j));
            reg=avg_ts;reg(:,j)=[];
            for k=1:size(vox_ts_from_mask,1)  %%% the number of callosal voxels
                y_voxel=(vox_ts_from_mask(k,:))';
                [Rho,~]=partialcorr(y_voxel,net,reg);
                Rho=0.5*(log((1+Rho)/(1-Rho)));

                parcorr_result(k,j)=Rho;

            end

        end
        roi=isnan(parcorr_result);
        parcorr_result(roi)=0;
        Subj = Subj_list(subji);
        save(par_corr_mat_path,'parcorr_result','Subj','-v7.3'); %% added
        disp(['Partial correlation between the ' fr_mask_name ' Voxels timeseries and ' WM_or_GM ' FN Average timseries done for ' Subj_list(subji).name])
    else
        disp(['Partial Correlation file found for ' Subj_list(subji).name ', hence skipping this step'])
    end
end



disp('Partial Correlation computed')