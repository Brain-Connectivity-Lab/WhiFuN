function fc_imshow(map,sort_idx_val,net_names)
%FC_IMSHOW Displays a functional connectivity (FC) matrix with network boundaries and labels.
%
%   FC_IMSHOW(MAP, SORT_IDX_VAL, NET_NAMES)
%
%   This function visualizes a functional connectivity matrix, typically one
%   that has been reordered based on network assignments, and overlays black
%   lines to demarcate the boundaries between the identified networks. It
%   also labels the axes with the network names or indices.
%
%   Input Arguments:
%   MAP          - The functional connectivity matrix (N x N) to display.
%                  Should be symmetric and ideally sorted by network assignment.
%   SORT_IDX_VAL - A vector (N x 1) containing the network index for each
%                  ROI/voxel in the MAP matrix. The map is assumed to be
%                  sorted such that all elements belonging to network 1 are
%                  first, then network 2, and so on.
%   NET_NAMES    - (Optional) A cell array of strings or a numeric vector
%                  containing the names/labels for each network. If omitted
%                  or only two arguments are provided, network indices (1, 2, 3...)
%                  will be used as labels.
%
%   Usage:
%   1. Display the matrix using imagesc (scales colors automatically).
%   2. Overlay black lines to highlight the boundaries between networks
%      based on changes in the SORT_IDX_VAL vector.
%   3. Center the tick marks and apply network labels on both axes.
%
%   Example:
%      % Assume 'FC_matrix' is 100x100 and 'network_labels' is 100x1
%      % and the matrix is already sorted.
%      % net_names = {'Net A', 'Net B', 'Net C'};
%      % fc_imshow(FC_matrix, network_labels, net_names)
%
%   Author: Pratik Jain

imagesc(map);axis image
hold on
% idx_diff = diff(sort_idx_val);
loc = find(diff(sort_idx_val))+0.5;
loc_cen = zeros(1,length(loc)+1);
for i = 1:length(loc)
    line([0,length(sort_idx_val)],[loc(i),loc(i)],'color',[0,0,0])
    line([loc(i),loc(i)],[0,length(sort_idx_val)],'color',[0,0,0])
    if i == 1
        loc_cen(i) = ((0+loc(i))/2);        
    else
        loc_cen(i) = ((loc(i-1)+loc(i))/2);
    end
end
loc_cen(length(loc)+1) = floor(loc(i)+length(sort_idx_val))/2;
if nargin == 2
    net_names = 1:length(loc_cen);
end
set(gca,'xtick',loc_cen,'xticklabel',net_names)
set(gca,'ytick',loc_cen,'yticklabel',net_names)
colorbar
end