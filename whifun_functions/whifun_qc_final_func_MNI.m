function whifun_qc_final_func_MNI(out_folder,final_func_MNI,GM_MNI,WM_MNI,CSF_MNI,template_path,motion_txt,name,slover_slices_mni,slover_contour_range_mni,slover_view,over_write)

[~,func_name,~]= fileparts(final_func_MNI);
[~,template_name,~]= fileparts(template_path);
out_image_ortho_path = fullfile(out_folder,'MNI_Space','Orthoslice_View',[name '_func_image' '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_ortho_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_orthoslice([final_func_MNI ',1'],template_path, out_image_ortho_path);
end

out_image_slover_path = fullfile(out_folder,'MNI_Space',[slover_view '_Slice_View'],[name '_underlay-' func_name '_overlay-contour-' template_name '.png']);
norm_qc_dir = whifun_create_file(over_write,out_image_slover_path);

if isempty(norm_qc_dir)
    whifun_qc_coreg_slover(template_path, [final_func_MNI,',1'], out_image_slover_path, slover_slices_mni, slover_contour_range_mni, slover_view)
end

if ~isempty(motion_txt)
    out_image_path_vox_ts = fullfile(out_folder,'MNI_Space','Vox_ts',[name '.png']);
    [out_folder1,~,~] = fileparts(out_image_path_vox_ts);
    if ~exist(out_folder1, 'dir')
        mkdir(out_folder1);
    end
    out_mask_path = fullfile(out_folder,'MNI_Space','Masks_for_Vox_ts');

    norm_file = whifun_create_file(over_write,out_image_path_vox_ts);

    if isempty(norm_file)
        % Quality Control
        % Plot the mean time series after Normalization

        f = figure('visible','off');
        GM_mask_path = GM_MNI;
        WM_mask_path = WM_MNI;
        CSF_mask_path = CSF_MNI;

        num_erosions = 4;
        Par_name = name;
        whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,final_func_MNI,motion_txt,num_erosions,Par_name,over_write,f)
        exportgraphics(f,out_image_path_vox_ts)

        clf(f)
        now_mask_path = dir(WM_mask_path);
        deep_WM_mask_path = fullfile(now_mask_path.folder,['deep_' 'num_er-' num2str(num_erosions) '_' now_mask_path.name]);
        whifun_ts_mask_qc(out_mask_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,final_func_MNI,name,slover_slices_mni,slover_contour_range_mni,slover_view)
    end
end


