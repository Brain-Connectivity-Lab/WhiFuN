function niftisave(niftiimage,filename,info)

% input -->
% niftiimage --> file to be saved
% info --> info file to be used
% filename --> desired file name

info.Filename = filename;
info.Datatype = class(niftiimage);
info.Filemoddate = char(datetime);
if length(info.ImageSize) == 3 && length(size(niftiimage)) == 4
    info.PixelDimensions = [info.PixelDimensions 0];%size(niftiimage);%info.PixelDimensions(1:length(info.ImageSize));
end
if length(info.ImageSize) == 4 && length(size(niftiimage)) == 3
    info.PixelDimensions = info.PixelDimensions(1:3);
end
info.ImageSize = size(niftiimage);
%
info.Filesize = [];
niftiwrite(niftiimage,filename,info)
end