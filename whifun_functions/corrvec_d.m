function Corr = corrvec_d(mat)
    b = size(mat);
    if size(b,2) == 2
        b(3) =1;
    end
    p=0;
    Corr = zeros(b(1)*(b(1)+1)/2,b(3));
    for i1=1:b(3)
        for i = 1:b(2)
            for j = i:b(1)
                p=p+1;
                Corr(p,i1) = mat(i,j,i1);
            end
        end
        p=0;
    end
   
    
    
