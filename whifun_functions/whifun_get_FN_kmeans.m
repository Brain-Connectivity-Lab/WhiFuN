function whifun_get_FN_kmeans(out_path,K,header_file,WMmask_path,over_write,d_flag,d,steps_,tot_steps)
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end

WMmask = niftiread(WMmask_path);

for k=K
    disp(['Creating WM networks using ' 'K = ' num2str(k)]);
    wm_steps = wm_steps + 1;
    d.Value = wm_steps/tot_wm_steps;
    d.Message = ['Creating clusters with K = ' num2str(K)];

    if d.CancelRequested
        disp('Creation of WM-FN terminated by User')
        return
    end
    IDX_allsubjs = kmeans(data_for_clustering_allsubjs, k,'distance','correlation','replicates',10);            % K-means clustering
    clustering_results_allsubjs = zeros(size(WMmask)); clustering_results_allsubjs(WM_voxels) = IDX_allsubjs;   % putting the clustering results in an image
    niftisave(clustering_results_allsubjs,out_path,niftiinfo(header_file),0,1)
    save_mat_to_nifti(func_img1_filename,clustering_results_allsubjs,fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(k) '.nii']));    % saving the results to file %% set output path
    clear clustering_results_allsubjs;
end