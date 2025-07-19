function whifun_ts_check(now_func_path_raw,now_txt_path,now_func_path_pro,now_anat_path,Reg_,quality_control_path,name,n_pca,max_fd_thres,pca_for_temp_reg)

if nargin < 10
    pca_for_temp_reg = [];
end
figure('position',[10 50 1500 400]);

a = niftiread(fullfile(now_func_path_raw.folder,now_func_path_raw.name));

[x,y,z,nt] = size(a);
a = reshape(a,x*y*z,nt);

gm = mean(mean(a)); % grand mean (4D)

% calculate pairwise variance
dt = zeros(1,nt-1);
for imagei = 1:nt-1
    dt(imagei) = (mean((a(:,imagei) - a(:,imagei+1)).^2))/gm;
end

meany = mean(a)./gm; % scaled global mean

rp = load(fullfile(now_txt_path.folder,now_txt_path.name));              % input the text file generated at the Realignment stage

fd_trans = fd_calc(rp(:,1:3));
fd_rotat = fd_calc(rp(:,4:6)*50);


if Reg_
    load(fullfile(now_func_path_raw.folder,'covariance_csf_REST.mat')); %#ok<LOAD>
end
% load the preprocessed functional images and calculate the global mean and pairwise variance
clear ar_mask dtr


rest_img = niftiread(fullfile(now_func_path_pro.folder,now_func_path_pro.name));
rest_mask1 = reslice_data(fullfile(now_anat_path.folder,'wanat_mask.nii'),fullfile(now_func_path_pro.folder,[now_func_path_pro.name ]),1,1,fullfile(now_func_path_pro.folder,'wrest_mask.nii'));

[x,y,z,nt] = size(rest_img);
rest_mask1 = reshape(rest_mask1,x*y*z,1);
rest_mask = zeros(x*y*z,1);
rest_mask(rest_mask1>0.5) = 1;
rest_img = reshape(rest_img,x*y*z,nt);



ar_mask = rest_img(rest_mask==1,:);
%                     ar_mask(isnan(ar_mask)) = 0;
%                     gmr = mean(mean(ar_mask)); % grand mean (4D) from the residual images (preprocessed images)

% calculate pairwise variance from the residual images (preprocessed images)
dtr = zeros(1,nt-1);
for imagei = 1:nt-1
    dtr(imagei) = (mean((ar_mask(:,imagei) - ar_mask(:,imagei+1)).^2,'omitnan'));
end

meanyr = mean(ar_mask,'omitnan'); % scaled global mean from the residual images (preprocessed images)

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
plot([fd_trans fd_rotat])
title('Framewise displacement');xlabel('Image pair')
legend('Translation','Rotation','location','best','box','off')
if max(fd_trans ) > max_fd_thres
    yline(max_fd_thres,'r',['FD = ' num2str(max_fd_thres)]);
end
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
    corr_raw = corr([meany' rp plot_csf meanyr']);
    corr_dt = corr([dt' fd_trans fd_rotat diff(plot_csf) dtr']);
else
    corr_raw = corr([meany' rp meanyr']);
    corr_dt = corr([dt' fd_trans fd_rotat dtr']);
end
subplot(2,5,5)
imagesc(corr_raw)
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
        for i = 8:8+n_pca-1
            PCA_leg{i} = ['CSF PCA ' num2str(ic)];
            ic = ic+1;
        end
        PCA_leg(n_pca+1) = {'G final'};
        yticklabels(PCA_leg);
    end
else
    yticks(1:9)
    yticklabels({'G raw','HM 1','HM 2','HM 3','HM 4','HM 5','HM 6','G final'})
end
colorbar
title('Correlation');

subplot(2,5,10)
imagesc(corr_dt)
clim([-1 1]);
if Reg_
    if pca_for_temp_reg == 0
        yticks(1:6)
        yticklabels({'V raw','FD T','FD R','d(CSF)','V final'})
    else
        yticks(1:(4+n_pca))
        PCA_leg = cell(1,(4+n_pca));
        PCA_leg(1:3) = {'V raw','FD T','FD R'};
        ic = 1;
        for i = 4:4+n_pca-1
            PCA_leg{i} = ['d(CSF PCA ' num2str(i) ')'];
            ic = ic + 1;
        end
        PCA_leg(4+n_pca) = {'V final'};
        yticklabels(PCA_leg)
    end
else
    yticks(1:5)
    yticklabels({'V raw','FD T','FD R','V final'})
end
colorbar
title('Correlation');
if Reg_
    if pca_for_temp_reg == 0
        mat_mask = [0 1 1 1 0;1 0 0 0 1;1 0 0 0 1;1 0 0 0 1; 0 1 1 1 0];
    else
        mat_mask = zeros(4+n_pca);
        mat_mask(1,2:end-1) = 1;
        mat_mask(end,2:end-1) = 1;
        mat_mask(2:end-1,1) = 1;
        mat_mask(2:end-1,end) = 1;
    end
else
    mat_mask = [0 1 1 0;1 0 0 1;1 0 0 1; 0 1 1 0];
end
[x,y] = find((corr_dt>0.3).*mat_mask);
hold on; scatter(x,y,[],'r','filled')

saveas(gcf,fullfile(quality_control_path,'Time_series_check',[name '.png']));
close all
