function whifun_view2(varargin)
%WHIFUN_VIEW Interactive multi-planar visualizer with overlay support.
%
%   WHIFUN_VIEW(vol1) 
%   WHIFUN_VIEW(vol1, M1)
%   WHIFUN_VIEW(vol1, M1, vol2)
%   WHIFUN_VIEW(vol1, M1, vol2, M2)
%
%   If 'vol2' is provided, it must be a 3D volume that matches the first 
%   3 dimensions of 'vol1'. If both affine matrices (M1, M2) are provided 
%   or read from NIfTI files, they must be strictly equal.
%
%   The UI provides independent colormap selections. The Alpha Threshold 
%   checkbox and Fade slider enable bidirectional opacity fading for values 
%   falling outside the specified low and high thresholds.
%
%   Author: Pratik Jain (Modified for Bidirectional Alpha & Fade Slider)

if nargin == 0
    error('At least one input volume is required.');
end

vol1 = []; vol2 = []; M1 = []; M2 = [];
hasOverlay = false;

% Parse inputs dynamically
for i = 1:nargin
    val = varargin{i};
    if ischar(val) || isstring(val) || ndims(val) >= 3
        if isempty(vol1)
            vol1 = val;
        else
            vol2 = val;
            hasOverlay = true;
        end
    elseif ismatrix(val) && isequal(size(val), [4 4])
        if ~hasOverlay
            M1 = val;
        else
            M2 = val;
        end
    end
end

% Extract NIfTI info for vol1 if path
if ischar(vol1) || isstring(vol1)
    v1_info = niftiinfo(vol1);
    vol1 = niftiread(vol1);
    M1 = v1_info.Transform.T;
end

% Extract NIfTI info for vol2 if path
if hasOverlay && (ischar(vol2) || isstring(vol2))
    v2_info = niftiinfo(vol2);
    vol2 = niftiread(vol2);
    M2 = v2_info.Transform.T;
end

nd1 = ndims(vol1);
if nd1 ~= 3 && nd1 ~= 4
    error('Underlay must be 3D or 4D.');
end

% Verification Checks for Overlay
if hasOverlay
    if ndims(vol2) ~= 3
        error('Overlay volume must be exactly 3D.');
    end
    sz1 = size(vol1); sz2 = size(vol2);
    if any(sz1(1:3) ~= sz2(1:3))
        error('The first 3 dimensions of the underlay and overlay must match perfectly.');
    end
    if ~isempty(M1) && ~isempty(M2) && ~isequal(M1, M2)
        error('Transformation matrices for the underlay and overlay do not match.');
    end
end

% Establish base variables
[X, Y, Z, T] = size(vol1);
if nd1 == 3, T = 1; end
pos = round([X, Y, Z] / 2);  
volIdx = 1; 
hasMNI = ~isempty(M1);
alphaVal = 1.0; % Base opacity for thresholded region
fadeVal = 0.5;  % Max opacity for faded out-of-bounds region
useAlphaThresh = 0; % Default alpha threshold state

% Create Figure & Separated Panels
f = figure('Name','WhiFuN View','Color','w','Units','normalized','Position',[0.1 0.1 0.85 0.75]);
plotPanel = uipanel(f, 'Position', [0 0.15 1 0.85], 'BorderType', 'none', 'BackgroundColor', 'w');
ctrlPanel = uipanel(f, 'Position', [0 0 1 0.15], 'BorderType', 'none', 'BackgroundColor', 'w');

t = tiledlayout(plotPanel,2,2,'TileSpacing','compact');

% Color limits
clims1 = double([min(vol1(:)), max(vol1(:))]);
if clims1(1) == clims1(2), clims1 = [clims1(1)-0.5, clims1(2)+0.5]; end

if hasOverlay
    clims2 = double([min(vol2(:)), max(vol2(:))]);
    if clims2(1) == clims2(2), clims2 = [clims2(1)-0.5, clims2(2)+0.5]; end
    lowThresh = clims2(1); highThresh = clims2(2);
    minVal = clims2(1); maxVal = clims2(2);
else
    clims2 = [0 1];
    lowThresh = clims1(1); highThresh = clims1(2);
    minVal = clims1(1); maxVal = clims1(2);
end

% Initialize Colormaps
cmapList = {'gray', 'jet', 'hot', 'bone', 'cool', 'parula'};
cmap1_idx = 1; % gray default for underlay
cmap2_idx = 3; % hot default for overlay
cmap1_data = colormap(f, cmapList{cmap1_idx});
cmap2_data = eval(sprintf('%s(256)', cmapList{cmap2_idx}));

