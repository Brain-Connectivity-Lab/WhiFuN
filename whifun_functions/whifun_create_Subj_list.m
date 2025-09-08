function [Subj_list_all,output_folder] = whifun_create_Subj_list()
% Multi-subject setup with interactive pattern fixing (files + folders)
%% Step 1: Select Data Folder
output_folder = uigetdir(pwd, 'Select output folder');
if isequal(output_folder,0)
    error('No folder selected');
end

%% Step 1: Select Data Folder
dataFolder = uigetdir(pwd, 'Select main data folder containing subject folders');
if isequal(dataFolder,0)
    error('No folder selected');
end

%% Step 2: Subject Folder Selection
subfolders = dir(dataFolder);
subfolders = subfolders([subfolders.isdir]); % only directories
subfolders = subfolders(~ismember({subfolders.name},{'.','..'}));

choice = questdlg('How do you want to select subject folders?', ...
    'Subject Selection', ...
    'All', 'Pattern', 'Manual', 'All');

switch choice
    case 'All'
        subjFolders = {subfolders.name};
    case 'Pattern'
        pattern = inputdlg('Enter folder name pattern (supports wildcards, e.g. sub*):', ...
            'Folder Pattern', 1, {'sub*'});
        matches = dir(fullfile(dataFolder, pattern{1}));
        subjFolders = {matches([matches.isdir]).name};
    case 'Manual'
        [indx,tf] = listdlg('PromptString','Select subject folders:', ...
            'ListString',{subfolders.name});
        if ~tf, error('No subjects selected'); end
        subjFolders = {subfolders(indx).name};
end

%% Step 3: Define Field Patterns
fieldNames = {
    'GM_native'
    'WM_native'
    'CSF_native'
    'GM_MNI'
    'WM_MNI'
    'CSF_MNI'
    'skull_stripped_anat_native'
    'anat_mask_native'
    'anat_mask_MNI'
    'coregistered_func_native'
    'func_mask_native_space'
    'smoothed_func'
    'func_MNI'
    'anat_MNI'
    'func_mask_MNI'
    'MNI_template'
    'final_func_MNI'
    };

% GUI for field patterns
f = figure('Name', 'Define field patterns (relative to subject folder)', ...
    'Position', [200 200 500 600], ...
    'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off');

t = uitable('Parent', f, ...
    'Data', [fieldNames, repmat({''}, numel(fieldNames), 1)], ...
    'ColumnName', {'Field', 'Pattern (relative)'}, ...
    'ColumnEditable', [false true], ...
    'ColumnWidth', {150, 300}, ...
    'Units', 'normalized', ...
    'Position', [0.05 0.2 0.9 0.75]);

uicontrol('Style', 'pushbutton', 'String', 'Save & Validate', ...
    'Units', 'normalized', ...
    'Position', [0.3 0.05 0.4 0.1], ...
    'Callback', @(~,~) uiresume(f));

uiwait(f);
finalData = get(t, 'Data');
delete(f);

% %% Step 4: Validate Patterns & Fix Interactively
% Subj_list_all = struct();
% for i = 1:size(finalData,1)
%     field = finalData{i,1};
%     pattern = finalData{i,2};
%     if isempty(pattern)
%         continue; % skip empty fields
%     end
%
%     valid = false;
%     while ~valid
%         allMatches = cell(numel(subjFolders),1);
%         multipleProblem = false;
%         zeroProblem = false;
%
%         for s = 1:numel(subjFolders)
%             subjPath = fullfile(dataFolder, subjFolders{s});
%             matches = dir(fullfile(subjPath, pattern));
%             allMatches{s} = matches;
%             if numel(matches) == 0
%                 zeroProblem = true;
%             elseif numel(matches) > 1
%                 multipleProblem = true;
%             end
%         end
%
%         if zeroProblem
%             answer = inputdlg(sprintf(['Pattern "%s" failed: No matches for at least one subject.\n' ...
%                                        'Field: %s\n\nEnter a new pattern:'], ...
%                                        pattern, field), ...
%                               'Fix Pattern', 1, {pattern});
%             if isempty(answer), break; end
%             pattern = answer{1};
%             continue;
%         elseif multipleProblem
%             answer = inputdlg(sprintf(['Pattern "%s" failed: Multiple matches for at least one subject.\n' ...
%                                        'Field: %s\n\nEnter a new pattern:'], ...
%                                        pattern, field), ...
%                               'Fix Pattern', 1, {pattern});
%             if isempty(answer), break; end
%             pattern = answer{1};
%             continue;
%         else
%             % Success: assign to all subjects
%             for s = 1:numel(subjFolders)
%                 m = allMatches{s}(1);
%                 if m.isdir
%                     Subj_list_all(s).(field) = fullfile(dataFolder, subjFolders{s}, m.name, filesep);
%                 else
%                     Subj_list_all(s).(field) = fullfile(dataFolder, subjFolders{s}, m.name);
%                 end
%             end
%             valid = true;
%         end
%     end
% end
%% Step 4: Validate Patterns & Fix Interactively
Subj_list_all = struct();
for s = 1:numel(subjFolders)
    Subj_list_all(s).name = subjFolders{s};
    Subj_list_all(s).folder = dataFolder;
end

for i = 1:size(finalData,1)
    field = finalData{i,1};
    pattern = strtrim(finalData{i,2});
    % Always create the field
    for s = 1:numel(subjFolders)
        if strcmp(field,'name')
            Subj_list_all(s).(field) = subjFolders{s};
        elseif strcmp(field,'folder')
            Subj_list_all(s).(field) = dataFolder;
        else
            Subj_list_all(s).(field) = '';
        end
    end

    if isempty(pattern)
        % Field left blank by user → leave as ''
        continue;
    end

    % Try to resolve pattern for each subject
    for s = 1:numel(subjFolders)

        subjPath = fullfile(dataFolder, subjFolders{s});
        matches = dir(fullfile(subjPath, pattern));

        if isscalar(matches)
            Subj_list_all(s).(field) = fullfile(matches.folder, matches.name);
        elseif isempty(matches)
            warning('No match found for field "%s" in subject folder "%s"', ...
                field, subjFolders{s});
        else
            warning('Multiple matches for field "%s" in subject folder "%s". Leaving blank.', ...
                field, subjFolders{s});
        end
    end
end
Subj_list_all = whifun_create_fields(Subj_list_all);
my_writetable(struct2table(Subj_list_all), fullfile(output_folder,"Subj_list.csv"))
disp('✅ Multi-subject setup complete.');
end
