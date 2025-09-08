function whifun_qc_global_ts(out_folder,initial_func,final_func_MNI,motion_txt,func_mask_MNI,name,Reg_,over_write,csf_covariate_path,n_pca,pca_for_temp_reg)
if ~Reg_
    csf_covariate_path = [];
    n_pca = [];
    pca_for_temp_reg = [];
end

% initial_vol_data = 1;
% final_func_MNI = 1;
% motion_txt = 1;
% func_mask_MNI = 1;
% csf_covariate_path = 1;

out_image_path = fullfile(out_folder,[name '.png']);
if ~exist("out_folder",'dir')
    mkdir(out_folder);
end
tqc_dir = whifun_create_file(over_write,out_image_path);

if isempty(tqc_dir)

    whifun_ts_check(initial_func,final_func_MNI,motion_txt,func_mask_MNI,out_image_path,Reg_,csf_covariate_path,n_pca,pca_for_temp_reg)

end

disp(['Time-series Quality Check done for ' name])
end