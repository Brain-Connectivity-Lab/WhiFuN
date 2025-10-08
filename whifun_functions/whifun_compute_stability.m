function [avg_max_dice,diceij_all,vox_num_all] = whifun_compute_stability(net_list,net_include)
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