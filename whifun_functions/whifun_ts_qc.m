function whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,func_path,motion_txt_path,pre_,num_erosions,Par_name,over_write,f)

% For deep wm mask creation
if ~exist("num_erosions",'var')
    num_erosions = 4;
end
out_pre = 'deep_';

now_mask_path = dir(WM_mask_path);

if create_mask(over_write,WM_mask_path,[out_pre 'num_er_' num2str(num_erosions) now_mask_path.name])
    whifun_erode(WM_mask_path,num_erosions,out_pre)
end
deep_WM_mask_path = fullfile(now_mask_path.folder,[out_pre 'num_er_' num2str(num_erosions) now_mask_path.name]);
[all_ts,n_gm,n_wm,n_deep_wm,n_csf] = whifun_ts_extract(GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,func_path,pre_,over_write);

fd = whifun_calculate_fd(func_path,motion_txt_path);

%%
if ~exist('f','var')
    f = figure;
end
nT = length(fd);  % number of timepoints

% Shift factor to leave space for title
shiftDown = 0.0001;
% Create some axes inside the figure
% First subplot (1/10 height, on top, shifted down)
ax1 = axes('Position',[0.1 0.85-shiftDown 0.85 0.1],'Parent',f); 
plot(ax1, 1:nT, fd);  
xlim(ax1, [1 nT]);
set(ax1,'XTickLabel',[]); % hide x-axis labels
ylabel(ax1,'FD');

% Second subplot (8/10 height, below it, shifted down)
ax2 = axes('Position',[0.1 0.1 0.85 0.75-shiftDown],'Parent',f); 
imagesc(ax2,1:nT, 1:(n_gm+n_wm+n_deep_wm+n_csf), all_ts);  
colormap(ax2, gray);
xlim(ax2, [1 nT]);
xlabel(ax2,'Time');
ylabel(ax2,'Voxels');

% Add category labels at midpoints
yticks(ax2, [ ...
    n_gm/2, ...
    n_gm + n_wm/2, ...
    n_gm + n_wm + n_deep_wm/2, ...
    n_gm + n_wm + n_deep_wm + n_csf/2 ]);
yticklabels(ax2, {['GM, n_{gm} = ' num2str(n_gm) ],['Sup WM, n_{sup_{wm}} = ' num2str(n_wm) ],['Deep WM, n_{deep_{wm}} = ' num2str(n_deep_wm) ],['CSF, n_{csf} = ' num2str(n_csf) ]});

% Add horizontal separator lines
hold(ax2, 'on');
yline(ax2, n_gm+0.5, 'r', 'LineWidth', 1.5);
yline(ax2, n_gm+n_wm+0.5, 'r', 'LineWidth', 1.5);
yline(ax2, n_gm+n_wm+n_deep_wm+0.5, 'r', 'LineWidth', 1.5);
hold(ax2, 'off');

% Link x-axes
linkaxes([ax1, ax2], 'x');

% Figure title (now with space at very top)
annotation(f,'textbox', [0 0.92 1 0.06], ...
    'String', ['Framewise Displacement and Voxel Time Series Participant: ' Par_name], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', ...
    'FontSize', 14);
end
function out = create_mask(over_write,mask_path,mask_name)

if over_write
    out = [];
else
    now_mask_path = dir(mask_path);
    out = dir(fullfile(now_mask_path.folder,mask_name));
end
if ~isempty(out)
    out = 0;
else
    out = 1;
end
end