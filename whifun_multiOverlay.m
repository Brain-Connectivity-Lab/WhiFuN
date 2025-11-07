function whifun_multiOverlay(volumes, overlayTypes, colormaps, slices, sliceType)
% whifun_multiOverlay  Display multiple slices with overlays from volumes
%
% Inputs:
%   volumes      - 3D matrix or cell array of volumes (or file paths)
%   overlayTypes - cell array: {'structure','contours'} for each volume
%   colormaps    - cell array of colormaps (e.g., {'gray','jet'})
%   slices       - vector of slice indices (e.g. [20 30 40])
%   sliceType    - 'axial','coronal','sagittal'
%
% Example:
%   vol1 = rand(50,50,50);
%   vol2 = rand(50,50,50) > 0.7;
%   whifun_multiOverlay({vol1,vol2},{'structure','contours'},{'gray','jet'},[10 20 30],'axial');

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
