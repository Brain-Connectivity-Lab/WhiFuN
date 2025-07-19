function whifun_regress(now_func_path,name,now_anat_path,motion_reg,Cut_pre,func_data_name,n_pca,Reg_pre)


func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));                           % Get Func file info
image_dim_REST = func_info.ImageSize;                                                                        % number of timepoints
nt = image_dim_REST(4);
% disp(['Loading rest mask for ' name]);

% Creating REST_MASK from the Anat mask

REST_MASK1 = whifun_create_rest_mask(now_func_path,now_anat_path,name);
REST_MASK = zeros(size(REST_MASK1));
REST_MASK(REST_MASK1>0.5) = 1;

% Loading Time Series realigned rest file
y_image_REST = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));
fprintf('loading covariates for REST... \n')

if motion_reg == 1
    % Loading the motion parameters
    fprintf('First loading the motion parameters for REST... \n')
    func_name_wo_ext = strsplit(func_data_name,'.');
    txt_file = dir(fullfile(now_func_path.folder,['rp_' Cut_pre func_name_wo_ext{1} '.txt']));
    rp=load(fullfile(txt_file.folder,txt_file.name));
    rp_temp = rp(1:nt,:);
    rp = zscore(rp_temp);
    rp_previous = [0 0 0 0 0 0; rp(1:end-1,:)];
    rp_auto = [rp rp.^2 rp_previous rp_previous.^2];
else
    rp_auto = [];
end

fprintf('Now loading csf and wm parameters timeseries for REST... \n')
fprintf('Loading covariates from: \n')
disp(fullfile(now_func_path.folder,'covariance_csf_REST.mat'))

load(fullfile(now_func_path.folder,'covariance_csf_REST.mat')); %#ok<LOAD>

fprintf('regressing out covariates for REST... \n')
mean_image_REST = mean(y_image_REST,4);   % calculate mean across time for all voxels | can be added back after regression to improve ICA performance

if exist("pca_CSF",'var')
    b_init = zscore([pca_CSF(:,1:n_pca) rp_auto]); %#ok<USENS> 
else
    b_init = zscore([MEAN_CSF_REST rp_auto]); 
end

fprintf('Loading of covariates complete! \n')


clear vi vj vk
y_image_REST_regressed = zeros(size(y_image_REST));
X = image_dim_REST(2);
Y = image_dim_REST(3);
for vi = 1:image_dim_REST(1)
%     fprintf('%d ',vi)

    for vj = 1:X
        for vk = 1:Y
            if REST_MASK(vi,vj,vk)==0

                y_image_REST_regressed(vi,vj,vk,:) = zeros(1,1,1,nt);

            else

                % CSF, WM and MOTION Regressors and Regressors from OTHER SESSIONs for the same subject

                [~,~,y_image_REST_regressed(vi,vj,vk,:)] = regress(shiftdim(y_image_REST(vi,vj,vk,:),3),[b_init ones(nt,1)]);
                y_image_REST_regressed(vi,vj,vk,:) = y_image_REST_regressed(vi,vj,vk,:) + mean_image_REST(vi,vj,vk);  
            end
        end

    end
end
y_image_REST_regressed = cast(y_image_REST_regressed,func_info.Datatype);

niftisave((y_image_REST_regressed),fullfile(now_func_path.folder,[Reg_pre ,now_func_path.name]),func_info);