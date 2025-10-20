function Subj_list_all = load_subjects_all(folder,name,new_run,overwrite)
% LOAD_SUBJECTS_ALL Loads all subjects from a CSV file, with options for new runs.
%
%   Subj_list_all = LOAD_SUBJECTS_ALL(folder, name) loads all subjects
%   from a CSV file without any filtering. The function reads the CSV file
%   named 'name' from the specified 'folder' and returns the data as a
%   structure array.
%
%   Subj_list_all = LOAD_SUBJECTS_ALL(folder, name, new_run) allows you to
%   initialize the file for a new data run.
%     - If `new_run` is true (1), the function adds 'error' and 'motion_ex'
%       columns and initializes them to zeros. This is useful for starting
%       a new analysis where you need to track errors and exclusions.
%
%   Subj_list_all = LOAD_SUBJECTS_ALL(folder, name, new_run, overwrite)
%   provides an option to overwrite existing 'motion_ex' data.
%     - If `new_run` and `overwrite` are both true (1), the function
%       will reset the 'motion_ex' column to all zeros, even if it
%       already exists.
%
%   Input Arguments:
%   folder    - The path to the folder containing the CSV file (char or string).
%   name      - The name of the CSV file (e.g., 'subjects.csv') (char or string).
%   new_run   - (Optional) A logical value to indicate a new run. If true,
%               it adds or initializes 'error' and 'motion_ex' columns.
%               Defaults to false if not provided.
%   overwrite - (Optional) A logical value. If true and `new_run` is also
%               true, it overwrites the 'motion_ex' column with zeros.
%               Defaults to false.
%
%   Output Arguments:
%   Subj_list_all - A structure array containing the data for all subjects
%                   from the CSV, with any new columns initialized as specified.
%
%   Example:
%      % Load all subjects from a CSV file in the current folder
%      subject_list = load_subjects_all(pwd, 'Subj_list.csv');
%
%      % Start a new run, initializing error and motion exclusion columns
%      new_subjects = load_subjects_all(pwd, 'Subj_list.csv', true);
%
%      % Start a new run and overwrite existing motion exclusion data
%      reset_subjects = load_subjects_all(pwd, 'Subj_list.csv', true, true);
%
%   See also READTABLE, DETECTIMPORTOPTIONS, TABLE2STRUCT.
%   Author: Pratik Jain


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
catch ex
    warning(['Error in loading the Subjects: ' ex.message])
    Subj_list_all = [] ;
end

end

