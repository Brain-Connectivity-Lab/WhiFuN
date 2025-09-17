function Subj_list_1  = whifun_coreg_preproc(quality_control_path,Subj_list_1,in_func_path_bef,in_func_path_after,in_anat_path,log_fileID,over_write,no_mean_func)
% WHIFUN_COREG_PREPROC Orchestrates SPM-based anatomical-functional coregistration.
%
%   Subj_list_1 = WHIFUN_COREG_PREPROC(quality_control_path, ..., over_write)
%   is a high-level function that manages the coregistration step of a
%   neuroimaging preprocessing pipeline. Coregistration is the process of
%   aligning a subject's functional scans to their high-resolution
%   anatomical scan.
%
%   The function first checks if a coregistration has already been performed
%   by comparing the transformation matrices of the input and image before realigned
%   functional files. If they are different or `over_write` is enabled, it
%   proceeds. The function then calls `whifun_coreg` to perform the actual
%   SPM coregistration job. The new file paths are implicitly handled by SPM.
%   The process output is logged to a specified file.
%
%   In case of an error, the function catches the exception, updates the
%   subject's `error` flag, and logs the detailed error information to a file.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path_bef     - Path to the functional file *before* coregistration.
%   in_func_path_after   - Path to the functional file *after* coregistration.
%   in_anat_path         - Path to the anatomical file.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1 - The updated subject structure, showing any errors found using the error flag.
%
%   Author: Pratik Jain
%   See also WHIFUN_COREG, NIFTIINFO, TRY, CATCH.

if ~exist("no_mean_func","var")
    no_mean_func = 0;
end

disp(['Coregisteration has started for ' Subj_list_1.name])

try

    now_anat_path = dir(in_anat_path) ;
    now_func_path_bef = dir(in_func_path_bef) ;
    now_func_path = dir(in_func_path_after) ;
    if over_write == 1
        coreg_dir = [];
    else
        cut_func_header = niftiinfo(fullfile(now_func_path_bef.folder,now_func_path_bef.name));
        realign_func_header = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));

        if prod(cut_func_header.Transform.T == realign_func_header.Transform.T,'all')
            coreg_dir = [];
        else
            coreg_dir = 1;
        end
    end
    
    if isempty(coreg_dir)


        if no_mean_func
            mean_func = [];
        else
            mean_func = dir(fullfile(now_func_path_bef.folder,['mean' now_func_path_bef.name])) ;
        end

        func_info = niftiinfo(in_func_path_after);
        nt = func_info.ImageSize(4);
        coreg_op = whifun_coreg(now_anat_path,now_func_path,mean_func,nt);

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Coregisteration\n');
        fprintf(log_fileID,'%s',  coreg_op);
    else
        disp(['Co-registeration file found, hence skipping this step for ' Subj_list_1.name]);
    end

    Subj_list_1.coregistered_func_native = in_func_path_after;
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Coregisteration for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
    return
end