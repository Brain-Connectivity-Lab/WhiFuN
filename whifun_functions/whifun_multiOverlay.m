function whifun_multiOverlay(volumes, overlayTypes, colormaps, slices, sliceType)
%WHIFUN_MULTIOVERLAY Displays a montage of structural MRI slices with contour overlays.
%
%   WHIFUN_MULTIOVERLAY(volumes, overlayTypes, colormaps, slices, sliceType)
%   extracts specified slices along a given anatomical plane, processes structural 
%   backgrounds, computes edge contours for overlays, and bundles them into a 
%   clean, multi-slice RGB montage figure.
%
%   Processing Details:
%       - Automatically loads NIfTI file paths or handles pre-loaded 3D/4D arrays.
%       - Truncates 4D volumes to their first frame automatically.
%       - Uses a Canny edge detector to extract contour overlays.
%       - Requires exactly one volume designated as 'Structural' to serve as the background.
%
%   Inputs:
%       volumes      - A single string/char path, numeric array, or a cell array 
%                      containing a mix of file paths and 3D/4D matrices.
%       overlayTypes - Cell array of strings corresponding to each item in 'volumes'.
%                      Supported types:
%                        'Structural' - Used as the grayscale background slice.
%                        'contours'   - Edge detected and blended onto the background.
%       colormaps    - Cell array of strings or function handles specifying colormaps 
%                      for each volume (e.g., {'gray', 'hot'}). The last color 
%                      of the contour's colormap is used for its edge color.
%       slices       - Vector of integers denoting the slice numbers to display.
%       sliceType    - String specifying the viewing plane. Options are:
%                      'axial', 'coronal', or 'sagittal'.
%
%   Outputs:
%       Generates a standard MATLAB figure containing the tiled slice montage.
%
%   Example:
%       vols     = {'C:\Data\T1.nii', 'C:\Data\LesionMask.nii'};
%       types    = {'Structural', 'contours'};
%       cmaps    = {'gray', 'hot'};
%       sliceVec = [45, 50, 55, 60];
%       whifun_multiOverlay(vols, types, cmaps, sliceVec, 'axial');
%   Author: Pratik Jain


%% --- Load Volumes ---
if ~iscell(volumes), volumes = {volumes}; end
nVols = numel(volumes);

for i = 1:nVols
    if ischar(volumes{i}) || isstring(volumes{i})
        nii = niftiread(volumes{i});
        volumes{i} = double(nii);
    else
        volumes{i} = double(volumes{i});
    end

    if length(size(volumes{i})) == 4
        volumes{i} = volumes{i}(:,:,:,1);
        warning(['Find multiple volumes in Volumes position ' num2str(i) ' Considereing only the first volume'])
    end
end

%% --- Collect images for montage ---
nSlices = numel(slices);
allSlices = [];  % 4D array for montage (HxWx1xN)

for s = 1:nSlices
    sliceIdx = slices(s);
    
    % Base image (first volume with 'structure')
    baseImg = [];
    for i = 1:nVols
        if strcmpi(overlayTypes{i},'Structural')
            vol = volumes{i};
            switch lower(sliceType)
                case 'axial'
                    baseImg = squeeze(vol(:,:,sliceIdx))';
                case 'coronal'
                    baseImg = squeeze(vol(:,sliceIdx,:))';
                case 'sagittal'
                    baseImg = squeeze(vol(sliceIdx,:,:))';
                otherwise
                    error('sliceType must be axial, coronal, or sagittal');
            end
            break; % use first structure image as base
        end
    end
    
    if isempty(baseImg)
        error('At least one volume with type "Structural" is required.');
    end
    
    % Make RGB image to allow overlays
    rgbImg = ind2rgb(mat2gray(baseImg), colormap(colormaps{1}));
    
    % Add contour overlays
    for i = 1:nVols
        if strcmpi(overlayTypes{i},'contours')
            vol = volumes{i};
            switch lower(sliceType)
                case 'axial'
                    img = squeeze(vol(:,:,sliceIdx))';
                case 'coronal'
                    img = squeeze(vol(:,sliceIdx,:))';
                case 'sagittal'
                    img = squeeze(vol(sliceIdx,:,:))';
            end
            
            % Get contours
            bw = edge(mat2gray(img),'Canny');
            cmap = feval(colormaps{i},256);
            color = cmap(end,:); % pick last color from colormap
            overlayMask = cat(3, bw*color(1), bw*color(2), bw*color(3));
            
            % Blend with base RGB
            rgbImg(bw,:) = overlayMask(bw,:);
        end
    end
    
    % Store into montage stack
    allSlices(:,:,:,s) = rgbImg;
end

%% --- Display montage ---
figure('Name','Multi-Slice Overlay','Color','w');
montage(allSlices,'Size',[NaN ceil(sqrt(nSlices))]);
title(sprintf('%s slices: %s',sliceType, mat2str(slices)));

end
