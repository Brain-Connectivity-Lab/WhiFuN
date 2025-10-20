function Dice_coef_LR = get_symettry_indi(current_clustering_solution)
%GET_SYMETTRY_INDI Measures the spatial symmetry of a functional network
%   clustering solution using the Dice similarity coefficient, leveraging an
%   external `dice_iou` function.
%
%   DICE_COEF_LR = GET_SYMETTRY_INDI(CURRENT_CLUSTERING_SOLUTION)
%
%   This function quantifies the degree of mirror-symmetry for a single
%   clustering solution across the mid-sagittal plane. It compares the
%   network labels in the Left hemisphere with the mirrored network labels
%   from the Right hemisphere using the Dice coefficient.
%
%   Input Arguments:
%   CURRENT_CLUSTERING_SOLUTION - A 3D NIfTI volume (X x Y x Z) where each
%                                 non-zero voxel contains a cluster/network
%                                 label (K).
%
%   Output Arguments:
%   DICE_COEF_LR                - The Dice similarity coefficient matrix (K x K),
%                                 where entry (i, j) represents the similarity
%                                 between network 'i' in the Left hemisphere (FN_L)
%                                 and network 'j' in the mirrored Right hemisphere (FN_R).
%
%   Assumptions:
%   - The first dimension (Dim 1) corresponds to the Left-Right axis.
%   - The external function `dice_iou` is available and correctly computes
%     the Dice similarity matrix between two labeled volumes.
%
%   Author: Pratik Jain

% separating the left and right sides of the clustering solutions, and flipping the right side, for direct comparison to the left
Mid_sagittal_slice = round(size(current_clustering_solution,1)/2);
current_clustering_solution_L = current_clustering_solution(1:Mid_sagittal_slice,:,:);
current_clustering_solution_R = flipdim(current_clustering_solution,1);
current_clustering_solution_R = current_clustering_solution_R(1:Mid_sagittal_slice,:,:);

% computing Dice's coefficient of similarity between the clustering results for both hemispheres
[Dice_coef_LR,~] = dice_iou(current_clustering_solution_L,current_clustering_solution_R,0,0);

end