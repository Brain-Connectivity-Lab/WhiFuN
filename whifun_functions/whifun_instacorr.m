function out_map = whifun_seed_corr(func_image_path,seed,radius,mask)
    
    func_image = niftiread(func_image_path);
    [x,y,z,nt] = size(func_image);
    func_image = zscore(func_image,0,4);

    func_image_info = niftiinfo(func_image_path);

    cor_ = whifun_convert_coords(func_image_info.Transform.T, [seed(1) seed(2) seed(3)], 'mni2vox');

    matlab_cor = cor_ + 1;

    vox_size = func_image_info.PixelDimensions(1:3);

    vox_list = whifun_create_sphere(matlab_cor, radius, vox_size, [x,y,z]);

    vox_ts = whifun_extract_ts_from_vox(func_image,vox_list+1);
   
    mean_ts = mean(vox_ts,1);

    func_image = reshape(func_image,[],nt);

    dot_prod = func_image * mean_ts(:);  % nVox x 1
    
    dot_prod(~isfinite(dot_prod)) = 0;
    out_map = reshape(dot_prod,x,y,z);

    if exist("mask",'var')
        if~isnumeric(mask)
            mask = double(niftiread(mask));
        end
        out_map = out_map .* mask;  % Apply the mask to the output map
    end

end

