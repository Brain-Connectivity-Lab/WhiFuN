function out = imfuse3d(A,B)

out = zeros([size(A,1),size(A,2),3,size(A,3)]);
for i = 1:size(A,3)
    C = imfuse(A(:,:,i),B(:,:,i));

    out(:,:,:,i) = C;
end

out = permute(out,[1,2,4,3]);

end