%% Clustering WM Functional networks

whifun_path = 'C:\Users\jainp\Box\WhiFuN_v2_beta\';                                % path to whifun toolbox
output_folder = 'C:\Users\jainp\Box\practice_NY_op_home_laptop';                        % Path of the output folder
vox = '3';                           % Voxel size of the normalized image (preprocessed image)

grp_wm_thres = 80/100;             % Group threshold on WM
indi_thres = 0.6;   % Inidividual threshold on WM tissue prob

K_range_l = 2;
K_range_h = 3;

CV_folds = 4;

Corpus_check = 1;

over_write = 0;
sub_sample = 'Subsample';

use_whifun_gui = 'No';   % Yes or No

% If not using WhiFuN GUI, (use_whifun_gui == 'No')
func_dir_path = 'C:\Users\jainp\Box\practice_NYU_abide\*\session_1\rest_1\wsREG_rc_rest.nii';
anat_dir_path = 'C:\Users\jainp\Box\practice_NYU_abide\*\session_1\anat_1\mprage.nii';
check_subjlist = 1;      % 1 it will notify the subjlist anat and func alignment, 0 will not notify. Used only if No whifun gui is selected



%% DO not change 

preproc_code_path = whifun_path;                                          %* path where the code is stored
addpath(fullfile(preproc_code_path,'BrainNetViewer_20191031'))                     %* Add path to the WhiFuN compatible BrainNet toolbox
addpath(fullfile(preproc_code_path,'whifun_functions'))
cc_mask_filename = fullfile(preproc_code_path,'Templates','Original_corpus_callosum.nii');     %* Get the CC mask path

if strcmp(use_whifun_gui,'No')
    sub_files_func = dir(func_dir_path);
    sub_files_anat = dir(anat_dir_path);

    sub_files_func = rmfield(sub_files_func,{'bytes','isdir','date','datenum'});
    sub_files_anat = rmfield(sub_files_anat,{'bytes','isdir','date','datenum'});

    Subj_list_func = sub_files_func;
    Subj_list_func = cell2struct(struct2cell(Subj_list_func), {'func_name', 'func_folder'});

    Subj_list_anat = sub_files_anat;
    Subj_list_anat = cell2struct(struct2cell(Subj_list_anat), {'anat_name', 'anat_folder'});

    fields = [fieldnames(Subj_list_anat); fieldnames(Subj_list_func)];
    Subj_list = cell2struct([struct2cell(Subj_list_anat); struct2cell(Subj_list_func)], fields, 1);

    disp(struct2table(Subj_list))
    if check_subjlist == 1
        disp('Please check if the anat and the func files are aligned')
        pause
    end
end



%             colon = char("'");
build_net = 0;                                                                     % will be used if previous made networks are detected

switch use_whifun_gui
    case 'Yes'
        Subj_list = load_subjects(output_folder,'Subj_list.csv');                      % Load the good participants using the CSV file

        Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv');              % Load all participants in the dataset
        load(fullfile(output_folder,'parameters.mat'))                                 % % load parameters saved during initial data check, if they were changed after initial data check, the change will be applied later in the code.
        if double(string(app.NoofVolumestoDiscardTextArea.Value)) ~= 0
            Cut_pre = 'c_';                                                         % Prefix for the Discarding Initial volumes File
        else
            Cut_pre = '';
        end
        Realign_pre = 'r';                                                          % Prefix for the Realignment File

        Norm_pre = 'w';                                                             % Prefix for the Normalized File
        quality_control_path = fullfile(output_folder,'Quality_control');           % Quality control path to store any error info

        if filter_check                                                                  % prefix for filtered file
            f_pre = 'f';
        else
            f_pre = '';
        end

        switch smooth_drop
            case 'No Smoothing'
                Smooth_pre = '';
            otherwise
                Smooth_pre = 's';                                                   % Prefix for the Smoothed File
        end

        switch Reg_drop
            case 'No Regression'
                Reg_pre = '';
            otherwise
                Reg_pre = 'REG_';
        end                                                                         % Prefix for the Regression File
    case 'No'
        Norm_pre = '';
        Smooth_pre = '';
        f_pre = '';
        Reg_pre = '';
        Realign_pre = '';
        Cut_pre = '';
end

mkdir(fullfile(output_folder,'Analysis','WM_FN'))                            % make the WM Networks results folder


mkdir(fullfile(output_folder,'Analysis','Group_Masks'))

% cd(data_path)

%%          These values can be changed but default is recommended

% definition of prefix of files for each tissue type
GM_file_prefix = 'wc1';
WM_file_prefix = 'wc2';
CSF_file_prefix = 'wc3';

HO_atlas_filename = fullfile(preproc_code_path,'Atlases','HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii'); %%% choose the HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii from the mask file



if K_range_l > K_range_h
    error(sprintf('Please check the K-range 1st number in the text field should be less than 2nd number, \nbut found otherwise\n'))
end


wm_steps = 0;
n_tot = length(Subj_list);

if Corpus_check
    tot_wm_steps = n_tot*6 + (K_range_h - K_range_l) + 5;
else
    tot_wm_steps = n_tot*4 + (K_range_h - K_range_l) + 1; %#ok<UNRCH> 
end
%             n_vol_dis = double(string(app.NoofVolumestoDiscardTextArea.Value));                  % No. of volumes to discard
d = waitbar(0,'Please wait','Name','Create WM-FNs');


%% 1 Create Group WM Mask

disp('##########################################################################################')
disp('Creating the group WM masks ')


