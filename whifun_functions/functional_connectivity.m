function [vec,nan_sub] = functional_connectivity(reg_ts,Z,win,stride,nl)
%FUNCTIONAL_CONNECTIVITY Calculates Functional Connectivity (FC) from averaged ROI time series.
%
%   [VEC, NAN_SUB] = FUNCTIONAL_CONNECTIVITY(REG_TS, Z, WIN, STRIDE, NL)
%
%   Computes static or dynamic functional connectivity matrices (Pearson
%   correlation or Non-linear Xi correlation) and returns the unique
%   upper-triangle elements as a vector.
%
%   Input Arguments:
%   REG_TS   - Time series of the ROIs. Expected dimensions: T x ROI x Subj
%              (Time points x Number of ROIs x Number of Subjects).
%   Z        - (Optional, default 0) Flag for Fisher Z-transformation:
%              Z = 1: Apply Fisher Z-transformation to Pearson correlation results.
%              Z = 0: Do not apply transformation.
%   WIN      - (Optional, default T) Window size for Dynamic Functional Connectivity (DFC).
%              WIN = T calculates Static FC.
%   STRIDE   - (Optional, default 1) Stride (step size) for sliding window in DFC.
%   NL       - (Optional, default 0) Flag for Non-linear FC:
%              NL = 1: Use Non-linear Xi correlation (requires xicor function).
%              NL = 0: Use Pearson correlation (default).
%
%   Output Arguments:
%   VEC      - The vectorized upper-triangle of the FC matrices.
%              - Static FC (NL=0, WIN=T): (ROI*(ROI-1)/2) x N_Subj
%              - Dynamic FC (NL=0, WIN<T): (ROI*(ROI-1)/2) x N_Windows x N_Subj
%              - Non-linear FC (NL=1): (ROI*(ROI-1)/2) x N_Subj (Static only)
%   NAN_SUB  - A vector of subject indices for which NaN values were detected
%              in the computed FC matrices (due to low-variance or missing data).
%
%   Dependencies:
%   - corrvec: Function to extract the unique upper-triangle elements of a matrix.
%   - xicor: Function to compute the Non-linear Xi correlation (if NL=1).
%
%   Author: Pratik Jain

nan_sub = [];
[T,ROI,sub] = size(reg_ts);

if nargin < 5
    nl = 0;
    if nargin < 4
        stride = 1;
        if nargin < 3
            win = T;
            stride = 1;
            if nargin < 2
                Z = 0;
            end
        end
    end
end
cor = zeros(ROI);
if Z == 1
    msg1 = 'With Fisher Z transform ..';
else
    msg1 = '..';
end
if win == T
    disp(['Creating Static map ',msg1]);
else
    disp(['Creating Dynamic map ',msg1]);
end
% x = 0;
% f = waitbar(x,msg);

if nl == 0
    for s = 1:sub
        p=1;
        for i1 = 1:stride:T-win+1
            cor(:,:,s) = corr(reg_ts(i1:i1+win-1,:,s));

            if nnz(isnan(cor(:,:,s)))
                disp('nan in')
                disp(s)
                nan_sub = [nan_sub,s];
            end
            if Z == 1
                cor(:,:,s) = 0.5*(log(1+cor(:,:,s))-log(1-cor(:,:,s)));
            end
            vec(:,p,s) = corrvec(cor(:,:,s));
            p=p+1;
        end
        % x = s/size(reg_ts,3);
        % waitbar(x,f)
    end
else
    parfor s = 1:sub
        temp1 = reg_ts(:,:,s);
        for i = 1:ROI
            for j = 1:ROI
                cor(i,j,s) = xicor(temp1(:,i),temp1(:,j),'symmetric',true);
            end
        end
        disp(s)
    end
    vec = corrvec(cor);
end
% close(f)
vec = squeeze(vec);
end