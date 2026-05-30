function whifun_preproc_all(output_folder,varargin)

%% ---- input parser ----
p = inputParser;
p.FunctionName = 'whifun_preproc';

% required
addRequired(p, 'output_folder', @(x) ischar(x) || isstring(x));

% general
addParameter(p, 'over_write', 0, @(x) islogical(x) || (isnumeric(x) && isscalar(x)));

% discard volumes
addParameter(p, 'Cut_pre', 'c_', @(x) ischar(x) || isstring(x));
addParameter(p, 'n_vol_dis', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);

% realignment
addParameter(p, 'Realign_pre', 'r', @(x) ischar(x) || isstring(x));

% framewise displacement
addParameter(p, 'max_fd', 0.5, @isnumeric);
addParameter(p, 'mean_fd', 0.2, @isnumeric);
addParameter(p, 'greater_than_20', 0.2, @isnumeric);

% Segmentation
addParameter(p, 'Seg_dartel_drop','No Dartel',@(x) ischar(x) || isstring(x));

% skull stripping
addParameter(p, 'skull_pre', 'b', @(x) ischar(x) || isstring(x));

% CSF mask / PCA
addParameter(p, 'Reg_drop', 'Mean CSF', @(x) ischar(x) || isstring(x));
addParameter(p, 'CSF_thres','0.95', @(x) ischar(x) || isstring(x));
addParameter(p, 'pca_for_temp_reg', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'n_pca', 5, @(x) isnumeric(x) && isscalar(x) && x>=0);

% nuisance regression
addParameter(p, 'Reg_pre', 'REG_', @(x) ischar(x) || isstring(x));
addParameter(p, 'motion_reg', 0, @(x) islogical(x) || isnumeric(x));

% filtering
addParameter(p, 'filter_check', 0, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'f_pre', 'f', @(x) ischar(x) || isstring(x));
addParameter(p, 'filter_lp', 0.01);
addParameter(p, 'filter_hp', 0.15);

% smoothing
addParameter(p, 'smooth_drop', 'WM-GM Seperate', @(x) ischar(x) || isstring(x));
addParameter(p, 'Smooth_pre', 's', @(x) ischar(x) || isstring(x));
addParameter(p, 'smooth_fwhm', 4, @(x) isnumeric(x) && isscalar(x) && x>=0);

% normalization
addParameter(p, 'Norm_pre', 'w', @(x) ischar(x) || isstring(x));
addParameter(p, 'vox', 3, @isnumeric);

addParameter(p,'par_on',0,  @(x) islogical(x) || isnumeric(x))
addParameter(p,'n_workers',0,@(x) isnumeric(x))
addParameter(p, 'gui', 0, @isnumeric);
addParameter(p, 'app', 0);

% parse inputs
parse(p, output_folder, varargin{:});
params = p.Results;

%% ---- Accessing parsed values (examples) ----
% You can refer to any parameter as params.<name>
% e.g.:
output_folder = params.output_folder;          % string
over_write = logical(params.over_write);   % logical
Cut_pre    = char(params.Cut_pre);         % char
n_vol_dis  = params.n_vol_dis;             % numeric scalar

Realign_pre = char(params.Realign_pre);

max_fd = params.max_fd;
mean_fd = params.mean_fd;
greater_than_20 = params.greater_than_20;
Seg_dartel_drop = params.Seg_dartel_drop;

skull_pre = char(params.skull_pre);

Reg_drop = params.Reg_drop;
CSF_thres = params.CSF_thres;
pca_for_temp_reg = logical(params.pca_for_temp_reg);
n_pca = params.n_pca;

Reg_pre = char(params.Reg_pre);
motion_reg = logical(params.motion_reg);

filter_check = logical(params.filter_check);
f_pre = char(params.f_pre);
filter_lp = params.filter_lp;
filter_hp = params.filter_hp;

smooth_drop = params.smooth_drop;
Smooth_pre = char(params.Smooth_pre);
smooth_fwhm = params.smooth_fwhm;

Norm_pre = char(params.Norm_pre);
vox = params.vox;  % 1x3 numeric

par_on = params.par_on;
n_workers = params.n_workers;
gui = params.gui;
app = params.app;

temp_path = mfilename('fullpath');                % path of the toolbox
preproc_code_path = fileparts(fileparts(temp_path));

