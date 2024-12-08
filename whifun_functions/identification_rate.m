function [acco,confu_] = identification_rate(vec1,vec2)
%% Inputs 
% vec1 = FC vector for 1st session of all subjects 
% vec2 = FC vector for 2nd session of all subjects

gt = 1:size(vec1,2);
[~,idf_idx] = max(corr(vec1,vec2));

confu_ = confusionmat(gt,gt(idf_idx));
acco = sum(diag(confu_))/sum(confu_(:));

end