function Subj_list_all = whifun_create_Subj_list_all_from_Subj_folder_details(data_path,comm_subj_name,comm_sess_name,func_folder_name,func_data_name,anat_folder_name,anat_data_name)
% Written by Pratik Jain

% WHIFUN_CREATE_SUBJ_LIST_ALL_FROM_SUBJ_LIST_ALL_DETAILS Scans a directory and creates a subject list if the patterns for the data folder is given.
%
%   Subj_list_all = WHIFUN_CREATE_SUBJ_LIST_ALL(comm_subj_name, ..., anat_data_name)
%   scans the current directory (or a specified pattern) for subject folders
%   and constructs a list of subject data. It assumes a specific directory
%   structure where each subject has folders for a session, and within that,
%   folders for functional and anatomical data. The function returns a
%   structure array where each element corresponds to a subject and includes
%   paths to their data files.
%
%   This function is useful for setting up a batch processing script WhiFuN
%
%   Input Arguments:
%   data_path        - The path of the directory that has all the subject folders    
%   comm_subj_name   - The common subject name or pattern to search for (e.g., 'sub-*').
%                      If empty (''), it defaults to all directories ('*').
%   comm_sess_name   - The common session folder name (e.g., 'ses-01').
%   func_folder_name - The name of the functional data subfolder (e.g., 'func').
%   func_data_name   - The base name of the functional data file (e.g., 'task-rest_bold').
%   anat_folder_name - The name of the anatomical data subfolder (e.g., 'anat').
%   anat_data_name   - The base name of the anatomical data file (e.g., 'T1w').
%
%   Output Arguments:
%   Subj_list_all - A structure array. Each element contains fields
%                   like `name`, `folder`, `isdir`, and new fields:
%                   `func_folder`, `func_name`, `anat_folder`, and `anat_name`.
%                   - `func_folder`: Full path to the functional data directory.
%                   - `func_name`: Pattern for the functional NIfTI file (e.g., 'task-rest_bold.nii*').
%                   - `anat_folder`: Full path to the anatomical data directory.
%                   - `anat_name`: Pattern for the anatomical NIfTI file (e.g., 'T1w.nii*').
%
%   Example:
%      % Assuming a BIDS-like directory structure:
%      %   .
%      %   |-- sub-01
%      %       |`-- ses-01
%      %           |-- anat
%      %      `       `-- T1w.nii.gz
%      %           |`-- func
%      %              `-- task-rest_bold.nii.gz
%      %   |-- sub-02
%      %      ...
%
%      % Create a subject list for this structure
%      subj_list = whifun_create_Subj_list_all('sub-*', 'ses-01', 'func', 'task-rest_bold', 'anat', 'T1w');
%
%   See also DIR, FULLFILE, STRCMP.

if strcmp(comm_subj_name,'') == 1
    comm_subj_name = '*';
end
% cd (data_path);

Subj_list_all = dir(fullfile(data_path,comm_subj_name) );

nt_dir = false(1,length(Subj_list_all));                                        % make a list of other files that are not directories
for i = 1:length(Subj_list_all)
    if Subj_list_all(i).isdir ~= 1
        nt_dir(i) = true;
    end
    Subj_list_all(i).func_folder = fullfile(Subj_list_all(i).folder, Subj_list_all(i).name ,char(comm_sess_name),char(func_folder_name));
    Subj_list_all(i).func_name = [char(func_data_name) '.nii*'];
    Subj_list_all(i).anat_folder = fullfile(Subj_list_all(i).folder, Subj_list_all(i).name,char(comm_sess_name),char(anat_folder_name));
    Subj_list_all(i).anat_name = [char(anat_data_name) '.nii*'];
end
Subj_list_all = Subj_list_all(~ismember({Subj_list_all.name},{'.','..','.DS_Store'}));
Subj_list_all(nt_dir) = [];                                                     % Remove all the files that are not directories (Now Subj_list should have all participant files)
