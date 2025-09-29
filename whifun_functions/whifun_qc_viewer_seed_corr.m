% Set up folder paths

% Declare global variables
global currentImageIndex folderPaths imageFiles
k_seed_cor_folder = 'K:\WhiFuN_HCP_S1200_op\Quality_control\k_Seed_Based_Corr';
vox_ts_folder = 'K:\WhiFuN_HCP_S1200_op\Quality_control\i_Final_func_MNI\MNI_Space\Vox_ts';
folderPaths = {fullfile(k_seed_cor_folder,'Default_Mode_Seed_lh_pcc_5_-49_40','axial_Slice_View'), ...
               fullfile(k_seed_cor_folder,'Auditory_Seed_lh_cort_aud_64_-12_2','axial_Slice_View'), ...
               fullfile(k_seed_cor_folder,'Visual_Seed_rh_cort_vis_-4_-91_-3','axial_Slice_View'), ...
               vox_ts_folder};

% Get a list of all image files in the first folder
imageFiles = dir(fullfile(folderPaths{1}, '*.png')); 

% Check if there are any image files
if isempty(imageFiles)
    error('No images found in the specified folders.');
end


% Initialize the global image index
currentImageIndex = 1;

% Create a figure for displaying images
figure('KeyPressFcn', @keyPressCallback);

% Display the initial set of images
displayImages;

% --- Nested Functions ---
function displayImages
    global currentImageIndex folderPaths imageFiles

    % Clear the previous images
    clf;

    % Check if the current index is valid
    if currentImageIndex > length(imageFiles)
        currentImageIndex = 1; % Loop back to the beginning
    elseif currentImageIndex < 1
        currentImageIndex = length(imageFiles); % Loop to the end
    end

    % Get the base name of the current image from the first folder
    currentImageName = imageFiles(currentImageIndex).name;
    baseName = currentImageName(1:6); % Assuming the first 6 characters are the subject ID

    % Define positions for the subplots to maximize space
    % [left bottom width height] - normalized units
    subplot_positions = {
        [0.02 0.52 0.46 0.46], % Top-left
        [0.50 0.52 0.46 0.46], % Top-right
        [0.02 0.02 0.46 0.46], % Bottom-left
        [0.50 0.02 0.46 0.46]  % Bottom-right
    };

    % Loop through each folder and display the image
    for i = 1:length(folderPaths)
        % Find the file in the current folder that starts with the base name
        matchFiles = dir(fullfile(folderPaths{i}, [baseName '*.png']));

        if ~isempty(matchFiles)
            % Use the first match found
            imagePath = fullfile(matchFiles(1).folder, matchFiles(1).name);

            % Create axes at the specified position
            ax = axes('Units', 'normalized', 'Position', subplot_positions{i});
            
            % Read and display the image
            img = imread(imagePath);
            imshow(img, 'Parent', ax, 'InitialMagnification', 'fit'); % 'fit' makes image fill the axes
            title(ax, sprintf('Folder %d: %s', i, matchFiles(1).name), 'FontSize', 10, 'Interpreter', 'none');
        else
            % Display a warning if no matching file is found
            fprintf('Warning: Image with pattern "%s" not found in %s\n', [baseName '*.png'], folderPaths{i});
            % You might want to display a placeholder or empty axes here
            ax = axes('Units', 'normalized', 'Position', subplot_positions{i});
            text(0.5, 0.5, 'Image not found', 'Parent', ax, 'HorizontalAlignment', 'center', 'Color', 'red');
            title(ax, sprintf('Folder %d: Missing', i), 'FontSize', 10);
        end
    end

    % Set a main title for the figure, slightly higher to avoid overlap
    sgtitle_ax = axes('Units', 'normalized', 'Position', [0 0.95 1 0.05], 'Visible', 'off');
    text(0.5, 0.5, sprintf('Displaying Image %d of %d (Base: %s)', currentImageIndex, length(imageFiles), baseName), ...
         'Parent', sgtitle_ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
end

function keyPressCallback(~, event)
    global currentImageIndex
    
    % This function handles key presses
    switch event.Key
        case 'rightarrow'
            currentImageIndex = currentImageIndex + 1;
            displayImages;
        case 'leftarrow'
            currentImageIndex = currentImageIndex - 1;
            displayImages;
        case 'q'
            % Close the figure if the 'q' key is pressed
            close(gcf);
    end
end