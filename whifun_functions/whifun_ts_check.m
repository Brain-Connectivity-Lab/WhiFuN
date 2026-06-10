function whifun_ts_check(func_path_raw,func_path_pro,txt_path,in_func_mni_mask_path,out_image_path,Reg_,csf_covariate_path,n_pca,pca_for_temp_reg)
% WHIFUN_TS_CHECK Generates a comprehensive time series quality check figure.
%
%   WHIFUN_TS_CHECK(func_path_raw, func_path_pro, txt_path, in_anat_mni_mask_path, out_func_mni_mask_path, out_image_path, Reg_, csf_covariate_path, n_pca, pca_for_temp_reg)
%   creates a multi-panel figure to visually inspect the effect of the
%   preprocessing pipeline on a subject's functional time series. The function
%   provides a detailed comparison of data quality before and after key
%   preprocessing steps.
%
%   The function generates ten plots in a 2x5 grid:
%   - **Global Mean (Raw)**: The mean signal of the raw data.
%   - **Pairwise Variance (Raw)**: A measure of signal change between time points.
%   - **Rigid Body Motion**: The 6 head motion parameters.
%   - **Framewise Displacement (FD)**: A single metric summarizing motion.
%   - **CSF Time Series & Derivatives**: The CSF time series and its derivative, if regression was performed.
%   - **Global Mean (Preprocessed)**: The mean signal of the final processed data.
%   - **Pairwise Variance (Preprocessed)**: The signal change after processing.
%   - **Correlation Matrix (Raw)**: A correlation heatmap of raw data metrics.
%   - **Correlation Matrix (Derivatives)**: A correlation heatmap of derivative metrics.
%
%   This function is a powerful diagnostic tool, helping to confirm that
%   nuisance signals have been effectively removed and that the preprocessing
%   steps have not introduced new artifacts.
%
%   Input Arguments:
%   func_path_raw           - Path to the raw (realigned) functional file.
%   func_path_pro           - Path to the preprocessed functional file.
%   txt_path                - Path to the motion parameter `.txt` file.
%   in_anat_mni_mask_path   - Path to the anatomical brain mask in MNI space.
%   out_func_mni_mask_path  - Output path for the resliced functional mask.
%   out_image_path          - Path where the final QC image will be saved.
%   Reg_                    - Logical flag for nuisance regression.
%   csf_covariate_path      - Path to the CSF time series `.mat` file.
%   n_pca                   - Number of PCA components used for CSF regression.
%   pca_for_temp_reg        - Logical flag to indicate if PCA was used.
%
%   Author: Pratik Jain, Xin Di
%   See also NIFTIREAD, RESLICE_DATA, WHIFUN_CALCULATE_FD, CORR, IMAGESC, SUBPLOT.

if ~Reg_
    csf_covariate_path = [];
    n_pca = [];
    pca_for_temp_reg = [];
end
f = gcf;%
clf(f);
set(f,'position',[10 50 1500 400]);
set(f,'PaperPosition',[10 50 1500 400]);

a = whifun_niftiread(func_path_raw);

[x,y,z,nt] = size(a);
a = reshape(a,x*y*z,nt);

gm = mean(mean(a,'omitnan')); % grand mean (4D)

% calculate pairwise variance
dt = zeros(1,nt-1);
for imagei = 1:nt-1
    dt(imagei) = (mean((a(:,imagei) - a(:,imagei+1)).^2))/gm;
end

meany = mean(a)./gm; % scaled global mean

if ~isnumeric(txt_path)
    rp = load(txt_path);              % input the text file generated at the Realignment stage
else
    rp = txt_path;
end

fd = whifun_calculate_fd(rp);

if Reg_
    load(csf_covariate_path); %#ok<LOAD>
end
% load the preprocessed functional images and calculate the global mean and pairwise variance
clear ar_mask dtr


rest_img = whifun_niftiread(func_path_pro);
rest_mask1 = whifun_niftiread(in_func_mni_mask_path);

[x,y,z,nt] = size(rest_img);
rest_mask1 = reshape(rest_mask1,x*y*z,1);
rest_mask = zeros(x*y*z,1);
rest_mask(rest_mask1>0.5) = 1;
rest_img = reshape(rest_img,x*y*z,nt);
ar_mask = rest_img(rest_mask==1,:);
gmr = mean(mean(rest_img,'omitnan')); % grand mean (4D)
% calculate pairwise variance from the residual images (preprocessed images)
dtr = zeros(1,nt-1);
for imagei = 1:nt-1
    dtr(imagei) = (mean((ar_mask(:,imagei) - ar_mask(:,imagei+1)).^2,'omitnan'))/gmr;
end

meanyr = mean(ar_mask,'omitnan')./gmr; % scaled global mean from the residual images (preprocessed images)

% plots
subplot(2,5,1)
plot(meany)
title('Global mean (raw)');xlabel('Image number')
box off

subplot(2,5,6)
plot(dt)
yline(mean(dt)+3*std(dt),'-','3 SD','color',[0 0.4470 0.7410]);
title('Pairwise variance (raw)');xlabel('Image pair')
box off

subplot(2,5,2)
plot([rp(:,1:3) rp(:,4:6)*180/pi])
title('Rigid body motion');xlabel('Image number')
box off