if over_write == 1
    wm_mask_dir = dir(fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'));
    if ~isempty(wm_mask_dir)
        delete(fullfile(wm_mask_dir.folder,wm_mask_dir.name))
    end
    wm_mask_dir = [];
else
    wm_mask_dir = dir(fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'));
end


if isempty(wm_mask_dir)

    func_img1_filename = complete_filepath(fullfile(Subj_list(1).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name])); % get one func file for the nifti header
    func_img1_filename_info = niftiinfo(func_img1_filename);
    size_image = func_img1_filename_info.ImageSize;
    WMmask_full = zeros(size_image(1:3));                         % Initializing the WM Mask
    disp(['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres) ' for every participant'])
    for subji = 1:length(Subj_list)      % For loop on number of participants

        if ~isfield(Subj_list,'nt_dis')
            func_img1_filename = complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name])); % get one func file for the nifti header
            func_img1_filename_info = niftiinfo(func_img1_filename);
            Subj_list(subji).nt_dis = func_img1_filename_info.ImageSize(4);
        end

        % getting the current participant's segmentation directory
        now_anat_path = fullfile(Subj_list(subji).anat_folder) ;
        WM_file_temp = dir(fullfile(now_anat_path, [WM_file_prefix '*.nii'])); WM_file = fullfile(WM_file_temp.folder, WM_file_temp.name);
        current_WM_mask = reslice_data(WM_file, func_img1_filename, 0);      % resize to func space
        WMmask_full(current_WM_mask>=indi_thres) = WMmask_full(current_WM_mask>=indi_thres) + 1; % Count of every voxel with prob greater than indi_thresh across all participants

        wm_steps = wm_steps + 1;
        waitbar(wm_steps/tot_wm_steps,d,['Collecting all the voxels that have WM probability greater than ' num2str(indi_thres)],'Name','Create WM-FNs')
       
    end
    WMmask_full = WMmask_full./length(Subj_list);                        % Probability of every voxel having WM prob greater than indi_thres across participants
    %% Optional stage - remove subcortical structures from the white-matter mask
    % these structures (putamen, globus pallidus) are erroneously identified in SPM as
    % white-matter due to their high iron content (see Lorio et al. 2016, NeuroImage).
    % We used here the Harvard-Oxford Atlas (obtained from DPABI toolbox) to delineate these subcortical structures,
    % and then remove them from the WM mask (and add them to the GM mask).

    % reading the Harvard-Oxford atlas and resampling it to the functional image's resolution
    HO_atlas = reslice_data(HO_atlas_filename, func_img1_filename, 0);

    % find the voxels defined as subcortical structures
    indices_subcortical = [find(HO_atlas==2010);	find(HO_atlas==2049);	find(HO_atlas==3011);	find(HO_atlas==3050);	find(HO_atlas==4012);	find(HO_atlas==4051);	find(HO_atlas==5013);	find(HO_atlas==5052);	find(HO_atlas==8026);	find(HO_atlas==8058);];

    % Remove these voxels from the white-matter mask and add them to the grey-matter mask
    WMmask_full(indices_subcortical)=0;

    %% Thresholding to find voxels defined as WM or GM in a big enough percent of the participants
    WMmask = WMmask_full >= grp_wm_thres;               % threshold for WM mask - >60% probability of identification as white-matter
    WM_voxels = find(WMmask>0);

    %% 2 Removal of parts of the mask for which functional data exists only in <80% of participants, such as the spinal cord
    threshold_notnan = 0.8;     % 80% of voxels need to be not NaN for each voxel to be included in the mask

    % defining the directory with average functional data of all participants,
    % arranged in separate directories for each participant

    % reading these files and counting how many participants have data in each voxel
    disp('Removal of parts of the mask for which functional data exists only in <80% of participants')
    num_subjs_notnan_WM = zeros(length(WM_voxels),1);
    for subji = 1:length(Subj_list)      % For loop on number of participants


        now_func_path = fullfile( Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]) ;

        % reading the current participant's mean functional file
        if ~isempty(now_func_path)
            curr_filename = dir(now_func_path);
        else
            disp('No average functional image found!')
            break;
        end
        curr_mean_func = mean(niftiread(fullfile(curr_filename.folder,curr_filename.name)),4);  % loading the participants' mean functional image

        % current participant - finding voxels which are not zero or NaN
        WM_voxels_with_data = find(curr_mean_func(WM_voxels)~=0 & ~isnan(curr_mean_func(WM_voxels)));

        % counting, for each voxel, in how many participants it is "good"
        num_subjs_notnan_WM(WM_voxels_with_data) = num_subjs_notnan_WM(WM_voxels_with_data) + 1;
        clear curr_mean_func;

        wm_steps = wm_steps + 1;
        
        waitbar(wm_steps/tot_wm_steps,d,'Removing parts of the mask for which functional data exists only in <80%','Name','Create WM-FNs')

    end

    % Removing voxels with <80% participants in which they are not NaN
    WM_voxels(num_subjs_notnan_WM < threshold_notnan*length(Subj_list)) = [];
    WMmask = zeros(size(WMmask)); WMmask(WM_voxels) = 1;

    %% Saving the resulting masks
    save_mat_to_nifti(func_img1_filename, WMmask, fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'));
else
    wm_steps = wm_steps + n_tot*2;
    disp('Group WM mask is found hence skipping this step')

end

disp('Group WM mask is done')
disp('##########################################################################################')

%% 3 Grid search for K
if Corpus_check == 1
    mkdir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN'))
    if ~isfile(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['Corpus_callosum_atlas_MNI_' char(vox) 'mm.nii']))
        cc_mask = reslice_data(cc_mask_filename,fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'),0);
        cc_mask_head = niftiinfo(fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii'));
        niftisave(cc_mask,fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['Corpus_callosum_atlas_MNI_' char(vox) 'mm.nii']),cc_mask_head)
    else
        cc_mask = niftiread(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['Corpus_callosum_atlas_MNI_' char(vox) 'mm.nii']));
    end
    cc_mask_filename = fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['Corpus_callosum_atlas_MNI_' char(vox) 'mm.nii']);
