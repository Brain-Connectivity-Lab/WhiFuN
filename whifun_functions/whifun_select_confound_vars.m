function idx_all = whifun_select_confound_vars(confound_vars, Reg_params)
% WHIFUN_SELECT_CONFOUND_VARS
% Select confound variables using wildcard patterns (*)
%
% INPUTS
%   confound_vars : cell array of char or string
%   Reg_params    : cell array of patterns (e.g., {'csf','aroma*','*motion*'})
%
% OUTPUT
%   selected_vars : cell array of matched confound variable names

    % Ensure cell array of char
    confound_vars = cellstr(confound_vars);
    Reg_params    = cellstr(Reg_params);

    idx_all = [];
    for i = 1:numel(Reg_params)
        pat = Reg_params{i};

        % Convert wildcard pattern to regex
        % Escape regex special chars except '*'
        pat_escaped = regexptranslate('escape', pat);
        pat_regex   = strrep(pat_escaped, '\*', '.*');

        % Anchor regex to full string
        pat_regex = ['^' pat_regex '$'];

        % Match against confound variables
        idx = find(~cellfun('isempty', regexp(confound_vars, pat_regex, 'once')));

        idx_all = [idx_all,idx];
    end

    % Remove duplicates while preserving order
    idx_all = unique(idx_all, 'stable');
end
