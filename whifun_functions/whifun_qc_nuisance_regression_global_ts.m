function whifun_qc_nuisance_regression_global_ts(out_folder,Subj_list_1,motion_reg,pca_for_temp_reg,over_write,n_pca)

if ~exist("n_pca",'var')
    n_pca = [];
end

out_image_path = fullfile(out_folder,'Native_Space','Global_ts',[Subj_list_1.name '.png']);
[out_folder,~,~] = fileparts(out_image_path);
if ~exist(out_folder, 'dir')
    mkdir(out_folder);
end
reg_qc_file = whifun_create_file(over_write,out_image_path);

% Quality Control
% Plot the mean time series before and after regression

if isempty(reg_qc_file)
    % Read the raw file

    y_image_REST = whifun_niftiread(Subj_list_1.coregistered_func_native);
    [x,y,z,nt] = size(y_image_REST);
    raw_file = reshape(y_image_REST,x*y*z,nt);
    global_ts = mean(raw_file,'omitnan');

    y_image_REST_regressed = whifun_niftiread(Subj_list_1.nuisance_regressed_func_native);
    [x,y,z,nt] = size(y_image_REST_regressed);
    raw_file = reshape(y_image_REST_regressed,x*y*z,nt);
    global_ts_r = mean(raw_file,"omitnan");
    if motion_reg == 1
        % Loading the motion parameters
        fprintf('First loading the motion parameters for REST... \n')
        rp=load(Subj_list_1.motion_txt);
        %                                 rp_temp = rp(1:nt,:);
        rp = zscore(rp);
        rp_previous = [0 0 0 0 0 0; rp(1:end-1,:)];
        rp_auto = [rp rp.^2 rp_previous rp_previous.^2];
    else
        rp_auto = [];
    end

    load(Subj_list_1.nuisance_regression_csf_covariates);
    if exist("pca_CSF",'var')
        b_init = zscore([pca_CSF(:,1:n_pca) rp_auto]); %#ok<USENS>
    else
        b_init = zscore([MEAN_CSF_REST rp_auto]);
    end

    if pca_for_temp_reg == 1
        no_of_reg = n_pca;
        b_init = b_init(:,1:n_pca);   % Choose only the PCA CSF regressors
    else
        no_of_reg = 1;
        b_init = b_init(:,1);   % Choose only the Mean CSF regressors
    end
    leg = cell(1,no_of_reg);
    leg{1} = 'Before regression';
    leg{2} = 'After regression';
    if no_of_reg > 1 && exist("pca_CSF",'var')
        for ir = 1:no_of_reg
            leg{ir+2} = ['CSF PC no.' num2str(ir)];
        end
    else
        leg{3} = 'Mean CSF';
    end
    f = figure('visible','off'); plot(global_ts-mean(global_ts));
    hold on
    plot(global_ts_r -mean(global_ts_r))
    hold on
    plot(b_init)
    title(['Global Time Series (mean subtracted)' ' Subject ' Subj_list_1.name])
    legend(leg)

    xlabel('time points')
    ylabel('Bold Signal (mean substracted)')
    exportgraphics(f,out_image_path)
end

disp(['Nuisance Regression qc done for ' Subj_list_1.name])