function whifun_get_FN_kmeans(out_path,K,avg_vox_level_FC,WMmask_,header_file,over_write,d_flag,d,steps_,tot_steps)
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


fn_folder = fileparts(out_path);
% Ensure the output directory exists
if ~exist(fn_folder, 'dir')
    mkdir(fn_folder);
end
fn_file = whifun_create_file(over_write,out_path);

if isempty(fn_file)
    if isstring(WMmask_) || ischar(WMmask_)
        WMmask = niftiread(WMmask_);
        WM_voxels = WMmask>0.5;
        header_file = niftiinfo(WMmask_);
    elseif isnumeric(WMmask_)
        if ~exist("header_file",'var')
            error('Header file needed if WM mask matrix or indexes are given')
        end
        if length(size(WMmask_)) == 3
            WM_voxels = WMmask_>0.5;
        elseif length(size(WMmask_)) == 2 && size(WMmask_,2) == 1
            WM_voxels = WMmask_;
        end
    end


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
        clustering_results_allsubjs = zeros(header_file.ImageSize); clustering_results_allsubjs(WM_voxels) = IDX_allsubjs;   % putting the clustering results in an image
        niftisave(clustering_results_allsubjs,out_path,header_file,0,1)
        clear clustering_results_allsubjs;

    end
else
    disp(['FN already created. See : ' out_path])
end