function whifun_create_brainnet_images(out_path,ROI_path,over_write)
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