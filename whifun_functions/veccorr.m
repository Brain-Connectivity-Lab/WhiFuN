%% Written by Pratik Jain
% Converts the uppertraingular vector of dimension n x (n-1) back to correlation matrix of dimension n x n (n is number of ROI) 
function mat = veccorr(vec)
%     if nargin == 2
%         maxthresh = 0;
%         minthresh = 0;
%     end
%     if nargin ==3
%         minthresh = -maxthresh;
%     end
    %Vec = data matrix
    %N= no. of Regions
    %thresh is threshold only values above +thresh and below -thresh will
    %be considered
    
    b = size(vec);
    N = (-1 + (1+8*b(1))^(1/2))/2 + 1;

    for i1 = 1:b(2)
        p=0;
        for i=1:N
            for j=i+1:N
                p=p+1;
%                 if vec(p,i1) > maxthresh || vec(p,i1) < minthresh
                mat(i,j,i1) = vec(p,i1);
                mat(j,i,i1) = vec(p,i1);
%                 end
            end
            mat(i,i,i1)=NaN;
        end
    end
