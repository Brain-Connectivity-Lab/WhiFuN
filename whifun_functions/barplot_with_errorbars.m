function mean_ = barplot_with_errorbars(data,names,s,nanflag,jit)
%BARPLOT_WITH_ERRORBARS Generates a bar plot with user-specified error bars
%   (Standard Deviation or Standard Error of the Mean) and optional data jitter.
%
%   MEAN_ = BARPLOT_WITH_ERRORBARS(DATA, NAMES, S, NANFLAG, JIT)
%
%   This function creates a bar graph showing the mean of the input data
%   and overlays error bars. It can handle numeric matrices for grouped
%   or ungrouped bars, or cell arrays where each cell contains data for a
%   single bar. Individual data points can optionally be plotted with jitter.
%
%   Input Arguments:
%   DATA      - The input data. Can be:
%               1. A numeric matrix (n x m or n x m x p): n=observations,
%                  m/p=variables/groups.
%               2. A cell array (m x p): Each cell contains a vector of
%                  observations for a single bar.
%   NAMES     - (Optional) A cell array of strings for x-axis tick labels.
%   S         - (Optional, default 1) Defines the error bar type:
%               S = 1: Standard Deviation (STD)
%               S = 2: Standard Error of the Mean (SEM)
%   NANFLAG   - (Optional, default 1) Flag to control NaN handling:
%               NANFLAG = 1: Exclude NaN values from mean/std calculation ('omitnan').
%               NANFLAG = 0: Include NaN values (will result in NaN mean/std if any NaN is present).
%   JIT       - (Optional, default 1) Flag to plot individual data points with jitter:
%               JIT = 1: Plot individual data points as black filled circles with jitter.
%               JIT = 0: Do not plot individual data points.
%
%   Output Arguments:
%   MEAN_     - The calculated mean value(s) plotted in the bar chart.
%
%   Example (Simple):
%      data = randn(50, 3);
%      names = {'Group 1', 'Group 2', 'Group 3'};
%      barplot_with_errorbars(data, names, 2, 1, 1); % SEM error bars, omit NaN, with jitter
%
%   Example (Cell Array - for unequal sample sizes):
%      data_cell = {randn(20, 1), randn(30, 1) + 1.5};
%      names = {'Control', 'Treated'};
%      barplot_with_errorbars(data_cell, names, 1, 1, 1); % STD error bars, with jitter
%
%   Author: Pratik Jain

if nargin <3
    s = 1;
    nanflag = 1;
end

if nargin <4
    nanflag = 1;
end

if ~exist('jit','var')
    jit = 1;
end

if isnumeric(data)
    [mean_,std_] = get_mean_std(data,nanflag,s);

elseif iscell(data)
    mean_ = zeros(size(data));
    std_ = zeros(size(data));
    for i1 = 1:size(data,1)
        for j1 = 1:size(data,2)
            
            [mean_(i1,j1),std_(i1,j1)] = get_mean_std(data{i1,j1},nanflag,s);
        end
    end
    
end

if size(size(data)) <= 2

%     figure;
    b = bar(mean_);
    hold on
    
    er.LineStyle = 'none';
    [ngroups,nbars] = size(mean_);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    if ngroups > 1
        for i = 1:nbars
            x(i,:) = b(i).XEndPoints;
        end
    else
        if size(data,1) < size(data,2)
            x = (1:nbars)';
        else
            x = 1:nbars;
        end
    end
    if iscell(data)
        for i = 1:size(data,1)
            for j = 1:size(data,2)
                if jit
                    scatter(x(j,i),data{i,j}','black','filled','jitter','on','JitterAmount',0.1)
     
                end
            end
        end
    elseif isnumeric(data)
        if jit
        scatter(1:size(data,2),data,'black','filled','jitter','on','JitterAmount',0.2)
        end
    end
    if exist("names","var")
        set(gca,'xtick',1:length(mean_),'xticklabel',names)
    end
    errorbar(x',mean_,std_,std_, 'LineWidth',3, 'MarkerSize',5,LineStyle = 'none',Color=[1,0,0],CapSize=15);
else
    b = bar(mean_, 'grouped');
    hold on
    % Calculate the number of groups and number of bars in each group
    [ngroups,nbars] = size(mean_);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    % Plot the errorbars
    errorbar(x',mean_,std_,std_,'k', 'LineWidth',3, 'MarkerSize',5,LineStyle = 'none',Color=[1,0,0],CapSize=15);
    hold off
    if exist("names","var")
        set(gca,'xtick',1:length(mean_),'xticklabel',names)
    end
end

function [mean_,std_] = get_mean_std(data,nanflag,s)

if nanflag == 1
    mean_ = squeeze(mean(data,'omitnan'));
else
    mean_ = squeeze(mean(data));
end

if s==1
    if nanflag == 1
        std_ = squeeze(std(data,'omitnan'));
    else
        std_ = squeeze(std(data));
    end
elseif s==2

    if nanflag == 1
        std_ = squeeze(std(data,'omitnan')/sqrt(size(data,1)));
    else
        std_ = squeeze(std(data)/sqrt(size(data,1)));
    end

end