%% --- Create Axes and Image Objects ---
% XZ
axXZ1 = nexttile(t,1);
imXZ1 = imagesc(axXZ1, zeros(Z, X)); 
hold(axXZ1,'on'); 
if hasOverlay, imXZ2 = imagesc(axXZ1, zeros(Z, X, 3)); else, imXZ2 = []; end
axis(axXZ1,'image'); set(axXZ1,'YDir','normal','XDir','reverse');
title(axXZ1,'XZ (Coronal)'); xlabel(axXZ1,'Inferior'); ylabel(axXZ1,'Left');
hxXZ1 = xline(axXZ1,pos(1),'r'); hyXZ1 = yline(axXZ1,pos(3),'r'); 

% YZ
axYZ = nexttile(t,2);
imYZ1 = imagesc(axYZ, zeros(Z, Y)); 
hold(axYZ,'on'); 
if hasOverlay, imYZ2 = imagesc(axYZ, zeros(Z, Y, 3)); else, imYZ2 = []; end
axis(axYZ,'image'); set(axYZ,'YDir','normal','XDir','reverse');
title(axYZ,'YZ (Sagittal)'); xlabel(axYZ,'Inferior'); ylabel(axYZ,'Anterior');
hxYZ = xline(axYZ,pos(2),'r'); hyYZ = yline(axYZ,pos(3),'r');

% XY
axXY1 = nexttile(t,3);
imXY1 = imagesc(axXY1, zeros(Y, X)); 
hold(axXY1,'on'); 
if hasOverlay, imXY2 = imagesc(axXY1, zeros(Y, X, 3)); else, imXY2 = []; end
axis(axXY1,'image'); set(axXY1,'YDir','normal','XDir','reverse');
title(axXY1,'XY (Axial)'); xlabel(axXY1,'Posterior'); ylabel(axXY1,'Left');
hxXY1 = xline(axXY1,pos(1),'r'); hyXY1 = yline(axXY1,pos(2),'r'); 

colormap(axXZ1, cmap1_data); colormap(axYZ, cmap1_data); colormap(axXY1, cmap1_data);
clim(axXZ1, clims1); clim(axYZ, clims1); clim(axXY1, clims1);

%% --- Time series / Value Plot ---
axTS = nexttile(t,4);
plt = []; marker = [];
if nd1 == 4
    ts = squeeze(vol1(pos(1),pos(2),pos(3),:));
    plt = plot(axTS,ts,'LineWidth',1.5,'Color','k'); hold(axTS,'on');
    marker = plot(axTS,volIdx,ts(volIdx),'ro','MarkerFaceColor','r');
    xlabel(axTS,'Time'); ylabel(axTS,'BOLD signal');
else
    axis(axTS,'off');
end

%% --- Store handles ---
handles = struct('vol1',vol1,'vol2',vol2,'pos',pos,'M1',M1,'hasMNI',hasMNI,'hasOverlay',hasOverlay, ...
    'imXZ1',imXZ1,'imYZ1',imYZ1,'imXY1',imXY1, 'imXZ2',imXZ2,'imYZ2',imYZ2,'imXY2',imXY2, ...
    'hxXZ1',hxXZ1,'hyXZ1',hyXZ1,'hxYZ',hxYZ,'hyYZ',hyYZ,'hxXY1',hxXY1,'hyXY1',hyXY1, ...
    'plt',plt,'marker',marker,'axTS',axTS,'fig',f,'nd',nd1,'volIdx',volIdx,'T',T, ...
    'minVal',minVal,'maxVal',maxVal,'lowThresh',lowThresh,'highThresh',highThresh, ...
    'clims1',clims1, 'clims2',clims2, 'cmap2_data',cmap2_data, 'alphaVal',alphaVal, ...
    'fadeVal',fadeVal, 'useAlphaThresh',useAlphaThresh);

%% --- Callbacks Initialization ---
set([axXZ1,imXZ1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 3));
set([axYZ,imYZ1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 2, 3));
set([axXY1,imXY1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 2));
if hasOverlay
    set(imXZ2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 3));
    set(imYZ2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 2, 3));
    set(imXY2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 2));
end

%% --- UI Elements (Positioned cleanly within ctrlPanel) ---
r1 = 0.55; % Row 1 Y position inside panel
r2 = 0.10; % Row 2 Y position inside panel
ht = 0.35; % Standard height for controls
visOverlay = 'off'; if hasOverlay, visOverlay = 'on'; end
enblFade = 'off'; if useAlphaThresh, enblFade = 'on'; end

