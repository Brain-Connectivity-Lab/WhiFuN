function quality_control_path = whifun_addpath_and_create_preproc_folders(preproc_code_path,output_folder)
% WHIFUN_ADDPATH_AND_CREATE_PREPROC_FOLDERS Sets up paths and output directories for preprocessing.
%   quality_control_path = WHIFUN_ADDPATH_AND_CREATE_PREPROC_FOLDERS(preproc_code_path, output_folder)
%   adds necessary code directories to the MATLAB path and creates a
%   standardized set of output folders for storing preprocessing results,
%   quality control metrics, and logs.
%
%   The function first adds the main preprocessing code path and a subfolder
%   of utility functions to the MATLAB path. It then checks if SPM is
%   available on the path, as it is a critical dependency for most
%   neuroimaging preprocessing pipelines. If SPM is not found, a message box
%   is displayed to the user.
%
%   Finally, the function creates a set of subdirectories within the
%   specified `output_folder` to organize the results of the preprocessing
%   workflow.
%
%   Input Arguments:
%   preproc_code_path - The full path to the directory containing the main
%                       preprocessing scripts.
%   output_folder     - The full path to the main directory where all
%                       preprocessing output will be stored.
%
%   Output Arguments:
%   quality_control_path - The full path to the newly created 'Quality_control'
%                          directory. This path can be used by subsequent
%                          functions to save output.
%
%   Created Directories:
%   - <output_folder>/Quality_control/b_Head_motion
%   - <output_folder>/Quality_control/Error_Info
%   - <output_folder>/Quality_control/logs
%
%   Example:
%       preproc_path = 'C:\Users\User\my_preproc_code';
%       output_path = 'D:\project_data\preprocessed_output';
%       qc_path = whifun_addpath_and_create_preproc_folders(preproc_path, output_path);
%       % The 'qc_path' variable now contains the full path to the 'Quality_control' folder.
%
%   See also ADDPATH, FULLFILE, WHICH, MKDIR, MSGBOX.
% Author: Pratik Jain

addpath(preproc_code_path)
addpath(fullfile(preproc_code_path,'whifun_functions'))
addpath(fullfile(preproc_code_path,'parTicToc'));

quality_control_path = fullfile(output_folder,'Quality_control');
spm_path = which('spm');
if isempty(spm_path)
    msgbox("Please set the SPM path by using the 'addpath' MATLAB function",'SPM path not set')
    error('SPM Not found')
end

%% Create Output folders

mkdir(fullfile(quality_control_path,'b_Head_motion'));
mkdir(fullfile(quality_control_path,'Error_Info'))
mkdir(fullfile(quality_control_path,'logs'))