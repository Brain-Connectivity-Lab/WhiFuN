function [Subj_list_1,out_func_path,out_func_mask_path] = whifun_nuisance_regress_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_mask_subj_space_path,Reg_pre,n_pca,in_csf_mat_path,in_motion_txt_path,log_fileID,over_write) %#ok<INUSD>
% WHIFUN_NUISANCE_REGRESS_PREPROC Orchestrates nuisance regression.
%
%   [Subj_list_1, out_func_path] = WHIFUN_NUISANCE_REGRESS_PREPROC(...)
%   is a high-level function that manages the nuisance regression step of a
%   neuroimaging preprocessing pipeline. It automates the process of removing
%   unwanted signals from the functional data, such as head motion artifacts
%   and physiological noise.
%
%   The function first checks if a pre-regressed file already exists. Based
%   on the `over_write` flag, it either skips the process or calls the
%   `whifun_regress` function to perform the actual regression. This utility
%   function ensures that the regression is performed only when needed.
%
%   The function updates the subject structure with the path to the newly
%   regressed functional file and logs the process output to a file. In case
%   of an error, it catches the exception, updates the subject's `error`
%   flag, and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path    - Path to the quality control directory for logs.
%   Subj_list_1             - A single subject structure to be updated.
%   in_func_path            - Path to the input functional file.
%   in_anat_mask_subj_space_path - Path to the anatomical mask file.

%   Reg_pre                 - The prefix for the output regressed file.
%   n_pca                   - Number of PCA components for CSF regression.
%   in_csf_mat_path         - Path to the CSF time series `.mat` file.
%   in_motion_txt_path      - Path to the motion parameter `.txt` file.
%   log_fileID              - File ID of the log file.
%   over_write              - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1   - The updated subject structure, with the `nuisance_regressed` field.
%   out_func_path - The full path to the regressed functional file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_REGRESS, TRY, CATCH.


disp(['Nuisance Regression is started for ' Subj_list_1.name])


try
    now_func_path = dir(in_func_path) ;
    % now_anat_path = dir(in_anat_mask_subj_space_path) ;
    
    out_func_path = fullfile(now_func_path.folder,[Reg_pre,now_func_path.name]);

    Reg_dir = whifun_create_file(over_write,out_func_path);
    
    if isempty(Reg_dir)
        reg_op = evalc('out_func_mask_path = whifun_regress(in_func_path,in_anat_mask_subj_space_path,in_csf_mat_path,in_motion_txt_path,out_func_path,n_pca)');
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Nuisance Regression\n');
        fprintf(log_fileID,'%s',  reg_op);
    else
        disp(['Nuisance Regression file found, hence skipping this step for ' Subj_list_1.name]);
        out_func_mask_path = fullfile(now_func_path.folder,['func_mask_' now_func_path.name]);
    end
    Subj_list_1.before_nuisance_regressed_func_native = in_func_path;
    Subj_list_1.nuisance_regressed_func_native = out_func_path;
    Subj_list_1.func_mask_native = out_func_mask_path; 
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Temporal Regression for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
    out_func_mask_path = [];
end
disp(['Nuisance REGRESSION is done for ' Subj_list_1.name])