end
if over_write == 1
    WM_cluster_file = dir(fullfile(output_folder,'Analysis','WM_FN','WM_clustering_K*.nii'));
    if ~isempty(WM_cluster_file)
        delete(fullfile(WM_cluster_file.folder,WM_cluster_file.name))
    end
    WM_cluster_file = [];
else
    WM_cluster_file = dir(fullfile(output_folder,'Analysis','WM_FN','WM_clustering_K*.nii'));
end

if ~isempty(WM_cluster_file)

    if length(WM_cluster_file) == 1
        K_old = str2double(WM_cluster_file(1).name(16:end-4));
    elseif length(WM_cluster_file) > 1
        K_old = zeros(1,length(WM_cluster_file));
        for i = 1:length(WM_cluster_file)
            K_old(i) = str2double(WM_cluster_file(i).name(16:end-4));
        end
    end

    answer = questdlg(['WM Clustering file already found with K = ', num2str(K_old) ,'. Do you want to build the networks again?'],...
        'WM CLustering file found','Yes','No','No');
    switch answer
        case 'Yes'
            build_net = 1;
        case 'No'
            if length(K_old) == 1
                K = K_old;
            else
                while (1)
                    ques = inputdlg(['Choose the K you want to proceed with, available options are K = ' num2str(K_old)]);
                    ques = str2double(cell2mat(ques));
                    if sum(ques == K_old)
                        K_old = ques;
                        K = K_old;
                        break
                    else
                        cancel = questdlg(['Requested K value not found please only choose from K = ' num2str(K_old)],'Not found K','Quit','Re-enter','Re-enter');

                        switch cancel
                            case 'Quit'
                                return
                        end
                    end
                end
            end
            cc_mask_filename = fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['Corpus_callosum_atlas_MNI_' char(vox) 'mm.nii']);
        otherwise
            return
    end
else
    build_net = 1;
