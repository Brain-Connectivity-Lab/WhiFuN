
net_names = {'Non Yeo','Visual','Somato Motor','Dorsal Attention','Ventral Attention','Limbic Network','Fronto-Parietal','Default Mode'}; % names of the networks
atlas_path = 'C:\Users\jainp\Downloads\dififf_cobe_results\2mm_new\s400_hcp.nii';
atlas_yeo = 'C:\Users\jainp\Downloads\dififf_cobe_results\2mm_new\yeo_7_net.nii';
idx = yeo_networks(atlas_path,atlas_yeo);
[sort_idx_val,sort_idx] = sort(idx);

%% in figure

map_ = map_(sort_idx,sort_idx);
fc_imshow(map_,sort_idx_val,net_names)

