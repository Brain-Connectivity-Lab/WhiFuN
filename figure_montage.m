function figure_montage(in,x,y)

out = [];
for y_i = 1:y

    out1 = [];
    for x_i = (y_i-1)*x+1:x*y_i

        out1 = [out1 in(:,:,x_i)];
    end
out = [out;out1];

end

figure;imagesc(out)
