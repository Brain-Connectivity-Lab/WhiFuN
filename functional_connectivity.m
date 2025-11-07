%% Written by Pratik Jain
%% Calculates Functional connectivity of given averaged ROI timeseries 


function [vec,nan_sub] = functional_connectivity(reg_ts,Z,win,stride,nl)

% reg_ts Timeseries of each ROI   T x ROI x sub
% win  window size for DFC
% stride for DFC
% nl = 1  Use Non linear FC
%    = 0  Use pearson correlation (default)
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
    msg = ['Creating Static map ',msg1];
else
    msg = ['Creating Dynamic map ',msg1];
end
x = 0;
f = waitbar(x,msg);

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
    x = s/size(reg_ts,3);
    waitbar(x,f) 
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
close(f)
vec = squeeze(vec);
end