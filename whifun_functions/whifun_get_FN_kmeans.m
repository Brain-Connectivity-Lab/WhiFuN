function whifun_get_FN_kmeans(out_path,K,avg_vox_level_FC,WMmask_path,d_flag,d,steps_,tot_steps)
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end

WMmask = niftiread(WMmask_path);
 WM_voxels = WMmask>0.5;
header_file = niftiinfo(WMmask_path);
for k=K
    disp(['Creating WM networks using ' 'K = ' num2str(k)]);

    if d_flag
        steps_ = steps_ + 1;
        d.Value = steps_/tot_steps;
        d.Message = ['Creating clusters with K = ' num2str(K)];

        if d.CancelRequested
            disp('Creation of WM-FN terminated by User')
            return
        end
    end
    IDX_allsubjs = kmeans(avg_vox_level_FC, k,'distance','correlation','replicates',10);            % K-means clustering
    clustering_results_allsubjs = zeros(size(WMmask)); clustering_results_allsubjs(WM_voxels) = IDX_allsubjs;   % putting the clustering results in an image
    niftisave(clustering_results_allsubjs,out_path,header_file,0,1)
    clear clustering_results_allsubjs;
end