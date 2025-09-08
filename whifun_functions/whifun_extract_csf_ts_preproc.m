function [Subj_list_1,out_csf_mat_path] = whifun_extract_csf_ts_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_mask_func_path,pca_for_temp_reg,n_pca,log_fileID,over_write)
% WHIFUN_EXTRACT_CSF_TS_PREPROC Extracts and preprocesses CSF time series data.
%
%   [Subj_list_1, out_csf_mat_path] = WHIFUN_EXTRACT_CSF_TS_PREPROC(...)
%   is a high-level function that manages the extraction of the
%   Cerebrospinal Fluid (CSF) signal from a functional scan. This time
%   series is often used as a nuisance regressor to reduce non-neuronal
%   signal in fMRI data.
%
%   The function first checks if a pre-existing CSF time series file
%   (e.g., `.mat` file) exists. Based on the `over_write` flag, it either
%   skips the process or calls the `whifun_extract_csf_ts` function to
%   perform the extraction. The function handles the option of performing
%   Principal Component Analysis (PCA) on the extracted time series.
%
%   The function updates the subject structure with the path to the
%   extracted CSF time series file and logs the process output to a file.
%   In case of an error, it catches the exception, updates the subject's
%   `error` flag, and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path  - Path to the quality control directory for logs.
%   Subj_list_1           - A single subject structure to be updated.
%   in_func_path          - The path to the functional NIfTI file.
%   in_csf_mask_func_path - The path to the CSF mask file in functional space.
%   pca_for_temp_reg      - A logical value (0 or 1) to indicate if PCA should
%                           be performed.
%   n_pca                 - The number of principal components to keep if PCA is
%                           performed.
%   log_fileID            - File ID of the log file for writing process output.
%   over_write            - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1      - The updated subject structure, with the CSF time series path.
%   out_csf_mat_path - The full path to the extracted CSF time series `.mat` file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_EXTRACT_CSF_TS, TRY, CATCH.

disp(['Extractation of CSF Timeseries has started for ' Subj_list_1.name])

try

    now_func_path = dir(in_func_path) ;
    now_csf_mask_func_path = dir(in_csf_mask_func_path) ;
    [~,name,~] = fileparts(now_csf_mask_func_path.name);
    out_csf_mat_path = fullfile(now_csf_mask_func_path.folder,['covariance_csf_' name '.mat']);
    
    out_csf_path = whifun_create_file(over_write,out_csf_mat_path);
    
    if isempty(out_csf_path)
        whifun_extract_csf_ts(fullfile(now_csf_mask_func_path.folder,now_csf_mask_func_path.name),now_func_path,pca_for_temp_reg,n_pca)
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'CSF timeseries extraction\n');
        fprintf(log_fileID,'%s',[' CSF timeseries extracted using the mask : ' in_csf_mask_func_path '\nfrom the functional data : ' in_func_path '.\nOutput is saved in : ' out_csf_mat_path]);
    else
        disp(['CSF Timeseries file found, hence skipping it for ' Subj_list_1.name])
    end
    Subj_list_1.nuisance_regression_csf_covariates = out_csf_mat_path;
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in CSF timeseries extraction for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    % Increament the error pointer

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
end
disp(['Extractation of CSF Timeseries is done for ' Subj_list_1.name])
