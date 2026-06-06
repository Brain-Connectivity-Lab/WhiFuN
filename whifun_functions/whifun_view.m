function whifun_view(varargin)
%WHIFUN_VIEW Interactive multi-planar visualizer with overlay support.
%
%   WHIFUN_VIEW(vol1) 
%   WHIFUN_VIEW(vol1, M1)
%   WHIFUN_VIEW(vol1, M1, vol2)
%   WHIFUN_VIEW(vol1, M1, vol2, M2)
%
%   Features include: Independent colormap selections, Alpha Thresholding,
%   Seed Timeseries plotting (4D), Z-scoring (4D), Correlation (4D), 
%   dynamic Voxel Value readouts, and a togglable master Colorbar.
%
%   Author: Pratik Jain (Modified for Correlation, UI Expansion, & 3D Bug Fix)

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

% Extract NIfTI info
if ischar(vol1) || isstring(vol1)
    v1_info = niftiinfo(vol1); vol1 = niftiread(vol1); M1 = v1_info.Transform.T;
end
if hasOverlay && (ischar(vol2) || isstring(vol2))
    v2_info = niftiinfo(vol2); vol2 = niftiread(vol2); M2 = v2_info.Transform.T;
end

nd1 = ndims(vol1);
if nd1 ~= 3 && nd1 ~= 4
    error('Underlay must be 3D or 4D.');
end

% Verification Checks
if hasOverlay
    if ndims(vol2) ~= 3, error('Overlay volume must be exactly 3D.'); end
    sz1 = size(vol1); sz2 = size(vol2);
    if any(sz1(1:3) ~= sz2(1:3)), error('The first 3 dimensions must match perfectly.'); end
    if ~isempty(M1) && ~isempty(M2) && ~isequal(M1, M2), error('Transformation matrices do not match.'); end
end

% Establish base variables
[X, Y, Z, T] = size(vol1);
if nd1 == 3, T = 1; end
pos = round([X, Y, Z] / 2);  
volIdx = 1; 
hasMNI = ~isempty(M1);
alphaVal = 1.0; fadeVal = 0.5; useAlphaThresh = 0; cbState = 1; 

% Seed and Analysis tracking (4D only)
hasSeed = false; seedPos = []; seedTS = []; 
isZscored = false; hideSeed = false; showCorr = false;

% Create Figure & Separated Panels (Adjusted for 3-row UI)
f = figure('Name','WhiFuN View','Color','w','Units','normalized','Position',[0.1 0.1 0.85 0.75]);
plotPanel = uipanel(f, 'Position', [0 0.18 1 0.82], 'BorderType', 'none', 'BackgroundColor', 'w');
ctrlPanel = uipanel(f, 'Position', [0 0 1 0.18], 'BorderType', 'none', 'BackgroundColor', 'w');

t = tiledlayout(plotPanel,2,2,'TileSpacing','compact');

% Color limits
clims1 = double([min(vol1(:)), max(vol1(:))]);
if clims1(1) == clims1(2), clims1 = [clims1(1)-0.5, clims1(2)+0.5]; end

if hasOverlay
    clims2 = double([min(vol2(:)), max(vol2(:))]);
    if clims2(1) == clims2(2), clims2 = [clims2(1)-0.5, clims2(2)+0.5]; end
    lowThresh = clims2(1); highThresh = clims2(2); minVal = clims2(1); maxVal = clims2(2);
else
    clims2 = [0 1]; lowThresh = clims1(1); highThresh = clims1(2); minVal = clims1(1); maxVal = clims1(2);
end

% Initialize Colormaps
cmapList = {'gray', 'jet', 'hot', 'bone', 'cool', 'parula'};
cmap1_idx = 1; cmap2_idx = 3; 
cmap1_data = eval(sprintf('%s(256)', cmapList{cmap1_idx}));
cmap2_data = eval(sprintf('%s(256)', cmapList{cmap2_idx}));

