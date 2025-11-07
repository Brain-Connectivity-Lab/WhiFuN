function REST_MASK1 = whifun_create_rest_mask(now_func_path,now_anat_path,name)

disp(['Loading rest mask for ' name]);

% Creating REST_MASK from the Anat mask
REST_MASK1= reslice_data(fullfile(now_anat_path.folder,'anat_mask.nii'),fullfile(now_func_path.folder,now_func_path.name),1,1,fullfile(now_func_path.folder,'rest_mask.nii'));
