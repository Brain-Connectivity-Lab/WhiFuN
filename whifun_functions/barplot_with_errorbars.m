function barplot_with_errorbars(data,names,s,nanflag)

%% inputs
% data --> data matrix with size n x m , n--> number of observations,
%          m --> no. of variables
% names --> cell containing the names you want to put on the x-axis
% s --> variable telling what to show in error bars
%         if s==1 --> std deviation (default)
%            s==2 --> standard error of the mean

% eg. names = {'Vehicle','LHRH'};

if nargin <3
    s = 1;
    nanflag = 1;
end

if nargin <4
    nanflag = 1;
end


if isnumeric(data)
    [mean_,std_] = get_mean_std(data,nanflag,s);

elseif iscell(data)
    mean_ = zeros(1,length(data));
    std_ = zeros(1,length(data));
    for i = 1:length(data)
        [mean_(i),std_(i)] = get_mean_std(data{i},nanflag,s);
    end
    
end

if size(size(data)) <= 2

%     figure;
    b = bar(mean_);
    hold on
    
    er.LineStyle = 'none';
    if iscell(data)
        for i = 1:length(data)
            scatter(i,data{i}','black','filled','jitter','on','JitterAmount',0.1)
        end
    elseif isnumeric(data)
        scatter(1:size(data,2),data,'black','filled','jitter','on','JitterAmount',0.2)
    end
    if exist("names","var")
        set(gca,'xtick',1:length(mean_),'xticklabel',names)
    end
    errorbar(1:length(mean_),mean_,std_,std_, 'LineWidth',3, 'MarkerSize',5,LineStyle = 'none',Color=[1,0,0],CapSize=15);
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