% function [dice_hc,IOU_hc] = compare_networks(net1_filepath,net2_filepath)
%
%     net1 = niftiread(net1_filepath);
%     net2 = niftiread(net2_filepath);
%     num_net1 = length(unique(net1));
%     num_net2 = length(unique(net2));
%
%
%     for i = 1:num_net1
%     temp = zeros(size(k10));
%     temp(k10==i) = 1;
%     result(:,:,:,i) = temp;
% end
%
% end

% [dice_hc,IOU_hc] = dice_iou(kmeans_net_1_path_h_abide,kmeans_net_1_path_h,'h_abide','h_cud','Healthy controls ABIDE','Healthy controls CUD dataset');
% [dice_hc,IOU_hc] = dice_iou(net1_filepath,net2_filepath);

function [dice,IOU] = dice_iou(kmeans_net_1_path,kmeans_net_2_path,align_net,fig_dice)

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
dice = zeros(num_net_1,num_net_2);
IOU = zeros(num_net_1,num_net_2);
for i = level_net_1'
    for j = level_net_2'
        net_1_roi = find(net_1 == i);
        net_2_roi = find(net_2 == j);

        net_1_inter_net_2 = intersect(net_1_roi,net_2_roi);
        net_1_union_net_2 = union(net_1_roi,net_2_roi);

        dice(i,j) = 2*length(net_1_inter_net_2) ./ (length(net_1_roi) + length(net_2_roi));

        IOU(i,j) = length(net_1_inter_net_2) ./ length(net_1_union_net_2);

    end
end


net_2_aligned = net_2;
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