% --- Block 1: Voxels & Time ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Vox X:','Units','normalized','Position',[0.01 r1 0.04 ht]);
handles.xBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(1)),'Units','normalized','Position',[0.05 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'x','vox'));
uicontrol('Parent',ctrlPanel,'Style','text','String','Vox Y:','Units','normalized','Position',[0.09 r1 0.04 ht]);
handles.yBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(2)),'Units','normalized','Position',[0.13 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'y','vox'));
uicontrol('Parent',ctrlPanel,'Style','text','String','Vox Z:','Units','normalized','Position',[0.17 r1 0.04 ht]);
handles.zBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(3)),'Units','normalized','Position',[0.21 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'z','vox'));

if nd1 == 4
    uicontrol('Parent',ctrlPanel,'Style','text','String','Vol #:','Units','normalized','Position',[0.01 r2 0.04 ht]);
    handles.volBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(volIdx),'Units','normalized','Position',[0.05 r2 0.03 ht],'Callback',@(src,evt) changeVolume(src));
    handles.volSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',1,'Max',T,'Value',volIdx,'SliderStep',[1/(T-1), 5/(T-1)],'Units','normalized','Position',[0.09 r2 0.15 ht],'Callback',@(src,evt) sliderVolume(src));
else
    handles.volBox = []; handles.volSlider = [];
end

% --- Block 2: MNI Coordinates ---
if hasMNI
    mniPos = whifun_convert_coords(M1,pos,'vox2mni');
    uicontrol('Parent',ctrlPanel,'Style','text','String','MNI X:','Units','normalized','Position',[0.26 r1 0.04 ht]);
    handles.xBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(mniPos(1)),'Units','normalized','Position',[0.30 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'x','mni'));
    uicontrol('Parent',ctrlPanel,'Style','text','String','MNI Y:','Units','normalized','Position',[0.35 r1 0.04 ht]);
    handles.yBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(mniPos(2)),'Units','normalized','Position',[0.39 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'y','mni'));
    uicontrol('Parent',ctrlPanel,'Style','text','String','MNI Z:','Units','normalized','Position',[0.44 r1 0.04 ht]);
    handles.zBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(mniPos(3)),'Units','normalized','Position',[0.48 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'z','mni'));
else
    handles.xBoxMNI=[]; handles.yBoxMNI=[]; handles.zBoxMNI=[];
end

% --- Block 3: Thresholds, Reset, & Alpha Threshold Checkbox ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Low Thresh:','Units','normalized','Position',[0.54 r1 0.06 ht]);
handles.lowBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(lowThresh),'Units','normalized','Position',[0.60 r1 0.05 ht],'Callback',@(src,evt) threshCallback(src,'low'));
uicontrol('Parent',ctrlPanel,'Style','text','String','High Thresh:','Units','normalized','Position',[0.66 r1 0.06 ht]);
handles.highBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(highThresh),'Units','normalized','Position',[0.72 r1 0.05 ht],'Callback',@(src,evt) threshCallback(src,'high'));

uicontrol('Parent',ctrlPanel,'Style','pushbutton','String','Reset Thresh','Units','normalized','Position',[0.52 r2 0.09 ht],'Callback',@(src,evt) resetCallback());
handles.alphaCheck = uicontrol('Parent',ctrlPanel,'Style','checkbox','String','Alpha Threshold','Units','normalized','Position',[0.62 r2 0.09 ht],'Value',useAlphaThresh,'Callback',@(src,evt) alphaCheckCallback(src), 'Visible', visOverlay);

% --- Block 4: Colormaps, Faded Opacity, & Main Opacity ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Underlay Map:','Units','normalized','Position',[0.79 r1 0.07 ht]);
uicontrol('Parent',ctrlPanel,'Style','popupmenu','String',cmapList,'Value',cmap1_idx,'Units','normalized','Position',[0.86 r1 0.05 ht],'Callback',@(src,evt) cmapCallback(src, 1));

uicontrol('Parent',ctrlPanel,'Style','text','String','Overlay Map:','Units','normalized','Position',[0.92 r1 0.06 ht], 'Visible', visOverlay);
uicontrol('Parent',ctrlPanel,'Style','popupmenu','String',cmapList,'Value',cmap2_idx,'Units','normalized','Position',[0.98 r1 0.05 ht],'Callback',@(src,evt) cmapCallback(src, 2), 'Visible', visOverlay);

uicontrol('Parent',ctrlPanel,'Style','text','String','Fade Opac:','Units','normalized','Position',[0.71 r2 0.06 ht], 'Visible', visOverlay);
handles.fadeSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',0,'Max',1,'Value',fadeVal,'Units','normalized','Position',[0.77 r2 0.06 ht],'Callback',@(src,evt) fadeCallback(src), 'Visible', visOverlay, 'Enable', enblFade);

