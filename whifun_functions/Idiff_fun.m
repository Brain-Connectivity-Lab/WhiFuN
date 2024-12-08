function out = Idiff_fun(sub_spec,ses)

p = 1;
for i = 1:ses
    for j = i+1:ses
        
test_retest = [i,j];

test_shssdl = sub_spec(:,test_retest(1):ses:end);
retest_shssdl = sub_spec(:,test_retest(2):ses:end);

A = corr(test_shssdl,retest_shssdl);
% figure;imagesc(A);colorbar;axis image

Iself_shssl = mean(abs(diag(A)));
Iothers_shssdl = mean(abs(A-diag(diag(A))),'all');

out(p) = (Iself_shssl - Iothers_shssdl)*100;
p = p+1;
    end
end