%% --- Create Axes and Image Objects ---
% XZ
axXZ1 = nexttile(t,1);
imXZ1 = imagesc(axXZ1, zeros(Z, X, 3)); hold(axXZ1,'on'); 
if hasOverlay, imXZ2 = imagesc(axXZ1, zeros(Z, X, 3)); else, imXZ2 = []; end
axis(axXZ1,'image'); set(axXZ1,'YDir','normal','XDir','reverse');
title(axXZ1,'XZ (Coronal)'); xlabel(axXZ1,'Inferior'); ylabel(axXZ1,'Left');
hxXZ1 = xline(axXZ1,pos(1),'r'); hyXZ1 = yline(axXZ1,pos(3),'r'); 

% YZ
axYZ = nexttile(t,2);
imYZ1 = imagesc(axYZ, zeros(Z, Y, 3)); hold(axYZ,'on'); 
if hasOverlay, imYZ2 = imagesc(axYZ, zeros(Z, Y, 3)); else, imYZ2 = []; end
axis(axYZ,'image'); set(axYZ,'YDir','normal','XDir','reverse');
title(axYZ,'YZ (Sagittal)'); xlabel(axYZ,'Inferior'); ylabel(axYZ,'Anterior');
hxYZ = xline(axYZ,pos(2),'r'); hyYZ = yline(axYZ,pos(3),'r');

% XY
axXY1 = nexttile(t,3);
imXY1 = imagesc(axXY1, zeros(Y, X, 3)); hold(axXY1,'on'); 
if hasOverlay, imXY2 = imagesc(axXY1, zeros(Y, X, 3)); else, imXY2 = []; end
axis(axXY1,'image'); set(axXY1,'YDir','normal','XDir','reverse');
title(axXY1,'XY (Axial)'); xlabel(axXY1,'Posterior'); ylabel(axXY1,'Left');
hxXY1 = xline(axXY1,pos(1),'r'); hyXY1 = yline(axXY1,pos(2),'r'); 

%% --- Master Colorbar Integration ---
cb = colorbar(axXZ1); cb.Layout.Tile = 'east'; 

%% --- Time series Plot ---
axTS = nexttile(t,4); if nd1 ~= 4, axis(axTS,'off'); end

%% --- UI Elements (Spacious 3-Row Layout) ---
r1 = 0.70; r2 = 0.40; r3 = 0.10; ht = 0.25; 
visOverlay = 'off'; if hasOverlay, visOverlay = 'on'; end
enblFade = 'off'; if useAlphaThresh, enblFade = 'on'; end
vis4D = 'off'; if nd1 == 4, vis4D = 'on'; end

% --- Determine Safe Slider Steps to Prevent Division by Zero ---
if T > 1
    sMax = T;
    sStep = [1/(T-1), min(1, 5/(T-1))]; % min() prevents >1 steps on short 4D files
else
    sMax = 2; % uicontrol Max must strictly be > Min
    sStep = [0.01, 0.1]; % Dummy valid step for hidden slider
end

% --- Row 1: Coordinates, Values, Maps, & Colorbar Toggle ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Vox X:','Units','normalized','Position',[0.01 r1 0.03 ht]);
handles.xBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(1)),'Units','normalized','Position',[0.04 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'x','vox'));
uicontrol('Parent',ctrlPanel,'Style','text','String','Y:','Units','normalized','Position',[0.08 r1 0.02 ht]);
handles.yBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(2)),'Units','normalized','Position',[0.10 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'y','vox'));
uicontrol('Parent',ctrlPanel,'Style','text','String','Z:','Units','normalized','Position',[0.14 r1 0.02 ht]);
handles.zBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(pos(3)),'Units','normalized','Position',[0.16 r1 0.03 ht],'Callback',@(src,evt) editBoxCallback(src,'z','vox'));

