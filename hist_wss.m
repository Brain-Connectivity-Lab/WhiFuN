function [Overlap_Area,min_cut_off]  = hist_wss(corr_mat,ses,d,min_cut_off)%Overlapp_Area %[max_bss,min_wss]

%% Input
%           corr_mat = Correlation matrix 
%           ses = No of sessions per subject
%           d = 1                                 Normalization of histogram to pdf
%             = 2                                 No normalization

if nargin <=2
    d = 2;  
end

mask_wss = zeros(size(corr_mat));                % mask for within subject initialised by 0 
% ses_idx = 1:ses:size(corr_mat,1);                % session index (will be used to create the mask) (It picks the 1st session of every subject)

for i = 1:ses:size(corr_mat,1)                   % for every session index
    mask_wss(i:i+ses-1,i:i+ses-1) = ones(ses);   % make all the blocks of diagonals with same subject 1
end
mask_bss = logical(1-mask_wss);                  % The opposite of this will be the mask for between subject mask

% for i = 1:size(corr_mat,1)                       % Make the diagonal elements 0 (As they are self correlations which will be 1)
%     mask_wss(i,i) = 0;
% end
mask_wss = logical(mask_wss);                    % Change data type to logical

max_bss = max(corr_mat(mask_bss),[],'all');      % get the maximum value in between subjects ( Usually between subjects correlation value should be as small as possible, hence here we are taking the maximum to understand how much it the extent)
min_wss = min(corr_mat(mask_wss),[],'all');     % get the minimum value in with subject ( Usually within subjects value should be as large as possible, hence we take minimum here to see the lowest possible value )

a_wss = corr_mat(mask_wss);                     % Only wss values 
% overlap_wss = nnz(a_wss(a_wss < max_bss));     
% 
a_bss = corr_mat(mask_bss);                     % Only bss values
% overlap_bss = nnz(a_bss(a_wss > min_wss));
if nargin <= 3                                    % if no cutoff specified than we have to find the cutoff
    
p = 1;                                            % counter variable will be used to find overlap
if min_wss < max_bss                              % if min of wss is less than max of bss there is a overlapp and the optimum threshold has to be found
cutoff = min_wss:0.01:max_bss;                    % We will search the cutoff that gives the minimum error in this range
else 
    cutoff = (min_wss + max_bss)/2;               % else there is no overlap, putting the cuttoff in the middle of the two
end

Overlapp = zeros(length(cutoff),1);               % initialising the overlapp variable
for cut_off = cutoff                              % for all values of cutoff
    overlap_wss = nnz(a_wss(a_wss < cut_off));    % Look how many are in error for wss
    overlap_bss = nnz(a_bss(a_bss > cut_off));    % Look how many are in error for bss

    Overlapp(p) = overlap_wss + overlap_bss;      % Overlap at that cutoff is the addition of the both found above
    p = p+1;                                      % increment the counter
end
[Overlap_Area,ids] = min(Overlapp);               % The minimum Overlap 
min_cut_off = cutoff(ids);                        % Cutoff for the minimum overlap

else                                                  % just use the specified cutoff
    overlap_wss = nnz(a_wss(a_wss < min_cut_off));    % Look how many are in error for wss
    overlap_bss = nnz(a_bss(a_bss > min_cut_off));    % Look how many are in error for bss

    Overlap_Area = overlap_wss + overlap_bss;      % Overlap at that cutoff is the addition of the both found above
end
% figure;
if d == 1
h1 = histogram(corr_mat(mask_wss),'DisplayStyle','stairs','Normalization','pdf'); % Ploting normalised histogram for wss
hold on
h2 = histogram(corr_mat(mask_bss),'DisplayStyle','stairs','Normalization','pdf'); % Ploting normalised histogram for bss
legend('wss','bss')
xline(min_cut_off,'--r')                                                          % Putting a verticle line at the cutoff

else 
h1 = histogram(corr_mat(mask_wss),'DisplayStyle','stairs');                       % Ploting normalised histogram for wss
hold on
h2 = histogram(corr_mat(mask_bss),'DisplayStyle','stairs');                       % Ploting normalised histogram for bss
legend('wss','bss')
xline(min_cut_off,'--r')                                                          % Putting a verticle line at the cutoff
end
% cut_off = ginput(1);

% cut_off = cut_off(1);

% a_wss = corr_mat(mask_wss);
% overlap_wss = nnz(a_wss(a_wss < cut_off));
% 
% a_bss = corr_mat(mask_bss);
% overlap_bss = nnz(a_bss(a_bss > cut_off));
% 
% Overlapp_Area = overlap_wss + overlap_bss;
end