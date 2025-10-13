function avg_ts_path = whifun_get_avg_ts_atlas(out_folder,ROI_path,Subj_list,field,QC_plots,over_write,d_flag,d,steps_,tot_steps)


if ~exist("field","var")
    field = 'final_func_MNI';
end
if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end
if ~exist("over_write","var")
    over_write = 0;
end

if ~exist("QC_plots","var")
    QC_plots = 0;
end

QC_plot_path = fullfile(out_folder,'ROI_Partial_null_regions');

[~,ROI_name,~] = fileparts(ROI_path);
[~,ROI_name,~] = fileparts(ROI_name);

avg_ts_path = fullfile(out_folder,['Participant_' ROI_name '_avg_ts']);
if ~exist(avg_ts_path,'dir')
    mkdir(avg_ts_path);
end

[ROI,ROI_info] = whifun_niftiread(ROI_path);
level = unique(sort((ROI(:))));
level(level == 0) = [];

reg = length(level);    % Number of Brain Regions to be considered

vox_count_in_reg = zeros(length(level));
disp(['Number of ROIs = ' num2str(reg)])
nan_sub = [];

disp(['Computing Average ROI timeseries using : ' ROI_name])
for subji = 1:length(Subj_list)

    out_avg_ts_path = fullfile(avg_ts_path, [Subj_list(subji).name '_'  ROI_name '_avg_ts.mat']);

    out_avg_ts_file = whifun_create_file(over_write,out_avg_ts_path);

    if isempty(out_avg_ts_file)
        func_file = dir(Subj_list(subji).(field));
        disp(['Obtaining averaged time series of ' ROI_name ' for participant: ' Subj_list(subji).name]);
        if d_flag
            
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Obtaining averaged time series of ' ROI_name ' for participant: ' Subj_list(subji).name];
            if d.CancelRequested
                disp('Creation of average timeseries terminated by User')
                return
            end
        end

        [func_image,func_info] = whifun_niftiread(fullfile(func_file.folder,func_file.name));
        [x,y,z,nT] = size(func_image);

        if ~all(func_info.ImageSize(1:3) == ROI_info.ImageSize(1:3))
            error(['ROI Image dimentions are different as compared to the Functional Image dimentions for Participant' Subj_list(subji).name])
        end

        avg_ts = zeros(nT,reg);
        subMat = reshape(func_image,[x*y*z,nT]);
        subMat = double(subMat');
        subMat_mean = mean(subMat,1);

        for r = 1:length(level)

            vox_id = find(ROI==level(r));
            [vx,vy,vz] = ind2sub(size(ROI),vox_id);
            pos = [mean(vx);mean(vy);mean(vz)];
            reg_voxels_ts = subMat(:,vox_id) - subMat_mean(vox_id);
            vox_count_in_reg(r) = size(reg_voxels_ts,2);

            voxels_with_data = sum(abs(reg_voxels_ts));
            Subj = Subj_list(subji);
            if nnz(voxels_with_data) == length(voxels_with_data) && nnz(isnan(voxels_with_data)) == 0
                good_sub = 1;
                avg_ts(:,r) = mean(reg_voxels_ts,2);  % mean TS of region 'r'
            else
                good_sub = 0;
            end

            if good_sub == 0
                if (nnz(voxels_with_data) < length(voxels_with_data) && nnz(voxels_with_data) > 0) || (nnz(isnan(voxels_with_data)) > 0 && nnz(isnan(voxels_with_data)) < length(voxels_with_data))
                    reg_voxels_ts(:,voxels_with_data==0) = [];
                    reg_voxels_ts(:,isnan(voxels_with_data)) = [];

                    vox_count_in_reg(r) = size(reg_voxels_ts,2);
                    avg_ts(:,r) = mean(reg_voxels_ts,2);
                    out_msg = sprintf(['ROI: ' ROI_name '\nROI region ' num2str(r) '\nROI has partial data \ndata for Participant' Subj_list(subji).name]);
                else
                    out_msg = sprintf(['ROI: ' ROI_name '\nROI region ' num2str(r) '\nROI does not have \ndata for Participant' Subj_list(subji).name]);
                    vox_count_in_reg(r) = 0;

                    new_atlas = zeros(size(ROI));
                    new_atlas(vox_id) = 1;
                    at_info = niftiinfo(ROI_path);
                    niftisave(new_atlas,'temp.nii',at_info)
                    fg = spm_figure('Create','Graphics','Visible','off');
                    spm_check_registration(char([fullfile(func_file.folder,func_file.name),',1'],...
                        'temp.nii'))
                    st1 = spm_vol([fullfile(func_file.folder,func_file.name),',1']);
                    tmp = st1.mat;
                    pos1 = tmp(1:3,:)*[pos ; 1];

                    spm_orthviews('Reposition',pos1);
                    spm_orthviews('Caption', 1, [Subj_list(subji).name ' ROI region ' num2str(r)]);
                    spm_orthviews('Caption', 2, out_msg);
                    spm_orthviews('contour','display',2,1);
                    if ~exist(fullfile(QC_plot_path,['ROI_region_' num2str(r)]),'dir')
                        mkdir(fullfile(QC_plot_path,['ROI_region_' num2str(r)]))
                    end
                    exportgraphics(fg,(fullfile(QC_plot_path,['ROI_region_' num2str(r)],[Subj_list(subji).name '_region_' num2str(r) '.png'])))
                    delete('temp.nii')
                end
                %                             spm_image('display',[fullfile(func_file.folder,func_file.name),',1']);
                if QC_plots
                    new_atlas = zeros(size(ROI));
                    new_atlas(vox_id) = 1;
                    at_info = niftiinfo(ROI_path);
                    niftisave(new_atlas,'temp.nii',at_info)
                    fg = spm_figure('Create','Graphics','Visible','off');
                    spm_check_registration(char([fullfile(func_file.folder,func_file.name),',1'],...
                        'temp.nii'))
                    st1 = spm_vol([fullfile(func_file.folder,func_file.name),',1']);
                    tmp = st1.mat;
                    pos1 = tmp(1:3,:)*[pos ; 1];

                    spm_orthviews('Reposition',pos1);
                    spm_orthviews('Caption', 1, [Subj_list(subji).name ' ROI region ' num2str(r)]);
                    spm_orthviews('Caption', 2, out_msg);
                    spm_orthviews('contour','display',2,1);
                    if ~exist(fullfile(QC_plot_path,['ROI_region_' num2str(r)]),'dir')
                        mkdir(fullfile(QC_plot_path,['ROI_region_' num2str(r)]))
                    end
                    exportgraphics(fg,(fullfile(QC_plot_path,['ROI_region_' num2str(r)],[Subj_list(subji).name '_region_' num2str(r) '.png'])))
                    delete('temp.nii')
                end
            end
        end


        [~,nan_sub_sub] = functional_connectivity(avg_ts);
        nan_sub = [nan_sub, nan_sub_sub]; %#ok<AGROW>
        save(out_avg_ts_path,'avg_ts','Subj','voxels_with_data','-v7.3'); %% added
    else
        disp([' Avg TS already extracted for ' Subj_list(subji).name ])
    end

end


if ~isempty(nan_sub)

    temp_tab = cell2table({Subj_list(nan_sub).name}');
    temp_tab.Properties.VariableNames = {'There are regions with no data for participants: '};
    disp(temp_tab)
    msgbox('There are regions with no data for some participants (look at matlab command for participant names). You may want to remove these participants or check the QC plots in Atlas_null_regions folder','participants with no data');
end
disp(['Extractation of Average Timeseries using Atlas: ' char(ROI_name) ' is done'])
disp('##########################################################################################')