if isempty(output_folder)
    msgbox('Please specify the output_folder,then Run Data Check, define Preprocessing parameters and then Run Preprocessing.','Output folder Path empty')
    return
end

qc_path = fullfile(output_folder,'Quality_control');
if ~exist(qc_path,'dir')
    msgbox('Quality_control folder not found. Please Run Initial Data check before Running the Preprocessing and Analyses ', 'Run Initial Data Check')
    return
end

load(fullfile(output_folder,'parameters.mat'),'data_path','comm_sess_name','anat_data_name','func_data_name','anat_folder_name','comm_subj_name','func_folder_name')                           % load parameters saved during initial data check, if they were changed after initial data check, the change will be applied later in the code.
Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv');
Subj_list = load_subjects(output_folder,'Subj_list.csv');




%%
fprintf('QC folder: %s\n', qc_path);
if over_write
    fprintf('Overwriting enabled.\n');
    res_ = questdlg('Overwrite is enabled, this will Delete any files that were already created and start everything from start. Want to proceed?','Overwrite enabled','Yes','No','No');
    switch res_
        case 'No'
            return
    end
end

try
    n_image = [Subj_list.nt];
catch ex
    if strcmp(ex.identifier,'MATLAB:nonExistentField')
        msgbox('Please Run Data Check Before Running Preprocessing','Run Data Check First')
        return
    else
        write_error(ex,qc_path,'Start')
    end
end

%%          Parameters
if n_vol_dis ==0
    Cut_pre = '';
end

switch Seg_dartel_drop
    case 'No Dartel'
        dartel_ = 0;
    case 'Dartel'
        dartel_ = 1;
end

% PCA or Mean for WM and CSF timeseries data that will be used as a
% regressor in temporal Regression
% 1 --> Will use PCA for getting the CSF Components
% 0 --> will use mean WM and CSF components (faster)
switch Reg_drop
    case 'Mean CSF'
        pca_for_temp_reg = 0;
        Reg_CSF = 1;
        n_pca = 0;
    case 'PCA CSF'
        pca_for_temp_reg = 1;
        % n_pca = double(string(app.NoofPCAcomponents));                   % number of pca components for WM and CSF (choose a value between 1 and 5)
        Reg_CSF = 1;
    case 'No CSF Regression'
        if ~motion_reg
            Reg_pre = '';
        end
        Reg_CSF = 0;
        pca_for_temp_reg = 0;
        n_pca = 0;
end
if filter_check

    if filter_lp > filter_hp
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

if gui
    d = uiprogressdlg(app.WhiFuNv33UIFigure,'Title','WhiFuN Preprocessing ','Message','Please wait, See Matlab Command window for progress.',...
        'Indeterminate','on');
end

if ~all(mean(n_image) == n_image)
    for_warning = struct2table(Subj_list);
    disp(for_warning)
    warning('The number of timepoints (nt) for all the participants is not the same. The number of time points corresponding to every participant is displayed above')
end

% Saving all the parameters in Output Folder for future
% reference
whifun_save_parameters(output_folder,'parameters.mat',...
                                data_path,output_folder,0,...
                                comm_sess_name,comm_subj_name,...
                                func_folder_name,anat_folder_name,...
                                func_data_name,anat_data_name,...
                                n_vol_dis,...
                                max_fd,mean_fd,greater_than_20,...
                                Seg_dartel_drop,...
                                CSF_thres,...
                                Reg_drop,n_pca,motion_reg,...
                                filter_check,filter_lp,filter_hp,...
                                smooth_drop,smooth_fwhm,...
                                vox)


%   Loop all participants in this group
n_tot = length(Subj_list);
if ~par_on
    n_workers = 0; % 0 workers means serial execution
else
    par_p = Par(n_tot);
end


Subj_list_all = whifun_create_fields_preproc(Subj_list_all);
Subj_list = whifun_create_fields_preproc(Subj_list);
dq = parallel.pool.DataQueue;
hWaitbar = waitbar(0, 'No. of Participants done...', 'Name', 'Preprocessing');
afterEach(dq, @(~) whifun_update_waitbar(hWaitbar, n_tot));