end
if build_net == 1
    %                 if ~exist('K_old','var')
    disp('##########################################################################################')
    disp('Creating the WM_FN using K-Means')
    %% loading pre-made group average WM and GM masks (from the script create_average_WM_and_GM_masks.m)
    % reading the masks using SPM's functions
    %%% input the group white-matter/gray-matter masks
    WMmask = niftiread(fullfile(output_folder,'Analysis','Group_Masks','WMmask_allsubjs.nii')); %% input the group white-matter mask that excludes callosal voxels


    %             GMmask = spm_read_vols(spm_vol(fullfile(output_folder,'Analysis','Group_Masks','GMmask_allsubjs.nii')));

    % Excluding Corpus callousum voxels in WM mask if Corpus
    % callosum networks are to be found
    if Corpus_check == 1
        WMmask(cc_mask>0) = 0;
    end

    % finding the locations of white-matter
    WM_voxels = find(WMmask>0);

    if ispc
        user = memory;
    end
    n_WM_voxels = numel(WM_voxels);
    txt_name = 'Subsampling_info.txt';
    switch sub_sample
        
        case 'Subsample'
            if ~ispc
                user.MaxPossibleArrayBytes = inf;
            end
            if (n_WM_voxels*n_WM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling,  looking if the voxel subsampled FC is lesser than 80% of Max possible array size
                text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                sub_samp = 1;
                fclose(text_sampling);
            else % the voxel FC is too big
                response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
                switch response_
                    case 'Yes'
                        text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                        fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                        sub_samp = 1;
                        warning('May get an Memory error');
                        fclose(text_sampling);
                    case 'No'
                        text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
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
                text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                fprintf(text_sampling, 'Choosing the entire FC.');
                sub_samp = 0;
                fclose(text_sampling);
            else
                response_ = questdlg('The entire FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. You may subsample to matrix to compute the WM networks?','Memory low','Subsample','Still Use entire FC','Subsample');
                switch response_
                    case 'Subsample'
                        if (n_WM_voxels*n_WM_voxels) < 0.8*user.MaxPossibleArrayBytes % Try subsampling
                            text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                            fprintf(text_sampling, ['Choosing the subsampling statergy as the WM-voxel FC matrix is too big for the PC.', 'Max Memory required for the array = ' num2str(n_WM_voxels*n_WM_voxels*8) ' Available memory in PC = ' num2str(0.8*user.MaxPossibleArrayBytes)]);
                            sub_samp = 1;
                            fclose(text_sampling);
                        else % subsampled voxel FC is too big as well
                            response_ = questdlg('The subsampled FC is also too big for this PC to process, you may get a memmory error or the computation will be very slow. Want to proceed?','Memory low','Yes','No','No');
                            switch response_
                                case 'Yes'
                                    text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                                    fprintf(text_sampling, 'Choosing the subsampling statergy as it was choosen by the user.');
                                    sub_samp = 1;
                                    warning('May get an Memory error');
                                    fclose(text_sampling);
                                case 'No'
                                    text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
                                    fprintf(text_sampling, 'WM Networks not formed as the subsampled matrix was too big for the PC.');
                                    fclose(text_sampling);
                                    return
                                otherwise
                                    return
                            end
                        end
                    case 'Still Use entire FC'
                        text_sampling = fopen(fullfile(output_folder,'Analysis','WM_FN',txt_name),'a');
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
        p = zeros(size(WMmask));    % defining a grid of 1s and 0s across the image
        p(2:2:end, 2:2:end, 2:2:end) = 1; p(1:2:end, 1:2:end, 1:2:end) = 1;
    else
        p = ones(size(WMmask));    % defining a grid of 1s and 0s across the image
    end
    p = p(WM_voxels);   % choosing only locations of white-matter voxels
    p = find(p);    % getting the indices of subsampled voxels in the whole mask
    p = p(randperm(length(p)));     % randomly mixing the voxels' indices

    % getting the data from each participant - correlation between all WM voxels and the subsampled WM voxels (num_WM_voxels X num_subsampled_voxels)
    data_for_clustering_allsubjs = zeros(length(WM_voxels),length(p));
    num_subjs_notnan = zeros(length(WM_voxels),length(p));

    disp('Creating the voxel level FC matrix')
    % definition of a file name with functional data - so that other files will be resampled to this file's resolution
    func_img1_filename = complete_filepath(fullfile(Subj_list(1).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name]));
    if isempty(dir(fullfile(output_folder,'Analysis','WM_FN','data_for_clustering_allsubjs.mat')))
        for subji = 1:length(Subj_list)      % For loop on number of participants

            wm_steps = wm_steps + 1;
            waitbar(wm_steps/tot_wm_steps,d,'Creating the voxel level FC matrix','Name','Create WM-FNs')
           
            try
                now_func_path = complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));
                func_data = niftiread(now_func_path);
                all_timecourses = reshape(func_data, [size(func_data,1)*size(func_data,2)*size(func_data,3) size(func_data,4)]); % resampling to 2D - num_WM_voxels X num_timepoints
                current_voxels_timecourses = double(all_timecourses(WM_voxels,:));  % getting the signal across time from all white-matter voxels
                clear all_timecourses; clear func_data;

                % loading the segmentation files of all participants, for identification of WM voxels in this specific participant
                current_seg_dir = complete_filepath(fullfile(Subj_list(subji).anat_folder));
                current_GM_file = dir(fullfile(current_seg_dir, [GM_file_prefix '*.nii']));
                current_WM_file = dir(fullfile(current_seg_dir, [WM_file_prefix '*.nii']));
                current_CSF_file = dir(fullfile(current_seg_dir, [CSF_file_prefix '*.nii']));

                % resampling the segmentation files to the functional image resolution
                current_GM_mask = reslice_data(fullfile(current_seg_dir,current_GM_file(1).name), func_img1_filename, 0);
                current_WM_mask = reslice_data(fullfile(current_seg_dir,current_WM_file(1).name), func_img1_filename, 0);
                current_CSF_mask = reslice_data(fullfile(current_seg_dir,current_CSF_file(1).name), func_img1_filename, 0);

                % finding where probability for white-matter is larger than 0.2 and
                % larger than probability for grey-matter or CSF
                current_seg_mask = (current_WM_mask>current_GM_mask) & (current_WM_mask>current_CSF_mask) & (current_WM_mask>0.2);

                % finding and ignoring irrelevant voxels (e.g. not defined as WM in this specific participant, or have NaN values)
                WM_voxels_with_data = find(var(current_voxels_timecourses,[],2)~=0 & ~isnan(var(current_voxels_timecourses,[],2)) & current_seg_mask(WM_voxels)==1);
                WM_voxels_p_with_data = find(var(current_voxels_timecourses(p,:),[],2)~=0 & ~isnan(var(current_voxels_timecourses(p,:),[],2)) & current_seg_mask(WM_voxels(p))==1);

                % Calculating correlation matrix of each WM voxel to the subsampled voxels
                current_corr = corr(current_voxels_timecourses(WM_voxels_with_data,:)', current_voxels_timecourses(p(WM_voxels_p_with_data),:)');

                % adding the current connectivity matrix to the sum of all participants, for later averaging
                data_for_clustering_allsubjs(WM_voxels_with_data, WM_voxels_p_with_data) = data_for_clustering_allsubjs(WM_voxels_with_data, WM_voxels_p_with_data) + current_corr;
                num_subjs_notnan(WM_voxels_with_data, WM_voxels_p_with_data) = num_subjs_notnan(WM_voxels_with_data, WM_voxels_p_with_data) + 1;

                clear current_voxels_timecourses; clear current_corr; clear current_seg_mask; clear WM_voxels_with_data; clear WM_voxels_p_with_data;


            catch exception
                
            end
        end
        
        data_for_clustering_allsubjs = data_for_clustering_allsubjs./num_subjs_notnan;
    else
        load(fullfile(output_folder,'Analysis','WM_FN','data_for_clustering_allsubjs.mat')) 
    end

    disp(' Averaging the Voxel level FC across all participants')
    data_for_clustering_allsubjs(isnan(data_for_clustering_allsubjs))=0;
    missing_voxels = find(std(data_for_clustering_allsubjs,[],2)==0);   % finding voxels with no data
    WM_voxels(missing_voxels) = []; data_for_clustering_allsubjs(missing_voxels,:)=[];

    missing_voxels = std(data_for_clustering_allsubjs,[],1)==0;   % finding voxels with no data
    data_for_clustering_allsubjs(:,missing_voxels)=[];


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% Selecting the best K on the group-level data, by measuring stability of clustering solutions

    % Here we separate the correlation matrix columns into 4 groups
    % (cross-validation folds), therefore selecting a subset of the features.
    % We perform the clustering on each fold, and then measure the similarity
    % between clustering solutions for all pairs of folds. This is repeated for
    % each K (number of clusters). A "good" K will give the same clustering
    % solution even when using different features, and will therefore have more
    % similarity (stability) between folds (Lange et al., Neural Comput 2004).
    %
    % For a MxN connectivity matrix, we'll get four Mx(N/4) matrices, and check
    % the correspondence of their clustering solutions to one another.


    if K_range_l ~= K_range_h           % If the lower and upper values of Grid search for K are the same, that means the grid search is not necessary skip it and directly calculate the networks
        disp('Doing a grid search to find optimal K-value ')
        disp([num2str(CV_folds) ' Fold Cross validation in process to find out the optimal value of K'])
        % separating the data into subsets of features
        num_CV_folds = CV_folds;
        num_replicates = 10;
        IDX_folds_new = cell(1,num_CV_folds);
        Dice_coefficient_folds_all = zeros(1,K_range_h - K_range_l + 1);
        elb = zeros(1,K_range_h - K_range_l + 1);

        for K= K_range_l:K_range_h          % going over all possible numbers of clusters, to measure each one's stability
            disp(['Currently making clusters with K = ' num2str(K)]);
            wm_steps = wm_steps + 1;
            waitbar(wm_steps/tot_wm_steps,d,['Creating clusters with K = ' num2str(K)],'Name','Create WM-FNs')

           
            IDX_folds = zeros(size(data_for_clustering_allsubjs,1),num_CV_folds); IDX_folds_new{K} = zeros(size(IDX_folds));
            size_fold = size(data_for_clustering_allsubjs,2)/num_CV_folds;
            sumD = zeros(K,num_CV_folds);
            for c=1:num_CV_folds        % going over folds (sub-matrices)
                disp(['Cross validation fold ' num2str(c) ' in progress'])
                mat_corr_current = data_for_clustering_allsubjs(:,round((c-1)*size_fold+1):round(c*size_fold));     % the sub-correlation-matrix
                [IDX_folds(:,c),~,sumD(:,c)] = kmeans(mat_corr_current, K,'distance','correlation','replicates',num_replicates);  % calculating the clustering result for this K
            end

            % computing the difference between adjacency matrices for each fold
            size_chunk = 100;   % need to compute adjacency matrices in parts - otherwise it takes too much memory (~300 million numbers per matrix)
            num_chunks = floor(size(IDX_folds,1) / size_chunk);
            sum_diff_adjmats_folds = zeros(num_CV_folds); sum_common_connections_adjmats = zeros(num_CV_folds); sum_all_connections_adjmats = zeros(num_CV_folds);
            for ch1=1:num_chunks
                for ch2=ch1:num_chunks    % iterating over all adjacency matrix parts combinations
                    current_clustering_adjmats = zeros(size_chunk,size_chunk,num_CV_folds);
                    current_chunk1 = (ch1-1)*size_chunk+1 : ch1*size_chunk;
                    current_chunk2 = (ch2-1)*size_chunk+1 : ch2*size_chunk;

                    % creating the current adjacency matrix part, for all folds
                    for c=1:num_CV_folds
                        for i=1:size_chunk
                            if ch1 == ch2
                                j_points = i:size_chunk;
                            else
                                j_points = 1:size_chunk;
                            end
                            for j=j_points
                                % In the adjacency matrix, cell (i,j) equals 1 if voxels (i,j) belong to the same cluster and 0 otherwise
                                % This allows comparison of clustering results even if the labels of the same clusters in each result are different
                                % (e.g. if the occipital cluster in solution 1 is labeled as cluster number 4, and in solution 2 it's labeled as cluster 7)
                                if IDX_folds(current_chunk1(i),c)==IDX_folds(current_chunk2(j),c)

                                    current_clustering_adjmats(i,j,c)=1;
                                    if ch1 == ch2
                                        current_clustering_adjmats(j,i,c)=1;
                                    end
                                end
                            end
                        end
                    end
                    %%
                    % Computing the difference between adjacency matrix for different folds, and adding this difference to the sum matrix
                    for c1=1:num_CV_folds
                        for c2=c1+1:num_CV_folds
                            sum_diff_adjmats_folds(c1,c2) = sum_diff_adjmats_folds(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1)~=current_clustering_adjmats(:,:,c2))));
                            sum_common_connections_adjmats(c1,c2) = sum_common_connections_adjmats(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1) & current_clustering_adjmats(:,:,c2))));
                            sum_all_connections_adjmats(c1,c2) = sum_all_connections_adjmats(c1,c2) + (sum(sum(current_clustering_adjmats(:,:,c1) + current_clustering_adjmats(:,:,c2))));
                            sum_diff_adjmats_folds(c2,c1) = sum_diff_adjmats_folds(c1,c2);
                            sum_common_connections_adjmats(c2,c1) = sum_common_connections_adjmats(c1,c2);
                            sum_all_connections_adjmats(c2,c1) = sum_all_connections_adjmats(c1,c2);
                        end
                    end
                end
            end

            % Calculating the average difference between adjacency matrices (across all folds pairs)
            %                 sum_diff_adjmats_folds_all(K) = mean(sum_diff_adjmats_folds(~eye(num_CV_folds)));   % sum of all differences
            elb(K) = mean(mean(sumD));
            Dice_coefficient = sum_common_connections_adjmats * 2 ./ sum_all_connections_adjmats;
            Dice_coefficient_folds_all(K) = mean(Dice_coefficient(~eye(num_CV_folds)));    % Dice's coef is 1 for perfect match, 0 for no commonalities
        end

        % plotting the stability results for all K values, to identify peaks
        %                     yyaxis left
        figure; plot(Dice_coefficient_folds_all,'Marker','*'), xlim([K_range_l K_range_h])
        xlabel('K-values')
        ylabel('Dice Coefficients')

        yyaxis right
        plot(elb,'Marker','+')
        ylabel('Distortion')
        saveas(gcf,fullfile(output_folder,'Analysis','WM_FN','K_grid_search_dice_corficient_WM.png'))
        K = str2double(cell2mat(inputdlg('Choose the K-value','K-Value')));

        if isnan(K)
            return
        end
        close gcf
    else
        K = K_range_l;  % Assign K as the lower K value (doesnt matter as the lower and upper K values are the same)
    end
    %% K-means clustering of participants' mean connectivity matrix

    for k=K
        disp(['Creating WM networks using ' 'K = ' num2str(k)]);
        wm_steps = wm_steps + 1;

        waitbar(wm_steps/tot_wm_steps,d,['Creating clusters with K = ' num2str(K)],'Name','Create WM-FNs')
        
        IDX_allsubjs = kmeans(data_for_clustering_allsubjs, k,'distance','correlation','replicates',10);            % K-means clustering
        clustering_results_allsubjs = zeros(size(WMmask)); clustering_results_allsubjs(WM_voxels) = IDX_allsubjs;   % putting the clustering results in an image
        save_mat_to_nifti(func_img1_filename,clustering_results_allsubjs,fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(k) '.nii']));    % saving the results to file %% set output path
        clear clustering_results_allsubjs;
    end
    %                 end
