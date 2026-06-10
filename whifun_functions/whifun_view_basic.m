function whifun_view_basic(vol, M)
%WHIFUN_VIEW Ortho viewer for 3D or 4D NIfTI volumes with interactive crosshairs,
%   coordinate display (Voxel and optional MNI), volume navigation, and time
%   series plotting.
%
% Usage:
%   whifun_view(vol4d, M)     % Pass 4D volume data and affine matrix M
%   whifun_view(vol3d)        % Pass 3D volume data
%   whifun_view(nifti_path)   % Pass NIfTI file path (reads data and header M)
%
% Input Arguments:
%   VOL: Input data. Can be:
%        - X x Y x Z x T numeric array (4D fMRI data).
%        - X x Y x Z numeric array (3D anatomical/map data).
%        - Character array or string specifying the path to a NIfTI file.
%   M: (Optional) 4x4 numeric affine transformation matrix (from NIfTI header)
%      for converting Voxel coordinates to MNI/World coordinates.
%
% Dependencies: niftiinfo, niftiread, whifun_convert_coords (assumed external/custom).
%
% Author: Pratik Jain

hasMNI = (nargin >= 2 && ~isempty(M)); % check if affine is given
if ischar(vol) || isstring(vol)
    vol_info = niftiinfo(vol);
    vol = niftiread(vol);
    M = vol_info.Transform.T;
    disp('---------------------Image info------------------------------')
    disp(vol_info)
    disp('-------------------------------------------------------------')
    if exist("M",'var')
        hasMNI = 1;
    end
end

nd = ndims(vol);
if nd ~= 3 && nd ~= 4
    error('Input must be 3D (X x Y x Z) or 4D (X x Y x Z x T)');
end

[X,Y,Z,T] = size(vol);
pos = round([X,Y,Z]/2);  % initial voxel coordinates
volIdx = 1; % initial time volume

f = figure('Name','WhiFuN View','Color','w','Units','normalized','Position',[0.1 0.1 0.85 0.7]);
t = tiledlayout(f,2,2,'TileSpacing','compact');

if min(vol(:))~=max(vol(:))
    clims = double([min(vol(:)), max(vol(:))]); % constant color scaling
else
    warning(['All the voxels have the same value : ' num2str(min(vol(:)))])
    clims = double([min(vol(:))-0.5, max(vol(:))+0.5]);
