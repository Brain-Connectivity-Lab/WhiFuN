function [avg_max_dice,diceij_all,vox_num_all] = whifun_compute_stability(net_list,net_include)
%WHIFUN_COMPUTE_STABILITY Calculates the stability of Functional Networks (FNs)
%   using the average maximum Dice similarity coefficient across all unique
%   pairwise comparisons of network maps.
%
%   [AVG_MAX_DICE, DICEIJ_ALL, VOX_NUM_ALL] = WHIFUN_COMPUTE_STABILITY(NET_LIST, NET_INCLUDE)
%
%   This is typically used in cross-validation/bootstrapping steps of FN
%   creation (e.g., k-means clustering) to assess how consistently networks
%   are identified across different partitions of the data.
%
%   Input Arguments:
%   NET_LIST    - A structure array (e.g., from MATLAB's `dir` function)
%                 where each element points to a NIfTI file containing the
%                 labeled Functional Network map for a specific data fold.
%   NET_INCLUDE - (Optional, default []) The number of top-ranked networks
%                 to include in the calculation of the average maximum Dice
%                 coefficient.
%                 - If empty ([]), it uses the minimum number of networks
%                   between the two maps being compared (standard practice
%                   when the number of clusters K is the same, or for
%                   fair comparison when K differs slightly).
%                 - If a number (e.g., K), it uses the top K matches.
%
%   Output Arguments:
%   AVG_MAX_DICE - A vector where each element is the average maximum Dice
%                  coefficient computed for one unique pairwise comparison
%                  between the networks in NET_LIST.
%   DICEIJ_ALL   - A cell array (Upper triangular) storing the raw Dice
%                  similarity matrices for each pairwise comparison.
%                  DICEIJ_ALL{i, j} is a matrix where entry (m, n) is the
%                  Dice coefficient between network m from map i and network n from map j.
%   VOX_NUM_ALL  - A cell array storing the voxel count for each network in
%                  the maps. VOX_NUM_ALL{i} is a vector of voxel counts for
%                  the networks in map i.
%
%   Dependencies: 'dice_iou' function (a custom utility that
%                 calculates Dice/IoU similarity and returns voxel counts).
%
%   Author: Pratik Jain
if nargin <2
    net_include = [];
end
p = 1;
diceij_all = cell(length(net_list));
vox_num_all = cell(length(net_list),1);
avg_max_dice = zeros(1,1);
for i = 1:length(net_list)
    for j  = i+1:length(net_list)
        
        [diceij,~,vox_num_1,vox_num_2] = dice_iou(fullfile(net_list(i).folder,net_list(i).name),fullfile(net_list(j).folder,net_list(j).name),0,0);
        diceij_all{i,j} = diceij;
        vox_num_all{i} = vox_num_1;
        if j == length(net_list) && i == 1
            vox_num_all{j} = vox_num_2;
        end

        if isempty (net_include)
        sq = size(diceij);

        if sq(1) == sq(2)
            avg_max_dice(p) = mean(max(diceij,[],2));
        else
            min_net = min(sq);
            temp = max(diceij,[],2);
            temp_sort = sort(temp,'descend');
            avg_max_dice(p) = mean(temp_sort(1:min_net));
        end
        else
            temp = max(diceij,[],2);
            temp_sort = sort(temp,'descend');
            avg_max_dice(p) = mean(temp_sort(1:net_include));
        end
        p = p+1;
    end
end
end