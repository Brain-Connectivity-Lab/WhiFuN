function [avg_vox_level_FC,mask_voxels] = whifun_create_avg_voxel_level_fc(out_analysis_path,Subj_list,group_mask_path,sub_sample_choose,WM_or_GM,focus_region_check,focus_region_mask,over_write,d_flag,d,steps_,tot_steps)

if ~exist('d_flag','var')
    % Only used for WhiFuN GUI
    d_flag = 0;
    d = 0;
    steps_ = 0;
    tot_steps = 0;
end


%% loading pre-made group average WM and GM masks (from the script create_average_WM_and_GM_masks.m)
% reading the masks using SPM's functions
%%% input the group white-matter/gray-matter masks
mask_ = niftiread(group_mask_path); %% input the group white-matter mask that excludes callosal voxels

% Excluding Corpus callousum voxels in WM mask if Corpus
% callosum networks are to be found

if ~exist('focus_region_check',"var")
    focus_region_check = 0;
    focus_region_mask = 0;
end
if focus_region_check == 1
    mask_(focus_region_mask>0) = 0;
end

% finding the locations of white-matter
mask_voxels = find(mask_>0);

if ispc
    user = memory;
end
n_WM_voxels = numel(mask_voxels);
txt_name = 'Subsampling_info.txt';

