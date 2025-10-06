function K = whifun_get_best_k(out_path,avg_vox_level_FC,K_range_l,K_range_h,CV_folds,num_replicates,size_chunk,d_flag,d,steps_,tot_steps)
%% Selecting the best K on the group-level data, by measuring stability of clustering solutions

% Here we separate the correlation matrix columns into 4 groups
% (cross-validation folds), therefore selecting a subset of the features.
% We perform the clustering on each fold, and then measure the similarity
% between clustering solutions for all pairs of folds. This is repeated for
% each K (number of clusters). A "good" K will give the same clustering
% solution even when using different features, and will therefore have more
% similarity (stability) between folds (Lange et al., Neural Comput 2004).
%
% For a MxN connectivity matrix, we'll get four Mx(N/4) matrices, and check
% the correspondence of their clustering solutions to one another.
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end
[out_fold,out_name,~] = fileparts(out_path);
if K_range_l ~= K_range_h           % If the lower and upper values of Grid search for K are the same, that means the grid search is not necessary skip it and directly calculate the networks
    disp('Doing a grid search to find optimal K-value ')
    disp([num2str(CV_folds) ' Fold Cross validation in process to find out the optimal value of K'])
    % separating the data into subsets of features
    num_CV_folds = CV_folds;
    % num_replicates = 10;
    IDX_folds_new = cell(1,num_CV_folds);
    Dice_coefficient_folds_all = zeros(1,K_range_h - K_range_l + 1);
    elb = zeros(1,K_range_h - K_range_l + 1);

    for K= K_range_l:K_range_h          % going over all possible numbers of clusters, to measure each one's stability
        disp(['Currently making clusters with K = ' num2str(K)]);

        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Creating clusters with K = ' num2str(K)];

            if d.CancelRequested
                disp('Creation of WM-FN terminated by User')
                return
            end
        end
        IDX_folds = zeros(size(avg_vox_level_FC,1),num_CV_folds); IDX_folds_new{K} = zeros(size(IDX_folds));
        size_fold = size(avg_vox_level_FC,2)/num_CV_folds;
        sumD = zeros(K,num_CV_folds);
        for c=1:num_CV_folds        % going over folds (sub-matrices)
            disp(['Cross validation fold ' num2str(c) ' in progress'])
            mat_corr_current = avg_vox_level_FC(:,round((c-1)*size_fold+1):round(c*size_fold));     % the sub-correlation-matrix
            [IDX_folds(:,c),~,sumD(:,c)] = kmeans(mat_corr_current, K,'distance','correlation','replicates',num_replicates);  % calculating the clustering result for this K
        end

        % computing the difference between adjacency matrices for each fold
        % size_chunk = 100;   % need to compute adjacency matrices in parts - otherwise it takes too much memory (~300 million numbers per matrix)
        num_chunks = floor(size(IDX_folds,1) / size_chunk);
        sum_diff_adjmats_folds = zeros(num_CV_folds); sum_common_connections_adjmats = zeros(num_CV_folds); sum_all_connections_adjmats = zeros(num_CV_folds);
        for ch1=1:num_chunks
            for ch2=ch1:num_chunks    % iterating over all adjacency matrix parts combinations
                current_clustering_adjmats = zeros(size_chunk,size_chunk,num_CV_folds);
                current_chunk1 = (ch1-1)*size_chunk+1 : ch1*size_chunk;
                current_chunk2 = (ch2-1)*size_chunk+1 : ch2*size_chunk;

                % creating the current adjacency matrix part, for all folds
                for c=1:num_CV_folds
                    for i=1:size_chunk
                        if ch1 == ch2
                            j_points = i:size_chunk;
                        else
                            j_points = 1:size_chunk;
                        end
                        for j=j_points
                            % In the adjacency matrix, cell (i,j) equals 1 if voxels (i,j) belong to the same cluster and 0 otherwise
                            % This allows comparison of clustering results even if the labels of the same clusters in each result are different
                            % (e.g. if the occipital cluster in solution 1 is labeled as cluster number 4, and in solution 2 it's labeled as cluster 7)
                            if IDX_folds(current_chunk1(i),c)==IDX_folds(current_chunk2(j),c)

                                current_clustering_adjmats(i,j,c)=1;
                                if ch1 == ch2
                                    current_clustering_adjmats(j,i,c)=1;
                                end
                            end
                        end
                    end
                end
                %%
                % Computing the difference between adjacency matrix for different folds, and adding this difference to the sum matrix
                for c1=1:num_CV_folds
                    for c2=c1+1:num_CV_folds
                        sum_diff_adjmats_folds(c1,c2) = sum_diff_adjmats_folds(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1)~=current_clustering_adjmats(:,:,c2))));
                        sum_common_connections_adjmats(c1,c2) = sum_common_connections_adjmats(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1) & current_clustering_adjmats(:,:,c2))));
                        sum_all_connections_adjmats(c1,c2) = sum_all_connections_adjmats(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1) + current_clustering_adjmats(:,:,c2))));
                        sum_diff_adjmats_folds(c2,c1) = sum_diff_adjmats_folds(c1,c2);
                        sum_common_connections_adjmats(c2,c1) = sum_common_connections_adjmats(c1,c2);
                        sum_all_connections_adjmats(c2,c1) = sum_all_connections_adjmats(c1,c2);
                    end
                end
            end
        end

        % Calculating the average difference between adjacency matrices (across all folds pairs)
        %                 sum_diff_adjmats_folds_all(K) = mean(sum_diff_adjmats_folds(~eye(num_CV_folds)));   % sum of all differences
        elb(K) = mean(mean(sumD));
        Dice_coefficient = sum_common_connections_adjmats * 2 ./ sum_all_connections_adjmats;
        Dice_coefficient_folds_all(K) = mean(Dice_coefficient(~eye(num_CV_folds)));    % Dice's coef is 1 for perfect match, 0 for no commonalities
    end

    whifun_plot_dice_coef_and_elb(Dice_coefficient_folds_all,elb,K_range_l,K_range_h)
    exportgraphics(gcf,out_path)
    K = str2double(cell2mat(inputdlg('Choose the K-value','K-Value')));
    save(fullfile(out_fold,[out_name , '.mat']),"Dice_coefficient_folds_all","elb","K_range_l","K_range_h")
    if ~isnumeric(K)
        if K < 1
            error('Invalid Value of K')
        end
    end
    close gcf
else
    K = K_range_l;  % Assign K as the lower K value (doesnt matter as the lower and upper K values are the same)
end