function [dice,IOU,vox_num_1,vox_num_2] = dice_iou(kmeans_net_1_path,kmeans_net_2_path,align_net,fig_dice)
%DICE_IOU Computes the Dice Similarity Coefficient and Intersection of Union (IoU)
%   between two functional network (FN) atlas NIfTI files. It can optionally
%   align the second network to the first and generate a visualization of the similarity matrix.
%
%   [DICE, IOU, VOX_NUM_1, VOX_NUM_2] = DICE_IOU(KMEANS_NET_1_PATH, KMEANS_NET_2_PATH, ALIGN_NET, FIG_DICE)
%
%   Input Arguments:
%   KMEANS_NET_1_PATH - Full path to the first FN NIfTI file, or the N-dimensional array itself.
%   KMEANS_NET_2_PATH - Full path to the second FN NIfTI file, or the N-dimensional array itself.
%   ALIGN_NET         - (Optional, default 0) Flag to align net_2 to net_1:
%                       ALIGN_NET = 1: Relabels net_2 based on the maximum Dice match
%                                      to net_1 and saves the aligned network.
%                       ALIGN_NET = 0: No alignment.
%   FIG_DICE          - (Optional, default 0) Flag to visualize the Dice matrix:
%                       FIG_DICE = 1: Displays a heatmap of the Dice matrix.
%                       FIG_DICE = 0: No plot generated.
%
%   Output Arguments:
%   DICE              - A matrix where DICE(i, j) is the Dice coefficient between
%                       network 'i' from the first map and network 'j' from the second map.
%   IOU               - A matrix where IOU(i, j) is the Jaccard Index (IoU) between
%                       network 'i' from the first map and network 'j' from the second map.
%   VOX_NUM_1         - A vector of voxel counts for each network in the first map.
%   VOX_NUM_2         - A vector of voxel counts for each network in the second map.
%
%   Dependencies: 'niftiread', 'niftiinfo', 'niftisave', and 'whifun_convert_3d_to_4d_atlas' (assumed).
%
%   Author: Pratik Jain

if nargin == 2
    align_net = 0;
    fig_dice = 0;
end

if nargin == 3
    fig_dice = 0;
end

if ~isnumeric(kmeans_net_1_path)
    net_1 = niftiread(kmeans_net_1_path);
else
    net_1 = kmeans_net_1_path;
end
if ~isnumeric(kmeans_net_2_path)
    net_2 = niftiread(kmeans_net_2_path);
else
    net_2 = kmeans_net_2_path;
end
level_net_1 = double(unique(net_1));
level_net_2 = double(unique(net_2));

level_net_1(level_net_1 == 0) = [];
level_net_2(level_net_2 == 0) = [];

num_net_1 = length(level_net_1);
num_net_2 = length(level_net_2);

vox_num_1 = length(level_net_1);
vox_num_2 = length(level_net_2);

dice = zeros(num_net_1,num_net_2);
IOU = zeros(num_net_1,num_net_2);
for i = level_net_1'
    net_1_roi = find(net_1 == i);
    vox_num_1(i) = length(net_1_roi);

    for j = level_net_2'

        net_2_roi = find(net_2 == j);
        vox_num_2(j) = length(net_2_roi);
        net_1_inter_net_2 = intersect(net_1_roi,net_2_roi);
        net_1_union_net_2 = union(net_1_roi,net_2_roi);

        dice(i,j) = 2*length(net_1_inter_net_2) ./ (length(net_1_roi) + length(net_2_roi));


        IOU(i,j) = length(net_1_inter_net_2) ./ length(net_1_union_net_2);
    end

end

net_2_aligned = zeros(size(net_2));
if align_net == 1
    disp('Aligning the 2nd Network based on the first network')

    [max_dice,max_dice_idx] = max(dice);

    for i = 1:length(max_dice_idx)
        net_2_aligned(net_2 == i) = max_dice_idx(i);
    end
    info = niftiinfo(kmeans_net_2_path);

    level_net_out = double(unique(net_2_aligned));
    level_net_out(level_net_out == 0) = [];

    if length(level_net_out) ~= length(level_net_2)
        disp('Two or more networks have combined, thus forming less number of networks in the output')
    end
    [folder,file,ext] = fileparts(kmeans_net_2_path);
    niftisave(net_2_aligned,fullfile(folder,[file '_aligned' ext]),info)
    whifun_convert_3d_to_4d_atlas(fullfile(folder,[file '_aligned' ext]));
    disp(['Network at ' kmeans_net_2_path ' aligned to network at ' kmeans_net_1_path])
    disp(['Average Dice coeficient between the two networks is ' num2str(mean(max_dice))])


end

if fig_dice == 1
    figure;
    if align_net == 1
        subplot(1,2,1)
        heatmap(round(dice,2)); colorbar;clim([0 1]);title('Before alignment');colormap('parula')

        dice = zeros(num_net_1,num_net_2);
        IOU = zeros(num_net_1,num_net_2);
        for i = level_net_1'
            for j = level_net_2'
                net_1_roi = find(net_1 == i);
                net_2_roi = find(net_2_aligned == j);

                net_1_inter_net_2 = intersect(net_1_roi,net_2_roi);
                net_1_union_net_2 = union(net_1_roi,net_2_roi);

                dice(i,j) = 2*length(net_1_inter_net_2) ./ (length(net_1_roi) + length(net_2_roi));

                IOU(i,j) = length(net_1_inter_net_2) ./ length(net_1_union_net_2);

            end
        end
        subplot(1,2,2)
        heatmap(round(dice,2)); colorbar;clim([0 1]);title('After alignment');colormap('parula')
    else
        heatmap(round(dice,2)); colorbar;clim([0 1]);colormap('parula')
    end
end