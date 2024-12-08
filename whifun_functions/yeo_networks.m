function idx = yeo_networks(atlas_brain_path,atlas_yeo_path)
%% Networks of Yeo
% Written by Pratik Jain
% Maps every ROI of the given atlas to one of the 7 Resting state networks
% of yeo
% Input -->   atlas_brain (Data type = Char) = Path of the brain atlas (nifti file) whose ROIs are to be
%             mapped 
%             atlas_yeo (Data type = Char)  = Path of the yeo brain atlas (nifti file) 
% Output --> idx = vector numbering every ROI to a yeo 7 network
%            if idx(i) = 1 --> ith node belongs to Visual network
%            if idx(i) = 2 --> ith node belongs to Somatomotor network
%            if idx(i) = 3 --> ith node belongs to Dorsal Attention network
%            if idx(i) = 4 --> ith node belongs to Ventral Attention network
%            if idx(i) = 5 --> ith node belongs to Limbic network
%            if idx(i) = 6 --> ith node belongs to Fronto-Parietal network
%            if idx(i) = 7 --> ith node belongs to Default Mode network
%            if idx(i) = 0 --> ith node does not belongs to any of the 7 yeo network

% Important points

% The given atlas should be a 3 dimentional nifti file with the ROIs
% numbered from 1 to n (n is the total number of ROIs) --> size of given atlas = p x q x r --> (p = number of rows of image) (q = number of columns of image) (r = number of image slices)

% The yeo atlas should be a four dimentional atlas that contains the voxel
% location of each of the seven yeo networks. size of yeo atlas --> (p x q x r x 7)

% example 
%            atlas_brain_path = 'D:\iit_mandi\Research\Anil_Sir\classify fmri\Dataset\Atlas\brainnectome\atlas246_BN_Atlas_246_2mm.nii'
%            atlas_yeo_path = 'D:\iit_mandi\Research\Anil_Sir\classify fmri\Dataset\Atlas\Yeo 7 network\yeo2011_7_liberal_combined_2mm.nii'

%% 

atlas_brain = niftiread(atlas_brain_path);
atlas_yeo = niftiread(atlas_yeo_path);


level = unique(sort(atlas_brain(:)));              % Get the numbers of ROIs in given atlas 

for r = 1:length(level)                            % loop for finding the number of voxels in each ROI 
        vox_id = find(atlas_brain==level(r));      % finds the voxels in rth ROI
        vox_count_in_reg(r) = length(vox_id);      % finds the number of voxels in rth ROI
end
disp(mean(vox_count_in_reg))

%%
clear Count
figure;

% Loop to count 
for i = 1:7
    atlas_yeo1 = atlas_yeo(:,:,:,i);                              % Considering the ith network
    atlas_br1 = zeros(size(atlas_brain));                         % Empty atlas same size   
    atlas_br1(find(atlas_yeo1)) = atlas_brain(find(atlas_yeo1));  % Get all the ROIs of given atlas belonging to ith yeo network
    h = histogram(atlas_br1,0:length(level));                     % tells us the number of voxels of each ROI present in the ith network
    Count(:,i) = (h.Values)./vox_count_in_reg*100;                % Tells us the percentage of voxels belonging to the ith netowork
end
close
Count = Count(2:end,:);                                           % As 1st row is empty
[maxC,idx] = max(Count,[],2);                                     % Assign the ROI to the network having maximum percentage

for i = 1:length(maxC)                                            % If the percentage is less than 10 dont assign to any of the yeo network .
    if maxC(i) <= 10                                              % As this means 90 percent of voxels are not belonging to any of the yeo network.
        idx(i) = 0;
    end
end