parfor (subji=1:n_tot,n_workers) %par

    Subj_list(subji)= whifun_preproc(output_folder,Subj_list(subji),...
        'over_write',over_write,...                                                                        General Inputs
        'Cut_pre',Cut_pre,'n_vol_dis',n_vol_dis,...                                                       Discard Volumes
        'Realign_pre',Realign_pre,...                                                                     Realignment
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...                           Framewise Displacement
        'skull_pre',skull_pre,...                                                                         Skull stripping
        'Reg_CSF',Reg_CSF,'CSF_thres',CSF_thres,...                                                             CSF MASK func
        'pca_for_temp_reg',pca_for_temp_reg,'n_pca',n_pca,...                                             CSF Timeseries extraction
        'Reg_pre',Reg_pre,'motion_reg',motion_reg,...                                                     Nuisance Regression
        'filter_check',filter_check,'f_pre',f_pre,'filter_lp',filter_lp,'filter_hp',filter_hp,...         Filtering
        'Smooth_',Smooth_,'Smooth_pre',Smooth_pre,'WM_GM_seperate',WM_GM,'smooth_fwhm',smooth_fwhm,...    Smoothing
        'dartel_',dartel_,'Norm_pre',Norm_pre,'vox',vox...                                                Normalization
        );
    send(dq, 1);

end
close(hWaitbar)
if par_on
    stop(par_p)
end

%% update CSV
for subji = 1:length(Subj_list)
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)) = Subj_list(subji);

    Subj_list_all = update_csv(Subj_list(subji),Subj_list_all,output_folder);
end

Subj_list = load_subjects(output_folder,'Subj_list.csv');

%% Dartel Normalisation

% Create Dartel Template

if dartel_
    [log_fileID,errmsg] = fopen(fullfile(qc_path,'logs','Dartel_log_info.txt'),'a');
    %
    if log_fileID == -1
        error(errmsg)
    end

    try
        if over_write == 1

            norm_dir_d = whifun_dir(fullfile(output_folder,'Dartel_group_template','Template_6.nii')) ;
            if ~isempty(norm_dir_d)
                whifun_delete(fullfile(norm_dir_d.folder,norm_dir_d.name))
            end
            norm_dir_d = [];
        else
            norm_dir_d = whifun_dir(fullfile(output_folder,'Dartel_group_template','Template_6.nii')) ;
        end
        if isempty(norm_dir_d)
            disp('Creating Dartel template')
            norm_op = whifun_dartel(Subj_list);
            mkdir(fullfile(output_folder,'Dartel_group_template'))
            copyfile(fullfile(Subj_list(1).anat_folder,'Template_6.nii'),fullfile(output_folder,'Dartel_group_template','Template_6.nii'))
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, ' Creating Dartel template \n');
            fprintf(log_fileID,'%s',  norm_op);
        else
            disp('Dartel template found, hence skipping this step ');

        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp('Preprocessing has encountered errors in Dartel Create Template, I have saved the variables in the participant folder :-) ')
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,qc_path, 'Dartel_Template')                % write error to text file and display                % write error to text file, update csv and display

    end

    if log_fileID == -1
        error(errmsg)
    end

    % Dartel Normalization to MNI space

    try
        if over_write == 1
            for subji = 1:length(Subj_list)
                norm_dir_d = whifun_dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                if ~isempty(norm_dir_d)
                    whifun_delete(fullfile(norm_dir_d.folder,norm_dir_d.name))
                end

            end
            norm_dir_d = [];
        else
            for subji = 1:length(Subj_list)
                norm_dir_d = whifun_dir(fullfile(Subj_list(subji).func_folder,[Norm_pre Smooth_pre f_pre Reg_pre Realign_pre Cut_pre Subj_list(subji).func_name])) ;
                if isempty(norm_dir_d)
                    break
                end
            end
        end
        if isempty(norm_dir_d)
            disp('Dartel Normalization is started')
            norm_op = whifun_dartel_normalize_smooth(Subj_list,1,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,skull_pre,output_folder,vox); % 1  for func
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, ' Dartel Normalisation \n');
            fprintf(log_fileID,'%s',  norm_op);
        else
            disp('Normalization file found, hence skipping this step');
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp('Preprocessing has encountered errors in Dartel Normalization Template, I have saved the variables in the participant folder :-) ')
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,qc_path, 'Dartel_Template')                % write error to text file and display                % write error to text file, update csv and display

    end
    % Anatomical normalization
    try
        if over_write == 1
            for subji = 1:length(Subj_list)
                norm_dir_d = whifun_dir(fullfile(Subj_list(subji).anat_folder,[Norm_pre skull_pre Subj_list(subji).anat_name])) ;
                if ~isempty(norm_dir_d)
                    whifun_delete(fullfile(norm_dir_d.folder,norm_dir_d.name))
                end

            end
            norm_dir_d = [];
        else
            for subji = 1:length(Subj_list)
                norm_dir_d = whifun_dir(fullfile(Subj_list(subji).anat_folder,[Norm_pre skull_pre Subj_list(subji).anat_name])) ;
                if isempty(norm_dir_d)
                    break
                end
            end
        end
        if isempty(norm_dir_d)
            disp('Dartel Normalization is started')
            norm_op0 = whifun_dartel_normalize_smooth(Subj_list,0,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,skull_pre,output_folder,nan); % 0 for anat
            norm_op2 = whifun_dartel_normalize_smooth(Subj_list,2,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,skull_pre,output_folder,nan); % 2 for anat c1
            norm_op3 = whifun_dartel_normalize_smooth(Subj_list,3,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,skull_pre,output_folder,nan); % 3 for anat c2
            norm_op4 = whifun_dartel_normalize_smooth(Subj_list,4,Smooth_pre,f_pre,Reg_pre,Realign_pre,Cut_pre,skull_pre,output_folder,nan); % 4 for anat c3
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, ' Dartel Normalisation skullstrip anat file\n');
            fprintf(log_fileID,'%s',  norm_op0);
            fprintf(log_fileID, ' Dartel Normalisation c1 file\n');
            fprintf(log_fileID,'%s',  norm_op2);
            fprintf(log_fileID, ' Dartel Normalisation c2 file\n');
            fprintf(log_fileID,'%s',  norm_op3);
            fprintf(log_fileID, ' Dartel Normalisation c3 file\n');
            fprintf(log_fileID,'%s',  norm_op4);
        else
            disp('Normalization file found, hence skipping this step');
        end
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp('Preprocessing has encountered errors in Dartel Normalization Template, I have saved the variables in the participant folder :-) ')
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        write_error(exception,qc_path, 'Dartel_Template')                % write error to text file and display                % write error to text file, update csv and display

    end