if hasMNI
    uicontrol('Parent',ctrlPanel,'Style','text','String','MNI X:','Units','normalized','Position',[0.21 r1 0.04 ht]);
    handles.xBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','Units','normalized','Position',[0.25 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'x','mni'));
    uicontrol('Parent',ctrlPanel,'Style','text','String','Y:','Units','normalized','Position',[0.30 r1 0.02 ht]);
    handles.yBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','Units','normalized','Position',[0.32 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'y','mni'));
    uicontrol('Parent',ctrlPanel,'Style','text','String','Z:','Units','normalized','Position',[0.37 r1 0.02 ht]);
    handles.zBoxMNI = uicontrol('Parent',ctrlPanel,'Style','edit','Units','normalized','Position',[0.39 r1 0.04 ht],'Callback',@(src,evt) editBoxCallback(src,'z','mni'));
else
    handles.xBoxMNI=[]; handles.yBoxMNI=[]; handles.zBoxMNI=[];
end

handles.txtVal1 = uicontrol('Parent',ctrlPanel,'Style','text','String','U-Val: -','HorizontalAlignment','left','Units','normalized','Position',[0.45 r1 0.10 ht]);
handles.txtVal2 = uicontrol('Parent',ctrlPanel,'Style','text','String','O-Val: -','HorizontalAlignment','left','Units','normalized','Position',[0.56 r1 0.10 ht], 'Visible', visOverlay);

uicontrol('Parent',ctrlPanel,'Style','text','String','U-Map:','Units','normalized','Position',[0.67 r1 0.04 ht]);
uicontrol('Parent',ctrlPanel,'Style','popupmenu','String',cmapList,'Value',cmap1_idx,'Units','normalized','Position',[0.71 r1 0.06 ht],'Callback',@(src,evt) cmapCallback(src, 1));

uicontrol('Parent',ctrlPanel,'Style','text','String','O-Map:','Units','normalized','Position',[0.79 r1 0.04 ht], 'Visible', visOverlay);
uicontrol('Parent',ctrlPanel,'Style','popupmenu','String',cmapList,'Value',cmap2_idx,'Units','normalized','Position',[0.83 r1 0.06 ht],'Callback',@(src,evt) cmapCallback(src, 2), 'Visible', visOverlay);

handles.btnToggleCB = uicontrol('Parent',ctrlPanel,'Style','pushbutton','String','CB: Underlay','Units','normalized','Position',[0.91 r1 0.08 ht], 'Visible', visOverlay, 'Callback', @(src,evt) toggleCBCallback(src));

% --- Row 2: 4D Controls (Volumes, Seeds, Z-Score, Correlation) ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Vol:','Units','normalized','Position',[0.01 r2 0.03 ht], 'Visible', vis4D);
handles.volBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(volIdx),'Units','normalized','Position',[0.04 r2 0.03 ht],'Callback',@(src,evt) changeVolume(src), 'Visible', vis4D);
handles.volSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',1,'Max',sMax,'Value',volIdx,'SliderStep',sStep,'Units','normalized','Position',[0.08 r2 0.08 ht],'Callback',@(src,evt) sliderVolume(src), 'Visible', vis4D);

uicontrol('Parent',ctrlPanel,'Style','pushbutton','String','Set Seed','Units','normalized','Position',[0.18 r2 0.06 ht],'Callback',@(src,evt) setSeedCallback(), 'Visible', vis4D);
uicontrol('Parent',ctrlPanel,'Style','pushbutton','String','Clear Seed','Units','normalized','Position',[0.25 r2 0.06 ht],'Callback',@(src,evt) clearSeedCallback(), 'Visible', vis4D);

