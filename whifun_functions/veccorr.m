function mat = veccorr(vec)
%VECCORR Converts a vectorized upper-triangular matrix back into a full square matrix.
%
%   MAT = VECCORR(VEC)
%
%   This function reconstructs a symmetric matrix (e.g., a correlation
%   matrix) from its compact vector representation of the unique
%   upper-off-diagonal elements.
%
%   Input Arguments:
%   VEC - The input vector or matrix containing the vectorized upper-off-diagonal
%         elements. Expected dimensions: (N*(N-1)/2) x S, where N is the
%         number of regions/ROIs and S is the number of matrices (e.g., subjects, windows).
%
%   Output Arguments:
%   MAT - The reconstructed full matrix (or stack of matrices).
%         Expected dimensions: N x N x S. The diagonal elements are set to NaN.
%
%   Derivation of N (Number of Regions):
%   The number of upper-off-diagonal elements (L) for an N x N matrix is
%   $L = \frac{N(N-1)}{2}$.
%   Solving for N gives the quadratic solution: $N = \frac{1 + \sqrt{1 + 8L}}{2}$.
%   In the code, $L = b(1)$ (the number of rows in the input vector), so $N = \frac{-1 + \sqrt{1 + 8 \cdot b(1)}}{2} + 1$.
%
%   Author: Pratik Jain

%     if nargin == 2
%         maxthresh = 0;
%         minthresh = 0;
%     end
%     if nargin ==3
%         minthresh = -maxthresh;
%     end

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
