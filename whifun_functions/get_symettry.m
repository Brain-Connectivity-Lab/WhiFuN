function Dice_coef_LR = get_symettry(current_clustering_solution)
%GET_SYMETTRY Measures the spatial symmetry of a functional network clustering solution
%   by comparing the clustering patterns in the Left and Right hemispheres.
%
%   DICE_COEF_LR = GET_SYMETTRY(CURRENT_CLUSTERING_SOLUTION)
%
%   This function quantifies the degree to which a functional network
%   solution is mirror-symmetric across the mid-sagittal plane. It achieves
%   this by:
%   1. Separating the clustering volume into Left (L) and Right (R) halves.
%   2. Flipping the Right half along the Left-Right axis (Dim 1) so it aligns
%      with the Left half.
%   3. Masking both halves to only include voxels present in both.
%   4. Converting the L and R clustering solutions into Adjacency Matrices (AMs)
%      based on whether pairs of voxels belong to the same cluster.
%   5. Calculating the Dice similarity coefficient between the L-AM and R-AM.
%
%   Input Arguments:
%   CURRENT_CLUSTERING_SOLUTION - A 3D NIfTI volume (X x Y x Z) where each non-zero
%                                 voxel contains a cluster/network label (K).
%                                 The X dimension is assumed to be the Left-Right axis.
%
%   Output Arguments:
%   DICE_COEF_LR                - The Dice coefficient (ranging from 0 to 1)
%                                 representing the similarity between the Left
%                                 and Right hemispheric clustering solutions.
%
%   Assumptions:
%   - The first dimension (Dim 1) corresponds to the Left-Right axis.
%   - The image is oriented such that indices [1 : Mid_sagittal_slice]
%     constitute one hemisphere (e.g., Left) and the rest is the other.
%   - Flipping Dim 1 of the whole volume and taking the first half aligns
%     the mirrored Right hemisphere with the original Left hemisphere.
%
%   Author: Pratik Jain

% separating the left and right sides of the clustering solutions, and flipping the right side, for direct comparison to the left
Mid_sagittal_slice = round(size(current_clustering_solution,1)/2);
current_clustering_solution_L = current_clustering_solution(1:Mid_sagittal_slice,:,:);
current_clustering_solution_R = flipdim(current_clustering_solution,1);
current_clustering_solution_R = current_clustering_solution_R(1:Mid_sagittal_slice,:,:);

% looking only at places where white-matter exists in both hemispheres
% (zeroing places where that is not true)
current_clustering_solution_L((current_clustering_solution_L & current_clustering_solution_R) ==0) = 0;
current_clustering_solution_R((current_clustering_solution_L & current_clustering_solution_R) ==0) = 0;
clustered_voxels = find(current_clustering_solution_L(:)>0);    % finding all voxels belonging to the white-matter in both hemispheres

% creating adjacency matrices for similarity between clustering solutions
% (1 indicates the two voxels belong to the same cluster)
adjmat_L = zeros(length(clustered_voxels)); adjmat_R = zeros(length(clustered_voxels));
for i=1:length(clustered_voxels)
    for j=1:length(clustered_voxels)
        if current_clustering_solution_L(clustered_voxels(i))==current_clustering_solution_L(clustered_voxels(j))
            adjmat_L(i,j)=1;
        end
        if current_clustering_solution_R(clustered_voxels(i))==current_clustering_solution_R(clustered_voxels(j))
            adjmat_R(i,j)=1;
        end
    end
end
% computing Dice's coefficient of similarity between the clustering results for both hemispheres
Dice_coef_LR = 2*sum(adjmat_R(:) & adjmat_L(:)) / (sum(adjmat_R(:)) + sum(adjmat_L(:)));

end