function fc_imshow(map,sort_idx_val,net_names)


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