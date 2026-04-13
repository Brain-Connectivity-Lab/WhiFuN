function [Subj_list,rm] = load_subjects(folder,name,first)
% LOAD_SUBJECTS Loads a list of subjects from a CSV file.
%
%   [Subj_list, rm] = LOAD_SUBJECTS(folder, name) loads a CSV file
%   named 'name' from the specified 'folder'. It returns a structure array
%   'Subj_list' containing the subject data and a logical array 'rm'
%   indicating which rows were removed. The function automatically
%   removes subjects marked with 'error', 'motion_ex', or 'manual_ex'.
%
%   [Subj_list, rm] = LOAD_SUBJECTS(folder, name, first) allows for
%   different behavior on the first run. If 'first' is true (1), the
%   function initializes new 'error' and 'motion_ex' columns with zeros and
%   only removes subjects marked with 'manual_ex'. This is useful for
%   initial data processing runs.
%
%   Input Arguments:
%   folder - The folder path where the CSV file is located (char or string).
%   name   - The name of the CSV file (char or string).
%   first  - (Optional) A logical value. If true, it performs a "first run"
%            initialization. Defaults to false if not provided.
%
%   Output Arguments:
%   Subj_list - A structure array containing the subject data after
%               filtering. Each row of the CSV becomes a structure in the
%               array.
%   rm        - A logical array indicating which rows were removed based on
%               the exclusion criteria.
%
%   Example:
%      % Load subjects from 'subject_data.csv' in the current folder
%      [subjects, removed] = load_subjects(pwd, 'subject_data.csv');
%
%   Author: Pratik Jain
%   See also READTABLE, TABLE2STRUCT, DETECTIMPORTOPTIONS.

if nargin < 3
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

        if ~nnz(isnan(T.manual_ex))
            rm = logical(T.manual_ex);
            Subj_list = table2struct(T(~rm,:));
        else
            Subj_list = table2struct(T);
        end
    else
        rm = (logical(T.error) | logical(T.motion_ex) | logical(T.manual_ex));
        Subj_list = table2struct(T(~rm,:));
    end
catch ex
    warning(['Error in loading the bad Subjects: ' ex.message])

    Subj_list = [] ;
end