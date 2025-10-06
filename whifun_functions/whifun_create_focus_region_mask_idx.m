function whifun_create_focus_region_mask_idx(out_fr_vox_idx_file,fr_mask_filename, over_write,d_flag,d,steps_,tot_steps)

if nargin < 3
    over_write = 0;
    d_flag = 0;
end
cc_vox_idx_file = whifun_create_file(over_write,out_fr_vox_idx_file);

if d_flag
    steps_ = steps_ + 1;
    d.Value = steps_/tot_steps;
    d.Message = 'Creating Corpus Callosum Mask';


    if d.CancelRequested
        disp('Creation of WM-FN terminated by User')
        return
    end
end
if isempty(cc_vox_idx_file)

    [data,head] = whifun_niftiread(fr_mask_filename);
    roi = find(data~=0);
    new_data_mask=zeros(size(data));

    for i = 1:length(roi)
        wp = roi(i);
        new_data_mask(wp) = i;

    end
    niftisave(new_data_mask,out_fr_vox_idx_file,head);
else
    disp('Corpus callosum Mask file found hence skipping this step')
end
