function Dice_coef_LR = get_symettry_indi(current_clustering_solution)
% separating the left and right sides of the clustering solutions, and flipping the right side, for direct comparison to the left
Mid_sagittal_slice = round(size(current_clustering_solution,1)/2);
current_clustering_solution_L = current_clustering_solution(1:Mid_sagittal_slice,:,:);
current_clustering_solution_R = flipdim(current_clustering_solution,1);
current_clustering_solution_R = current_clustering_solution_R(1:Mid_sagittal_slice,:,:);

% computing Dice's coefficient of similarity between the clustering results for both hemispheres
[Dice_coef_LR,~] = dice_iou(current_clustering_solution_L,current_clustering_solution_R,0,0);

end