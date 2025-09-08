function whifun_qc_csf_mask_alignment(out_folder,func_image_path,CSF_mask_func_path,name,slover_slices_ss,slover_contour_range_ss,slover_view,over_write)

[~,underlay_name,~] =  fileparts(func_image_path);
[~,overlay_contour_name,~] =  fileparts(CSF_mask_func_path);
out_image_path = fullfile(out_folder,'Native_Space','Orthoslice_View',[name '_underlay-' underlay_name '_overlay_contour-' overlay_contour_name '.png']);
out_coreg_orthoslice_path = whifun_create_file(over_write,out_image_path);
if isempty(out_coreg_orthoslice_path)
    whifun_qc_coreg_orthoslice(CSF_mask_func_path,[func_image_path ',1'],out_image_path);
end

out_image_path = fullfile(out_folder,'Native_Space',[slover_view '_Slice_View'],[name '_underlay-' underlay_name '_overlay_contour-' overlay_contour_name '.png']);
out_coreg_slover_path = whifun_create_file(over_write,out_image_path);
if isempty(out_coreg_slover_path)
    whifun_qc_coreg_slover(CSF_mask_func_path,[func_image_path ',1'],out_image_path,slover_slices_ss,slover_contour_range_ss,slover_view);
end
disp(['CSF_mask check qc done for ' name])
