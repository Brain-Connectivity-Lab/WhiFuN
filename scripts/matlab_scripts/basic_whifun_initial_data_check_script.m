clear

%% Addpaths if not already added 

% spm_path = '/tools/spm25/'; % Paste SPM toolbox path
% addpath(spm_path)

% whifun_path = '/tools/whifun/'
% addpath(whifun_path);

%% Input Paths

data_path = 'D:\Github_desktop\WhiFuN\Data\practice_NYU_abide';
output_folder = 'D:\Github_desktop\WhiFuN\Data\Whifun_op'; % Specify an empty folder where you want to store whifun outputs
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end
app.comm_subj_name = '';
app.comm_sess_name = 'session_1';
app.func_folder_name = 'rest_1';
app.anat_folder_name = 'anat_1';
app.func_data_name = 'rest' ;       % %   Functional data name
app.anat_data_name = 'mprage';     % %   Anatomical data name


%% Initial Data Check

Subj_list_all = whifun_create_Subj_list_all_from_Subj_folder_details(data_path,app.comm_subj_name,app.comm_sess_name,app.func_folder_name,app.func_data_name,app.anat_folder_name,app.anat_data_name);

whifun_func_path = which('whifun.m');
quality_control_path = whifun_addpath_and_create_preproc_folders(fileparts(whifun_func_path),output_folder);

addpath(fullfile(fileparts(whifun_func_path),'whifun_functions'))
app.func_data_name = char(app.func_data_name) ;       % %   Functional data name
app.anat_data_name = char(app.anat_data_name) ;     % %   Anatomical data name

[report,n_image,tr,voxel_func,voxel_anat,mis_data] =  whifun_check_data(output_folder,Subj_list_all,app.comm_sess_name,app.func_folder_name,app.func_data_name,app.anat_folder_name,app.anat_data_name);

whifun_save_parameters(output_folder,'parameters.mat',...
                                data_path,output_folder,0,...
                                app.comm_sess_name,app.comm_subj_name,...
                                app.func_folder_name,app.anat_folder_name,...
                                app.func_data_name,app.anat_data_name,...
                                0,5,0.2,0.2,0,0.95,1,0,1,0,0.01,0.15,1,"4","3")
Subj_list = load_subjects(output_folder,'Subj_list.csv');

% Plot all the parameters across participants
whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)