uicontrol('Parent',ctrlPanel,'Style','text','String','Base Opac:','Units','normalized','Position',[0.84 r2 0.06 ht], 'Visible', visOverlay);
handles.alphaSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',0,'Max',1,'Value',alphaVal,'Units','normalized','Position',[0.90 r2 0.09 ht],'Callback',@(src,evt) alphaCallback(src), 'Visible', visOverlay);

% Apply initial rendering
updateViews(handles); 
guidata(f,handles);

%% --- Nested Helper Functions ---
    function rgb = apply_colormap(slice, clims, cmap)
        norm_slice = (slice - clims(1)) / (clims(2) - clims(1));
        norm_slice(norm_slice < 0) = 0; norm_slice(norm_slice > 1) = 1;
        idx = round(norm_slice * (size(cmap, 1) - 1)) + 1;
        idx(isnan(idx)) = 1; 
        R = cmap(idx, 1); G = cmap(idx, 2); B = cmap(idx, 3);
        rgb = cat(3, reshape(R, size(slice)), reshape(G, size(slice)), reshape(B, size(slice)));
    end

    function aMask = calculate_alpha(v, h)
        if h.useAlphaThresh
            % Core fully kept at primary opacity
            core = double(v >= h.lowThresh & v <= h.highThresh) * h.alphaVal;
            
            % Fade Below Low Threshold (down to minVal)
            rangeLow = h.lowThresh - h.minVal;
            if rangeLow > 0
                lowFade = double(v >= h.minVal & v < h.lowThresh) .* ((v - h.minVal) ./ rangeLow) * h.fadeVal;
            else
                lowFade = 0;
            end
            
            % Fade Above High Threshold (up to maxVal)
            rangeHigh = h.maxVal - h.highThresh;
            if rangeHigh > 0
                highFade = double(v > h.highThresh & v <= h.maxVal) .* ((h.maxVal - v) ./ rangeHigh) * h.fadeVal;
            else
                highFade = 0;
            end
            
            aMask = core + lowFade + highFade;
        else
            % Strict thresholding
            aMask = double(v >= h.lowThresh & v <= h.highThresh) * h.alphaVal;
        end
    end