else
    wm_steps = wm_steps + n_tot + (K_range_h-K_range_l) + 1;   
end

%% Create brain net viwer images
if over_write == 1
    WM_brainnet_image = dir(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K',num2str(K),'_BrainNet_images'],'WM_1_Anterior.png'));
    if ~isempty(WM_brainnet_image)
        delete(fullfile(WM_brainnet_image.folder,WM_brainnet_image.name))
    end
    WM_brainnet_image = [];
else
    WM_brainnet_image = dir(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K',num2str(K),'_BrainNet_images'],'WM_1_Anterior.png'));
end
if isempty(WM_brainnet_image)
    mkdir(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(K) '_BrainNet_images']))
    image_folder = fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(K) '_BrainNet_images']);

    cluster = dir(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(K) '.nii']));

    mode = 'WM';
    view_angles = [ 0 , 0 ;
        90, 0 ;
        0 , 90;
        180, 0 ;
        180,-90;
        -90, 0 ;];
    view_names = {'Posterior';
        'Right'  ;
        'Dorsal'  ;
        'Anterior' ;
        'Ventral' ;
        'left'   ;};
    for i = 1:length(view_angles)
        for j = 1:K
            BrainNet_MapCfg_WhifuN(fullfile(preproc_code_path,'BrainNetViewer_20191031','Data','SurfTemplate','BrainMesh_Ch2withCerebellum.nv'),fullfile(cluster.folder,cluster.name),fullfile(preproc_code_path,'BrainNetViewer_20191031','brainnet_parameters2.mat'),view_angles(i,:),j,fullfile(image_folder,[mode '_' num2str(j) '_' view_names{i} '.png']));%fullfile(preproc_code_path,'BrainNetViewer_20191031','brainnet_parameters2.mat')  'temp.mat'
        end
    end
