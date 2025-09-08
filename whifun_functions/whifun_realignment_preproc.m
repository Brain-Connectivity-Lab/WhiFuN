function [Subj_list_1,out_func_path,out_motion_txt_path] = whifun_realignment_preproc(quality_control_path,Subj_list_1,in_func_path,Realign_pre,log_fileID, over_write)
% WHIFUN_REALIGNMENT_PREPROC Performs motion correction (realignment) on functional data.
%
%   [Subj_list_1, out_func_path, out_motion_txt_path] = WHIFUN_REALIGNMENT_PREPROC(...)
%   is a high-level function that orchestrates the realignment step of fMRI
%   preprocessing. Realignment corrects for head motion that occurs during
%   a scan.
%
%   The function first checks for and resolves multiple input files. It then
%   determines the output file path and, based on the `over_write` flag,
%   decides whether to perform the realignment or skip it if the output
%   file already exists. It calls a sub-function `whifun_realignment` to
%   execute the SPM-based realignment. The function updates the subject
%   structure with the paths to the realigned file and the motion parameters
%   file. All process output is logged to a specified file.
%
%   In case of an error, the function catches the exception, updates the
%   subject's error flag, and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path  - Path to the quality control directory for logs.
%   Subj_list_1           - A single subject structure to be updated.
%   in_func_path          - The path to the input functional NIfTI file.
%   Realign_pre           - The prefix to use for the output realigned file.
%   log_fileID            - File ID of the log file for writing process output.
%   over_write            - (Optional) A logical value (0 or 1) to force
%                           overwriting the output files. Defaults to 0.
%
%   Output Arguments:
%   Subj_list_1         - The updated subject structure with `realigned` and
%                         `motion_txt` fields.
%   out_func_path       - The full path to the realigned functional file.
%   out_motion_txt_path - The full path to the motion parameter `.txt` file.
%
%   Author: Pratik Jain
%   See also WHIFUN_MULTIPLE_FILE_FOUND, WHIFUN_CREATE_FILE, WHIFUN_REALIGNMENT, TRY, CATCH.


if ~exist("over_write",'var')
    over_write = 0 ;
end
disp(['Realignment Begins for ' Subj_list_1.name])

try
    now_func_path = dir(in_func_path);
    if length(now_func_path) > 1
        now_func_path = whifun_multiple_file_found(now_func_path,'functional');
    end
    out_func_path = fullfile(now_func_path.folder,[Realign_pre,now_func_path.name]);
    % Check if any previous realignment file exists
    rfunc_dir = whifun_create_file(over_write,out_func_path);


    if isempty(rfunc_dir)

        cd(now_func_path.folder)
        temp = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));
        nt = temp.ImageSize(4);

        if nt == 0
            error(['No. of timepoints is 0 for func file : ' fullfile(now_func_path.folder,now_func_path.name)] )
        end
        realignment_op = whifun_realignment(now_func_path,Realign_pre,nt);

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Realignment\n');
        fprintf(log_fileID,'%s',  realignment_op);
    else
        disp(['Participant ' Subj_list_1.name ' is already realigned hence skipping this step'])

    end
    func_name_wo_ext = strsplit(now_func_path.name,'.');
    out_motion_txt_path = fullfile(now_func_path.folder,['rp_' func_name_wo_ext{1} '.txt']) ;
    Subj_list_1.motion_txt = out_motion_txt_path;
    Subj_list_1.realigned_func_native = out_func_path;



catch exception                                                                       % If error is found
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Realignment for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display

    return
end
disp(['Realignment over for ' Subj_list_1.name])