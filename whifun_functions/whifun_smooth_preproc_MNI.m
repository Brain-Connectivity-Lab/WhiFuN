function [Subj_list_1,out_func_path] = whifun_smooth_preproc_MNI(quality_control_path,Subj_list_1,in_func_path,GM_path,WM_path,WM_GM,smooth_fwhm,Smooth_pre,log_fileID,over_write)

% WHIFUN_SMOOTH_PREPROC Performs spatial smoothing on functional data.
%
%   [Subj_list_1, out_func_path] = WHIFUN_SMOOTH_PREPROC(...) is a high-level
%   function that manages the spatial smoothing step of fMRI preprocessing.
%   Smoothing increases the signal-to-noise ratio and allows for inter-subject
%   comparisons. The function supports two types of smoothing:
%
%   1.  **Separate Smoothing (WM/GM)**: If the `WM_GM` flag is true (1), the
%       function calls `whifun_smooth_WM_GM_separately_fast` to smooth the
%       White Matter and Gray Matter regions independently. This can be
%       beneficial for preserving tissue-specific boundaries.
%   2.  **Joint Smoothing**: If `WM_GM` is false (0), the function calls
%       `whifun_smooth_together` to apply a single smoothing kernel to the
%       entire brain.
%
%   The function first checks if a smoothed file already exists and, based on
%   the `over_write` flag, either skips the process or proceeds. It logs all
%   process outputs and, in case of an error, catches the exception, updates
%   the subject's `error` flag, and logs the detailed error information to a
%   file.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path         - The path to the input functional file.
%   GM_path              - Path to the Gray Matter segmented file 
%   WM_path              - Path to the White Matter segmented file 
%   WM_GM                - A logical value (0 or 1). If 1, smooth WM and GM separately.
%   smooth_fwhm          - The FWHM (Full Width at Half Maximum) of the smoothing kernel.
%   Smooth_pre           - The prefix for the output smoothed file.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1   - The updated subject structure, with the `smoothed` file path.
%   out_func_path - The full path to the smoothed functional file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_SMOOTH_WM_GM_SEPARATELY_FAST, WHIFUN_SMOOTH_TOGETHER, TRY, CATCH.


now_func_path = dir(in_func_path);
out_func_path = fullfile(now_func_path.folder,[Smooth_pre now_func_path.name]);

smooth_path = whifun_create_file(over_write,out_func_path);
if WM_GM == 1

    disp(['Smoothing White matter and Gray Matter Seperately for ' Subj_list_1.name])

    try

        if isempty(smooth_path)

            whifun_smooth_WM_GM_separately_fast_MNI_sub_sep(in_func_path, GM_path, WM_path ,Smooth_pre, smooth_fwhm, over_write);
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Smoothing White Matter and Gray Matter seperately convn\n');
            % fprintf(log_fileID,'Gray Matter Smoothing\n');
            % fprintf(log_fileID,'%s',  smooth_op_gm);
            % fprintf(log_fileID,'White Matter Smoothing\n');
            % fprintf(log_fileID,'%s',  smooth_op_wm);
        else
            disp(['Smoothing file found, hence skipping this step for ' Subj_list_1.name]);
        end
        Subj_list_1.smoothed_func = out_func_path;
    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Smoothing WM GM seperately for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
        write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
        return

    end

else
    disp('Smoothing White matter and Gray Matter together')


    try
        
        if isempty(smooth_path)
            nt = Subj_list_1.nt_dis;

            smooth_op = whifun_smooth_together(nt,now_func_path,smooth_fwhm,Smooth_pre);
            fprintf(log_fileID,'#####################################################################################################################\n \n');
            fprintf(log_fileID, 'Smoothing White Matter and Gray Matter together\n');
            fprintf(log_fileID,'%s',  smooth_op);

        else
            disp(['Smoothing file found, hence skipping this step for ' Subj_list_1.name]);
        end
        Subj_list_1.smoothed_func = out_func_path;

    catch exception
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Smoothing for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
        write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
        return
    end

end