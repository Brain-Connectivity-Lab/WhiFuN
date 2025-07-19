
%% This code written by Pratik Jain.
%% This code was written with the help of different preprocessing scripts given by
%% Dr. Xin Di, Dr. Rakibul Hafeez, Dr. Wang Pan, Donna Chen and Wonbum Sohn
%% Under guidance of Dr Andrew Micheal and Dr. Bharat Biswal.
clc
clear
%% Addpaths

whifun_path = 'C:\Users\krish\Box\WhiFuN_v2_beta';
spm_path = 'D:\toolboxes\spm12\spm12\';

%% Setup Parameters
output_folder = 'C:\Users\krish\Box\practice_NY_op';     % Output Folder Path: Select the folder path where all the quality control plots generated during preprocessing, analysis results of the toolbox will be stored.

if exist(fullfile(output_folder,'parameters.mat'),"file")
    load(fullfile(output_folder,'parameters.mat'))                           % % load parameters saved during initial data check, if they were changed after initial data check, the change will be applied later in the code.
else
    msgbox('Please Run initial Datacheck from WhiFuN GUI and try again','Parameter file not found')
end
%% Modify Parameters here
% Preprocess Parameters
n_vol_dis = 10;                  % Discard initial volumes/timepoints to achieve magnetization stability, put 0 if no volumes should be discarded

% FD thresholds for motion outlier detection (mm)
% Framewise displacement (FD): A measure to reject participants having excessive motion. FD is calculated for every time point using equations given by Power et. al. (2011).
% These thresholds can also be revised/changed after preprocesssing is complete using the tools tab.
max_fd = 6;              % Threshold on max FD , if the max FD (across every time point) of a participant is greater than this threshold then the participant will be rejected
mean_fd = 0.25;           % Threshold on mean FD , if the mean FD (across every time point) of a participant is greater than this threshold then the participant will be rejected
greater_than_20 = 0.25;   % Threshold on greater than 20%, if the FD values is greater than this threshold for 20% or more volumes, then the participant will be rejected

% Nuisance Regression
% Regress out the noise from all the voxels in the brain.
% It is assumed that the BOLD signal from CSF regions is noisy as it contains
% no neuronal information. Thus the user can regress out, either the mean CSF BOLD signal
% or the First n PCA components of the CSF BOLD signal.

Reg_drop = 'Mean CSF'; %'Mean CSF' , 'PCA CSF' ,'No Regression'
motion_reg = 1;     % 1 --> this will also regress out the 24 Friston motion parameters (Friston et. al. 1996) from every voxel in the brain.

if strcmp(Reg_drop,'PCA CSF')
    n_pca = 5;                   % number of pca components for CSF
end

% Temporal filtering :Temporal Butterworth bandpass filter of 2nd order

filter_check = 0;  %If 1, Butterworth bandpass filter of 2nd order will be applied on every brain voxel

if filter_check
    filter_lp = 0.01; %#ok<UNRCH> Low frequency cutoff
    filter_hp = 0.15;           % High frequency cutoff
end

% Smoothing : Spatial smoothing. Used to increase the signal to noise ratio in fMRI timeseries.

smooth_drop = 'WM-GM Seperate';  % Smoothing options: 'WM-GM Seperate','All Together','No Smoothing'. Since the focus of WhiFuN is White Matter(WM) regions, it is recommended to smooth the WM and Gray Matter (GM) seperately to ensure there is no influence of GM voxels on WM.
smooth_fwhm = 4;                 % Smoothing Full width half maximum

% Normalisation
% Normalization transforms the images from participant space to Montreal Neurological Institute (MNI) space.
% The voxel size of the transformed image in MNI space is required. The default is 3mm as later,
% during the creation of WM and GM Functional Networks, a voxel level Functional Connectivity Matrix is created,
% if a smaller voxel size is choosen computation of WM and GM networks could cause memory problems.

vox = 3;                         % Voxel Size of the Normalized (MNI) space

% Parellel Processing
par_on = 0;
if par_on
    parforArg = 4;
end
% Error handeling parameters
% Ignore any previous results
% -> 1 If previous preprocessing files exist (delete them and rerun)
% -> 0 If previous preprocessing files exits (Keep them and skip)
over_write = 0;




%%          These values can be changed but default is recommended
Cut_pre = 'c_';                                                             % Prefix for the Discarding Initial volumes File
Realign_pre = 'r';                                                          % Prefix for the Realignment File
skull_pre = 'b';                                                            % Prefix for the Skull Stripped File
Reg_pre = 'REG_';                                                           % Prefix for the Regressed File
f_pre = 'f';                                                                % prefix for filtered file
Norm_pre = 'w';                                                             % Prefix for the Normalized File
Smooth_pre = 's';                                                           % Prefix for the Smoothed File

% CSF_thresh = '0.95';
%% Preprocesssing Code

if isempty(data_path)
    msgbox('Please specify the Participant folder, Run Data Check, define Preprocessing parameters and then Run Preprocessing.','Participant Data folder path empty')
    return
end


if isempty(output_folder)
    msgbox('Please specify the output_folder, Run Data Check, define Preprocessing parameters and then Run Preprocessing.','Output folder Path empty')
    return
end
quality_control_path = fullfile(output_folder,'Quality_control');


Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv',1);
Subj_list = load_subjects(output_folder,'Subj_list.csv');
if ~exist(fullfile(output_folder,'Analysis','Group_Masks'),'dir')
    msgbox('Please Run Initial Data check before Running the Preprocessing and Analyses ', 'Run Initial Data Check')
    return
end



if n_vol_dis == 0
    Cut_pre = '';
end


spm_path = which('spm');
spm_path = spm_path(1:end-5);
preproc_code_path = whifun_path;

addpath(preproc_code_path)
addpath(fullfile(preproc_code_path,'whifun_functions'))
cd (data_path);

% PCA or Mean for WM and CSF timeseries data that will be used as a
% regressor in temporal Regression
% 1 --> Will use PCA for getting the CSF Components
% 0 --> will use mean WM and CSF components (faster)

switch Reg_drop
    case 'Mean CSF'
        pca_for_temp_reg = 0;
        Reg_ = 1;
    case 'PCA CSF'
        pca_for_temp_reg = 1;

        Reg_ = 1;
    case 'No Regression'
        Reg_pre = '';
        Reg_ = 0;
end
if filter_check

    if filter_lp > filter_hp                                                %#ok<UNRCH>
        error(sprintf('Please check the filter cutoffs, lower_cutoff should be less than higher cutoff, \nbut found otherwise\n'))
    end
else
    f_pre = '';

end

switch smooth_drop
    case 'WM-GM Seperate'
        WM_GM = 1;
        Smooth_ = 1;
    case 'All Together'
        WM_GM = 0;
        Smooth_ = 1;
    case 'No Smoothing'
        Smooth_pre = '';
        Smooth_ = 0;
        WM_GM = 0;
