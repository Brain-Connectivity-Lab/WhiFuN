function out_mask_path = whifun_erode(path_,num_erosions,out_pre)

% WHIFUN_ERODE Erodes a binary mask.
%
%   out_mask_path = WHIFUN_ERODE(path_, num_erosions, out_pre) performs
%   morphological erosion on a binary or probabilistic mask image.
%   Erosion removes voxels from the boundary of a mask, making it smaller.
%   This is often used to create a more central "deep" mask of a tissue
%   type, for example, a deep white matter mask to avoid contamination from
%   gray matter.
%
%   The function performs the following steps:
%   1.  **Read Image**: It reads the input NIfTI mask file.
%   2.  **Erode**: It iteratively applies SPM's `spm_erode` function a
%       specified number of times (`num_erosions`).
%   3.  **Save Output**: The eroded mask is saved as a new NIfTI file with a
%       name that includes the number of erosions and a specified prefix.
%
%   Input Arguments:
%   path_         - The full path to the input NIfTI mask file.
%   num_erosions  - The number of times to apply the erosion operation.
%   out_pre       - The prefix for the output eroded file.
%
%   Output Arguments:
%   out_mask_path - The full path to the newly created eroded mask file.
%
%   Author: Pratik Jain
%   See also SPM_ERODE, NIFTIREAD, NIFTISAVE, FULLFILE.

now_mask_path = dir(path_);
out_mask_path = fullfile(now_mask_path.folder,[out_pre 'num_er-' num2str(num_erosions) '_' now_mask_path.name]);
vol = double(niftiread(path_));
vol_info = niftiinfo(path_);
eroded_vol = vol;
for i = 1:num_erosions
    eroded_vol = spm_erode(eroded_vol);
end
niftisave(eroded_vol,out_mask_path,vol_info)