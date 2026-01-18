function whifun_create_all_fn_image_montage(inputFolder, outputPrefix, tissueTypes)
% WHIFUN_CREATE_ALL_FN_IMAGE_MONTAGE Consolidates network views into a large grid.
%
%   This function scans a folder for brain network visualizations (PNGs), 
%   extracts their network IDs, and tiles them into a large canvas. Each row 
%   represents a specific Functional Network (FN), and each column 
%   represents a specific anatomical view (Left, Dorsal, Posterior).
%
%   INPUTS:
%       inputFolder  - String. Directory containing the individual network PNGs.
%       outputPrefix - String. Filename prefix for the final montage (e.g., 'Group_ICA').
%       tissueTypes  - Cell Array. e.g., {'WM', 'GM'} to process White and Grey matter.
%
%   FILE NAMING CONVENTION EXPECTED:
%       [Tissue]_FN_K[TotalNets]_[NetID]_[View].png
%       Example: GM_FN_K17_5_left.png (Grey Matter, 17 total nets, Net #5, Left view).
%
%   See also IMREAD, IMWRITE, REGEXP.
%   Author: Pratik Jain

% Define views as per standard toolbox output
    % inputFolder : folder containing WM and GM images
    % outputPrefix: prefix for output files (e.g., 'Networks')
    %
    % Will create 'Networks_WM_montage.png' and 'Networks_GM_montage.png'

    % Define tissue types and views
    % tissueTypes = {'WM', 'GM'};
    views = {"left", "Dorsal", "posterior"};
    numViews = numel(views);

    for t = 1:numel(tissueTypes)
        tissue = tissueTypes{t};

        % Get list of files for this tissue
        files = dir(fullfile(inputFolder, [tissue '_*_*.png']));
        if isempty(files)
            error('No images found for %s in %s', tissue, inputFolder);
        end

        % Extract network numbers
        netNums = [];
        for i = 1:numel(files)
            tokens = regexp(files(i).name, [tissue '_FN_K(\d+)_(\d+)_'], 'tokens');
            if ~isempty(tokens)
                netNums(end+1) = str2double(tokens{1}{2});
            end
        end
        networks = unique(netNums);
        numNets = numel(networks);

        % Read one image to get size
        sampleImg = imread(fullfile(inputFolder, files(1).name));
        [h, w, c] = size(sampleImg);

        % Preallocate big canvas
        bigImage = uint8(255*ones(numNets*h, numViews*w, c));

        % Fill the canvas
        for i = 1:numNets
            netID = networks(i);
            for j = 1:numViews
                imgName = sprintf('%s_FN_K%d_%d_%s.png', tissue,numNets ,netID, views{j});
                imgPath = fullfile(inputFolder, imgName);

                if isfile(imgPath)
                    img = imread(imgPath);
                    rowIdx = (i-1)*h + (1:h);
                    colIdx = (j-1)*w + (1:w);
                    bigImage(rowIdx, colIdx, :) = img;
                else
                    warning('Missing image: %s', imgName);
                end
            end
        end

        % Save montage
        outputFile = sprintf('%s_%s_montage.png', outputPrefix, tissue);
        imwrite(bigImage, outputFile);
        fprintf('Montage saved: %s\n', outputFile);
    end
end
