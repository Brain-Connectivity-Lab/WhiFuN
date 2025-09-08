function Subj_list_1 = whifun_fd_preproc(quality_control_path,Subj_list_1,in_motion_txt_path,max_fd,mean_fd,greater_than_20)
% WHIFUN_FD_PREPROC Performs quality control based on framewise displacement.
%
%   Subj_list_1 = WHIFUN_FD_PREPROC(quality_control_path, Subj_list_1, ..., greater_than_20)
%   calculates the framewise displacement (FD) and assesses whether a
%   subject's head motion exceeds predefined quality control thresholds.
%
%   The function first computes the FD using the motion parameters. It then
%   applies three checks:
%   1.  **Maximum FD**: Is the maximum FD value greater than `max_fd`?
%   2.  **Mean FD**: Is the mean FD value greater than `mean_fd`?
%   3.  **Percentage of high-motion volumes**: Is the percentage of volumes
%       with FD greater than `greater_than_20` more than 20%?
%
%   If any of these conditions are met, the subject is flagged for exclusion
%   by setting `Subj_list_1.motion_ex` to 1. The function also generates a
%   report in a text file within the quality control directory, detailing
%   why the subject was excluded. If the subject passes all checks, the
%   report file is deleted.
%
%   Input Arguments:
%   quality_control_path - The path to the quality control directory.
%   Subj_list_1          - A single subject structure to be updated.
%   in_motion_txt_path   - The path to the motion parameter `.txt` file.
%   max_fd               - The maximum FD threshold for exclusion.
%   mean_fd              - The mean FD threshold for exclusion.
%   greater_than_20      - The FD threshold for calculating the percentage of
%                          volumes with high motion.
%
%   Output Arguments:
%   Subj_list_1 - The updated subject structure. The `motion_ex` field will
%                 be set to 1 if the subject fails any of the motion checks.
%
%   Author: Pratik Jain
%   See also WHIFUN_CALCULATE_FD, MAX, MEAN, FOPEN, FPRINTF, FCLOSE.
%% 5 Framewise displacement
disp(['Framewise Displacement Begins for ' Subj_list_1.name])


fd = whifun_calculate_fd(in_motion_txt_path);
[fd_max,loc_fd_max_trans] = max(fd);                     % Get the maximum framewize displacement
fd_mean = mean(fd);                                               % Get the mean framewize displacement
fd_greater_than_20 = nnz(abs(fd)>greater_than_20)/length(fd)*100;

out_path = fullfile(quality_control_path,'b_Head_motion');
if ~exist(out_path,'dir')
    mkdir(out_path);  % Create the directory for head motion reports
end

fileID = fopen(fullfile(quality_control_path,'b_Head_motion',['excluded_' Subj_list_1.name '_.txt']),'w+');

if abs(fd_max) > max_fd
    msg = ['Excluded participant ' Subj_list_1.name ' as it had max motion at location ' ...
        num2str(loc_fd_max_trans) ' of ' num2str(fd_max) ' which is greater than ' num2str(max_fd) ' mm max threshold'];
    disp(msg) ;
    fprintf(fileID, [msg '\n']);
    Subj_list_1.motion_ex = 1;
end

if abs(fd_mean) > mean_fd
    msg = ['Excluded participant ' Subj_list_1.name ' as it had mean fd motion ',...
        'of ' num2str(fd_mean) ' which is greater than ' num2str(mean_fd) ' mm mean threshold'];
    disp(msg) ;
    fprintf(fileID, [msg '\n']);
    Subj_list_1.motion_ex = 1;
end

if fd_greater_than_20 > 20
    msg = ['Excluded participant ' Subj_list_1.name ' as it had ',num2str(fd_greater_than_20) ' percent of fMRI volumes (timepoints) ',...
        'greater than ' num2str(greater_than_20) ' threshold'];
    disp(msg) ;
    fprintf(fileID, [msg '\n']);

    Subj_list_1.motion_ex = 1;
end

if Subj_list_1.motion_ex == 1
    fclose(fileID);
    return
else
    fclose(fileID);
    delete(fullfile(quality_control_path,'b_Head_motion',['excluded_' Subj_list_1.name '_.txt']))
end

disp(['Framewise displacement over for ' Subj_list_1.name])