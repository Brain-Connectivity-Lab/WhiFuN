% function subgroups = whifun_make_subgroups(total_subjects, n)
%     % make_subgroups: Divide subjects into subgroups of size n with minimal overlap
%     % Inputs:
%     %   total_subjects - total number of subjects (e.g., 929)
%     %   n - subgroup size
%     % Output:
%     %   subgroups - cell array, each cell contains subject indices
% 
%     % Check inputs
%     if n > total_subjects
%         error('Subgroup size n must be <= total number of subjects');
%     end
% 
%     % Shuffle subject indices to randomize assignment
%     subjects = randperm(total_subjects);
% 
%     % Compute number of full groups
%     num_full_groups = floor(total_subjects / n);
%     remainder = mod(total_subjects, n);
% 
%     subgroups = cell(num_full_groups + (remainder > 0), 1);
% 
%     % Assign full groups
%     for i = 1:num_full_groups
%         idx_start = (i-1)*n + 1;
%         idx_end = i*n;
%         subgroups{i} = subjects(idx_start:idx_end);
%     end
% 
%     % If remainder exists, assign leftover subjects
%     if remainder > 0
%         leftover = subjects(num_full_groups*n + 1:end);
% 
%         % To keep group size = n, fill with random subjects from earlier groups
%         filler_needed = n - remainder;
%         filler = randperm(num_full_groups*n, filler_needed);
% 
%         subgroups{end} = [leftover, subjects(filler)];
%     end
% end

function [subgroups, overlaps] = whifun_make_subgroups(total_subjects, n)
    % make_subgroups_with_overlap:
    % Divide subjects into subgroups of size n with minimal overlap
    % and record any overlaps.
    %
    % Inputs:
    %   total_subjects - total number of subjects (e.g., 929)
    %   n              - subgroup size
    %
    % Outputs:
    %   subgroups - cell array, each cell contains subject indices
    %   overlaps  - struct listing subjects that appear in multiple groups
    
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