end
%% Obtaining averaged time series of WMFNs
disp('##########################################################################################')
disp('Getting average timeseries from WM_FN')
if over_write == 1
    wmfn_file = dir(fullfile(output_folder,'Analysis','WM_FN',['network_avgts_wm_K' num2str(K) '.mat']));
    if ~isempty(wmfn_file)
        delete(fullfile(output_folder,'Analysis','WM_FN',['network_avgts_wm_K' num2str(K) '.mat']));
        wmfn_file = [];
    end
else
    if exist("K","var")
        wmfn_file = dir(fullfile(output_folder,'Analysis','WM_FN',['network_avgts_wm_K' num2str(K) '.mat']));
    else
        wmfn_file = [];
    end
end



if isempty(wmfn_file)
    func_img1_filename = complete_filepath(fullfile(Subj_list(1).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name])); % get one func file for the nifti header
    func_img1_filename_info = niftiinfo(func_img1_filename);
    Subj_list(1).nt_dis = func_img1_filename_info.ImageSize(4);
    nt = Subj_list(1).nt_dis;       % nt has to be the same for all participants for corpus callosum networks
    [new_data_mask,~]=y_Read(fullfile(output_folder,'Analysis','WM_FN',['WM_clustering_K' num2str(K) '.nii'])); %%% input the mask of white-matter functional netwotks
    index=unique(new_data_mask);index(index==0)=[];
    final_result = zeros(nt,numel(index),length(Subj_list) );    % nt has to be same for all participants

    for subji = 1:length(Subj_list)      % For loop on number of participants
        wm_steps = wm_steps + 1;
        
        waitbar(wm_steps/tot_wm_steps,d,'Obtaining averaged time series of WMFNs','Name','Create WM-FNs')
        now_func_path = complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));

        
        [data,~]=y_Read(now_func_path);
        roi1=isnan(data);data(roi1)=0;[x,y,z,t]=size(data);
        new_data=reshape(data,x*y*z,t);
        for k=1:length(index)
            roi=new_data_mask==k;
            result=mean(new_data(roi,:));
            final_result(:,k,subji)=result;
            clear result
        end

    end

    save(fullfile(output_folder,'Analysis','WM_FN',['network_avgts_wm_K' num2str(K) '.mat']),'final_result',"Subj_list"); %% added

else

    disp('White matter Average time series file found, hence skipping this step. ')
    load(fullfile(output_folder,'Analysis','WM_FN',['network_avgts_wm_K' num2str(K) '.mat']),'final_result','Subj_list');
    wm_steps = wm_steps + n_tot;

end

disp('Average timeseries from WM networks extracted')

disp('##########################################################################################')

