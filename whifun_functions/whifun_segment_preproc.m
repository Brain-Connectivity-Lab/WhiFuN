function [Subj_list_1,out_def_path,GM_native,WM_native,CSF_native,GM_MNI,WM_MNI,CSF_MNI] = whifun_segment_preproc(quality_control_path,Subj_list_1,in_anat_path,log_fileID,over_write)
% WHIFUN_SEGMENT_PREPROC Orchestrates SPM-based anatomical segmentation.
%
%   [Subj_list_1, out_def_path] = WHIFUN_SEGMENT_PREPROC(quality_control_path, ..., over_write)
%   is a high-level function that manages the anatomical segmentation and
%   normalization step using SPM.
%
%   This function first checks for and resolves any ambiguity in the input
%   anatomical file. It then checks if the core output (the deformation
%   field file, prefixed with 'y_') already exists. Based on the `over_write`
%   flag, it either skips the segmentation or proceeds by calling the
%   `whifun_segment` function.
%
%   After the segmentation job, the function updates the subject structure
%   with the paths to all the generated files, including:
%   - Bias-corrected anatomical image (`m...`)
%   - Gray, White, and CSF segments in both native (`c1...`, `c2...`, `c3...`)
%     and MNI space (`wc1...`, `wc2...`, `wc3...`)
%   - The deformation field (`y...`)
%
%   In case of an error, the function catches the exception, updates the
%   subject's `error` flag, and logs the detailed error information to a file.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_anat_path         - The path to the input anatomical NIfTI file.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1  - The updated subject structure with all new file paths.
%   out_def_path - The full path to the forward deformation field file.
%
%   Author: Pratik Jain
%   See also WHIFUN_MULTIPLE_FILE_FOUND, WHIFUN_CREATE_FILE, WHIFUN_SEGMENT, TRY, CATCH.

disp(['Segmentation has started for ' Subj_list_1.name])
spm_path = fileparts(which('spm'));
if isempty(spm_path)
    error('SPM not found');
end
try

    now_anat_path = dir(in_anat_path) ;
    
    if length(now_anat_path) > 1

        now_anat_path = whifun_multiple_file_found(now_anat_path,anat_func);
    end
    out_def_path = fullfile(now_anat_path.folder,['y_' now_anat_path.name]);
    y_banat_path = whifun_create_file(over_write,out_def_path);
    
    if isempty(y_banat_path)
        seg_op = whifun_segment(now_anat_path,spm_path);

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Segmentation\n');
        fprintf(log_fileID,'%s',  seg_op);

    else
        disp(['Segmentation file found for ' Subj_list_1.name,'  hence skipping this step']);
    end

    Subj_list_1.bias_corrected_anat_native = fullfile(now_anat_path.folder,['m' now_anat_path.name]);
    GM_native = fullfile(now_anat_path.folder,['c1' now_anat_path.name]);
    Subj_list_1.GM_native = GM_native;
    WM_native = fullfile(now_anat_path.folder,['c2' now_anat_path.name]);
    Subj_list_1.WM_native = WM_native;
    CSF_native = fullfile(now_anat_path.folder,['c3' now_anat_path.name]);
    Subj_list_1.CSF_native = CSF_native;
    GM_MNI = fullfile(now_anat_path.folder,['wc1' now_anat_path.name]);
    Subj_list_1.GM_MNI = GM_MNI;
    WM_MNI = fullfile(now_anat_path.folder,['wc2' now_anat_path.name]);
    Subj_list_1.WM_MNI = WM_MNI;
    CSF_MNI = fullfile(now_anat_path.folder,['wc3' now_anat_path.name]);
    Subj_list_1.CSF_MNI = CSF_MNI;
    Subj_list_1.deformation_field = out_def_path;

catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Segmentation for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display

    return
end
disp(['Segmentation done for ' Subj_list_1.name])
