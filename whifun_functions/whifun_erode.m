function whifun_erode(path_,num_erosions,out_pre)
now_mask_path = dir(path_);
V = spm_vol(path_);
vol = spm_read_vols(V);
eroded_vol = vol;
for i = 1:num_erosions
    eroded_vol = spm_erode(eroded_vol);
end
V.fname = [out_pre 'num_er_' num2str(num_erosions) now_mask_path.name]; % Set the output filename for the eroded volume
spm_write_vol(V, eroded_vol);