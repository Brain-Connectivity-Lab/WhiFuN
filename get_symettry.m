function Dice_coef_LR = get_symettry(current_clustering_solution)
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