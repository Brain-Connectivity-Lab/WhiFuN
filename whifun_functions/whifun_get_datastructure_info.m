function summary = whifun_get_datastructure_info(dataDir, funcPattern, anatPattern, varargin)
% WHIFUN - Scans subject subfolders (e.g., BAS1, BAS2) for scan completion.
    
    % 1. Setup subject list
    subDirs = dir(dataDir);
    subDirs = subDirs([subDirs.isdir] & ~startsWith({subDirs.name}, '.'));
    
    allData = {}; % To store rows of data

    fprintf('Scanning subjects in: %s\n\n', dataDir);

    % 2. Loop through each subject
    for i = 1:length(subDirs)
        subName = subDirs(i).name;
        subPath = fullfile(dataDir, subName);
        
        % Get intermediate folders (e.g., BAS1, BAS2)
        interDirs = dir(subPath);
        interDirs = interDirs([interDirs.isdir] & ~startsWith({interDirs.name}, '.'));
        
        % 3. Loop through intermediate folders (BAS1, etc.)
        for j = 1:length(interDirs)
            interName = interDirs(j).name;
            interPath = fullfile(subPath, interName);
            
            % Check for files inside this specific intermediate folder
            % Uses '**' to handle cases where files are in further subfolders (e.g., BAS1/anat/)
            hasFunc = ~isempty(dir(fullfile(interPath, '**', funcPattern)));
            hasAnat = ~isempty(dir(fullfile(interPath, '**', anatPattern)));
            
            % Add to our data collection
            allData(end+1, :) = {subName, interName, hasFunc, hasAnat}; %#ok<AGROW>
        end
    end

    % 4. Create Table
    summary = cell2table(allData, 'VariableNames', {'Subject', 'FolderType', 'Has_Func', 'Has_Anat'});

    % 5. Print the breakdown by Folder Type (BAS1, BAS2, etc.)
    uniqueFolders = unique(summary.FolderType);
    
    fprintf('%-12s | %-10s | %-12s | %-12s\n', 'Folder Type', 'Total', 'Complete', 'Missing Part');
    fprintf('-------------------------------------------------------------\n');
    
    for k = 1:length(uniqueFolders)
        fName = uniqueFolders{k};
        subset = summary(strcmp(summary.FolderType, fName), :);
        
        total = height(subset);
        complete = sum(subset.Has_Func & subset.Has_Anat);
        missing  = sum(~(subset.Has_Func & subset.Has_Anat));
        
        fprintf('%-12s | %-10d | %-12d | %-12d\n', fName, total, complete, missing);
    end
end