if Corpus_check == 1
    disp('Creating Corpus Callosum Mask')


    %% Obtaining corpus callosum each voxel different Mask

    if over_write == 1
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
        if ~isempty(cc_file)
            delete(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
            cc_file = [];
        end
    else
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
    end
    wm_steps = wm_steps + 1;
    
    waitbar(wm_steps/tot_wm_steps,d,'Creating Corpus Callosum Mask','Name','Create WM-FNs')
    
    if isempty(cc_file)

        [data,head] = y_Read(cc_mask_filename);
        roi = find(data~=0);
        new_data_mask=zeros(size(data));

        for i = 1:length(roi)
            wp = roi(i);
            new_data_mask(wp) = i;

        end
        head.fname = fullfile(output_folder,'Analysis');
        y_Write(new_data_mask,head,fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
    else
        disp('Corpus callosum Mask file found hence skipping this step')
    end


    %% Getting the Corpus callousum signals

    if over_write == 1
        cc_net_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','cc_signals.mat'));
        if ~isempty(cc_net_file)
            delete(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','cc_signals.mat'));
            cc_net_file = [];
        end
    else
        cc_net_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','cc_signals.mat'));


    end
    disp('Getting Corpus callosum voxel timeseries')
    if isempty(cc_net_file)
        new_data_mask = niftiread(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
        now_func_path_temp = complete_filepath(fullfile(Subj_list(1).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(1).func_name]));
        temp_info = niftiinfo(now_func_path_temp);
        index=unique(new_data_mask);index(index==0)=[];
        final_result_cc = zeros(length(index),temp_info.ImageSize(4),length(Subj_list));
        for subji = 1:length(Subj_list)      % For loop on number of participants
            

            wm_steps = wm_steps + 1;
            waitbar(wm_steps/tot_wm_steps,d,'Getting Corpus callosum voxel timeseries for participant: ','Name','Create WM-FNs')
           
            now_func_path = complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));

            [data,~]=y_Read(now_func_path);
            roi1=isnan(data);data(roi1)=0;[x,y,z,t]=size(data);
            new_data=reshape(data,x*y*z,t);

            for k=1:length(index)
                roi=new_data_mask==k;
                result = new_data(roi,:);
                final_result_cc(k,:,subji)=result;
                clear result
            end

        end
        save(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','cc_signals.mat'),'final_result_cc','Subj_list'); %% added

        disp('Corpus callosum voxel timeseries acquired')
    else
        disp('Corpus callosum voxel timeseries file found hence skipping this step')
        load(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','cc_signals.mat'),'final_result_cc'); 
        wm_steps = wm_steps + n_tot;
    end
    %% Partial Correlation analysis
    disp('Partial correlation between the Corpus Callosum Voxels timeseries and WM Network Average timseries')
    if over_write == 1
        par_cor_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['parcorr_result_K',num2str(K),'.mat']));
        if ~isempty(par_cor_file)
            delete(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['parcorr_result_K',num2str(K),'.mat']));
            par_cor_file = [];
        end
    else
        par_cor_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['parcorr_result_K',num2str(K),'.mat']));
    end
    wm_steps = wm_steps + 1;
    waitbar(wm_steps/tot_wm_steps,d,'Computing Partial Correlations between Corpus Callosum Voxels and WM-FNs','Name','Create WM-FNs')

   
    if isempty(par_cor_file)

        network_final_result=final_result;clear final_result;
        parcorr_result = zeros(size(final_result_cc,1),size(network_final_result,2),size(network_final_result,3));
        for i=1:length(network_final_result(1,1,:)) %%% the number of participants
            voxel=final_result_cc(:,:,i);
            network=network_final_result(:,:,i);
            for j=1:length(network_final_result(1,:,1))  %%% the number of white-matter functional networks
                net=(network(:,j));
                reg=network;reg(:,j)=[];
                for k=1:length(voxel(:,1))  %%% the number of callosal voxels
                    y_voxel=(voxel(k,:))';
                    [Rho,~]=partialcorr(y_voxel,net,reg);
                    Rho=0.5*(log((1+Rho)/(1-Rho)));
                    parcorr_result(k,j,i)=Rho;
                end
            end
        end
        roi=isnan(parcorr_result);
        parcorr_result(roi)=0;

        save(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['parcorr_result_K',num2str(K),'.mat']),'parcorr_result'); %% added
        disp('Partial Correlation computed')
    else
        disp('Partial Correlation file found, hence skipping this step')
        load(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['parcorr_result_K',num2str(K),'.mat']),'parcorr_result')
    end

    %% create CC atlas using partial correlation
    if over_write == 1
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii']));
        if ~isempty(cc_file)
            delete(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii']));
            cc_file = [];
        end
    else
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii']));
    end
    disp('Creating Corpus Callosum Networks that have maximal partial correlation with the WM networks')

    wm_steps = wm_steps + 1;
    waitbar(wm_steps/tot_wm_steps,d,'Creating Corpus Callosum Networks that have maximal partial correclation with the WM networks','Name','Create WM-FNs')
    
    if isempty(cc_file)
        wp = zeros(size(parcorr_result(:,:,1)));
        for i = 1:size(parcorr_result,1)  % cc voxel
            for j = 1:size(parcorr_result,2) % wm-networks
                [~,~,~,stat] = ttest(squeeze(parcorr_result(i,j,:)));
                wp(i,j) = stat.tstat;
            end
        end

        [~,max_idx] = max(wp,[],2);

        new_data_mask = niftiread(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));
        head = niftiinfo(fullfile(output_folder,'Analysis','Corpus_Callosum_FN','CC_thres.nii'));

        [x,y,z] = size(new_data_mask);

        new_mask = new_data_mask;
        cc_atlas = zeros(x,y,z);
        for k=1:size(parcorr_result,1)   %% the number of callosal voxel
            a=new_mask==k;
            cc_atlas(a)=max_idx(k);
        end

        niftisave(cc_atlas,fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii']),head);

    else
        disp('White matter Corpus callosum atlas file found, hence skipping this step. ')
    end
    disp('Corpus Callosum Networks Created.')
    %% Create brain net viwer images
    if over_write == 1
        CC_brainnet_image = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K',num2str(K),'_BrainNet_images'],'CC_1_Anterior.png'));
        if ~isempty(CC_brainnet_image)
            delete(fullfile(CC_brainnet_image.folder,CC_brainnet_image.name))
        end
        CC_brainnet_image = [];
    else
        CC_brainnet_image = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K',num2str(K),'_BrainNet_images'],'CC_1_Anterior.png'));
    end

    if isempty(CC_brainnet_image)
        mkdir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '_BrainNet_images']))
        image_folder = fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '_BrainNet_images']);

        cluster = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii']));

        mode = 'CC';
        view_angles = [ 0 , 0 ;
            90, 0 ;
            0 , 90;
            180, 0 ;
            180,-90;
            -90, 0 ;];
        view_names = {'Posterior';
            'Right'  ;
            'Dorsal'  ;
            'Anterior' ;
            'Ventral' ;
            'left'   ;};
        for i = 1:length(view_angles)
            for j = 1:K
                BrainNet_MapCfg_WhifuN(fullfile(preproc_code_path,'BrainNetViewer_20191031','Data','SurfTemplate','BrainMesh_Ch2withCerebellum.nv'),fullfile(cluster.folder,cluster.name),fullfile(preproc_code_path,'BrainNetViewer_20191031','brainnet_parameters2.mat'),view_angles(i,:),j,fullfile(image_folder,[mode '_' num2str(j) '_' view_names{i} '.png']));%fullfile(preproc_code_path,'BrainNetViewer_20191031','brainnet_parameters2.mat')  'temp.mat'
            end
        end
    end
    %% Obtaining averaged time series of Corpus callosum networks
    disp('Getting average timeseries from Corpus Callosum Networks')
    if over_write == 1
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['network_avgts_cc_K' num2str(K) '.mat']));
        if ~isempty(cc_file)
            delete(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['network_avgts_cc_K' num2str(K) '.mat']));
            cc_file = [];
        end
    else
        cc_file = dir(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['network_avgts_cc_K' num2str(K) '.mat']));

    end

    if isempty(cc_file)
        nt = Subj_list(1).nt_dis;       % nt has to be the same for all participants for Corpus_Callosum_FN
        [new_data_mask,~]=y_Read(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['CC_network_from_WM_K' num2str(K) '.nii'])); %%% input the mask of white-matter functional netwotks
        index=unique(new_data_mask);index(index==0)=[];
        final_result_ccn = zeros(nt,numel(index),length(Subj_list) );    % nt has to be same for all participants
        for subji = 1:length(Subj_list)      % For loop on number of participants
            

            wm_steps = wm_steps + 1;
            waitbar(wm_steps/tot_wm_steps,d,'Getting average timeseries from Corpus Callosum Networks','Name','Create WM-FNs')
            now_func_path = complete_filepath(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name]));

            [data,~]=y_Read(now_func_path);
            roi1=isnan(data);data(roi1)=0;[x,y,z,t]=size(data);
            new_data=reshape(data,x*y*z,t);
            for k=1:length(index)
                roi=new_data_mask==k;
                result=mean(new_data(roi,:));
                final_result_ccn(:,k,subji)=result;
                clear result
            end
        end
        save(fullfile(output_folder,'Analysis','Corpus_Callosum_FN',['network_avgts_cc_K' num2str(K) '.mat']),'final_result_ccn','Subj_list'); %% added
    end
    disp('Average timeseries from Corpus Callosum networks extracted')
