function Corr = corrvec(mat,d)
%CORRVEC Extracts the unique upper-triangular elements of a 2D or 3D correlation/adjacency matrix.
%
%   CORR = CORRVEC(MAT, D)
%
%   This function is primarily used to convert symmetric matrices (like
%   correlation matrices or adjacency matrices) into a compact vector
%   representation, which is often necessary before feeding data into
%   clustering or multivariate statistical algorithms.
%
%   Input Arguments:
%   MAT - The input matrix (or matrices).
%         - If 2D (N x N): A single symmetric matrix (e.g., a connectivity map).
%         - If 3D (N x N x S): A stack of S symmetric matrices (e.g., dynamic FC windows, or multiple subjects).
%   D   - (Optional, default 0) Flag to determine whether to include the
%         diagonal elements (the self-correlations, which are usually 1):
%         D = 0: Exclude the diagonal (upper off-diagonal triangle only).
%         D = 1: Include the diagonal (upper triangle including diagonal).
%
%   Output Arguments:
%   CORR - The vectorized form of the unique elements.
%          - If MAT is N x N: Output size is (N*(N-1)/2) x 1 (if D=0) or (N*(N+1)/2) x 1 (if D=1).
%          - If MAT is N x N x S: Output size is (N*(N-1)/2) x S (if D=0) or (N*(N+1)/2) x S (if D=1).
%
%   Author: Pratik Jain

if nargin < 2
    d = 0;
end

b = size(mat);
if numel(b) == 2
    b(3) = 1;
end
p = 0;

if d == 0
    Corr = zeros(b(1)*(b(1)-1)/2, b(3));
elseif d == 1
    Corr = zeros(b(1)*(b(1)+1)/2, b(3));
end

for i1 = 1:b(3)
    for i = 1:b(2)
        if d == 0
            j_indices = (i+1:b(1));
        elseif d == 1
            j_indices = (i:b(1));
        end
        p = p + numel(j_indices);
        Corr(p - numel(j_indices) + 1:p, i1) = mat(i, j_indices, i1);
    end
    p = 0;
end