switch sub_sample_choose
    case 'Subsample'
        if ~ispc
            user.MaxPossibleArrayBytes = inf;
        end
        if (n_WM_voxels*n_WM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling,  looking if the voxel subsampled FC is lesser than 80% of Max possible array size
            text_sampling = fopen(fullfile(out_analysis_path, [WM_or_GM '_FN'],txt_name),'a');
            fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
            sub_samp = 1;
            fclose(text_sampling);
        else % the voxel FC is too big
            response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
            switch response_
                case 'Yes'
                    text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                    fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                    sub_samp = 1;
                    warning('May get an Memory error');
                    fclose(text_sampling);
                case 'No'
                    text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                    fprintf(text_sampling, 'WM Networks not formed as the subsampled matrix was too big for the PC.');
                    fclose(text_sampling);
                    return
                otherwise
                    return
            end
        end
    case 'Use entire FC'
        if ~ispc
            user.MaxPossibleArrayBytes = inf;
        end
        if n_WM_voxels*n_WM_voxels*8 < 0.8*user.MaxPossibleArrayBytes  % if the voxel-FC matrix size is lesser than 80% of Max possible array size
            %% Choose entire FC
            text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
            fprintf(text_sampling, 'Choosing the entire FC.');
            sub_samp = 0;
            fclose(text_sampling);
        else
            response_ = questdlg('The entire FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. You may subsample to matrix to compute the WM networks?','Memory low','Subsample','Still Use entire FC','Subsample');
            switch response_
                case 'Subsample'
                    if (n_WM_voxels*n_WM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling
                        text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                        fprintf(text_sampling, ['Choosing the subsampling statergy as the WM-voxel FC matrix is too big for the PC.', 'Max Memory required for the array = ' num2str(n_WM_voxels*n_WM_voxels*8) ' Available memory in PC = ' num2str(0.8*user.MaxPossibleArrayBytes)]);
                        sub_samp = 1;
                        fclose(text_sampling);
                    else % subsampled voxel FC is too big as well
                        response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
                        switch response_
                            case 'Yes'
                                text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                                fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                                sub_samp = 1;
                                warning('May get an Memory error');
                                fclose(text_sampling);
                            case 'No'
                                text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                                fprintf(text_sampling, 'WM Networks not formed as the subsampled matrix was too big for the PC.');
                                fclose(text_sampling);
                                return
                            otherwise
                                return
                        end
                    end
                case 'Still Use entire FC'
                    text_sampling = fopen(fullfile(output_folder,'Analysis',[WM_or_GM '_FN'],txt_name),'a');
                    fprintf(text_sampling, 'Choosing the entire FC as it was choosen by the user.');
                    sub_samp = 0;
                    warning('May get an Memory error');
                    fclose(text_sampling);
                otherwise
                    return
            end
        end
end

%% Computing the data for clustering from each participant
% this data is a NxM matrix:
% - rows of the matrix correspond to all WM voxels
% - columns of the matrix correspond to a subsampled WM matrix, to aid the
%   next stage of clustering by reducing the number of features
% for example for 12,000 white-matter voxels, the matrix will be 12k x 3k
%
% each matrix cell contains the correlation between the corresponding
% voxels' signals, averaged across participants

% defining a sub-sampling of the mask voxels
if sub_samp == 1
    p = zeros(size(mask_));    % defining a grid of 1s and 0s across the image

    switch WM_or_GM
        case 'WM'
            p(2:2:end, 2:2:end, 2:2:end) = 1; p(1:2:end, 1:2:end, 1:2:end) = 1;
        case 'GM'
            p(2:3:end, 2:3:end, 2:2:end) = 1; p(1:3:end, 1:3:end, 1:2:end) = 1;   % for grey-matter
    end
else
    p = ones(size(mask_));    % defining a grid of 1s and 0s across the image
end
p = p(mask_voxels);   % choosing only locations of white-matter voxels
p = find(p);    % getting the indices of subsampled voxels in the whole mask
p = p(randperm(length(p)));     % randomly mixing the voxels' indices

% getting the data from each participant - correlation between all WM voxels and the subsampled WM voxels (num_WM_voxels X num_subsampled_voxels)
avg_vox_level_FC = zeros(length(mask_voxels),length(p));
num_subjs_notnan = zeros(length(mask_voxels),length(p));

disp('Creating the average voxel level FC matrix')
% definition of a file name with functional data - so that other files will be resampled to this file's resolution
func_img1_filename = Subj_list(1).final_func_MNI;%complet

out_mat_path = fullfile(out_analysis_path,[WM_or_GM '_FN'],'avg_vox_level_FC.mat');
mat_dir = whifun_create_file(over_write,out_mat_path);
if isempty(mat_dir)
    for subji = 1:length(Subj_list)      % For loop on number of participants
        
        if d_flag
            disp(['Currently Processing ' Subj_list(subji).name])
        else
            disp(['Currently Processing ' Subj_list(subji).name ' ' num2str(subji) ' out of ' num2str(length(Subj_list))])
        end

        if d_flag
            steps_ = steps_ + 1;
            d.Value = steps_/tot_steps;
            d.Message = ['Creating Voxel-based FC for participant: ' Subj_list(subji).name];

            if d.CancelRequested
                disp('Creation of WM-FN terminated by User')
                return
            end
        end
        now_func_path = Subj_list(subji).final_func_MNI;%complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));
        func_data = niftiread(now_func_path);
        all_timecourses = reshape(func_data, [size(func_data,1)*size(func_data,2)*size(func_data,3) size(func_data,4)]); % resampling to 2D - num_WM_voxels X num_timepoints
        current_voxels_timecourses = double(all_timecourses(mask_voxels,:));  % getting the signal across time from all white-matter voxels
        clear all_timecourses; clear func_data;

        % loading the segmentation files of all participants, for identification of WM voxels in this specific participant
        current_seg_dir = complete_filepath(fullfile(Subj_list(subji).anat_folder));
        current_GM_file = dir(Subj_list(subji).GM_MNI);
        current_WM_file = dir(Subj_list(subji).WM_MNI);
        current_CSF_file = dir(Subj_list(subji).CSF_MNI);

        % resampling the segmentation files to the functional image resolution
        current_GM_mask = reslice_data(fullfile(current_seg_dir,current_GM_file(1).name), func_img1_filename, 0);
        current_WM_mask = reslice_data(fullfile(current_seg_dir,current_WM_file(1).name), func_img1_filename, 0);
        current_CSF_mask = reslice_data(fullfile(current_seg_dir,current_CSF_file(1).name), func_img1_filename, 0);

        % finding where probability for white-matter is larger than 0.2 and
        % larger than probability for grey-matter or CSF
        current_seg_mask = (current_WM_mask>current_GM_mask) & (current_WM_mask>current_CSF_mask) & (current_WM_mask>0.2);

        % finding and ignoring irrelevant voxels (e.g. not defined as WM in this specific participant, or have NaN values)
        WM_voxels_with_data = find(var(current_voxels_timecourses,[],2)~=0 & ~isnan(var(current_voxels_timecourses,[],2)) & current_seg_mask(mask_voxels)==1);
        WM_voxels_p_with_data = find(var(current_voxels_timecourses(p,:),[],2)~=0 & ~isnan(var(current_voxels_timecourses(p,:),[],2)) & current_seg_mask(mask_voxels(p))==1);

        % Calculating correlation matrix of each WM voxel to the subsampled voxels
        current_corr = corr(current_voxels_timecourses(WM_voxels_with_data,:)', current_voxels_timecourses(p(WM_voxels_p_with_data),:)');

        % adding the current connectivity matrix to the sum of all participants, for later averaging
        avg_vox_level_FC(WM_voxels_with_data, WM_voxels_p_with_data) = avg_vox_level_FC(WM_voxels_with_data, WM_voxels_p_with_data) + current_corr;
        num_subjs_notnan(WM_voxels_with_data, WM_voxels_p_with_data) = num_subjs_notnan(WM_voxels_with_data, WM_voxels_p_with_data) + 1;

        clear current_voxels_timecourses; clear current_corr; clear current_seg_mask; clear WM_voxels_with_data; clear WM_voxels_p_with_data;
    end

    avg_vox_level_FC = avg_vox_level_FC./num_subjs_notnan;
else
    load(out_mat_path) %#ok<LOAD>
end

avg_vox_level_FC(isnan(avg_vox_level_FC))=0;
missing_voxels = find(std(avg_vox_level_FC,[],2)==0);   % finding voxels with no data
mask_voxels(missing_voxels) = []; avg_vox_level_FC(missing_voxels,:)=[];

missing_voxels = std(avg_vox_level_FC,[],1)==0;   % finding voxels with no data
avg_vox_level_FC(:,missing_voxels)=[];