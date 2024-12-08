function [idiff_score,A,Iself,Iothers] = idiff(vec1,vec2,fig_op,pca_op)

%% Input 
% vec1 -> FC of all subjects first session
% vec2 -> FC of all subjects second session
% fig_op -> 1 -> plots the A matrix
% fig_op -> 0 -> does not plot the matrix
% pca_op -> 1 -> do pca
% pca _op -> 0 -> no pca
 [d,s] = size(vec1);
if ~exist("fig_op",'var')
    fig_op = 0;
end

if ~exist("pca_op",'var')
    pca_op = 0;
end

if pca_op == 0
    A = corr(vec1,vec2);
    if fig_op == 1
        figure;imagesc(A)
    end
    Iself = mean(abs(diag(A)));
    I = eye(size(A));
    I(I==1) = nan;
    Iothers = mean(abs(A-I),'all','omitnan');
    
    idiff_score = (Iself - Iothers)*100;

else % PCA
    
    [V,Ws,~,~,~,mean_map] = pca([vec1,vec2]);                   % PCA 
    Ws = Ws';
    idiff_score = zeros(size(V,2),1);                 % initialising idiff
%     Sub_spec_pca = zeros(size([vec1,vec2]));

    for i = 1:size(V,2)                             % For the different PCs
        eig_com = 1:i;                                  % Choose the first i PCs
    
        Sub_spec_pca = V(:,eig_com)*Ws(eig_com,:) + mean_map';                  % Project the data on eigen vectors
        idiff_score(i) = idiff(Sub_spec_pca(1:s,:)',Sub_spec_pca(s+1:end,:)');                     % Calculate idiff
    end

end