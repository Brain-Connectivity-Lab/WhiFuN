function Subj_list = load_subjects_bad(folder,name)
% LOAD_SUBJECTS_BAD Loads the Subjects that wont be preprocessed or analysed due to error, Motion exclusion or Manual rejection list of subjects from a CSV file.
%
%   [Subj_list, rm] = LOAD_SUBJECTS_BAD(folder, name) loads a CSV file
%   named 'name' from the specified 'folder'. It returns a structure array
%   'Subj_list' containing the subject data. The function loads
%   subjects marked with 'error', 'motion_ex', or 'manual_ex'.
%
%   Input Arguments:
%   folder - The folder path where the CSV file is located (char or string).
%   name   - The name of the CSV file (char or string).
%
%   Output Arguments:
%   Subj_list - A structure array containing the subject data after
%               filtering. Each row of the CSV becomes a structure in the
%               array.
%
%   Example:
%      % Load bad subjects from 'subject_data.csv' in the current folder
%      [subjects, removed] = load_subjects_bad(pwd, 'subject_data.csv');
%
%   Author: Pratik Jain
%   See also READTABLE, TABLE2STRUCT, DETECTIMPORTOPTIONS.

try
    opts = detectImportOptions(fullfile(folder,name),'Delimiter',',');
    opts = setvartype(opts, 'char'); % or 'string', depending on your MATLAB version
    T1 = readtable(fullfile(folder,name),opts);

    T = readtable(fullfile(folder,name),'Delimiter',',');

    T.name = T1.name;

    rm = (logical(T.error) | logical(T.motion_ex) | logical(T.manual_ex));
    Subj_list = table2struct(T(rm,:));
catch ex
    warning(['Error in loading the bad Subjects: ' ex.message])
    write_error(exception)
    Subj_list = [] ;
end