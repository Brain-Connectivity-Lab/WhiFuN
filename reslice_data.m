function [OutVolume] = reslice_data(InputFile,TargetSpace,hld,wr,OutputFile,nn)

if nargin < 4
    wr = 0;
    nn = 0;
end
if nargin < 6
    nn = 0;
end

[RefData, RefHead]   = y_Read(TargetSpace);
mat=RefHead.mat;
dim=RefHead.dim;
[SourceData,SourceHead]=y_Read(InputFile);

%Handle .nii.gz. Referenced from y_Read.m. YAN Chao-Gan, 151117
[pathstr, name, ext] = fileparts(InputFile);
if strcmpi(ext,'.gz')
    gunzip(InputFile);
    FileNameWithoutGZ = fullfile(pathstr,name);
    SourceHead.fname = FileNameWithoutGZ;
end

[x1,x2,x3] = ndgrid(1:dim(1),1:dim(2),1:dim(3));
d     = [hld*[1 1 1]' [1 1 0]'];
C = spm_bsplinc(SourceHead, d);
v = zeros(dim);

M = inv(SourceHead.mat)*mat; % M = inv(mat\SourceHead.mat) in spm_reslice.m
y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));


OutVolume    = spm_bsplins(C, y1,y2,y3, d);

%Revised by YAN Chao-Gan 121214. Apply a mask from the source image: don't extend values to outside brain.
tiny = 5e-2; % From spm_vol_utils.c
Mask = true(size(y1));
Mask = Mask & (y1 >= (1-tiny) & y1 <= (SourceHead.dim(1)+tiny));
Mask = Mask & (y2 >= (1-tiny) & y2 <= (SourceHead.dim(2)+tiny));
Mask = Mask & (y3 >= (1-tiny) & y3 <= (SourceHead.dim(3)+tiny));

OutVolume(~Mask) = 0;


OutHead=SourceHead;
OutHead.mat      = mat;
OutHead.dim(1:3) = dim;

if wr == 1
    if nn==1
        OutVolume = round(OutVolume);
    end
    y_Write(OutVolume,OutHead,OutputFile);
end