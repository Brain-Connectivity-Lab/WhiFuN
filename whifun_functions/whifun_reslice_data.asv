function whifun_reslice_data(InputFile,TargetSpace,out_path,interpo)

if ~exist("interpo",'var')
    interpo = 1; % Default interpolation 1 = trilinear interpolation if not specified
end


[fold_,name,ext] = fileparts(InputFile);

if strcmp(ext,'.gz')
    gz_in = 1;
    gunzip(InputFile);
    InputFile = fullfile(fold_,name);
end

[fold_,name,ext] = fileparts(TargetSpace);

if strcmp(ext,'.gz')
    gz_tar = 1;

    gunzip(TargetSpace);
    TargetSpace = fullfile(fold_,name);
end

% Reference image (the one you want to match)
% TargetSpace = 'fmri_img1.nii';   % [47 59 51 200]

% Source image (the one you want to reslice)
% InputFile = 'fmri_img2.nii';   % [59 70 60 200]

% Load both into a char array for spm_reslice
P = char(TargetSpace, InputFile);

% Set reslicing flags
flags = struct( ...
    'interp', interpo, ...   % 1 = trilinear interpolation (3 or 4 for spline)
    'wrap', [0 0 0], ...
    'mask', 0, ...
    'which', 1, ...    % 0=write mean only, 1=write resliced images
    'mean', 0 ...      % 0=don't write mean image
);

% Perform reslicing
spm_reslice(P, flags);

[filepath, name, ext] = fileparts(InputFile);

resliced_img = fullfile(filepath, ['r' name ext]); % path to resliced file

if gz_in
    gzip(resliced_img)
    delete(resliced_img)
    resliced_img = [resliced_img '.gz'];
    
end

if exist("out_path","var")
    movefile(resliced_img, out_path);
end


if gz_in
    delete(InputFile)
end
if gz_tar
    delete(TargetSpace)
end