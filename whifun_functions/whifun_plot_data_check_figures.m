function whifun_plot_data_check_figures(quality_control_path,n_image,tr,voxel_func,voxel_anat,mis_data)

% Plot all the parameters across participants
fh = figure('DefaultAxesFontSize',18,'Visible','off','Position',[0,0,2000,1000]);

subplot(4,1,1)
bar(n_image)
title('# of fMRI images')
box off

subplot(4,1,2)
bar(tr)
title('TR of fMRI images')
box off

subplot(4,1,3)
bar(voxel_func)
title('Voxel sizes of fMRI images')
legend({'x','y','z'})
box off

subplot(4,1,4)
bar(voxel_anat)
title('Voxel sizes of structrual images')
legend({'x','y','z'})
box off

exportgraphics(fh,fullfile(quality_control_path,'Q1a_scanning_parameters.png'));
clf(fh)
fh = figure('DefaultAxesFontSize',14,'Visible','off','Position',[0,0,2000,1000]);
fh.WindowState = 'maximized';


subplot(3,2,1)
histogram(n_image);
xlabel('Number of time points')
ylabel('Number of participants')

subplot(3,2,2)
histogram(tr);
xlabel('TR')
ylabel('Number of participants')

subplot(3,3,4)
histogram(voxel_func(:,1));
xlabel("Voxel 'x' dimension")
ylabel('Number of participants')

subplot(3,3,5)
histogram(voxel_func(:,2));
xlabel("Voxel 'y' dimension")
ylabel('Number of participants')
title({'' ;'Voxel sizes of fMRI images'})

subplot(3,3,6)
histogram(voxel_func(:,3));
xlabel("Voxel 'z' dimension")
ylabel('Number of participants')

subplot(3,3,7)
histogram(voxel_anat(:,1));
xlabel("Voxel 'x' dimension")
ylabel('Number of participants')

subplot(3,3,8)
histogram(voxel_anat(:,2));
xlabel("Voxel 'y' dimension")
ylabel('Number of participants')
title({'' ;'Voxel sizes of sMRI images'})

subplot(3,3,9)
histogram(voxel_anat(:,3));
xlabel("Voxel 'x' dimension")
ylabel('Number of participants')
sgtitle('Histograms of parameters acorss participants: Its ideal to have a single bar for all plots');

if mis_data == 1
    annstr = "Because there were missing files, the parameters corresponding to those are not mentioned";
    annpos = [0.02 0.9 0.1 0.1]; % annotation position in figure coordinates
    annotation('textbox',annpos,'string',annstr);
end
exportgraphics(fh,fullfile(quality_control_path,'Q1a_scanning_parameters_histogram.png'));