handles.btnHideSeed = uicontrol('Parent',ctrlPanel,'Style','togglebutton','String','Hide Seed','Units','normalized','Position',[0.32 r2 0.06 ht],'Callback',@(src,evt) hideSeedCallback(src), 'Visible', vis4D, 'Enable', 'off');
uicontrol('Parent',ctrlPanel,'Style','togglebutton','String','Z-Score','Units','normalized','Position',[0.39 r2 0.06 ht],'Callback',@(src,evt) zscoreCallback(src), 'Visible', vis4D);
handles.btnCorr = uicontrol('Parent',ctrlPanel,'Style','togglebutton','String','Correlation','Units','normalized','Position',[0.46 r2 0.07 ht],'Callback',@(src,evt) corrCallback(src), 'Visible', vis4D, 'Enable', 'off');

% --- Row 3: Overlay Thresholds & Alpha Controls ---
uicontrol('Parent',ctrlPanel,'Style','text','String','Low:','Units','normalized','Position',[0.01 r3 0.03 ht]);
handles.lowBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(lowThresh),'Units','normalized','Position',[0.04 r3 0.04 ht],'Callback',@(src,evt) threshCallback(src,'low'));
uicontrol('Parent',ctrlPanel,'Style','text','String','High:','Units','normalized','Position',[0.09 r3 0.03 ht]);
handles.highBox = uicontrol('Parent',ctrlPanel,'Style','edit','String',num2str(highThresh),'Units','normalized','Position',[0.12 r3 0.04 ht],'Callback',@(src,evt) threshCallback(src,'high'));

uicontrol('Parent',ctrlPanel,'Style','pushbutton','String','Reset Thresh','Units','normalized','Position',[0.18 r3 0.07 ht],'Callback',@(src,evt) resetCallback());
handles.alphaCheck = uicontrol('Parent',ctrlPanel,'Style','checkbox','String','Alpha Threshold','Units','normalized','Position',[0.27 r3 0.10 ht],'Value',useAlphaThresh,'Callback',@(src,evt) alphaCheckCallback(src), 'Visible', visOverlay);

uicontrol('Parent',ctrlPanel,'Style','text','String','Fade:','Units','normalized','Position',[0.39 r3 0.04 ht], 'Visible', visOverlay);
handles.fadeSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',0,'Max',1,'Value',fadeVal,'Units','normalized','Position',[0.43 r3 0.08 ht],'Callback',@(src,evt) fadeCallback(src), 'Visible', visOverlay, 'Enable', enblFade);

uicontrol('Parent',ctrlPanel,'Style','text','String','Opac:','Units','normalized','Position',[0.53 r3 0.04 ht], 'Visible', visOverlay);
handles.alphaSlider = uicontrol('Parent',ctrlPanel,'Style','slider','Min',0,'Max',1,'Value',alphaVal,'Units','normalized','Position',[0.57 r3 0.08 ht],'Callback',@(src,evt) alphaCallback(src), 'Visible', visOverlay);

%% --- Store Handles & Initialize ---
handles.pos=pos; handles.M1=M1; handles.hasMNI=hasMNI; handles.hasOverlay=hasOverlay;
handles.vol1=vol1; handles.vol2=vol2; handles.imXZ1=imXZ1; handles.imYZ1=imYZ1; handles.imXY1=imXY1;
handles.imXZ2=imXZ2; handles.imYZ2=imYZ2; handles.imXY2=imXY2; handles.hxXZ1=hxXZ1; handles.hyXZ1=hyXZ1; 
handles.hxYZ=hxYZ; handles.hyYZ=hyYZ; handles.hxXY1=hxXY1; handles.hyXY1=hyXY1; handles.axTS=axTS;
handles.axXZ1=axXZ1; handles.cb=cb; handles.cbState=cbState; handles.fig=f; handles.nd=nd1; handles.volIdx=volIdx;
handles.T=T; handles.minVal=minVal; handles.maxVal=maxVal; handles.lowThresh=lowThresh; handles.highThresh=highThresh;
handles.clims1=clims1; handles.clims2=clims2; handles.cmap1_data=cmap1_data; handles.cmap2_data=cmap2_data;
handles.alphaVal=alphaVal; handles.fadeVal=fadeVal; handles.useAlphaThresh=useAlphaThresh;
handles.hasSeed=hasSeed; handles.seedPos=seedPos; handles.seedTS=seedTS; handles.isZscored=isZscored;
handles.hideSeed=hideSeed; handles.showCorr=showCorr;

