function whifun_convert_3d_to_4d_atlas(input_atlas_path, output_path)
% whifun_convert_3d_to_4d_atlas(input_atlas_path, [output_path])
%
% Converts a 3D labeled atlas into a 4D NIfTI file, where each label
% (level) becomes a separate 3D volume in the 4th dimension.
%
% Example:
%   whifun_convert_3d_to_4d_atlas('atlas_3d.nii');
%   whifun_convert_3d_to_4d_atlas('atlas_3d.nii', 'atlas_4d.nii');
%
% Inputs:
%   input_atlas_path : Path to the input 3D atlas NIfTI file.
%   output_path      : (Optional) Output 4D NIfTI file path.
%                      If not provided, saved as <input_name>_4d.nii
%
% Notes:
%   - Each volume in the 4D output corresponds to one unique label in the atlas.
%   - Background (0) is ignored.
%
% Requires:
%   SPM toolbox (for spm_vol, spm_read_vols, spm_write_vol)

    if nargin < 1
        error('Usage: whifun_convert_3d_to_4d_atlas(input_atlas_path, [output_path])');
    end

    if ~isfile(input_atlas_path)
        error('File not found: %s', input_atlas_path);
    end

    % --- Determine output file path ---
    if nargin < 2 || isempty(output_path)
        [p, n, ext1] = fileparts(input_atlas_path);
        [~,n,ext2] = fileparts(n);
        output_path = fullfile(p, [n '_4d' ext2 ext1]);
    end

    % --- Load the input atlas ---
    [atlas_data,head] = whifun_niftiread(input_atlas_path);

    % --- Find unique nonzero labels ---
    labels = unique(atlas_data(:));
    labels(labels == 0 | isnan(labels)) = [];
    nLabels = numel(labels);

    fprintf('Found %d unique labels.\n', nLabels);

    % --- Create 4D volume ---
    [nx, ny, nz] = size(atlas_data);
    atlas_4d = zeros(nx, ny, nz, nLabels);

    for i = 1:nLabels
        atlas_4d(:,:,:,i) = double(atlas_data == labels(i));
    end

    % --- Write out 4D NIfTI ---
    niftisave(atlas_4d,output_path,head)

    disp('4D atlas saved to: %s\n', output_path,head);
end


