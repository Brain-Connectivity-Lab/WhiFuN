% function h = whifun_orthosliceViewer(image_,Slices,f)
% 
% if ~exist("f","var")
%     f = figure;
% 
% end
% 
% if isstruct(image_)
%     if length(image_) == 1
%         image_ = niftiread(fullfile(image_.folder,image_.name));
%     else
%         msgbox('More than one files found in the structure provided','More than one file')
%     end
% elseif isstring(image_) || ischar(image_)
%     image_ = niftiread(image_);
% end
% if nnz(~isfinite(image_))
%     warning('Elements with infinte value found. Setting them to zero.')
%     image_(~isfinite(image_)) = 0;
% end
% if length(size(image_)) == 4
%     image_3d = image_(:,:,:,1);
%     t = tiledlayout(1,2,"Parent",f);
%     nexttile(1)
%     ax = gca;
%     p = uipanel('BorderType', 'none', 'Position', [0 0 1 1]); % Create a borderless panel inside the axes
% 
% end
% 
% h = orthosliceViewer(permute(image_3d,[3,1,2]),"Parent",p);
% 
% if exist("Slices",'var')
%     h.SliceNumbers = [Slices(1),Slices(3),Slices(2)];
% end
% [hXY,hYZ,hXZ] = getAxesHandles(h);
% 
% hXY.View = [180,90];
% hYZ.View = [180,90];
% hXZ.View = [180,90];
% 
% % 4. Add custom labels to each axes view
% % Label the XY-plane view
% xlabel(hXY, 'Superior');
% ylabel(hXY, 'left');
% 
% % Label the YZ-plane view
% ylabel(hYZ, 'Anterior');
% xlabel(hYZ, 'Superior');
% 
% % Label the XZ-plane view
% xlabel(hXZ, 'Anterior');
% ylabel(hXZ, 'Left');
% 
% if length(size(image_)) == 4
%     nexttile(2)
%     plot(squeeze(image_(h.SliceNumbers(1),h.SliceNumbers(3),h.SliceNumbers(2),:)))
% end

% function h = whifun_orthosliceViewer(image_,Slices,f)
% 
% if ~exist("f","var")
%     f = figure;
% end
% 
% % --- Load image ---
% if isstruct(image_)
%     if length(image_) == 1
%         image_ = niftiread(fullfile(image_.folder,image_.name));
%     else
%         msgbox('More than one files found in the structure provided','More than one file')
%     end
% elseif isstring(image_) || ischar(image_)
%     image_ = niftiread(image_);
% end
% 
% if nnz(~isfinite(image_))
%     warning('Elements with infinite value found. Setting them to zero.')
%     image_(~isfinite(image_)) = 0;
% end
% 
% if ndims(image_) == 4
%     image_3d = image_(:,:,:,1);
% else
%     image_3d = image_;
% end
% 
% % --- Create tiled layout ---
% t = tiledlayout(f,1,2);
% 
% % --- Left tile: replace axes with a uipanel ---
% ax1 = nexttile(t,1);     % This creates an axes
% pos = ax1.Position;      % Record its position in normalized units
% delete(ax1);             % Delete the axes
% 
% % Create a uipanel in the same tile slot
% p1 = uipanel('Parent',f,'Units','normalized','Position',pos);
% 
% % Embed orthosliceViewer inside the panel
% h = orthosliceViewer(permute(image_3d,[3,1,2]),'Parent',p1);
% 
% if exist("Slices",'var')
%     h.SliceNumbers = [Slices(1),Slices(3),Slices(2)];
% end
% 
% % Access handles
% [hXY,hYZ,hXZ] = getAxesHandles(h);
% 
% hXY.View = [180,90];
% hYZ.View = [180,90];
% hXZ.View = [180,90];
% 
% xlabel(hXY, 'Superior'); ylabel(hXY, 'Left');
% ylabel(hYZ, 'Anterior'); xlabel(hYZ, 'Superior');
% xlabel(hXZ, 'Anterior'); ylabel(hXZ, 'Left');

% % --- Right tile: time series ---
% if ndims(image_) == 4
%     ax2 = nexttile(t,2);
%     plot(ax2, squeeze(image_(h.SliceNumbers(1),h.SliceNumbers(3),h.SliceNumbers(2),:)))
% end
% 
% end

function h = whifun_orthosliceViewer(image_,Slices,f)

if ~exist("f","var")
    f = figure;
end

% --- Load image ---
if isstruct(image_)
    if length(image_) == 1
        image_ = niftiread(fullfile(image_.folder,image_.name));
    else
        msgbox('More than one files found in the structure provided','More than one file')
    end
elseif isstring(image_) || ischar(image_)
    image_ = niftiread(image_);
end

if nnz(~isfinite(image_))
    warning('Elements with infinite value found. Setting them to zero.')
    image_(~isfinite(image_)) = 0;
end

if ndims(image_) == 4
    image_3d = image_(:,:,:,1);
else
    image_3d = image_;
end

% --- Create tiled layout ---
t = tiledlayout(f,1,2);

% --- Left tile: orthosliceViewer inside a panel ---
ax1 = nexttile(t,1);
pos = ax1.Position;
delete(ax1);

p1 = uipanel('Parent',f,'Units','normalized','Position',pos);

h = orthosliceViewer(permute(image_3d,[3,1,2]),'Parent',p1);

if exist("Slices",'var')
    h.SliceNumbers = [Slices(1),Slices(3),Slices(2)];
end

% --- Right tile: time series ---
ax2 = nexttile(t,2);
if ndims(image_) == 4
    ts = squeeze(image_(h.SliceNumbers(1),h.SliceNumbers(3),h.SliceNumbers(2),:));
else
    ts = [];
end
plt = plot(ax2, ts);
xlabel(ax2,'Time');
ylabel(ax2,'BOLD signal');

% --- Attach callbacks to sliders inside orthosliceViewer ---
if ndims(image_) == 4
    % Find all sliders inside the orthosliceViewer panel
    sliders = findobj(p1,'Style','slider');
    for k = 1:numel(sliders)
        sliders(k).Callback = @(src,evt) updatePlot(h,image_,plt,ax2);
    end
end

end


function updatePlot(h,image_,plt,ax2)
    slices = h.SliceNumbers; % [X Y Z]
    ts = squeeze(image_(slices(1),slices(3),slices(2),:));
    if isempty(ts), return; end
    set(plt,'YData',ts,'XData',1:numel(ts));
    title(ax2,sprintf('Voxel: [%d %d %d]',slices));
    drawnow;
end
