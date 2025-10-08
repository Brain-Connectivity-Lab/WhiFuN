function [subgroups, overlaps] = whifun_make_subgroups(total_subjects, n)
%WHIFUN_MAKE_SUBGROUPS Creates non-overlapping and potentially one-overlapping
%                       subgroups of subjects from a total pool.
%
%   [SUBGROUPS, OVERLAPS] = WHIFUN_MAKE_SUBGROUPS(TOTAL_SUBJECTS, N)
%
%   This function partitions a set of 'total_subjects' into subgroups of
%   size 'n'. If the total number of subjects is not divisible by 'n',
%   the last subgroup is formed by taking the remaining subjects and
%   "filling" the group to size 'n' by randomly sampling subjects from the
%   previously formed full subgroups. This ensures all subgroups are of
%   uniform size 'n', but the last group may overlap with others.
%
%   Input Arguments:
%   TOTAL_SUBJECTS - The total number of subjects available (e.g., number of rows in a data table).
%   N              - The desired size of each subgroup (number of subjects per group).
%
%   Output Arguments:
%   SUBGROUPS      - A cell array where each cell contains a vector of subject
%                    indices (1 to TOTAL_SUBJECTS) forming a subgroup of size 'n'.
%   OVERLAPS       - A structure detailing the subjects involved in an overlap
%                    (i.e., subjects who are in the last group and one of the
%                    previous groups).
%       .subjects  - A vector of subject indices that appear in more than one subgroup.
%       .groups    - A cell array where OVERLAPS.groups{i} lists the subgroup
%                    indices (1, 2, ...) that OVERLAPS.subjects(i) belongs to.
%
%   Example:
%      [groups, overlap_info] = whifun_make_subgroups(10, 3);
%      % groups might be: {[ 6 3 7], [ 8 5 1], [ 2 4 9], [10 3 4]} - where
%      3, 4 were repeated
%      % overlap_info will contain information on which subjects (3, 4)
%      % were repeated.
%
%   Author: Pratik Jain


    % ---- Check inputs ----
    if n > total_subjects
        error('Subgroup size n must be <= total number of subjects');
    end
    
    % ---- Shuffle subject indices ----
    subjects = randperm(total_subjects);
    
    % ---- Compute groups ----
    num_full_groups = floor(total_subjects / n);
    remainder = mod(total_subjects, n);
    
    subgroups = cell(num_full_groups + (remainder > 0), 1);
    
    % Full groups
    for i = 1:num_full_groups
        idx_start = (i-1)*n + 1;
        idx_end = i*n;
        subgroups{i} = subjects(idx_start:idx_end);
    end
    
    % Handle remainder
    if remainder > 0
        leftover = subjects(num_full_groups*n + 1:end);
        filler_needed = n - remainder;
        
        % Sample filler subjects from previous groups
        filler = subjects(randperm(num_full_groups*n, filler_needed));
        
        subgroups{end} = [leftover, filler];
    end
    
    % ---- Detect overlaps ----
    all_ids = [subgroups{:}];
    [unique_ids, ~, ic] = unique(all_ids);
    counts = accumarray(ic, 1);
    
    overlapping_subjects = unique_ids(counts > 1);
    
    overlaps = struct();
    overlaps.subjects = overlapping_subjects;
    overlaps.groups = cell(numel(overlapping_subjects), 1);
    
    for i = 1:numel(overlapping_subjects)
        s = overlapping_subjects(i);
        groups_with_s = find(cellfun(@(g) ismember(s, g), subgroups));
        overlaps.groups{i} = groups_with_s;
    end
end
