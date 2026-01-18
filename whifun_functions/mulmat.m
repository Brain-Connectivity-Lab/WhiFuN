function mul=mulmat(mat,f)
%MULMAT Calculates the element-wise product across the 3rd dimension.
%
%   MUL = MULMAT(MAT) computes the cumulative product of all 2D slices 
%   contained in the 3D matrix MAT. The result is a 2D matrix of the 
%   same height and width as the input slices.
%
%   MUL = MULMAT(MAT, F) allows toggling the figure display. If F is 1 
%   (default), a new figure window is opened. If F is 0, it plots in 
%   the current axes.
%
%   INPUTS:
%       mat - A 3D numeric array (Height x Width x Slices).
%       f   - Binary flag (0 or 1). Determines if a new figure is created.
%
%   OUTPUTS:
%       mul - The resulting 2D product matrix.
%
%   MATHEMATICAL NOTE:
%       For each voxel (i,j), the output is calculated as:
%       $$P(i,j) = \prod_{k=1}^{n} A(i,j,k)$$
%       where n is the number of slices in the 3rd dimension.
%
%   See also PROD, IMAGESC, COLORBAR.
%   Author: Pratik Jain

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