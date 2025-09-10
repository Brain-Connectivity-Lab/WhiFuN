function pattern_table = whifun_count_file_patterns(dataset_path)

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
