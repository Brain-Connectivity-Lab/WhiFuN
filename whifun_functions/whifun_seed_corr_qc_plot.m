function whifun_seed_corr_qc_plot(output_path,func_path,seed,rad,seed_cor_output_path,thresh,slover_slices_mni,slover_view,mask)
%WHIFUN_SEED_CORR_QC_PLOT Computes seed-based functional connectivity (FC)
%   and generates a quality control (QC) visualization using the Slover tool.
%
%   WHIFUN_SEED_CORR_QC_PLOT(OUTPUT_PATH, FUNC_PATH, SEED, RAD, SEED_COR_OUTPUT_PATH, THRESH, SLICES_MNI, VIEW, MASK)
%
%   This function first calculates the seed-to-voxel correlation map for a
%   given seed location. It then creates two temporary thresholded versions
%   of the correlation map and visualizes them simultaneously using Slover
%   (e.g., one for positive correlation, one for negative) on top of the
%   structural image for QC purposes. The temporary files are deleted after
%   plotting.
%
%   Input Arguments:
%   OUTPUT_PATH          - Full path to save the final QC plot graphic (e.g., PNG).
%   FUNC_PATH            - Full path to the 4D functional NIfTI file.
%   SEED                 - 1x3 vector of MNI coordinates [x, y, z] for the seed center.
%   RAD                  - Radius (in mm) of the spherical seed region.
%   SEED_COR_OUTPUT_PATH - Full path to save the unthresholded seed correlation NIfTI map.
%   THRESH               - 1x2 vector [thresh_neg, thresh_pos] for negative and positive
%                          correlation thresholds (e.g., [-0.3, 0.3]).
%   SLOVER_SLICES_MNI    - Vector of slice coordinates or method for Slover visualization (e.g., [4, 8, 12]).
%   SLOVER_VIEW          - String defining the view for Slover (e.g., 'axial').
%   MASK                 - (Optional) Full path to a NIfTI mask file to constrain the correlation analysis.
%
%   Dependencies: 'whifun_seed_corr', 'spm_figure', 'whifun_slover'.
%
%   Author: Pratik Jain

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
