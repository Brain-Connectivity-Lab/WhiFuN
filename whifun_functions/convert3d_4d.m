function a = convert3d_4d(folder,filter,TR,out_filename,atlas)
    %% Input 
%     folder --> the subject folder that contains all the 3d nifti files
%     filter --> common name of the 3d niftifiles 
%     TR --> Temporal resolution 
%     filename (optional) --> specify the output filename

% Eg. if the 3d niftifiles look 
% f2021-12-22_10-56.nii
% f2021-12-22_10-54.nii

% the filter will be --> 'f202*'
    tic
    files = dir(fullfile(folder,filter));

    if strcmp(files(1).name, '.')                                           % If the first file is '.', then remove it as it is not a subject directory
        files(1) = [];
    end

    if strcmp(files(1).name, '..')                                          % If the first file is '..', then remove it as it is not a subject directory
        files(1) = [];
    end

    if nargin < 4
        out_filename = fullfile(folder,[files(1).name(1:end-4),'_4d.nii']);
        atlas = 0;
    end
    if ~isempty(files)
        header = niftiinfo(fullfile(files(1).folder,files(1).name));
        a = zeros([header.ImageSize(1:3),length(files)]);
        for i = 1:length(files)
            if atlas == 0
                a(:,:,:,i) = (niftiread(fullfile(files(i).folder,files(i).name)));
            else
                a(:,:,:,i) = i.*(niftiread(fullfile(files(i).folder,files(i).name)));
            end
        end
        toc
        header.Filesize = numel(a)*2;
        header.Datatype = class(a);
        header.Filemoddate = char(datetime);
        header.Filename = out_filename;
        header.ImageSize = size(a);
        header.PixelDimensions = [header.PixelDimensions(1:3),TR];
        header.Filesize = [];
        niftiwrite(a,out_filename,header)
    else
        a = 0;
        disp('No files found')
    end

end