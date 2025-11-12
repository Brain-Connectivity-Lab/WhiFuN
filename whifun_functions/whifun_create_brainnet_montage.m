function whifun_create_brainnet_montage(inputFolder, outputPrefix,tissueTypes)
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
