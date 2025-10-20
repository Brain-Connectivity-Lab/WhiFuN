function whifun_clean_up_after_preprocessing(Subj_list_1,log_file_id)
%WHIFUN_CLEAN_UP_AFTER_PREPROCESSING Manages the deletion of temporary and intermediate
%   files generated during the anatomical and functional preprocessing steps for a single subject.
%
%   WHIFUN_CLEAN_UP_AFTER_PREPROCESSING(SUBJ_LIST_1, LOG_FILE_ID)
%
%   This function serves as a wrapper to systematically call a lower-level cleanup
%   function (`whifun_clean_up_folder`) for the main anatomical and functional
%   data directories of a given subject, logging the process.
%
%   Input Arguments:
%   SUBJ_LIST_1 - A structure containing subject-specific paths, including:
%                 - SUBJ_LIST_1.anat_folder: Full path to the subject's anatomical data folder.
%                 - SUBJ_LIST_1.func_folder: Full path to the subject's functional data folder.
%   LOG_FILE_ID - The file identifier (FID) of the log file opened for writing,
%                 where messages about the cleanup process will be recorded.
%
%   Dependencies:
%   - `whifun_clean_up_folder`: A separate function responsible for the actual
%     file deletion logic within a specified folder.
%
%   Author: Pratik Jain
msg = '---------------------------------------------------Anat Clean up------------------------------------------------------------------\n';

fprintf(log_file_id,msg);
fprintf(msg);

% anat
whifun_clean_up_folder(Subj_list_1.anat_folder,log_file_id)

msg = '---------------------------------------------------func Clean up------------------------------------------------------------------\n';

fprintf(log_file_id,msg);
fprintf(msg);

%func
whifun_clean_up_folder(Subj_list_1.func_folder,log_file_id)

end