%% --- Callbacks ---
    function clickCallback(evt, dim1, dim2)
        h = guidata(f); pt = round(evt.IntersectionPoint(1:2));
        h.pos(dim1) = pt(1); h.pos(dim2) = pt(2); 
        updateViews(h); guidata(f,h);
    end

    function editBoxCallback(src,dim,type)
        h = guidata(f);
        if strcmp(type,'vox')
            val = round(str2double(src.String));
            switch dim
                case 'x', h.pos(1)=val; case 'y', h.pos(2)=val; case 'z', h.pos(3)=val;
            end
        elseif strcmp(type,'mni') && h.hasMNI
            mniCoord = [str2double(h.xBoxMNI.String), str2double(h.yBoxMNI.String), str2double(h.zBoxMNI.String)];
            h.pos = round(whifun_convert_coords(h.M1, mniCoord, 'mni2vox'));
        end
        updateViews(h); guidata(f,h);
    end

    function changeVolume(src)
        h = guidata(f);
        v = max(1,min(h.T,round(str2double(src.String))));
        h.volIdx = v;
        if ~isempty(h.volSlider), set(h.volSlider,'Value',v); end
        updateViews(h); guidata(f,h);
    end

    function sliderVolume(src)
        h = guidata(f); h.volIdx = round(get(src,'Value'));
        if ~isempty(h.volBox), set(h.volBox,'String',num2str(h.volIdx)); end
        updateViews(h); guidata(f,h);
    end

    function threshCallback(src,type)
        h = guidata(f); val = str2double(src.String);
        if isnan(val), return; end
        if strcmp(type,'low'), h.lowThresh = val; else, h.highThresh = val; end
        updateViews(h); guidata(f,h);
    end

    function resetCallback()
        h = guidata(f); h.lowThresh = h.minVal; h.highThresh = h.maxVal;
        set(h.lowBox,'String',num2str(h.lowThresh)); set(h.highBox,'String',num2str(h.highThresh));
        updateViews(h); guidata(f,h);
    end

    function cmapCallback(src, target)
        h = guidata(f);
        maps = src.String; sel = maps{src.Value};
        if target == 1
            cmap_data = colormap(f, sel);
            colormap(axXZ1, cmap_data); colormap(axYZ, cmap_data); colormap(axXY1, cmap_data);
        else
            h.cmap2_data = eval(sprintf('%s(256)', sel));
            updateViews(h); guidata(f,h);
        end
    end

    function alphaCallback(src)
        h = guidata(f);
        h.alphaVal = get(src, 'Value');
        updateViews(h);
        guidata(f, h);
    end

    function fadeCallback(src)
        h = guidata(f);
        h.fadeVal = get(src, 'Value');
        updateViews(h);
        guidata(f, h);
    end

    function alphaCheckCallback(src)
        h = guidata(f);
        h.useAlphaThresh = src.Value;
        if h.useAlphaThresh
            set(h.fadeSlider, 'Enable', 'on');
        else
            set(h.fadeSlider, 'Enable', 'off');
        end
        updateViews(h);
        guidata(f, h);
    end

    function updateViews(h)
        x=h.pos(1); y=h.pos(2); z=h.pos(3); v=h.volIdx;
        
        % Slice Underlay
        uXZ = squeeze(h.vol1(:,y,:,v))'; uYZ = squeeze(h.vol1(x,:,:,v))'; uXY = squeeze(h.vol1(:,:,z,v))';
        
        if ~h.hasOverlay
            % Single volume thresholding
            uXZ(uXZ < h.lowThresh | uXZ > h.highThresh) = NaN;
            uYZ(uYZ < h.lowThresh | uYZ > h.highThresh) = NaN;
            uXY(uXY < h.lowThresh | uXY > h.highThresh) = NaN;
        end
        h.imXZ1.CData = uXZ; h.imYZ1.CData = uYZ; h.imXY1.CData = uXY;
        
        if h.hasOverlay
            % Slice Overlay
            oXZ = squeeze(h.vol2(:,y,:))'; oYZ = squeeze(h.vol2(x,:,:))'; oXY = squeeze(h.vol2(:,:,z))';
            
            % Generate Transparency Masks
            aXZ = calculate_alpha(oXZ, h);
            aYZ = calculate_alpha(oYZ, h);
            aXY = calculate_alpha(oXY, h);
            
            % Apply RGB Colormap manually
            h.imXZ2.CData = apply_colormap(oXZ, h.clims2, h.cmap2_data);
            h.imYZ2.CData = apply_colormap(oYZ, h.clims2, h.cmap2_data);
            h.imXY2.CData = apply_colormap(oXY, h.clims2, h.cmap2_data);
            
            % Bind Masks
            h.imXZ2.AlphaData = aXZ; h.imYZ2.AlphaData = aYZ; h.imXY2.AlphaData = aXY;
        end
        
        % Update UI states
        h.hxXZ1.Value=x; h.hyXZ1.Value=z; h.hxYZ.Value=y; h.hyYZ.Value=z; h.hxXY1.Value=x; h.hyXY1.Value=y;
        set(h.xBox,'String',num2str(x)); set(h.yBox,'String',num2str(y)); set(h.zBox,'String',num2str(z));
        
        if h.hasMNI
            mniPos=whifun_convert_coords(h.M1,[x,y,z],'vox2mni');
            set(h.xBoxMNI,'String',num2str(mniPos(1))); set(h.yBoxMNI,'String',num2str(mniPos(2))); set(h.zBoxMNI,'String',num2str(mniPos(3)));
        end
        
        % Text/Graph Panel
        cla(h.axTS);
        if h.nd == 4
            ts=squeeze(h.vol1(x,y,z,:));
            h.plt = plot(h.axTS, ts, 'LineWidth', 1.5, 'Color', 'k'); hold(h.axTS, 'on');
            h.marker = plot(h.axTS, v, ts(v), 'ro', 'MarkerFaceColor', 'r');
            if h.hasMNI, ttl = sprintf('V=[%d,%d,%d] | MNI=[%.1f,%.1f,%.1f]',[x,y,z],mniPos); else, ttl = sprintf('V=[%d,%d,%d]',[x,y,z]); end
            title(h.axTS, ttl); xlabel(h.axTS, 'Time'); ylabel(h.axTS, 'BOLD signal');
        else
            val1 = h.vol1(x,y,z);
            if h.hasOverlay, val2 = h.vol2(x,y,z); str = sprintf('V=[%d,%d,%d]\nVal1=%.2f | Val2=%.2f',x,y,z,val1,val2);
            else, str = sprintf('V=[%d,%d,%d] | Val=%.2f',x,y,z,val1); end
            if h.hasMNI, str = [sprintf('MNI=[%.1f,%.1f,%.1f]\n',mniPos), str]; end
            text(0.5,0.5,str,'Parent',h.axTS,'Units','normalized','HorizontalAlignment','center','FontSize',12);
            axis(h.axTS,'off');
        end
        drawnow;
    end
end