function whifun_seed_corr_qc_plot(output_path,func_path,name,mask_,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view_array)
%% Seed Corr QC Plots 

for i = 1:length(slover_view_array)
    mkdir(output_path,[slover_view_array{i} '_Slice_View'])
end
whifun_seed_corr(func_path,seed,rad,mask_,seed_cor_output_path,thresh);

% Axial View
fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
pause(0.1)
[fold,file,ext] = fileparts(seed_cor_output_path);
[~,file_nii,ext2] = fileparts(file);
        
seed_corr_thresh_path = fullfile(fold,[file_nii '_thresh-' num2str(thresh) ext2 ext]);

% hot_cold = [winter;[0,0,0];flip(autumn)];

for i = 1:length(slover_view_array)
    whifun_slover({[func_path,',1'],seed_corr_thresh_path},{'Structural','Structural'},{gray,hot},slover_slices_mni,[],slover_view_array{i},[0.8 1],fg);% end
    exportgraphics(fg,fullfile(output_path,[slover_view_array{i} '_Slice_View'],[name '.png']))
    clf(fg)
end
delete(seed_corr_thresh_path);
