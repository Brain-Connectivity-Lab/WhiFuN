function whifun_copyfiles(Subj_list, field_name, dest_folder)
% whifun_copyfiles(Subj_list, field_name, dest_folder)
%
% Copies files listed in a specified field of a struct array to a destination folder,
% preserving their directory structure relative to their source locations.
%
% Example:
%   whifun_copyfiles(Subj_list, 'func_path', 'D:\All_Func_Files')
%
% Inputs:
%   Subj_list   : Struct array (e.g., Subj_list(i).func_path = '/data/sub1/func.nii')
%   field_name  : Name of the field containing file paths
%   dest_folder : Destination root folder for copied files
%
% Notes:
%   - Creates subfolders as needed to mirror the source directory structure.
%   - Keeps original filenames.
%   - Assumes all files share a common root (e.g., '/data').
%
%   You can customize the 'common_root' detection below if needed.
%  Author: Pratik Jain

    if nargin < 3
        error('Usage: whifun_copyfiles(Subj_list, field_name, dest_folder)');
    end

    if ~isstruct(Subj_list)
        error('Subj_list must be a struct array.');
    end

    if ~ischar(field_name) && ~isstring(field_name)
        error('field_name must be a string or character array.');
    end

    if ~exist(dest_folder, 'dir')
        mkdir(dest_folder);
        fprintf('Created destination folder: %s\n', dest_folder);
    end

    nSubj = numel(Subj_list);

    % --- Collect all valid source paths ---
    allPaths = {};
    for i = 1:nSubj
        if isfield(Subj_list(i), field_name)
            fpath = Subj_list(i).(field_name);
            if isfile(fpath)
                allPaths{end+1} = fpath; %#ok<AGROW>
            else
                warning('File not found: %s', fpath);
            end
        else
            warning('Field "%s" not found in Subj_list(%d)', field_name, i);
        end
    end

    if isempty(allPaths)
        warning('No valid files found in field "%s".', field_name);
        return;
    end

    % --- Detect common root directory ---
    splitPaths = cellfun(@(p) strsplit(p, filesep), allPaths, 'UniformOutput', false);
    minLen = min(cellfun(@numel, splitPaths));
    commonRootParts = {};
    for j = 1:minLen
        partsAtLevel = cellfun(@(c) c{j}, splitPaths, 'UniformOutput', false);
        if isscalar(unique(partsAtLevel))
            commonRootParts{end+1} = partsAtLevel{1}; %#ok<AGROW>
        else
            break;
        end
    end
    common_root = fullfile(commonRootParts{:});

    fprintf('Detected common root: %s\n', common_root);
    fprintf('Copying files to %s\n', dest_folder);

    % --- Copy files preserving structure ---
    for i = 1:nSubj
        if isfield(Subj_list(i), field_name)
            src = Subj_list(i).(field_name);
            if ~isfile(src)
                continue;
            end

            % relative path after common root
            relPath = strrep(src, common_root, '');
            if startsWith(relPath, filesep)
                relPath = relPath(2:end);
            end

            destPath = fullfile(dest_folder, relPath);
            destDir = fileparts(destPath);
            if ~exist(destDir, 'dir')

                for ii = 1:5
                    try
                        mkdir(destDir);
                        break
                    catch
                    end
                end
            end

            copyfile(src, destPath);
            fprintf('Copied: %s → %s\n', src, destPath);
        end
    end

    fprintf('✅ Done copying files with preserved folder structure.\n');
end
