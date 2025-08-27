%%          Defining Important paths and Creating Output directories
function quality_control_path = whifun_addpath_and_create_preproc_folders(preproc_code_path,output_folder)
addpath(preproc_code_path)
addpath(fullfile(preproc_code_path,'whifun_functions'))
quality_control_path = fullfile(output_folder,'Quality_control');


%% Create Output folders

mkdir(fullfile(quality_control_path,'b_Head_motion'));
mkdir(fullfile(quality_control_path,'Error_Info'))
mkdir(fullfile(quality_control_path,'logs'))