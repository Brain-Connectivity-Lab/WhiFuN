function mul=mulmat(mat,f)
    if nargin < 2
        f=1;
    end
    
    b = size(mat);
    mul = ones(b(1),b(2));
   
    for i = 1: b(3)
        mul = mul.*mat(:,:,i);
        
    end
%     mul2 = (mul)^(1/b(3));
%     mul1 = 1./(1+exp(-mul));
%     mul1 = mul/max(max(mul));
    if f==1
    figure;
    end
    imagesc(mul);
    colorbar;