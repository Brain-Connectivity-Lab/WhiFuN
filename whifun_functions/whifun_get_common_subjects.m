function S_common = whifun_get_common_subjects(S1, S2)
% WHIFUN_GET_COMMON_SUBJECTS
% Returns a structure containing elements whose 'name' field
% is common between two structure arrays.
%
% Inputs:
%   S1, S2 - structure arrays with field 'name'
%
% Output:
%   S_common - structure array with common 'name' entries

    % Extract names
    names1 = {S1.name};
    names2 = {S2.name};

    % Find common names
    common_names = intersect(names1, names2);

    % Logical index for S1 entries with common names
    idx_common = ismember(names1, common_names);

    % Return subset of S1 (structure preserved)
    S_common = S1(idx_common);
end