end

%% update CSV
for subji = 1:length(Subj_list)
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)) = Subj_list(subji);
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)) = Subj_list(subji);

    Subj_list_all = update_csv(Subj_list(subji),Subj_list_all,output_folder);
end
if gui
    close(d)
    d = uiprogressdlg(app.WhiFuNv33UIFigure,'Icon',fullfile(preproc_code_path,'icon_small_2.png'), ...
        'Title','Quality Check','Interpreter','html','Cancelable','on');
end
%% ######################################################################################################################################################################################################################
%% ######################################################################################################################################################################################################################

%% QC

Subj_list = Subj_list_all;
fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
for subji = 1:length(Subj_list)

    if gui
        if d.CancelRequested
            msg = 'Quality check canceled by the User';
            disp(msg)
            return
        end
        d.Value = subji/length(Subj_list);
        d.Message = ['Currently Processing ' Subj_list(subji).name];
    end

    disp('..')
    disp(['Currently Processing ' Subj_list(subji).name])

    Subj_list_1 = Subj_list(subji);

    whifun_qc(qc_path,Subj_list_1,...
        'over_write',over_write,...
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...
        'Reg_CSF',logical(Reg_CSF),'n_pca',n_pca,'motion_reg',logical(motion_reg),'pca_for_temp_reg',logical(pca_for_temp_reg),'slover_view','axial');

    whifun_qc(qc_path,Subj_list_1,...
        'over_write',over_write,...
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...
        'Reg_CSF',logical(Reg_CSF),'n_pca',n_pca,'motion_reg',logical(motion_reg),'pca_for_temp_reg',logical(pca_for_temp_reg),'slover_view','sagittal');

    whifun_qc(qc_path,Subj_list_1,...
        'over_write',over_write,...
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...
        'Reg_CSF',logical(Reg_CSF),'n_pca',n_pca,'motion_reg',logical(motion_reg),'pca_for_temp_reg',logical(pca_for_temp_reg),'slover_view','coronal');
end
close(fg)
if gui
    close(d)
end