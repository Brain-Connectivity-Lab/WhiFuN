function Subj_list_all = load_subjects_all(folder,name,ini_error,ini_motion)
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
%   ini_error - (Optional) A logical value to reinitialize error column. If true,
%               it adds or initializes 'error' columns.
%               Defaults to false if not provided.
%   ini_motion- (Optional) A logical value. If true and `ini_run` is also
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
%      % Initializing (or overwriting) error columns
%      subject_list = load_subjects_all(pwd, 'Subj_list.csv', true);
%
%      % Initializing (or overwriting) existing motion exclusion data
%      subject_list = load_subjects_all(pwd, 'Subj_list.csv', true, true);
%
%   See also READTABLE, DETECTIMPORTOPTIONS, TABLE2STRUCT.
%   Author: Pratik Jain


if nargin < 4
    ini_error = 0;
end

opts = detectImportOptions(fullfile(folder,name),'Delimiter',',');
opts = setvartype(opts, 'char'); % or 'string', depending on your MATLAB version
T1 = readtable(fullfile(folder,name),opts);

T = readtable(fullfile(folder,name),'Delimiter',',');

try
T1.error = T.error;
catch
end

try
T1.motion_ex = T.motion_ex;
catch
end

try
T1.manual_ex = T.manual_ex;
catch
end

try
T1.x_func = T.x_func;
catch
end

try
T1.y_func = T.y_func;
catch
end

try
T1.z_func = T.z_func;
catch
end

try
T1.x_Anat = T.x_Anat;
catch
end

try
T1.y_Anat = T.y_Anat;
catch
end

try
T1.z_Anat = T.z_Anat;
catch
end

try
T1.nt = T.nt;
catch
end

try
T1.TR = T.TR;
catch
end

try
T1.time_preprocess_min = T.time_preprocess_min;
catch
end

try
T1.nt_dis = T.nt_dis;
catch
end

T = T1;


try
    if ini_error
        T.error = zeros(height(T),1);
        if ~ismember('motion_ex', T.Properties.VariableNames)
            T.motion_ex = zeros(height(T),1);
        end

        if ini_motion
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

