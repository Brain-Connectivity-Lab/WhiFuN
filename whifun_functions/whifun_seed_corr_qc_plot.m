function whifun_seed_corr_qc_plot(output_path,func_path,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,mask)

%% Seed Corr QC Plots 
if exist("mask","var")
    if ~isempty(mask)
        [~,~,thresh] = whifun_seed_corr(func_path,seed,rad,seed_cor_output_path,thresh,mask);
    else
        [~,~,thresh] = whifun_seed_corr(func_path,seed,rad,seed_cor_output_path,thresh);
    end

else
    [~,~,thresh] = whifun_seed_corr(func_path,seed,rad,seed_cor_output_path,thresh);
end
% Axial View
fg = spm_figure('GetWin','Graphics');
% temp = spm('WinSize','Graphics');
% set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
% set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
pause(0.1)
[fold,file,ext] = fileparts(seed_cor_output_path);
[~,file_nii,ext2] = fileparts(file);
        
seed_corr_thresh_path_2 = fullfile(fold,[file_nii '_thresh-' num2str(thresh(2)) ext2 ext]);

seed_corr_thresh_path_1 = fullfile(fold,[file_nii '_thresh-' num2str(thresh(1)) ext2 ext]);

% hot_cold = [winter;[0,0,0];flip(autumn)];

% for i = 1:length(slover_view_array)
whifun_slover({[func_path,',1'],seed_corr_thresh_path_1,seed_corr_thresh_path_2},{'Structural','Structural','Structural'},{gray,[cool;0,0,0],[0,0,0;hot]},slover_slices_mni,[],slover_view,[0.5 1 1],fg,1);% end
exportgraphics(fg,output_path)
clf(fg)
% end
delete(seed_corr_thresh_path_2);
delete(seed_corr_thresh_path_1);
