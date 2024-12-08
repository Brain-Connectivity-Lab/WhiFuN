function h = whifun_orthosliceViewer(image)

h = orthosliceViewer(permute(image,[3,1,2]));
[hXY,hYZ,hXZ] = getAxesHandles(h);

hXY.View = [180,90];
hYZ.View = [180,90];
hXZ.View = [180,90];

end