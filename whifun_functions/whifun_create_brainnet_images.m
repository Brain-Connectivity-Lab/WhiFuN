function whifun_create_brainnet_images(out_path,ROI_path,over_write)
%WHIFUN_CREATE_BRAINNET_IMAGES Generates a series of PNG images for each
%   network in a labeled NIfTI volume using the BrainNet Viewer toolbox.
%
%   WHIFUN_CREATE_BRAINNET_IMAGES(OUT_PATH, ROI_PATH, OVER_WRITE)
%
%   This function iterates through all unique network labels in the input ROI
%   NIfTI file and creates a visualization of each network from multiple
%   standard viewing angles using BrainNet Viewer.
%
%   Input Arguments:
%   OUT_PATH    - The directory where the resulting PNG images will be saved.
%   ROI_PATH    - The full path to the input NIfTI file containing the labeled
%                 Functional Network (FN) map (e.g., 'WM_clustering_K10.nii').
%   OVER_WRITE  - Flag (0 or 1). If 0, image generation will be skipped if
%                 the first output file already exists.
%
%   Output:
%   A set of PNG files saved to OUT_PATH, named in the format:
%   `<ROI_name>_<Network_Label>_<View_Name>.png`
%
%   Dependencies:
%   - MATLAB's `mfilename`, `fileparts`, `addpath`.
%   - Custom functions: `whifun_niftiread`, `whifun_create_file`.
%   - External tool: `BrainNet_MapCfg_WhifuN`.
%
%   Assumptions:
%   - The BrainNet Viewer toolbox folder structure is located at:
%     `fileparts(fileparts(mfilename('fullpath'))) / BrainNetViewer_20191031`
%
%   Author: Pratik Jain

if ~exist(out_path,'dir')
    mkdir(out_path)
end
temp = mfilename("fullpath");
preproc_code_path = fileparts(fileparts(temp));
addpath(fullfile(preproc_code_path,'BrainNetViewer_20191031'))
[~,ROI_name,~] = fileparts(ROI_path);
[~,ROI_name,~] = fileparts(ROI_name);

out_file = fullfile(out_path,[ROI_name '_1_Anterior.png']);
ROI = whifun_niftiread(ROI_path);
levels = unique(ROI);
levels(levels==0) = [];
WM_brainnet_image = whifun_create_file(over_write,out_file);

%% Create brain net viwer images

if isempty(WM_brainnet_image)
    image_folder = out_path;

    % ROI_path = dir(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(K) '.nii']));

    view_angles = [ 0 , 0 ;
        90, 0 ;
        0 , 90;
        180, 0 ;
        180,-90;
        -90, 0 ;];

    view_names = {'Posterior';
        'Right'  ;
        'Dorsal'  ;
        'Anterior' ;
        'Ventral' ;
        'left'   ;};
    for i = 1:length(view_angles)
        for j = levels'
            BrainNet_MapCfg_WhifuN(fullfile(preproc_code_path,'BrainNetViewer_20191031','Data','SurfTemplate','BrainMesh_Ch2withCerebellum.nv'),...
                                            ROI_path,...
                                            fullfile(preproc_code_path,'BrainNetViewer_20191031','brainnet_parameters2.mat'),...
                                            view_angles(i,:),j,...
                                            fullfile(image_folder,[ROI_name '_' num2str(j) '_' view_names{i} '.png']));
        end
    end
end