end
%% --- XZ plane (Coronal) ---
axXZ1 = nexttile(t,1);
imXZ1 = imagesc(axXZ1, squeeze(vol(:,pos(2),:,volIdx))'); 
axis(axXZ1,'image'); set(axXZ1,'YDir','normal','XDir','reverse');
title(axXZ1,'XZ (Coronal)'); xlabel(axXZ1,'Inferior'); ylabel(axXZ1,'Left');
hold(axXZ1,'on'); hxXZ1 = xline(axXZ1,pos(1),'r'); hyXZ1 = yline(axXZ1,pos(3),'r'); colorbar(axXZ1);clim(clims);

%% --- YZ plane (Sagittal) ---
axYZ = nexttile(t,2);
imYZ = imagesc(axYZ, squeeze(vol(pos(1),:,:,volIdx))'); 
axis(axYZ,'image'); set(axYZ,'YDir','normal','XDir','reverse');
title(axYZ,'YZ (Sagittal)'); xlabel(axYZ,'Inferior'); ylabel(axYZ,'Anterior');
hold(axYZ,'on'); hxYZ = xline(axYZ,pos(2),'r'); hyYZ = yline(axYZ,pos(3),'r'); colorbar(axYZ);clim(clims);

%% --- XY plane (Axial) ---
axXY1 = nexttile(t,3);
imXY1 = imagesc(axXY1, squeeze(vol(:,:,pos(3),volIdx))'); 
axis(axXY1,'image'); set(axXY1,'YDir','normal','XDir','reverse');
title(axXY1,'XY (Axial)'); xlabel(axXY1,'Posterior'); ylabel(axXY1,'Left');
hold(axXY1,'on'); hxXY1 = xline(axXY1,pos(1),'r'); hyXY1 = yline(axXY1,pos(2),'r'); colorbar(axXY1);clim(clims);

%% --- Time series (4D) or Value (3D) ---
axTS = nexttile(t,4);
if nd == 4
    ts = squeeze(vol(pos(1),pos(2),pos(3),:));
    if hasMNI
        mniPos = whifun_convert_coords(M,pos,'vox2mni');
        ttl = sprintf('Voxel = [%d,%d,%d] | MNI = [%.1f, %.1f, %.1f]',pos,mniPos);
    else
        ttl = sprintf('Voxel = [%d,%d,%d]',pos);
    end
    plt = plot(axTS,ts,'LineWidth',1.5,'Color','k'); hold(axTS,'on');
    marker = plot(axTS,volIdx,ts(volIdx),'ro','MarkerFaceColor','r');
    xlabel(axTS,'Time'); ylabel(axTS,'BOLD signal'); title(axTS,ttl);
else
    val = vol(pos(1),pos(2),pos(3));
    if hasMNI
        mniPos = whifun_convert_coords(M,pos,'vox2mni');
        ttl = sprintf('Voxel = [%d,%d,%d] | MNI = [%.1f, %.1f, %.1f] | Value = %.2f',pos,mniPos,val);
    else
        ttl = sprintf('Voxel = [%d,%d,%d] | Value = %.2f',pos,val);
    end
    text(0.5,0.5,ttl,'Parent',axTS,'Units','normalized','HorizontalAlignment','center','FontSize',12);
    axis(axTS,'off'); plt = []; marker = [];
end

%% --- Store handles ---
handles = struct('vol',vol,'pos',pos,'M',[],'hasMNI',hasMNI, ...
    'imXZ1',imXZ1,'imYZ',imYZ,'imXY1',imXY1, ...
    'hxXZ1',hxXZ1,'hyXZ1',hyXZ1,'hxYZ',hxYZ,'hyYZ',hyYZ,'hxXY1',hxXY1,'hyXY1',hyXY1, ...
    'plt',plt,'marker',marker,'axTS',axTS,'fig',f,'nd',nd,'volIdx',volIdx,'T',T);

if hasMNI, handles.M = M; end

%% --- Click callbacks ---
set([axXZ1,imXZ1],'ButtonDownFcn',@(src,evt) clickXZ1(src,evt));
set([axYZ,imYZ],'ButtonDownFcn',@(src,evt) clickYZ(src,evt));
set([axXY1,imXY1],'ButtonDownFcn',@(src,evt) clickXY1(src,evt));

%% --- Editable boxes for voxel coordinates ---
uicontrol('Style','text','String','Voxel X:','Units','normalized','Position',[0.1 0.01 0.05 0.03]);
xBox = uicontrol('Style','edit','String',num2str(pos(1)),'Units','normalized','Position',[0.16 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'x','vox'));
uicontrol('Style','text','String','Voxel Y:','Units','normalized','Position',[0.23 0.01 0.05 0.03]);
yBox = uicontrol('Style','edit','String',num2str(pos(2)),'Units','normalized','Position',[0.29 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'y','vox'));
uicontrol('Style','text','String','Voxel Z:','Units','normalized','Position',[0.36 0.01 0.05 0.03]);
zBox = uicontrol('Style','edit','String',num2str(pos(3)),'Units','normalized','Position',[0.42 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'z','vox'));

%% --- Volume selector (slider + text) for 4D data ---
if nd == 4
    uicontrol('Style','text','String','Volume #:','Units','normalized','Position',[0.05 0.05 0.07 0.03]);
    volBox = uicontrol('Style','edit','String',num2str(volIdx),'Units','normalized','Position',[0.13 0.05 0.05 0.03],...
        'Callback',@(src,evt) changeVolume(src));
    volSlider = uicontrol('Style','slider','Min',1,'Max',T,'Value',volIdx,'SliderStep',[1/(T-1), 5/(T-1)], ...
        'Units','normalized','Position',[0.2 0.05 0.3 0.03], ...
        'Callback',@(src,evt) sliderVolume(src));
else
    volBox = []; volSlider = [];
end

%% --- Editable boxes for MNI coordinates (only if affine given) ---
if hasMNI
    mniPos = whifun_convert_coords(M,pos,'vox2mni');
    uicontrol('Style','text','String','MNI X:','Units','normalized','Position',[0.5 0.01 0.05 0.03]);
    xBoxMNI = uicontrol('Style','edit','String',num2str(mniPos(1)),'Units','normalized','Position',[0.56 0.01 0.05 0.03],...
        'Callback',@(src,evt) editBoxCallback(src,'x','mni'));
    uicontrol('Style','text','String','MNI Y:','Units','normalized','Position',[0.63 0.01 0.05 0.03]);
    yBoxMNI = uicontrol('Style','edit','String',num2str(mniPos(2)),'Units','normalized','Position',[0.69 0.01 0.05 0.03],...
        'Callback',@(src,evt) editBoxCallback(src,'y','mni'));
    uicontrol('Style','text','String','MNI Z:','Units','normalized','Position',[0.76 0.01 0.05 0.03]);
    zBoxMNI = uicontrol('Style','edit','String',num2str(mniPos(3)),'Units','normalized','Position',[0.82 0.01 0.05 0.03],...
        'Callback',@(src,evt) editBoxCallback(src,'z','mni'));
else
    xBoxMNI=[]; yBoxMNI=[]; zBoxMNI=[];
end

% Store all handles
handles.xBox = xBox; handles.yBox = yBox; handles.zBox = zBox;
handles.xBoxMNI = xBoxMNI; handles.yBoxMNI = yBoxMNI; handles.zBoxMNI = zBoxMNI;
handles.volBox = volBox; handles.volSlider = volSlider;
guidata(f,handles);

%% --- Nested callback functions ---
    function clickXZ1(~,evt)
        h = guidata(f); pt = round(evt.IntersectionPoint(1:2));
        h.pos(1)=pt(1); h.pos(3)=pt(2); updateViews(h); guidata(f,h);
    end
    function clickYZ(~,evt)
        h = guidata(f); pt = round(evt.IntersectionPoint(1:2));
        h.pos(2)=pt(1); h.pos(3)=pt(2); updateViews(h); guidata(f,h);
    end
    function clickXY1(~,evt)
        h = guidata(f); pt = round(evt.IntersectionPoint(1:2));
        h.pos(1)=pt(1); h.pos(2)=pt(2); updateViews(h); guidata(f,h);
    end

    function editBoxCallback(src,dim,type)
        h = guidata(f);
        if strcmp(type,'vox')
            val = round(str2double(src.String));
            switch dim
                case 'x', h.pos(1)=val;
                case 'y', h.pos(2)=val;
                case 'z', h.pos(3)=val;
            end
        elseif strcmp(type,'mni') && h.hasMNI
            mniCoord = [str2double(h.xBoxMNI.String), str2double(h.yBoxMNI.String), str2double(h.zBoxMNI.String)];
            voxelCoord = whifun_convert_coords(h.M, mniCoord, 'mni2vox');
            h.pos = round(voxelCoord);
        end
        updateViews(h); guidata(f,h);
    end

    function changeVolume(src)
        h = guidata(f);
        v = round(str2double(src.String));
        v = max(1,min(h.T,v));
        h.volIdx = v;
        if ~isempty(h.volSlider)
            set(h.volSlider,'Value',v);
        end
        updateViews(h);
        guidata(f,h);
    end

    function sliderVolume(src)
        h = guidata(f);
        v = round(get(src,'Value'));
        h.volIdx = v;
        if ~isempty(h.volBox)
            set(h.volBox,'String',num2str(v));
        end
        updateViews(h);
        guidata(f,h);
    end

    function updateViews(h)
        x=h.pos(1); y=h.pos(2); z=h.pos(3); v=h.volIdx;
        h.imXZ1.CData = squeeze(h.vol(:,y,:,v))';
        h.imYZ.CData  = squeeze(h.vol(x,:,:,v))';
        h.imXY1.CData = squeeze(h.vol(:,:,z,v))';
        h.hxXZ1.Value=x; h.hyXZ1.Value=z;
        h.hxYZ.Value=y; h.hyYZ.Value=z;
        h.hxXY1.Value=x; h.hyXY1.Value=y;
        set(h.xBox,'String',num2str(x));
        set(h.yBox,'String',num2str(y));
        set(h.zBox,'String',num2str(z));
        if h.nd==4 && ~isempty(h.volBox)
            set(h.volBox,'String',num2str(v));
        end
        if h.hasMNI
            mniPos=whifun_convert_coords(h.M,[x,y,z],'vox2mni');
            set(h.xBoxMNI,'String',num2str(mniPos(1)));
            set(h.yBoxMNI,'String',num2str(mniPos(2)));
            set(h.zBoxMNI,'String',num2str(mniPos(3)));
        end
        if h.nd==4
            ts=squeeze(h.vol(x,y,z,:));
            h.plt.YData=ts;
            h.marker.XData=v;
            h.marker.YData=ts(v);
        else
            val=h.vol(x,y,z);
            cla(h.axTS);
            text(0.5,0.5,sprintf('Voxel=[%d,%d,%d] | Value=%.2f',x,y,z,val), ...
                'Parent',h.axTS,'Units','normalized','HorizontalAlignment','center','FontSize',12);
            axis(h.axTS,'off');
        end
        drawnow;
    end
end