end

close(d)
disp('##########################################################################################')


function [Subj_list,rm] = load_subjects(folder,name,first)
if nargin < 4
    first = 0;
end
try
    opts = detectImportOptions(fullfile(folder,name),'Delimiter',',');
    opts = setvartype(opts, 'char'); % or 'string', depending on your MATLAB version
    T1 = readtable(fullfile(folder,name),opts);

    T = readtable(fullfile(folder,name),'Delimiter',',');

    T.name = T1.name;

    if first
        T.error = zeros(height(T),1);
        T.motion_ex = zeros(height(T),1);
        rm = logical(T.manual_ex);
        Subj_list = table2struct(T(~rm,:));
    else
        rm = (logical(T.error) | logical(T.motion_ex) | logical(T.manual_ex));
        Subj_list = table2struct(T(~rm,:));
    end
catch
    Subj_list = [] ;
end

end

function Subj_list_all = load_subjects_all(folder,name,new_run,overwrite)
if nargin < 4
    new_run = 0;
end

opts = detectImportOptions(fullfile(folder,name),'Delimiter',',');
opts = setvartype(opts, 'char'); % or 'string', depending on your MATLAB version
T1 = readtable(fullfile(folder,name),opts);

T = readtable(fullfile(folder,name),'Delimiter',',');

T.name = T1.name;

try
    if new_run
        T.error = zeros(height(T),1);
        if ~ismember('motion_ex', T.Properties.VariableNames)
            T.motion_ex = zeros(height(T),1);
        end

        if overwrite
            T.motion_ex = zeros(height(T),1);
        end
        Subj_list_all = table2struct(T);

    else

        Subj_list_all = table2struct(T);
    end
catch
    Subj_list_all = [] ;
end

end
