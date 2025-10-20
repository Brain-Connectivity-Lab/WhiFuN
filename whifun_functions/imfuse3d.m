function out = imfuse3d(A,B)

out = zeros([size(A,1),size(A,2),size(A,3)]);
for i = 1:size(A,3)
    C = imfuse(A(:,:,i),B(:,:,i));

    out(:,:,i) = mean(C,3);
end

out = permute(out,[1,2,3]);

end