function h = whifun_orthosliceViewer(image)

if isstruct(image)
    if length(image) == 1
        image = niftiread(fullfile(image.folder,image.name));
    else
        msgbox('More than one files found in the structure provided','More than one file')
    end
elseif isstring(image) || ischar(image)
    image = niftiread(image);
end
h = orthosliceViewer(permute(image,[3,1,2]));
[hXY,hYZ,hXZ] = getAxesHandles(h);

hXY.View = [180,90];
hYZ.View = [180,90];
hXZ.View = [180,90];

end