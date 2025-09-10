function important_table = whifun_plot_important(dataset_path, important_endings)

    % First get the full table using your function
    pattern_table = whifun_count_file_patterns(dataset_path);

    % If user did not provide important endings, use default list
    if nargin < 2 || isempty(important_endings)
        important_endings = { ...
            'space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz', ...
            'space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz', ...
            'task-rest_run-1_desc-confounds_timeseries.tsv', ...
            'space-MNI152NLin2009cAsym_label-GM_probseg.nii.gz', ...
            'space-MNI152NLin2009cAsym_label-WM_probseg.nii.gz', ...
            'space-MNI152NLin2009cAsym_label-CSF_probseg.nii.gz', ...
            'space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz' ...
        };
    end

    % Filter rows that match any important ending
    isImportant = false(height(pattern_table),1);
    for i = 1:length(important_endings)
        matches = endsWith(pattern_table.Name, important_endings{i});
        isImportant = isImportant | matches;
    end

    important_table = pattern_table(isImportant,:);

    % Plot histogram (bar chart)
    figure;
    bar(categorical(important_table.Name), important_table.Value);
    ylabel('Count');
    title('Counts of Important Files in Dataset');
    xtickangle(45);

    % Display filtered table as well
    disp('Important files:');
    disp(important_table);

end
