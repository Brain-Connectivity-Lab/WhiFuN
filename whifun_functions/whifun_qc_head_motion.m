function whifun_qc_head_motion(out_folder,realigned_func_native,name,max_fd,mean_fd,greater_than_20,over_write,motion_txt)
% WHIFUN_QC_HEAD_MOTION Generates a quality control figure for head motion.
%
%   WHIFUN_QC_HEAD_MOTION(out_folder, realigned_func_native, ..., motion_txt)
%   creates a comprehensive quality control report for head motion for a single
%   subject. The report consists of four plots combined into a single figure.
%
%   The function performs the following steps:
%   1.  **Check Existence**: It checks if a head motion QC image already exists
%       and, based on the `over_write` flag, either skips or generates a new
%       one.
%   2.  **Calculate Metrics**: It reads the realigned functional data and the
%       motion parameter file. It then calculates:
%       -   **Global Mean**: The scaled global signal mean over time.
%       -   **Pairwise Variance**: A measure of voxel-wise signal change
%           between consecutive time points.
%       -   **Framewise Displacement (FD)**: A composite measure of motion
%           combining translations and rotations.
%   3.  **Plotting**: It creates a figure with four subplots:
%       -   **Global Mean**: A plot of the scaled global mean over time.
%       -   **Pairwise Variance**: A plot of the pairwise variance with a
%           line indicating 3 standard deviations above the mean.
%       -   **Rigid Body Motion**: A plot of the 6 rigid body motion parameters
%           (3 translations and 3 rotations).
%       -   **Framewise Displacement**: A plot of the FD with lines showing
%           the thresholds used for quality control.
%   4.  **Export**: The figure is saved as a `.png` file in the specified
%       output folder.
%
%   Input Arguments:
%   out_folder             - The path to the quality control directory for saving the figure.
%   realigned_func_native  - The full path to the realigned functional file.
%   name                   - The subject's name.
%   max_fd                 - The maximum FD threshold.
%   mean_fd                - The mean FD threshold.
%   greater_than_20        - The FD threshold for the percentage of excluded volumes.
%   over_write             - (Optional) A logical value (0 or 1) to force overwriting.
%   motion_txt             - (Optional) A matrix of motion parameters to plot instead
%                            of reading from the `Subj_list_1.motion_txt` path.
%
%   Author: Pratik Jain
%   See also NIFTIREAD, RESHAPE, MEAN, PLOT, SUBPLOT, TITLE, LEGEND, EXPORTGRAPHICS.

if ~exist('over_write','var')
    over_write = 0; % Default value for over_write if not provided
end


now_func_path = dir(realigned_func_native) ;

out_head_qc = fullfile(out_folder,[name '.png']);

if ~exist(fileparts(out_head_qc),'dir')
    mkdir(fileparts(out_head_qc)); % Create output directory if it doesn't exist
end
head_mot_qc_file = whifun_create_file(over_write,out_head_qc);

if isempty(head_mot_qc_file)
    func_image = niftiread(fullfile(now_func_path.folder,now_func_path.name)); % Read the func file
    [x,y,z,nt] = size(func_image);                                             % get the size
    func_image = reshape(func_image,x*y*z,nt);                                 % Reshape into voxel x timepoints

    gm = mean(func_image,'all','omitnan');                                               % grand mean (4D)

    % calculate pairwise variance
    dt = zeros(1,nt-1);
    for imagei = 1:nt-1
        dt(imagei) = (mean((func_image(:,imagei) - func_image(:,imagei+1)).^2,'omitnan'))/gm;
    end

    meany = mean(func_image,'omitnan')./gm;                                              % scaled global mean
end

if ~isnumeric(motion_txt)

    now_func_path = dir(motion_txt) ;
    rp_rest = load(fullfile(now_func_path.folder,now_func_path.name));              % input the text file generated at the Realignment stage
else
    rp_rest = motion_txt;  % Load motion parameters
end

rp_diff_trans = diff(rp_rest(:,1:3));                      % The first 3 parameters tell the displacement in x,y, and z direction in mm. Here the vector difference operator is used to get the derivative of vector. (framewise difference)
%                 rp_diff_rotat = diff(rp_rest(:,4:6)*180/pi);             % % The last  3 parameters tell the rotation values pitch, yaw and roll in radians (here we convert them to degrees)
rp_diff_rotat = diff(rp_rest(:,4:6)*50);                   % Converting angles to mm by asuming a 50mm radius circle


fd = sum(rp_diff_trans,2) + sum(rp_diff_rotat,2)  ;

% plots
if isempty(head_mot_qc_file) || over_write == 1
    % f = figure('Position', get(0,'screensize'),'visible','off');
    f = gcf;
    clf(f)
    subplot(2,2,1)
    plot(meany)
    title('Global mean (raw)');xlabel('Image number')
    box off

    subplot(2,2,3)
    plot(dt)
    yline(mean(dt)+3*std(dt),'-','3 SD','color',[0 0.4470 0.7410]);
    title('Pairwise variance (raw)');xlabel('Image pair')
    box off

    subplot(2,2,2)
    plot([rp_rest(:,1:3) rp_rest(:,4:6)*180/pi])
    title('Rigid body motion');xlabel('Image number')
    legend('Trans: x','Trans: y','Trans: z','Rot: pitch','Rot: roll','Rot: yaw','location','best')
    box off

    subplot(2,2,4)
    plot(fd)
    title('Framewise displacement');xlabel('Image pair')
    yline(max_fd,'r')
    yline(greater_than_20,'k')
    yline(mean_fd,'y')
    legend('Framewise displacement','Max Threshold','Mean Threshold','Greater than 20% threshold','location','best','box','off')
    exportgraphics(f,out_head_qc);

end
disp(' ')
disp(['Head motion QC plot generated for Participant: ' name])
disp(['See : ' out_head_qc])
disp(' ')