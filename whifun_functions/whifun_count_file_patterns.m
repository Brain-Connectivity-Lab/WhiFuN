function pattern_table = whifun_count_file_patterns(dataset_path)
% WHIFUN_COUNT_FILE_PATTERNS Audits dataset structure by counting file naming patterns.
%
%   Author: Pratik Jain
%
%   This function recursively scans a directory and identifies unique file 
%   naming patterns by abstracting subject-specific IDs (sub-XXXX) into 
%   wildcards (sub*). It is designed to validate BIDS-compliant datasets.
%
%   INPUTS:
%       dataset_path - String. The root directory of your fMRI dataset.
%
%   OUTPUTS:
%       pattern_table - A table containing:
%           * Name: The abstracted file path and pattern.
%           * Value: The total count of files matching that pattern.
%
%   EXAMPLE:
%       % Check if all 20 subjects have their MNI-space bold files
%       audit = whifun_count_file_patterns('/data/project/derivatives/fmriprep');
%
%   See also DIR, REGEXPREP, CONTAINERS.MAP.
%   Author: Pratik Jain

% 1. Recursively list all files
% Using '**' allows MATLAB to look through all subfolders
    % Recursively list all files
    file_list = dir(fullfile(dataset_path, '**', '*.*'));
    file_list = file_list(~[file_list.isdir]); % remove folders

    patterns = containers.Map(); % dictionary for storing patterns

    for i = 1:length(file_list)
        % Get relative path from dataset root
        rel_path = strrep(file_list(i).folder, dataset_path, '');
        if startsWith(rel_path, filesep)
            rel_path = rel_path(2:end); % remove leading slash
        end

        % File name
        fname = file_list(i).name;

        % Replace subject IDs with wildcard
        % Keep session IDs as-is
        fname_pattern = regexprep(fname, 'sub-[^_\\/]*', 'sub*');
        rel_pattern  = regexprep(rel_path, 'sub-[^\\/]*', 'sub*');

        % Combine relative path + filename
        full_pattern = fullfile(rel_pattern, fname_pattern);

        % Count occurrences
        if isKey(patterns, full_pattern)
            patterns(full_pattern) = patterns(full_pattern) + 1;
        else
            patterns(full_pattern) = 1;
        end
    end

    % Convert to table
    keys_list   = keys(patterns);
    values_list = values(patterns);
    pattern_table = table(keys_list', cell2mat(values_list'), ...
                          'VariableNames', {'Name','Value'});

    % Display results
    fprintf('name , value\n');
    disp(pattern_table);

end
