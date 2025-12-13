function [Subj_list_1,out_csf_mask_func_path] = whifun_csf_mask_extraction_preproc(quality_control_path,Subj_list_1,in_func_path,in_csf_tpm_path,CSF_thres,log_fileID,over_write)

% WHIFUN_CSF_MASK_EXTRACTION_PREPROC Creates a CSF mask in functional space.
%
%   [Subj_list_1, out_csf_mask_func_path] = WHIFUN_CSF_MASK_EXTRACTION_PREPROC(...)
%   is a high-level function that manages the creation of a Cerebrospinal Fluid (CSF)
%   mask in the functional image's native space. This mask is often used to
%   extract a mean CSF signal for nuisance regression.
%
%   The function first checks for the input functional file and the CSF tissue
%   probability map (TPM). It then determines the output file path for the
%   CSF mask and, based on the `over_write` flag, either skips the process
%   or proceeds by calling `whifun_create_csf_mask`.
%
%   The function updates the subject structure with the path to the newly
%   created CSF mask and logs the process output to a file. In case of an
%   error, it catches the exception, updates the subject's `error` flag,
%   and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path         - The path to the input functional NIfTI file.
%   in_csf_tpm_path      - The path to the CSF tissue probability map (TPM).
%   CSF_thres            - A numerical value representing the probability
%                          threshold for including a voxel in the CSF mask.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1            - The updated subject structure, with the `CSF_mask_func` field.
%   out_csf_mask_func_path - The full path to the created CSF mask file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_CREATE_CSF_MASK, TRY, CATCH.


disp(['CSF_MASK extractation has started for ' Subj_list_1.name])

try

    now_func_path = dir(in_func_path) ;
    now_csf_tpm_path = dir(in_csf_tpm_path) ;

    out_csf_mask_func_path = fullfile(now_func_path.folder,['CSF_MASK_' char(CSF_thres) '_' now_func_path.name]);
    csf_mask_path = whifun_create_file(over_write,out_csf_mask_func_path);

    if isempty(csf_mask_path)
        csf_mask_op = whifun_create_csf_mask(fullfile(now_csf_tpm_path.folder,now_csf_tpm_path.name),now_func_path,CSF_thres);
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'CSF Mask\n');
        fprintf(log_fileID,'%s',  csf_mask_op);


    else
        disp(['CSF_MASK file found, hence skipping this step for ' Subj_list_1.name]);
    end
    Subj_list_1.CSF_mask_func = out_csf_mask_func_path;

catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in CSF_Mask extraction for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
    return
end
disp(['CSF_MASK extraction is done for ' Subj_list_1.name])