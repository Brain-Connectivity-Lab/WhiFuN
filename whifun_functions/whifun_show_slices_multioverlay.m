function whifun_show_slices_multioverlay(volumes, overlay_types, cmaps, slices, orientation)
% WHIFUN_SHOW_SLICES_MULTIOVERLAY
% Display multiple slices (one per image) in a montage with overlay support.
%
% Inputs:
%   volumes        - cell array of file paths or 3D matrices
%   overlay_types  - cell array: {'structure','contour',...}
%   cmaps          - cell array of colormaps for each image
%   slices         - array of slice indices (one per image)
%   orientation    - 'axial' | 'sagittal' | 'coronal'
%
% Example:
%   vols = {'sub1.nii','sub2.nii','sub3.nii'};
%   types = {'structure','contour','structure'};
%   cmaps = {hot, lines, gray};
%   slices = [40 45 50];
%   whifun_show_slices_multioverlay(vols, types, cmaps, slices, 'axial');

    % --- Input checks ---
    if ~iscell(volumes), volumes = {volumes}; end
    nVols = numel(volumes);
    if numel(overlay_types) ~= nVols || numel(cmaps) ~= nVols || numel(slices) ~= nVols
        error('All inputs (volumes, overlay_types, cmaps, slices) must have same length.');
    end

    % --- Load all volumes ---
    allData = cell(1,nVols);
    allMin = inf; allMax = -inf;
    for i = 1:nVols
        if ischar(volumes{i}) || isstring(volumes{i})
            vol = niftiread(volumes{i});
        else
            vol = volumes{i};
        end
        allData{i} = double(vol);
        allMin = min(allMin, min(vol(:)));
        allMax = max(allMax, max(vol(:)));
    end

    % --- Prepare figure ---
    figure('Color','w');
    t = tiledlayout(1, nVols, 'TileSpacing','compact', 'Padding','compact');

    for i = 1:nVols
        nexttile;
        vol = allData{i};
        slice_idx = slices(i);
        overlay_type = lower(overlay_types{i});
        cmap = cmaps{i};

        % --- Extract the slice depending on orientation ---
        switch lower(orientation)
            case 'axial'
                img = squeeze(vol(:,:,slice_idx));
                img = flipud(img); % flip vertically to match neuro orientation
            case 'sagittal'
                img = squeeze(vol(slice_idx,:,:))';
                img = flipud(img);
            case 'coronal'
                img = squeeze(vol(:,slice_idx,:))';
                img = flipud(img);
            otherwise
                error('Orientation must be "axial", "sagittal", or "coronal"');
        end

        % --- Display based on type ---
        hold on;
        switch overlay_type
            case 'structure'
                imagesc(img,[allMin allMax]);
                axis image off;
                colormap(gca, cmap);
            case 'contour'
                base = mat2gray(img, [allMin allMax]);
                imshow(base, 'InitialMagnification', 'fit');
                hold on;
                contour(base, 3, 'LineColor', cmap(ceil(size(cmap,1)/2),:), 'LineWidth',1.5);
            otherwise
                error('Overlay type must be "structure" or "contour"');
        end
        title(sprintf('%s Slice %d', capitalize(orientation), slice_idx), 'FontSize',10);
        hold off;
    end
    colorbar;
    title(t, sprintf('%s view montage', capitalize(orientation)), 'FontSize',12, 'FontWeight','bold');
end

function s = capitalize(str)
    s = lower(str);
    s(1) = upper(s(1));
end
