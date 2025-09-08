function [REST_MASK1,func_mask_path] = whifun_create_rest_mask(in_func_path,in_anat_mask_subj_space_path)
% WHIFUN_CREATE_REST_MASK Creates a brain mask in functional space.
%
%   [REST_MASK1, func_mask_path] = WHIFUN_CREATE_REST_MASK(in_func_path, in_anat_mask_subj_space_path)
%   creates a brain mask for a functional image based on a pre-existing
%   anatomical brain mask. This is a crucial step for subsequent analysis
%   that needs to be restricted to brain tissue.
%
%   The function uses `reslice_data` (an assumed helper function, as it is
%   not a standard MATLAB function) to resample the anatomical mask into the
%   functional image's space. Reslicing ensures that the mask has the same
%   dimensions and voxel-to-world mapping as the functional data, allowing
%   for direct application.
%
%   Input Arguments:
%   in_func_path                 - The path to the functional NIfTI file. This
%                                  file's dimensions and transformations are used
%                                  as a template for the new mask.
%   in_anat_mask_subj_space_path - The path to the brain mask created from the
%                                  anatomical image in the subject's native space.
%
%   Output Arguments:
%   REST_MASK1       - A `dir` structure pointing to the newly created mask file.
%   func_mask_path   - The full path to the created mask file.
%
%   Author: Pratik Jain
%   See also RESLICE_DATA, DIR, FULLFILE.


now_func_path = dir(in_func_path);
% Creating func_mask from the Anat mask
func_mask_path = fullfile(now_func_path.folder,['func_mask_' now_func_path.name]);
REST_MASK1= reslice_data(in_anat_mask_subj_space_path,in_func_path,1,1,func_mask_path);