subplot(2,5,7)
plot(fd)
title('Framewise displacement');xlabel('Image pair')
box off

if Reg_
    if exist("pca_CSF",'var')
        plot_csf = pca_CSF;
    else
        plot_csf = MEAN_CSF_REST;
    end

    subplot(2,5,3)
    plot(plot_csf)
    title('CSF');xlabel('Image number')
    box off

    subplot(2,5,8)
    plot(diff(plot_csf))
    title('d(CSF)');xlabel('Image pair')
    box off
end
subplot(2,5,4)
plot(meanyr)
title('Global mean (preprocessed)');xlabel('Image number')
box off

subplot(2,5,9)
plot(dtr)
yline(mean(dtr)+3*std(dtr),'-','3 SD','color',[0 0.4470 0.7410]);
title('Pairewise variance (preprocessed)');xlabel('Image pair')
box off
if Reg_
    [corr_raw,pval_raw] = corr([meany' rp plot_csf meanyr']);%[rho,pval]
    [corr_dt,pval_dt] = corr([dt' fd diff(plot_csf) dtr']);
else
    [corr_raw,pval_raw] = corr([meany' rp meanyr']);
    [corr_dt,pval_dt] = corr([dt' fd dtr']);
end
subplot(2,5,5)
imagesc(corr_raw)
colormap("jet")
clim([-1 1]);
if Reg_
    if pca_for_temp_reg == 0
        yticks(1:9)
        yticklabels({'G raw','HM 1','HM 2','HM 3','HM 4','HM 5','HM 6','CSF','G final'})
    else
        yticks(1:8+n_pca)
        PCA_leg = cell(1,8+n_pca);
        PCA_leg(1:7) = {'G raw','HM 1','HM 2','HM 3','HM 4','HM 5','HM 6'};
        ic = 1;
        for i = 8:8+n_pca
            PCA_leg{i} = ['CSF PCA ' num2str(ic)];
            ic = ic+1;
        end
        PCA_leg(7+n_pca+1) = {'G final'};
        yticklabels(PCA_leg);
    end
else
    yticks(1:9)
    yticklabels({'G raw','HM 1','HM 2','HM 3','HM 4','HM 5','HM 6','G final'})
end
colorbar
title('Correlation');
if Reg_
    if pca_for_temp_reg == 0
        mat_mask = create_mask(9);
        % mat_mask = zeros(9);
        % mat_mask(1,2:end-1) = 1;
        % mat_mask(end,2:end-1) = 1;
        % mat_mask(2:end-1,1) = 1;
        % mat_mask(2:end-1,end) = 1;
    else
        mat_mask = create_mask(8+n_pca);
        % mat_mask = zeros(8+n_pca);
        % mat_mask(1,2:end-1) = 1;
        % mat_mask(end,2:end-1) = 1;
        % mat_mask(2:end-1,1) = 1;
        % mat_mask(2:end-1,end) = 1;
    end
else
    mat_mask = create_mask(8);
    % mat_mask = [0 1 0;1 0 1; 0 1 0];
end
[x,y] = find((pval_raw<0.05 & abs(corr_raw)>0.3).*mat_mask);
hold on; scatter(x,y,[],'r','filled')

subplot(2,5,10)
imagesc(corr_dt)
colormap("jet")

clim([-1 1]);
if Reg_
    if pca_for_temp_reg == 0
        yticks(1:6)
        yticklabels({'V raw','FD','d(CSF)','V final'})
    else
        yticks(1:(2+n_pca+1))
        PCA_leg = cell(1,(4+n_pca));
        PCA_leg(1:2) = {'V raw','FD'};
        ic = 1;
        for i = 3:3+n_pca
            PCA_leg{i} = ['d(CSF PCA ' num2str(ic) ')'];
            ic = ic + 1;
        end
        PCA_leg(2+n_pca+1) = {'V final'};
        yticklabels(PCA_leg)
    end
else
    yticks(1:5)
    yticklabels({'V raw','FD','V final'})
end

colorbar
title('Correlation');
if Reg_
    if pca_for_temp_reg == 0
        mat_mask = [0 1 1 0;1 0 0 1;1 0 0 1; 0 1 1 0];
        % mat_mask = create_mask(4);
    else
        mat_mask = create_mask(3+n_pca);
        % mat_mask = zeros(3+n_pca);
        % mat_mask(1,2:end-1) = 1;
        % mat_mask(end,2:end-1) = 1;
        % mat_mask(2:end-1,1) = 1;
        % mat_mask(2:end-1,end) = 1;
    end
else
    mat_mask = create_mask(3);
    % mat_mask = [0 1 0;1 0 1; 0 1 0];
end
[x,y] = find((pval_dt<0.05 & abs(corr_dt)>0.3).*mat_mask);
hold on; scatter(x,y,[],'r','filled')

set(f,'position',[10 50 1500 400]);
set(f,'PaperPosition',[10 50 1500 400]);
% pause(0.1)
exportgraphics(f,out_image_path);
exportgraphics(f,out_image_path);
colormap("gray")
end
function mat_mask = create_mask(n)
mat_mask = zeros(n);
mat_mask(1,2:end-1) = 1;
mat_mask(end,2:end-1) = 1;
mat_mask(2:end-1,1) = 1;
mat_mask(2:end-1,end) = 1;
end