set([axXZ1,imXZ1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 3));
set([axYZ,imYZ1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 2, 3));
set([axXY1,imXY1],'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 2));
if hasOverlay
    set(imXZ2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 3));
    set(imYZ2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 2, 3));
    set(imXY2,'ButtonDownFcn',@(src,evt) clickCallback(evt, 1, 2));
end

updateCb(handles); updateViews(handles); guidata(f,handles);

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
            core = double(v >= h.lowThresh & v <= h.highThresh) * h.alphaVal;
            rangeLow = h.lowThresh - h.minVal;
            if rangeLow > 0, lowFade = double(v >= h.minVal & v < h.lowThresh) .* ((v - h.minVal) ./ rangeLow) * h.fadeVal; else, lowFade = 0; end
            rangeHigh = h.maxVal - h.highThresh;
            if rangeHigh > 0, highFade = double(v > h.highThresh & v <= h.maxVal) .* ((h.maxVal - v) ./ rangeHigh) * h.fadeVal; else, highFade = 0; end
            aMask = core + lowFade + highFade;
        else
            aMask = double(v >= h.lowThresh & v <= h.highThresh) * h.alphaVal;
        end
    end

%% --- Callbacks ---
    function updateCb(h)
        if h.cbState == 1
            colormap(h.axXZ1, h.cmap1_data); clim(h.axXZ1, h.clims1); ylabel(h.cb, 'Underlay Values');
        else
            colormap(h.axXZ1, h.cmap2_data); clim(h.axXZ1, h.clims2); ylabel(h.cb, 'Overlay Values');
        end
    end

    function toggleCBCallback(src)
        h = guidata(f); if h.cbState == 1, h.cbState = 2; src.String = 'CB: Overlay'; else, h.cbState = 1; src.String = 'CB: Underlay'; end
        updateCb(h); guidata(f,h);
    end

    function setSeedCallback()
        h = guidata(f); h.hasSeed = true; h.seedPos = h.pos;
        h.seedTS = squeeze(h.vol1(h.pos(1), h.pos(2), h.pos(3), :));
        set(h.btnHideSeed, 'Enable', 'on'); set(h.btnCorr, 'Enable', 'on');
        updateViews(h); guidata(f,h);
    end

    function clearSeedCallback()
        h = guidata(f); h.hasSeed = false; h.seedPos = []; h.seedTS = [];
        h.hideSeed = false; h.showCorr = false;
        set(h.btnHideSeed, 'Value', 0, 'Enable', 'off'); 
        set(h.btnCorr, 'Value', 0, 'Enable', 'off');
        updateViews(h); guidata(f,h);
    end

    function hideSeedCallback(src)
        h = guidata(f); h.hideSeed = src.Value; updateViews(h); guidata(f,h);
    end

    function zscoreCallback(src)
        h = guidata(f); h.isZscored = src.Value; updateViews(h); guidata(f,h);
    end

    function corrCallback(src)
        h = guidata(f); h.showCorr = src.Value; updateViews(h); guidata(f,h);
    end

    function clickCallback(evt, dim1, dim2)
        h = guidata(f); pt = round(evt.IntersectionPoint(1:2));
        h.pos(dim1) = pt(1); h.pos(dim2) = pt(2); updateViews(h); guidata(f,h);
    end

    function editBoxCallback(src,dim,type)
        h = guidata(f);
        if strcmp(type,'vox')
            val = round(str2double(src.String));
            switch dim, case 'x', h.pos(1)=val; case 'y', h.pos(2)=val; case 'z', h.pos(3)=val; end
        elseif strcmp(type,'mni') && h.hasMNI
            mniCoord = [str2double(h.xBoxMNI.String), str2double(h.yBoxMNI.String), str2double(h.zBoxMNI.String)];
            h.pos = round(whifun_convert_coords(h.M1, mniCoord, 'mni2vox'));
        end
        updateViews(h); guidata(f,h);
    end

    function changeVolume(src)
        h = guidata(f); v = max(1,min(h.T,round(str2double(src.String))));
        h.volIdx = v; if ~isempty(h.volSlider), set(h.volSlider,'Value',v); end
        updateViews(h); guidata(f,h);
    end

    function sliderVolume(src)
        h = guidata(f); h.volIdx = round(get(src,'Value'));
        if ~isempty(h.volBox), set(h.volBox,'String',num2str(h.volIdx)); end
        updateViews(h); guidata(f,h);
    end

    function threshCallback(src,type)
        h = guidata(f); val = str2double(src.String); if isnan(val), return; end
        if strcmp(type,'low'), h.lowThresh = val; else, h.highThresh = val; end
        updateViews(h); guidata(f,h);
    end

    function resetCallback()
        h = guidata(f); h.lowThresh = h.minVal; h.highThresh = h.maxVal;
        set(h.lowBox,'String',num2str(h.lowThresh)); set(h.highBox,'String',num2str(h.highThresh));
        updateViews(h); guidata(f,h);
    end

    function cmapCallback(src, target)
        h = guidata(f); maps = src.String; sel = maps{src.Value};
        if target == 1, h.cmap1_data = eval(sprintf('%s(256)', sel)); else, h.cmap2_data = eval(sprintf('%s(256)', sel)); end
        updateCb(h); updateViews(h); guidata(f,h);
    end

    function alphaCallback(src)
        h = guidata(f); h.alphaVal = get(src, 'Value'); updateViews(h); guidata(f, h);
    end

    function fadeCallback(src)
        h = guidata(f); h.fadeVal = get(src, 'Value'); updateViews(h); guidata(f, h);
    end

    function alphaCheckCallback(src)
        h = guidata(f); h.useAlphaThresh = src.Value;
        if h.useAlphaThresh, set(h.fadeSlider, 'Enable', 'on'); else, set(h.fadeSlider, 'Enable', 'off'); end
        updateViews(h); guidata(f, h);
    end

    function updateViews(h)
        x=h.pos(1); y=h.pos(2); z=h.pos(3); v=h.volIdx;
        
        % Data Extract
        uXZ = squeeze(h.vol1(:,y,:,v))'; uYZ = squeeze(h.vol1(x,:,:,v))'; uXY = squeeze(h.vol1(:,:,z,v))';
        maskXZ = true(size(uXZ)); maskYZ = true(size(uYZ)); maskXY = true(size(uXY));
        if ~h.hasOverlay
            maskXZ = (uXZ >= h.lowThresh & uXZ <= h.highThresh);
            maskYZ = (uYZ >= h.lowThresh & uYZ <= h.highThresh);
            maskXY = (uXY >= h.lowThresh & uXY <= h.highThresh);
        end
        uXZ(isnan(uXZ)) = h.clims1(1); uYZ(isnan(uYZ)) = h.clims1(1); uXY(isnan(uXY)) = h.clims1(1);
        
        % Draw Underlay
        h.imXZ1.CData = apply_colormap(uXZ, h.clims1, h.cmap1_data); h.imXZ1.AlphaData = double(maskXZ);
        h.imYZ1.CData = apply_colormap(uYZ, h.clims1, h.cmap1_data); h.imYZ1.AlphaData = double(maskYZ);
        h.imXY1.CData = apply_colormap(uXY, h.clims1, h.cmap1_data); h.imXY1.AlphaData = double(maskXY);
        
        if h.hasOverlay
            oXZ = squeeze(h.vol2(:,y,:))'; oYZ = squeeze(h.vol2(x,:,:))'; oXY = squeeze(h.vol2(:,:,z))';
            h.imXZ2.CData = apply_colormap(oXZ, h.clims2, h.cmap2_data); h.imXZ2.AlphaData = calculate_alpha(oXZ, h);
            h.imYZ2.CData = apply_colormap(oYZ, h.clims2, h.cmap2_data); h.imYZ2.AlphaData = calculate_alpha(oYZ, h);
            h.imXY2.CData = apply_colormap(oXY, h.clims2, h.cmap2_data); h.imXY2.AlphaData = calculate_alpha(oXY, h);
        end
        
        % Update UI Position Values
        h.hxXZ1.Value=x; h.hyXZ1.Value=z; h.hxYZ.Value=y; h.hyYZ.Value=z; h.hxXY1.Value=x; h.hyXY1.Value=y;
        set(h.xBox,'String',num2str(x)); set(h.yBox,'String',num2str(y)); set(h.zBox,'String',num2str(z));
        if h.hasMNI
            mniPos=whifun_convert_coords(h.M1,[x,y,z],'vox2mni');
            set(h.xBoxMNI,'String',num2str(mniPos(1))); set(h.yBoxMNI,'String',num2str(mniPos(2))); set(h.zBoxMNI,'String',num2str(mniPos(3)));
        end
        
        % Voxel Values
        if h.nd == 4, val1 = h.vol1(x,y,z,v); else, val1 = h.vol1(x,y,z); end
        set(h.txtVal1, 'String', sprintf('U-Val: %.2f', val1));
        if h.hasOverlay, val2 = h.vol2(x,y,z); set(h.txtVal2, 'String', sprintf('O-Val: %.2f', val2)); end
        
        % Text/Graph Panel
        cla(h.axTS);
        if h.nd == 4
            ts = squeeze(h.vol1(x,y,z,:));
            ts_plot = ts; ylbl = 'BOLD signal';
            if h.hasSeed, seed_plot = h.seedTS; end
            
            % Apply Z-score if enabled
            if h.isZscored
                st = std(ts); if st == 0, st = 1; end 
                ts_plot = (ts - mean(ts)) / st;
                if h.hasSeed
                    ss = std(h.seedTS); if ss == 0, ss = 1; end
                    seed_plot = (h.seedTS - mean(h.seedTS)) / ss;
                end
                ylbl = 'BOLD signal (Z)';
            end

            hold(h.axTS, 'on');
            
            % Plot Seed (Red) unless Hidden
            if h.hasSeed && ~h.hideSeed
                plot(h.axTS, seed_plot, 'r', 'LineWidth', 1.5);
                plot(h.axTS, v, seed_plot(v), 'ro', 'MarkerFaceColor', 'r');
            end
            
            % Plot Current (Black)
            plot(h.axTS, ts_plot, 'k', 'LineWidth', 1.5);
            plot(h.axTS, v, ts_plot(v), 'ko', 'MarkerFaceColor', 'k');
            
            % Generate Title
            titleStr = sprintf('Current V=[%d,%d,%d]', x, y, z);
            if h.hasSeed
                titleStr = [titleStr, sprintf(' | Seed=[%d,%d,%d]', h.seedPos)];
                
                % Add Correlation if enabled
                if h.showCorr
                    [R, P] = corrcoef(ts, h.seedTS);
                    if numel(R) > 1
                        titleStr = [titleStr, sprintf(' | r=%.3f (p=%.3f)', R(1,2), P(1,2))];
                    else
                        titleStr = [titleStr, ' | r=NaN (p=NaN)'];
                    end
                end
            end
            title(h.axTS, titleStr);
            xlabel(h.axTS, 'Time'); ylabel(h.axTS, ylbl);
        else
            axis(h.axTS,'off');
        end
        drawnow;
    end
end