end

% Saving all the parameters in Output Folder for future
% reference

save(fullfile(output_folder,"parameters.mat"),"data_path","output_folder",'comm_sess_name','comm_subj_name','bids_check',...
    'func_folder_name','anat_folder_name','func_data_name',"anat_data_name",'n_vol_dis',...
    'max_fd','CSF_thres','Reg_drop','n_pca','motion_reg','filter_lp','filter_hp',"smooth_drop",...
    "smooth_fwhm","vox","grp_gm_thres","grp_wm_thres","K_range_l",'K_range_h',"CV_folds","K_range_l_gm",'K_range_h_gm'...
    ,"CV_folds_gm","Corpus_check",...
    "over_write",'filter_check','mean_fd','greater_than_20')
%   Loop all participants in this group
n_tot = length(Subj_list);

if ~par_on
    parforArg = 0; % 0 workers means serial execution
else
    par_p = Par(n_tot);
end
addpath(fullfile(preproc_code_path,'parTicToc'));

for subji=1:n_tot%(subji=1:n_tot,parforArg) %par
    if ~par_on
        tic
    else
        Par.tic;
    end
    log_fileID = fopen(fullfile(quality_control_path,'logs',[Subj_list(subji).name '_log_info.txt']),'a');

    disp(' ')
    disp(['Currently Processing ' Subj_list(subji).name])
    %%     1     Unzipping

    %% Functional Data
    disp('##########################################################################################')
    disp(['Unzipping files for ' Subj_list(subji).name])
    now_func_path = dir(fullfile(Subj_list(subji).func_folder,Subj_list(subji).func_name)) ;
    if isempty(now_func_path)
        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Subj_list(subji).func_name '*'])) ;
    end
    if length(now_func_path)>1  % If more than one func files found choose the one that was created the first

        [~,idx] = sort([now_func_path.datenum]);
        now_func_path = now_func_path(idx);
        now_func_path(2:end) = [];
        warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first for ' Subj_list(subji).name]);
    end
    cd(now_func_path(1).folder)
    %   To extract the names of existing nii.gz files
    file_name = now_func_path.name ;            %   Ex: file name.nii.gz
    separate_name = split(file_name, '.') ;     %   Ex: 3×1 cell array: {'file name'} {'nii'        } {'gz'         }
    data_name = char(separate_name(1)) ;        %   Ex: file name
    data_type = char(separate_name(2)) ;        %   Ex: nii

    %   If there is unzipped .nii file, skip this unzipping step
    if ~isfile([data_name '.' data_type])       %   If there is no nii file
        if isfile(file_name)                  %   If there is gz file
            gunzip(file_name)
            disp(['Complete unziping of functional data in ' file_name])
            Subj_list(subji).func_name = [data_name '.' data_type];
        elseif ~isfile(file_name)             %   If there is not gz file also
            disp('You need a .nii or a .gz file of functional data for further processing.')
        end
    elseif isfile([data_name '.' data_type])    %   If there is nii file already
        disp(['You have already a .nii file of functional data for participant , ' Subj_list(subji).name,' hence skipping this step.'])
        Subj_list(subji).func_name = [data_name '.' data_type];
    end

    now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
    if isempty(now_anat_path)
        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[Subj_list(subji).anat_name '.nii*'])) ;
    end
    if length(now_anat_path)>1  % If more than one func files found choose the one that was created the first

        [~,idx] = sort([now_anat_path.datenum]);
        now_anat_path = now_anat_path(idx);
        now_anat_path(2:end) = [];
        warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first for ' Subj_list(subji).name]);
    end
    cd(now_anat_path(1).folder)

    %   To extract the names of existing nii.gz files
    file_name = now_anat_path.name ;               %   Ex: file name.nii.gz
    separate_name = split(file_name, '.') ;     %   Ex: 3×1 cell array: {'file name'} {'nii'        } {'gz'         }
    data_name = char(separate_name(1)) ;        %   Ex: file name
    data_type = char(separate_name(2)) ;        %   Ex: nii

    %   If there is unzipped .nii file, skip this unzipping step
    if ~isfile([data_name '.' data_type])       %   If not nii file
        if isfile(file_name)                  %   If there is gz file
            gunzip(file_name)
            disp(['Complete unziping of anatomical data in ' file_name])
            Subj_list(subji).anat_name = [data_name '.' data_type];
        elseif ~isfile(file_name)             %   If there is not gz file also
            disp(['You need a .nii or a .gz file of anatomical data for further processing for ' Subj_list(subji).name])
        end
    elseif isfile([data_name '.' data_type])    %   If there is nii file already
        disp(['You have already a .nii file of anatomical data, ' Subj_list(subji).name,' so skipping to unzip  .gz file.'])
        Subj_list(subji).anat_name = [data_name '.' data_type];
    end

    %                 disp('___________________________________________________________________________________________')

    %% 3  Discarding intial volumes
    %                 disp('___________________________________________________________________________________________')


    if n_vol_dis ~= 0
        disp(['Discarding ',num2str(n_vol_dis ),' Initial Volumes'])

        try
            % Check if the discarded volume file already exists
            if over_write == 1 % if overwrite is 1, even if the file already exists delete it and create a new one
                dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
                dir(fullfile(Subj_list(subji).func_folder,Subj_list(subji).func_name)) ;
                cfunc_dir = dir(fullfile(Subj_list(subji).func_folder,[Cut_pre Subj_list(subji).func_name])) ;
                if ~isempty(cfunc_dir)
                    delete(fullfile(cfunc_dir.folder,cfunc_dir.name))
                end
                cfunc_dir = [];

            else

                cfunc_dir = dir(fullfile(Subj_list(subji).func_folder,[Cut_pre Subj_list(subji).func_name])) ;
            end

            if isempty(cfunc_dir)
                now_func_path = dir(fullfile(Subj_list(subji).func_folder,Subj_list(subji).func_name)) ;
                if length(now_func_path) > 1

                    [~,idx] = sort([now_func_path.datenum]);
                    now_func_path = now_func_path(idx);
                    now_func_path(2:end) = [];
                    warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first.']);
                end
                func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));    % read the nifti header
                func_image = niftiread(fullfile(now_func_path.folder,now_func_path.name));   % read the image

                cfunc_image = func_image(:,:,:,n_vol_dis+1:end);                             % Discard the volumes
                Subj_list(subji).nt_dis = Subj_list(subji).nt - n_vol_dis;
                %                             Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).nt_dis = Subj_list(subji).nt - n_vol_dis;
                niftisave(cfunc_image,fullfile(now_func_path.folder,[Cut_pre ,now_func_path.name]),func_info); % Save the new file
                disp(['Discarding volumes is complete for ' Subj_list(subji).name])
            else
                info = niftiinfo(fullfile(cfunc_dir.folder,cfunc_dir.name));
                Subj_list(subji).nt_dis = info.ImageSize(4);
                disp(['Volumes already discarded for ' Subj_list(subji).name])
            end

        catch exception                                                                       % If error is found

            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            disp(['Preprocessing has encountered errors in Discarding Initial Volumes for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')


            write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
            Subj_list(subji).error = 1;
            %                                                 Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).error = 1;         % Remove participant from further preprocessing
            continue
        end
        disp(['Discarding Volumes over for ' Subj_list(subji).name])
    else
        Subj_list(subji).nt_dis = Subj_list(subji).nt;

    end
    %                 disp('___________________________________________________________________________________________')
    %%     4     Realignment
    disp(['Realignment Begins for ' Subj_list(subji).name])

    try

        % Check if any previous realignment file exists
        if over_write == 1

            rfunc_dir = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            if ~isempty(rfunc_dir)
                delete(fullfile(rfunc_dir.folder,rfunc_dir.name))
            end
            rfunc_dir = [];

        else
            rfunc_dir = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        end

        if isempty(rfunc_dir)

            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Cut_pre Subj_list(subji).func_name])) ;

            if length(now_func_path) > 1

                [~,idx] = sort([now_func_path.datenum]);
                now_func_path = now_func_path(idx);
                now_func_path(2:end) = [];
                warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first.']);
            end
            cd(now_func_path(1).folder)
            temp = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));
            nt = temp.ImageSize(4);
            realignment_op = whifun_realignment(now_func_path,Realign_pre,nt);

            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Realignment\n');
            fprintf(log_fileID,'%s',  realignment_op);


        else
            disp(['Participant ' Subj_list(subji).name ' is already realigned hence skipping this step'])
        end

    catch exception                                                                       % If error is found
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Realignment for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display

        Subj_list(subji).error = 1;                                                       % Remove participant from further preprocessing
        continue
    end
    disp(['Realignment over for ' Subj_list(subji).name])
    %                 disp('___________________________________________________________________________________________')
    %% 5 Framewise displacement
    disp(['Framewise Displacement Begins for ' Subj_list(subji).name])

    now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
    cd(now_func_path(1).folder)

    func_name_wo_ext = strsplit(Subj_list(subji).func_name,'.');

    now_func_path = dir(fullfile(Subj_list(subji).func_folder,['rp_' Cut_pre func_name_wo_ext{1} '.txt'])) ;
    rp_rest = load(fullfile(now_func_path.folder,now_func_path.name));              % input the text file generated at the Realignment stage

    rp_diff_trans = diff(rp_rest(:,1:3));                      % The first 3 parameters tell the displacement in x,y, and z direction in mm. Here the vector difference operator is used to get the derivative of vector. (framewise difference)
    %                 rp_diff_rotat = diff(rp_rest(:,4:6)*180/pi);             % % The last  3 parameters tell the rotation values pitch, yaw and roll in radians (here we convert them to degrees)
    rp_diff_rotat = diff(rp_rest(:,4:6)*50);                   % Converting angles to mm by asuming a 50mm radius circle


    fd = sum(rp_diff_trans,2) + sum(rp_diff_rotat,2)  ;
    [fd_max,loc_fd_max_trans] = max(fd);                     % Get the maximum framewize displacement
    fd_mean = mean(fd);                                               % Get the mean framewize displacement
    fd_greater_than_02 = nnz(fd>greater_than_20)/length(fd)*100;

    fileID = fopen(fullfile(quality_control_path,'Head_motion',['excluded_' Subj_list(subji).name '_.txt']),'w+');
    if fd_max > max_fd
        msg = ['Excluded participant ' Subj_list(subji).name ' as it had max motion at location ' ...
            num2str(loc_fd_max_trans) ' of ' num2str(fd_max) ' which is greater than ' num2str(max_fd) ' mm max threshold'];
        disp(msg) ;
        fprintf(fileID, [msg '\n']);
        Subj_list(subji).motion_ex = 1;
    end

    if fd_mean > mean_fd
        msg = ['Excluded participant ' Subj_list(subji).name ' as it had mean fd motion ',...
            'of ' num2str(fd_mean) ' which is greater than ' num2str(mean_fd) ' mm mean threshold'];
        disp(msg) ;
        fprintf(fileID, [msg '\n']);
        Subj_list(subji).motion_ex = 1;
    end

    if fd_greater_than_02 > 20
        msg = ['Excluded participant ' Subj_list(subji).name ' as it had ',num2str(fd_greater_than_02) ' percent of fMRI volumes (timepoints) ',...
            'greater than ' num2str(greater_than_20) ' threshold'];
        disp(msg) ;
        fprintf(fileID, [msg '\n']);

        Subj_list(subji).motion_ex = 1;
    end

    if Subj_list(subji).motion_ex == 1
        continue
    end

    disp(['Framewise displacement over for ' Subj_list(subji).name])
    %                 disp('___________________________________________________________________________________________')
    %%     6     Segmentation

    disp(['Segmentation has started for ' Subj_list(subji).name])

    try

        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
        if length(now_anat_path) > 1

            [~,idx] = sort([now_anat_path.datenum]);
            now_anat_path = now_anat_path(idx);
            now_anat_path(2:end) = [];
            warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
        end
        if over_write == 1                                                  % Check for a previous segmentation file

            y_banat_dir = dir(fullfile(Subj_list(subji).anat_folder,['y_' Subj_list(subji).anat_name])) ;
            if ~isempty(y_banat_dir)
                delete(fullfile(y_banat_dir.folder,y_banat_dir.name))
            end
            y_banat_dir = [];
        else
            y_banat_dir = dir(fullfile(Subj_list(subji).anat_folder,['y_' Subj_list(subji).anat_name])) ;
        end
        if isempty(y_banat_dir)
            cd(now_anat_path(1).folder)
            seg_op = whifun_segment(now_anat_path,spm_path);

            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Segmentation\n');
            fprintf(log_fileID,'%s',  seg_op);

        else
            disp(['Segmentation file found for ' Subj_list(subji).name,'  hence skipping this step']);
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Segmentation for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;                                                        % Remove participant from further preprocessing
        continue
    end
    disp(['Segmentation done for ' Subj_list(subji).name])


    %%     7     Skull Stripping

    disp(['Skull Stripping started for ' Subj_list(subji).name])

    disp(['Currently Processing ' Subj_list(subji).name])
    try

        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
        if length(now_anat_path) > 1

            [~,idx] = sort([now_anat_path.datenum]);
            now_anat_path = now_anat_path(idx);
            now_anat_path(2:end) = [];
            warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
        end
        cd(now_anat_path(1).folder)
        if over_write == 1
            banat_dir = dir(fullfile(now_anat_path.folder,[skull_pre now_anat_path.name]));
            if ~isempty(banat_dir)
                delete(fullfile(banat_dir.folder,banat_dir.name))
            end
            banat_dir = [];%dir(fullfile(now_anat_path.folder,[skull_pre now_anat_path.name]));
        else

            banat_dir = dir(fullfile(now_anat_path.folder,[skull_pre Subj_list(subji).anat_name]));
        end

        m_file = dir(fullfile(now_anat_path(1).folder, ['m' Subj_list(subji).anat_name]));
        if isempty(banat_dir)

            if length(m_file)>1
                m_not_needed_file = dir(fullfile(now_anat_path(1).folder, ['mwc' Subj_list(subji).anat_name]));

                % convert structs into matrices
                A = struct2cell(m_file); A(2:end,:) = [];
                B = struct2cell(m_not_needed_file);  B(2:end,:) = [];
                % intersect the equivalent representation
                [~, ia] = intersect(A,B );
                m_file(ia) = [];
            end
            skull_op = whifun_skullstrip(m_file,now_anat_path,Subj_list(subji).anat_name,skull_pre);

            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Skull Strip\n');
            fprintf(log_fileID,'%s',  skull_op);
        else
            disp('Skull Stripped file found, hence skipping this step');
        end
        disp(['Skull Stripping done for ' Subj_list(subji).name])
        %                     disp('___________________________________________________________________________________________')
        % Making mask for regression
        disp(['Making Mask for regression for ' Subj_list(subji).name])
        if over_write == 1
            anat_mask = dir(fullfile(now_anat_path.folder,'anat_mask.nii'));
            if ~isempty(anat_mask)
                delete(fullfile(anat_mask.folder,anat_mask.name))
            end
            anat_mask = [];
        else
            anat_mask = dir(fullfile(now_anat_path.folder,'anat_mask.nii'));
        end
        if isempty(anat_mask)

            anat_mask_op = whifun_anat_mask(m_file,now_anat_path,Subj_list(subji).anat_name,0);

            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Anat Mask\n');
            fprintf(log_fileID,'%s', anat_mask_op);
        end

        % Making anat mask in MNI Space
        disp(['Making Anat mask in MNI Space for ' Subj_list(subji).name])
        if over_write == 1
            wanat_mask = dir(fullfile(now_anat_path.folder,'wanat_mask.nii'));
            if ~isempty(wanat_mask)
                delete(fullfile(wanat_mask.folder,wanat_mask.name))
            end
            wanat_mask = [];%dir(fullfile(now_anat_path.folder,[skull_pre now_anat_path.name]));
        else
            wanat_mask = dir(fullfile(now_anat_path.folder,'wanat_mask.nii'));
        end
        if isempty(wanat_mask)

            anat_mask_mni_op = whifun_anat_mask(m_file,now_anat_path,Subj_list(subji).anat_name,1);
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Anat Mask MNI\n');
            fprintf(log_fileID,'%s',  anat_mask_mni_op);
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Skull strip for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;

        continue
    end


    %                 disp('___________________________________________________________________________________________')

    %% 8 COREGISTRATION REST
    % Coregister anatomical image to the functional image
    disp(['Coregisteration has started for ' Subj_list(subji).name])

    try

        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;
        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Cut_pre Subj_list(subji).func_name])) ;
        if over_write == 1
            coreg_dir = [];
        else
            cut_func_header = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));
            realign_func_header = niftiinfo(fullfile(now_func_path.folder,[Realign_pre now_func_path.name]));

            if prod(cut_func_header.Transform.T == realign_func_header.Transform.T,'all')
                coreg_dir = [];
            else
                coreg_dir = 1;
            end
        end
        if isempty(coreg_dir)

            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;

            mean_func = dir(fullfile(Subj_list(subji).func_folder,['mean' Cut_pre Subj_list(subji).func_name])) ;

            nt = Subj_list(subji).nt_dis;
            coreg_op = whifun_coreg(now_anat_path,now_func_path,mean_func,nt);

            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Coregisteration\n');
            fprintf(log_fileID,'%s',  coreg_op);
        else
            disp(['Co-registeration file found, hence skipping this step for ' Subj_list(subji).name]);
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Coregisteration for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;                                                          % Remove participant from further preprocessing
        continue
    end


    %                  disp('___________________________________________________________________________________________')
    %%     9     Making CSF_MASK for REST
    disp(['CSF_MASK extractation has started for ' Subj_list(subji).name])

    if Reg_ == 1
        try

            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;

            if over_write == 1

                csf_mask_dir = dir(fullfile(Subj_list(subji).anat_folder,['CSF_MASK' CSF_thres '.nii'])) ;
                if ~isempty(csf_mask_dir)
                    delete(fullfile(csf_mask_dir.folder,csf_mask_dir.name))
                end
                csf_mask_dir = [];
            else
                csf_mask_dir = dir(fullfile(Subj_list(subji).anat_folder,['CSF_MASK' char(CSF_thres) '.nii'])) ;
            end
            if isempty(csf_mask_dir)
                csf_mask_op = whifun_create_csf_mask(Subj_list(subji).anat_name,now_func_path,now_anat_path,CSF_thres);
                fprintf(log_fileID,'#####################################################################################################################\n \n');
                fprintf(log_fileID, 'CSF Mask\n');
                fprintf(log_fileID,'%s',  csf_mask_op);


            else
                disp(['CSF_MASK file found, hence skipping this step for ' Subj_list(subji).name]);
            end

        catch exception
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            disp(['Preprocessing has encountered errors in CSF_Mask extraction for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

            write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
            Subj_list(subji).error = 1;                       % Remove participant from further preprocessing
            continue
        end
    else
        disp('Since No Regression is Specified, CSF Mask will not be created')
    end

    disp(['CSF_MASK extraction is done for ' Subj_list(subji).name])
    %                  disp('___________________________________________________________________________________________')
    %%    10     Extracting CSF time-series

    if Reg_ == 1
        disp(['Extractation of CSF Timeseries has started for ' Subj_list(subji).name])

        try

            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;

            % loading CSF MASKS
            if over_write == 1
                Reg_dir = dir(fullfile(now_func_path.folder,'covariance_csf_REST.mat'));
                if ~isempty(Reg_dir)
                    delete(fullfile(Reg_dir.folder,Reg_dir.name))
                end
                Reg_dir = [];
            else
                Reg_dir = dir(fullfile(now_func_path.folder,'covariance_csf_REST.mat')) ;
            end
            if isempty(Reg_dir)
                whifun_extract_csf_ts(now_anat_path,now_func_path,CSF_thres,pca_for_temp_reg,n_pca)
            else
                disp(['Regresion file found, no need to extract the CSF timeseries for ' Subj_list(subji).name])
            end
        catch exception
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            disp(['Preprocessing has encountered errors in CSF timeseries extraction for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            % Increament the error pointer

            write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
            Subj_list(subji).error = 1;   % Remove participant from further preprocessing

        end

        disp(['Extractation of CSF Timeseries is done for ' Subj_list(subji).name])
        %                      disp('___________________________________________________________________________________________')
        %%     11     TEMPORAL REGRESSION: removing nusisance signals and motion correction

        disp(['Nuisance REGRESSION is started for ' Subj_list(subji).name])


        try
            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            cd(now_func_path(1).folder)

            now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;

            if over_write == 1

                Reg_dir = dir(fullfile(Subj_list(subji).func_folder,[Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                if ~isempty(Reg_dir)
                    delete(fullfile(Reg_dir.folder,Reg_dir.name))
                end
                Reg_dir = [];
            else
                Reg_dir = dir(fullfile(Subj_list(subji).func_folder,[Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            end

            if isempty(Reg_dir)
                whifun_regress(now_func_path,Subj_list(subji).name,now_anat_path,motion_reg,Cut_pre,Subj_list(subji).func_name,n_pca,Reg_pre)
            else
                disp(['Nuisance Regression file found, hence skipping this step for ' Subj_list(subji).name]);
            end

        catch exception
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            disp(['Preprocessing has encountered errors in Temporal Regression for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

            write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
            Subj_list(subji).error = 1;  % Remove participant from further preprocessing

        end
        disp(['Nuisance REGRESSION is done for ' Subj_list(subji).name])
    else
        disp('Nuisance Regression Skipped')
        [~] = whifun_create_rest_mask(now_func_path,now_anat_path,Subj_list(subji).name);
    end
    %                  disp('___________________________________________________________________________________________')
    %%     12     Filtering


    if filter_check
        disp(['Filtering is started for ' Subj_list(subji).name])                                                       %#ok<UNRCH>
        try
            if over_write == 1

                f_dir = dir(fullfile(Subj_list(subji).func_folder,[f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                if ~isempty(f_dir)
                    delete(fullfile(f_dir.folder,f_dir.name))
                end
                f_dir = [];
            else
                f_dir = dir(fullfile(Subj_list(subji).func_folder,[f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            end
            if isempty(f_dir)

                now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                cd(now_func_path(1).folder)
                func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));
                func_image = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));
                dim = size(func_image);
                nt  = dim(4);
                func_image = reshape(func_image,[],nt);
                tr = Subj_list(subji).TR;

                % Loading Rest mask
                REST_MASK = niftiread(fullfile(now_func_path.folder,'rest_mask.nii'));
                REST_MASK = logical(reshape(REST_MASK,[],1));

                fs = 1/tr;
                disp('Using Butterworth filter of 2th order for filtering')
                [b,a] = butter(2,[filter_lp,filter_hp]/(fs/2),'bandpass');
                figure; freqz(b,a,512,fs);          % Plot the frequency responce using 512 points
                saveas(gcf,fullfile(quality_control_path,'Filter',[Subj_list(subji).name '_filter_freq_response.png']))
                close gcf

                f_func_image = zeros(prod(dim(1:3)),nt)';
                ts = func_image(REST_MASK,:)-mean(func_image(REST_MASK,:),2);
                ts(isnan(ts)) = 0;
                f_func_image(:,REST_MASK) = filtfilt(b,a,ts');
                f_func_image = f_func_image';
                f_func_image = f_func_image + mean(func_image,2);

                f_func_image = reshape(f_func_image,dim);
                f_func_image = cast(f_func_image,func_info.Datatype);

                niftisave(f_func_image,fullfile(now_func_path.folder,[f_pre ,now_func_path.name]),func_info);

            end


        catch exception
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
            disp(['Preprocessing has encountered errors in filtering for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
            disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

            write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
            Subj_list(subji).error = 1;  % Remove participant from further preprocessing
            continue
        end

        disp(['Filtering is done for ' Subj_list(subji).name])
    end
    %                 disp('___________________________________________________________________________________________')
    %%    13     Smoothing

    disp(['Smoothing is started for ' Subj_list(subji).name])

    if Smooth_ == 1

        if WM_GM == 1

            disp(['Smoothing White matter and Gray Matter Seperately for ' Subj_list(subji).name])

            GM_filename_prefix = 'c1';
            WM_filename_prefix = 'c2';


            try
                if over_write == 1

                    smooth_dir = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                    if ~isempty(smooth_dir)
                        delete(fullfile(smooth_dir.folder,smooth_dir.name))
                    end
                    smooth_dir = [];
                else
                    smooth_dir = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                end

                if isempty(smooth_dir)

                    now_func_path = dir(fullfile(Subj_list(subji).func_folder,[f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                    now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;

                    functional_dir = fullfile(now_func_path.folder,now_func_path.name);
                    segmentation_dir = fullfile(now_anat_path(1).folder);
                    smooth_name = [Smooth_pre now_func_path.name];
                    [smooth_op_gm, smooth_op_wm] = p_smooth_WM_GM_separately_fast(functional_dir, segmentation_dir, now_func_path.folder,smooth_name, smooth_fwhm, GM_filename_prefix, WM_filename_prefix,over_write);
                    fprintf(log_fileID,'#####################################################################################################################\n \n');
                    fprintf(log_fileID, 'Smoothing White Matter and Gray Matter seperately\n');
                    fprintf(log_fileID,'Gray Matter Smoothing\n');
                    fprintf(log_fileID,'%s',  smooth_op_gm);
                    fprintf(log_fileID,'White Matter Smoothing\n');
                    fprintf(log_fileID,'%s',  smooth_op_wm);
                else
                    disp(['Smoothing file found, hence skipping this step for ' Subj_list(subji).name]);
                end

            catch exception
                disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
                disp(['Preprocessing has encountered errors in Smoothing for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
                disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

                write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
                Subj_list(subji).error = 1;  % Remove participant from further preprocessing
                continue

            end

        else
            disp('Smoothing White matter and Gray Matter together')


            try
                if over_write == 1
                    smooth_dir = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                    if ~isempty(smooth_dir)
                        delete(fullfile(smooth_dir.folder,smooth_dir.name))
                    end
                    smooth_dir = [];
                else
                    smooth_dir = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                end

                if isempty(smooth_dir)

                    now_func_path = dir(fullfile(Subj_list(subji).func_folder,[f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;


                    nt = Subj_list(subji).nt_dis;

                    smooth_op = whifun_smooth_together(nt,now_func_path,smooth_fwhm,Smooth_pre);
                    fprintf(log_fileID,'#####################################################################################################################\n \n');
                    fprintf(log_fileID, 'Smoothing White Matter and Gray Matter together\n');
                    fprintf(log_fileID,'%s',  smooth_op);

                else
                    disp(['Smoothing file found, hence skipping this step for ' Subj_list(subji).name]);
                end


            catch exception
                disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
                disp(['Preprocessing has encountered errors in Smoothing for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
                disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

                write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
                Subj_list(subji).error = 1;  % Remove participant from further preprocessing

            end

        end
    else
        disp('No smoothing is selected hence skipping this step')
    end
    disp(['Smoothing is done for ' Subj_list(subji).name])
    %                  disp('___________________________________________________________________________________________')
    %%    14     Normalization
    disp(['Normalization is started for ' Subj_list(subji).name])

    try

        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;

        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,['y_' Subj_list(subji).anat_name])) ;

        if over_write == 1

            norm_dir = dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            if ~isempty(norm_dir)
                delete(fullfile(norm_dir.folder,norm_dir.name))
            end
            norm_dir = [];
        else
            norm_dir = dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        end
        if isempty(norm_dir)
            nt = Subj_list(subji).nt_dis;
            norm_op = whifun_normalise(now_anat_path,now_func_path,Subj_list(subji).anat_name,nt,vox,Norm_pre,skull_pre,1); %func
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Normalization to MNI space\n');
            fprintf(log_fileID,'%s',  norm_op);
        else
            disp(['Normalization file found, hence skipping this step for ' Subj_list(subji).name]);
        end

    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Normalization for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;  % Remove participant from further preprocessing
        continue

    end


    disp(['Normalization is done for ' Subj_list(subji).name])
    %                  disp('___________________________________________________________________________________________')
    %%     15     Normalization of anatomical images
    disp(['Anatomical Normalization of is started  for ' Subj_list(subji).name])

    try
        if over_write == 1

            norm_a_dir = dir(fullfile(Subj_list(subji).anat_folder,[Norm_pre skull_pre Subj_list(subji).anat_name])) ;
            if ~isempty(norm_a_dir)
                delete(fullfile(norm_a_dir.folder,norm_a_dir.name))
            end
            norm_a_dir = [];
        else
            norm_a_dir = dir(fullfile(Subj_list(subji).anat_folder,[Norm_pre skull_pre Subj_list(subji).anat_name])) ;
        end

        if isempty(norm_a_dir)

            now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,['y_' Subj_list(subji).anat_name])) ;
            norm_op = whifun_normalise(now_anat_path,'',Subj_list(subji).anat_name,0,vox,Norm_pre,skull_pre,0);
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Normalization of Anatomical images to MNI space\n');
            fprintf(log_fileID,'%s',  norm_op);
        else
            disp(['Anatomical Normalization file found, hence skipping this step for ' Subj_list(subji).name]);
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Anatomical Normalization for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display

        Subj_list(subji).error = 1; % Remove this participant from further preprocessing

        continue

    end

    disp(['Anatomical Normalization is done for ' Subj_list(subji).name])
    %                  disp('___________________________________________________________________________________________')

    if ~par_on
        time_el = toc/60;
    else
        par_p(subji) = Par.toc;
        time_el = (par_p(subji).ItStop-par_p(subji).ItStart)/60;
    end

    if time_el > 1
        Subj_list(subji).time_preprocess_min = time_el;

    end
    fclose(log_fileID);
end
if par_on
    stop(par_p)                                                                         %#ok<UNRCH>
end
for subji = 1:length(Subj_list)

    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).func_name = Subj_list(subji).func_name;
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).anat_name = Subj_list(subji).anat_name;

    %%     2     Anatomical and Functional initial alignment check
    disp(['Anatomical and Functional initial alignment check for ' Subj_list(subji).name])

    now_func_path = dir(fullfile(Subj_list(subji).func_folder,Subj_list(subji).func_name)) ;

    now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
    if length(now_anat_path) > 1

        [~,idx] = sort([now_anat_path.datenum]);
        now_anat_path = now_anat_path(idx);
        now_anat_path(2:end) = [];
        warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
    end

    if length(now_func_path) > 1

        [~,idx] = sort([now_func_path.datenum]);
        now_func_path = now_func_path(idx);
        now_func_path(2:end) = [];
        warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first.']);
    end
    % Check if the discarded volume file already exists
    if over_write == 1 % if overwrite is 1, even if the file already exists delete it and create a new one
        init_check_func_dir = dir(fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_func.png'])) ;
        init_check_anat_dir = dir(fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_anat.png'])) ;
        if ~isempty(init_check_func_dir) && ~isempty(init_check_anat_dir)
            delete(fullfile(init_check_func_dir.folder,init_check_func_dir.name))
            delete(fullfile(init_check_anat_dir.folder,init_check_anat_dir.name))
        end
        init_check_func_dir = [];
        init_check_anat_dir = [];

    else
        init_check_func_dir = dir(fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_func.png'])) ;
        init_check_anat_dir = dir(fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_anat.png'])) ;
    end

    if isempty(init_check_func_dir) || isempty(init_check_anat_dir)
        % Initial anat file check
        % Plot the anatomical image and check its intitial position with reference to the MNI template

        imgs = char(fullfile(now_anat_path.folder,now_anat_path.name),...
            fullfile(spm_path,'canonical','single_subj_T1.nii'));
        [~] = spm_check_registration_evalc(imgs);  % Plot the two images using Check Registration

        % Display the participant's ID
        spm_orthviews('Caption', 1, Subj_list(subji).name);
        spm_orthviews('Caption', 2, 'single_subj_T1 (MNI)');

        % Display contour of 1st image onto 2nd
        spm_orthviews('contour','display',1,2);
        saveas(gcf,fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_anat.png']),'png')
        close gcf

        % Initial func file check
        % Plot the first functional image and check its intitial position with reference to the MNI template

        imgs = char(fullfile(now_func_path.folder,[now_func_path.name ',1']),...
            fullfile(spm_path,'canonical','single_subj_T1.nii'));
        [~] = spm_check_registration_evalc(imgs);  % Plot the two images using Check Registration

        % Display the participant's ID
        spm_orthviews('Caption', 1, Subj_list(subji).name);
        spm_orthviews('Caption', 2, 'single_subj_T1 (MNI)');

        % Display contour of 1st image onto 2nd
        spm_orthviews('contour','display',1,2);
        saveas(gcf,fullfile(quality_control_path,'Initial_check',[Subj_list(subji).name '_func.png']),'png')
        close gcf
    else
        disp(['Anatomical and Functional initial alignment check already done for participant ' Subj_list(subji).name ' hence skipping this step'])
    end

    disp(['Anatomical and Functional initial alignment check done for' Subj_list(subji).name])

    %% Head motion QC

    now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
    cd(now_func_path(1).folder)


    if over_write == 1
        head_mot_qc_file = dir(fullfile(quality_control_path,'Head_motion',[Subj_list(subji).name '.png'])); % Check for a previous head motion qc file
        if ~isempty(head_mot_qc_file)
            delete(fullfile(head_mot_qc_file.folder,head_mot_qc_file.name))
        end
        head_mot_qc_file = [];
    else
        head_mot_qc_file = dir(fullfile(quality_control_path,'Head_motion',[Subj_list(subji).name '.png'])); % Check for a previous head motion qc file
    end

    if isempty(head_mot_qc_file)
        func_image = niftiread(fullfile(now_func_path.folder,now_func_path.name)); % Read the func file
        [x,y,z,nt] = size(func_image);                                             % get the size
        func_image = reshape(func_image,x*y*z,nt);                                 % Reshape into voxel x timepoints

        gm = mean(func_image,'all','omitnan');                                               % grand mean (4D)

        % calculate pairwise variance
        dt = zeros(1,nt-1);
        for imagei = 1:nt-1
            dt(imagei) = (mean((func_image(:,imagei) - func_image(:,imagei+1)).^2,'omitnan'))/gm;
        end

        meany = mean(func_image,'omitnan')./gm;                                              % scaled global mean
    end
    func_name_wo_ext = strsplit(Subj_list(subji).func_name,'.');

    now_func_path = dir(fullfile(Subj_list(subji).func_folder,['rp_' Cut_pre func_name_wo_ext{1} '.txt'])) ;
    rp_rest = load(fullfile(now_func_path.folder,now_func_path.name));              % input the text file generated at the Realignment stage

    rp_diff_trans = diff(rp_rest(:,1:3));                      % The first 3 parameters tell the displacement in x,y, and z direction in mm. Here the vector difference operator is used to get the derivative of vector. (framewise difference)
    %                 rp_diff_rotat = diff(rp_rest(:,4:6)*180/pi);             % % The last  3 parameters tell the rotation values pitch, yaw and roll in radians (here we convert them to degrees)
    rp_diff_rotat = diff(rp_rest(:,4:6)*50);                   % Converting angles to mm by asuming a 50mm radius circle


    fd = sum(rp_diff_trans,2) + sum(rp_diff_rotat,2)  ;
    %                 [fd_max,loc_fd_max_trans] = max(fd);                     % Get the maximum framewize displacement
    %                 fd_mean = mean(fd);                                               % Get the mean framewize displacement
    %                 fd_greater_than_02 = nnz(fd>great20_fd_thres)/length(fd)*100;
    % plots
    if isempty(head_mot_qc_file) || over_write == 1
        figure('Position', get(0,'screensize'))

        subplot(2,2,1)
        plot(meany)
        title('Global mean (raw)');xlabel('Image number')
        box off

        subplot(2,2,3)
        plot(dt)
        yline(mean(dt)+3*std(dt),'-','3 SD','color',[0 0.4470 0.7410]);
        title('Pairwise variance (raw)');xlabel('Image pair')
        box off

        subplot(2,2,2)
        plot([rp_rest(:,1:3) rp_rest(:,4:6)*180/pi])
        title('Rigid body motion');xlabel('Image number')
        legend('Trans: x','Trans: y','Trans: z','Rot: pitch','Rot: roll','Rot: yaw','location','best')
        box off

        subplot(2,2,4)
        plot(fd)
        title('Framewise displacement');xlabel('Image pair')
        yline(max_fd,'r')
        yline(str2double(greater_than_20),'k')
        yline(str2double(mean_fd),'y')
        legend('Framewise displacement','Max Threshold','Mean Threshold','Greater than 20% threshold','location','best','box','off')
        saveas(gcf,fullfile(quality_control_path,'Head_motion',[Subj_list(subji).name '.png']));
        close gcf
    else
        disp(['Head motion Quality check file found hence skipping this step for participant ' Subj_list(subji).name])
    end
    %% Segmentation QC

    now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,Subj_list(subji).anat_name)) ;
    whifun_segment_qc(quality_control_path,now_anat_path,spm_path,Subj_list(subji).name,over_write)
    %                 disp('___________________________________________________________________________________________')

    %% Coregisteration QC
    coreg_qc_file = dir(fullfile(quality_control_path,'Co_registeration',[Subj_list(subji).name '.png']));
    try
        if isempty(coreg_qc_file) || over_write == 1

            now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
            now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;
            % Quality Control
            % dsplay the anatomical and the Realigned func image after co-registeration
            [~] = spm_check_registration_evalc(char(fullfile(now_anat_path.folder,now_anat_path.name),[fullfile(now_func_path.folder,now_func_path.name),',1']));

            % Display the participant's ID
            spm_orthviews('Caption', 1, Subj_list(subji).name);

            spm_orthviews('contour','display',1,2);
            saveas(gcf,(fullfile(quality_control_path,'Co_registeration',[Subj_list(subji).name '.png'])))
            close gcf
        end
    catch exception                                                                       % If error is found

        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Co-registeration QC for ' Subj_list(subji).name ', I have saved the error text in the error_info.txt :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;
        continue
    end

    disp(['Co-registeration done for ' Subj_list(subji).name])

    %% CSF mask
    %                 now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
    %                 now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;
    csf_qc_file = dir(fullfile(quality_control_path,'Masks',['CSF_' Subj_list(subji).name '.png']));
    if isempty(csf_qc_file) || over_write == 1
        % Quality Control

        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        csf_mask_dir = dir(fullfile(Subj_list(subji).anat_folder,['CSF_MASK' char(CSF_thres) '.nii'])) ;

        % Display the csf mask and the func file
        [~] = spm_check_registration_evalc(char(fullfile(csf_mask_dir.folder,csf_mask_dir.name),[fullfile(now_func_path.folder,now_func_path.name),',1']));
        % Display the participant's ID
        spm_orthviews('Caption', 1, [Subj_list(subji).name ' CSF Mask']);
        spm_orthviews('Caption', 2, [Subj_list(subji).name ' Rest image 1']);
        spm_orthviews('contour','display',1,2);
        saveas(gcf,(fullfile(quality_control_path,'Masks',['CSF_' Subj_list(subji).name '.png'])))
        close gcf
    end
    %% Regression QC

    reg_qc_file = dir(fullfile(quality_control_path,'Regression',[Subj_list(subji).name '.png']));
    if isempty(reg_qc_file) || over_write == 1

        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        % Quality Control
        % Plot the mean time series before and after regression

        % Read the raw file

        if ~exist("y_image_REST","var")
            y_image_REST = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));
        end
        [x,y,z,nt] = size(y_image_REST);
        raw_file = reshape(y_image_REST,x*y*z,nt);
        global_ts = mean(raw_file,'omitnan');

        if ~exist("y_image_REST_regressed",'var')
            y_image_REST_regressed = double(niftiread(fullfile(now_func_path.folder,[Reg_pre, now_func_path.name])));
        end
        [x,y,z,nt] = size(y_image_REST_regressed);
        raw_file = reshape(y_image_REST_regressed,x*y*z,nt);
        global_ts_r = mean(raw_file,"omitnan");
        func_name_wo_ext = strsplit(Subj_list(subji).func_name,'.');
        if motion_reg == 1
            % Loading the motion parameters
            fprintf('First loading the motion parameters for REST... \n')
            txt_file = dir(fullfile(now_func_path.folder,['rp_' Cut_pre func_name_wo_ext{1} '.txt']));
            rp=load(fullfile(txt_file.folder,txt_file.name));
            rp_temp = rp(1:nt,:);
            rp = zscore(rp_temp);
            rp_previous = [0 0 0 0 0 0; rp(1:end-1,:)];
            rp_auto = [rp rp.^2 rp_previous rp_previous.^2];
        else
            rp_auto = [];
        end

        if ~exist("b_init",'var')
            load(fullfile(now_func_path.folder,'covariance_csf_REST.mat')); 
            if exist("pca_CSF",'var')
                b_init = zscore([pca_CSF(:,1:n_pca) rp_auto]); 
            else
                b_init = zscore([MEAN_CSF_REST rp_auto]);
            end
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
        figure; plot(global_ts-mean(global_ts));
        hold on
        plot(global_ts_r -mean(global_ts_r))
        hold on
        plot(b_init)
        title(['Global Time Series (mean subtracted)' ' Subject ' Subj_list(subji).name])
        legend(leg)

        xlabel('time points')
        ylabel('Bold Signal (mean substracted)')
        saveas(gcf,fullfile(quality_control_path,'Regression',[Subj_list(subji).name '.png']))

        close gcf
    end
    %% Filtering QC

    fil_qc_file = dir(fullfile(quality_control_path,'Filter',[Subj_list(subji).name '.png']));


    if isempty(fil_qc_file) || over_write == 1

        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        % Quality Control
        % Plot the mean time series before and after regression

        % Read the raw file

        func_image = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));
        [x,y,z,nt] = size(func_image);
        func_image = reshape(func_image,x*y*z,nt);

        global_ts = mean(func_image,'omitnan');

        f_func_image = double(niftiread(fullfile(now_func_path.folder,[f_pre now_func_path.name])));
        [x,y,z,nt] = size(f_func_image);
        f_file = reshape(f_func_image,x*y*z,nt);
        global_ts_f = mean(f_file,'omitnan');

        figure; plot(global_ts-mean(global_ts));
        hold on
        plot(global_ts_f -mean(global_ts_f))
        title(['Global Time Series (mean subtracted)' ' participant ' Subj_list(subji).name])
        legend('Before filtering','After filtering')

        xlabel('time points')
        ylabel('Bold Signal (mean substracted)')
        saveas(gcf,fullfile(quality_control_path,'Filter',[Subj_list(subji).name '.png']))

        close gcf
    end
    %% Smoothing QC
    smooth_qc_file = dir(fullfile(quality_control_path,'Smoothing',[Subj_list(subji).name '.png']));
    if isempty(smooth_qc_file) || over_write == 1
        norm_dir = dir(fullfile(Subj_list(subji).func_folder,[Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        [~] = spm_check_registration_evalc(char(fullfile(norm_dir.folder,[norm_dir.name ',1'])));
        spm_orthviews('Caption', 1, [Subj_list(subji).name ' Smooth Image (MNI space)']);
        saveas(gcf,(fullfile(quality_control_path,'Smoothing',[Subj_list(subji).name '.png'])))
        close gcf
    end

    %% normalization QC

    norm_qc_file = dir(fullfile(quality_control_path,'Normalization',[Subj_list(subji).name '_func_image' '.png']));

    if isempty(norm_qc_file) || over_write == 1
        % Quality Control

        norm_dir = dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
        [~] = spm_check_registration_evalc(char(fullfile(norm_dir.folder,[norm_dir.name ',1']),fullfile(spm_path,'canonical','single_subj_T1.nii')));
        spm_orthviews('contour','display',1,2);
        spm_orthviews('Caption', 1, [Subj_list(subji).name ' Normalized Image (MNI space)']);
        spm_orthviews('Caption', 2,  ' Single Subject MNI space Reference');

        saveas(gcf,(fullfile(quality_control_path,'Normalization',[Subj_list(subji).name '_func_image' '.png'])))
    end

    %% 16 Time series Quality Check

    disp(['Time-series Quality Check for ' Subj_list(subji).name])


    try

        now_func_path = dir(fullfile(Subj_list(subji).func_folder,[Cut_pre Subj_list(subji).func_name])) ;
        now_anat_path = dir(fullfile(Subj_list(subji).anat_folder,[skull_pre Subj_list(subji).anat_name])) ;

        if length(now_func_path)>1  % If more than one func files found choose the one that was created the first

            [~,idx] = sort([now_func_path.datenum]);
            now_func_path = now_func_path(idx);
            warning(['More than one functional files found. Choosing the file ' ,char(now_func_path(1).name), ' as it was created the first.']);
            now_func_path(2:end) = [];
        end
        if over_write == 1
            tqc_dir = dir(fullfile(quality_control_path,'Time_series_check',[Subj_list(subji).name '.png']));
            if ~isempty(tqc_dir)
                delete(fullfile(tqc_dir.folder,tqc_dir.name))
            end
            tqc_dir = [];
        else
            tqc_dir = dir(fullfile(quality_control_path,'Time_series_check',[Subj_list(subji).name '.png'])) ;
        end

        if isempty(tqc_dir)
            func_name_wo_ext = strsplit(Subj_list(subji).func_name,'.');

            now_txt_path = dir(fullfile(Subj_list(subji).func_folder,['rp_' Cut_pre func_name_wo_ext{1} '.txt'])) ;
            now_func_path_pro = dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;

            if Reg_
                whifun_ts_check(now_func_path,now_txt_path,now_func_path_pro,now_anat_path,Reg_,quality_control_path,Subj_list(subji).name,n_pca,max_fd,pca_for_temp_reg)
            else
                whifun_ts_check(now_func_path,now_txt_path,now_func_path_pro,now_anat_path,Reg_,quality_control_path,Subj_list(subji).name,n_pca,max_fd)
            end

        end

        disp(['Time-series Quality Check done for ' Subj_list(subji).name])
        disp('##########################################################################################')
        disp(' ')
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Time-series check for ' Subj_list(subji).name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,quality_control_path, Subj_list(subji).name)                % write error to text file and display
        Subj_list(subji).error = 1;

        continue
    end


    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).motion_ex = Subj_list(subji).motion_ex;
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).error = Subj_list(subji).error;
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).nt_dis = Subj_list(subji).nt_dis;

    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).time_preprocess_min = Subj_list(subji).time_preprocess_min;
end
my_writetable(struct2table(Subj_list_all), fullfile(output_folder,"Subj_list.csv"))

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

