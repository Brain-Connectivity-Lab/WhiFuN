function whifun_orthosliceViewer4d(vol4d)
% whifun_orthosliceViewer4d - Ortho viewer with crosshairs, time series,
% and editable coordinate boxes
%
% vol4d: X x Y x Z x T fMRI volume

if ndims(vol4d) ~= 4
    error('Input must be 4D (X x Y x Z x T)');
end

[X,Y,Z,T] = size(vol4d);
pos = round([X,Y,Z]/2);

f = figure('Name','WhiFuN Ortho Viewer','Color','w','Units','normalized','Position',[0.1 0.1 0.8 0.7]);
t = tiledlayout(f,2,2,'TileSpacing','compact');

%% --- XY plane (Coronal) ---
axXY = nexttile(t,1);
imXY = imagesc(axXY, flipud(squeeze(vol4d(:,pos(2),:,1))')); axis(axXY,'image');
title(axXY,'XY (Coronal)'); xlabel(axXY,'Superior'); ylabel(axXY,'Left');
hold(axXY,'on'); hxXY = xline(axXY,pos(1),'r'); hyXY = yline(axXY,pos(2),'r');

%% --- YZ plane (Coronal) ---
axYZ = nexttile(t,2);
imYZ = imagesc(axYZ, fliplr(flipud(squeeze(vol4d(pos(1),:,:,1))'))); axis(axYZ,'image');
title(axYZ,'YZ (Coronal)'); xlabel(axYZ,'Superior'); ylabel(axYZ,'Anterior');
hold(axYZ,'on'); hxYZ = xline(axYZ,pos(2),'r'); hyYZ = yline(axYZ,pos(3),'r');

%% --- XZ plane (Sagittal) ---
axXZ = nexttile(t,3);
imXZ = imagesc(axXZ, flipud(squeeze(vol4d(:,:,pos(3),1))')); axis(axXZ,'image');
title(axXZ,'XZ (Sagittal)'); xlabel(axXZ,'Anterior'); ylabel(axXZ,'Left');
hold(axXZ,'on'); hxXZ = xline(axXZ,pos(1),'r'); hyXZ = yline(axXZ,pos(3),'r');

%% --- Time series ---
axTS = nexttile(t,4);
ts = squeeze(vol4d(pos(1),pos(2),pos(3),:));
plt = plot(axTS,ts,'LineWidth',1.5);
xlabel(axTS,'Time'); ylabel(axTS,'BOLD signal');
title(axTS,sprintf('Voxel = [%d,%d,%d]',pos));

%% --- Store handles in guidata ---
handles = struct('vol',vol4d,'pos',pos, ...
    'imXY',imXY,'imYZ',imYZ,'imXZ',imXZ, ...
    'hxXY',hxXY,'hyXY',hyXY, ...
    'hxYZ',hxYZ,'hyYZ',hyYZ, ...
    'hxXZ',hxXZ,'hyXZ',hyXZ, ...
    'plt',plt,'axTS',axTS,'fig',f);

%% --- Set click callbacks ---
set(axXY,'ButtonDownFcn',@(src,evt) clickXY(src,evt));
set(imXY,'ButtonDownFcn',@(src,evt) clickXY(src,evt));
set(axYZ,'ButtonDownFcn',@(src,evt) clickYZ(src,evt));
set(imYZ,'ButtonDownFcn',@(src,evt) clickYZ(src,evt));
set(axXZ,'ButtonDownFcn',@(src,evt) clickXZ(src,evt));
set(imXZ,'ButtonDownFcn',@(src,evt) clickXZ(src,evt));

%% --- Add editable coordinate boxes ---
uicontrol('Style','text','String','X:','Units','normalized','Position',[0.1 0.01 0.03 0.03]);
xBox = uicontrol('Style','edit','String',num2str(pos(1)),'Units','normalized','Position',[0.13 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'x'));

uicontrol('Style','text','String','Y:','Units','normalized','Position',[0.2 0.01 0.03 0.03]);
yBox = uicontrol('Style','edit','String',num2str(pos(2)),'Units','normalized','Position',[0.23 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'y'));

uicontrol('Style','text','String','Z:','Units','normalized','Position',[0.3 0.01 0.03 0.03]);
zBox = uicontrol('Style','edit','String',num2str(pos(3)),'Units','normalized','Position',[0.33 0.01 0.05 0.03],...
    'Callback',@(src,evt) editBoxCallback(src,'z'));

% Save boxes in handles and store in guidata
handles.xBox = xBox; handles.yBox = yBox; handles.zBox = zBox;
guidata(f,handles);

end

%% --- Click callbacks ---
function clickXY(~,evt)
f = ancestor(evt.Source,'figure');
handles = guidata(f);
pt = round(evt.IntersectionPoint(1:2));
handles.pos(1) = pt(1); handles.pos(2) = pt(2);
updateViews(handles);
guidata(f,handles);
end

function clickYZ(~,evt)
f = ancestor(evt.Source,'figure');
handles = guidata(f);
pt = round(evt.IntersectionPoint(1:2));
handles.pos(2) = pt(1); handles.pos(3) = pt(2);
updateViews(handles);
guidata(f,handles);
end

function clickXZ(~,evt)
f = ancestor(evt.Source,'figure');
handles = guidata(f);
pt = round(evt.IntersectionPoint(1:2));
handles.pos(1) = pt(1); handles.pos(3) = pt(2);
updateViews(handles);
guidata(f,handles);
end

%% --- Edit box callback ---
function editBoxCallback(src,dim)
f = ancestor(src,'figure');
handles = guidata(f);
volSize = size(handles.vol);
val = round(str2double(src.String));

switch dim
    case 'x', val = max(1,min(volSize(1),val)); handles.pos(1)=val;
    case 'y', val = max(1,min(volSize(2),val)); handles.pos(2)=val;
    case 'z', val = max(1,min(volSize(3),val)); handles.pos(3)=val;
end

% Update boxes to current position
set(handles.xBox,'String',num2str(handles.pos(1)));
set(handles.yBox,'String',num2str(handles.pos(2)));
set(handles.zBox,'String',num2str(handles.pos(3)));

updateViews(handles);
guidata(f,handles);
end

%% --- Update slices, crosshairs, time series ---
function updateViews(h)
x = h.pos(1); y = h.pos(2); z = h.pos(3);

h.imXY.CData = flipud(squeeze(h.vol(:,y,:,1))');
h.imYZ.CData = fliplr(flipud(squeeze(h.vol(x,:,:,1))'));
h.imXZ.CData = flipud(squeeze(h.vol(:,:,z,1))');

h.hxXY.Value = x; h.hyXY.Value = y;
h.hxYZ.Value = y; h.hyYZ.Value = z;
h.hxXZ.Value = x; h.hyXZ.Value = z;

ts = squeeze(h.vol(x,y,z,:));
h.plt.YData = ts; h.plt.XData = 1:numel(ts);
title(h.axTS,sprintf('Voxel = [%d,%d,%d]',[x,y,z]));
drawnow;
end
