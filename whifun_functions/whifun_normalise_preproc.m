function [Subj_list_1,out_func_path,out_anat_path] = whifun_normalise_preproc(quality_control_path,Subj_list_1,in_func_path,in_anat_path,in_def_path,vox,Norm_pre,GM_path,WM_path,CSF_path,log_fileID,over_write)
% WHIFUN_NORMALISE_PREPROC Orchestrates normalization to MNI space.
%
%   [Subj_list_1, out_func_path, out_anat_path] = WHIFUN_NORMALISE_PREPROC(...)
%   is a high-level function that manages the spatial normalization step of
%   a neuroimaging preprocessing pipeline. It applies a previously calculated
%   deformation field (from the segmentation step) to both functional and
%   anatomical images, transforming them from the subject's native space
%   to a standard template space (MNI).
%
%   The function performs the normalization in two separate steps:
%   1.  **Functional Normalization**: It checks for an existing normalized
%       functional file and, based on the `over_write` flag, either skips
%       or calls `whifun_normalise` to perform the transformation.
%   2.  **Anatomical Normalization**: Similarly, it checks for an existing
%       normalized anatomical file and performs the normalization if needed.
%
%   For each step, the function logs the process output to a file and updates
%   the subject structure with the path to the newly created files. In case
%   of an error during either normalization process, it catches the exception,
%   updates the subject's `error` flag, and logs the detailed error
%   information to a file.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path         - The path to the input functional file.
%   in_anat_path         - The path to the input anatomical file.
%   in_def_path          - The path to the deformation field file (`y_...nii`).
%   vox                  - The voxel size for the normalized output.
%   Norm_pre             - The prefix for the output normalized files (e.g., 'w').
%   log_fileID           - File ID of the log file.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1   - The updated subject structure, with `func_MNI` and `anat_MNI` paths.
%   out_func_path - The full path to the normalized functional file.
%   out_anat_path - The full path to the normalized anatomical file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, WHIFUN_NORMALISE, TRY, CATCH.

disp(['Normalization is started for ' Subj_list_1.name])

disp(['Normalization is done for ' Subj_list_1.name])
try
    disp(['Anatomical Normalization of is started  for ' Subj_list_1.name])
    now_anat_path = dir(in_anat_path) ;
    out_anat_path = fullfile(now_anat_path.folder,[Norm_pre,now_anat_path.name]);

    norm_a_dir = whifun_create_file(over_write,out_anat_path);

    if isempty(norm_a_dir)
        norm_op = whifun_normalise(in_def_path,'',in_anat_path,0,nan,Norm_pre,0);
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Normalization of Anatomical images to MNI space\n');
        fprintf(log_fileID,'%s',  norm_op);
    else
        disp(['Anatomical Normalization file found, hence skipping this step for ' Subj_list_1.name]);
    end
    Subj_list_1.anat_MNI = out_anat_path;

    % Making anat mask in MNI Space
    disp(['Making Anat mask in MNI Space for ' Subj_list_1.name])
    
    now_anat_path = dir(out_anat_path);
    out_wanat_mask_MNI_path = fullfile(now_anat_path.folder,['anat_mask_' now_anat_path.name]);
    wanat_mask_path = whifun_create_file(over_write, out_wanat_mask_MNI_path);
    
    if isempty(wanat_mask_path)
        anat_mask_mni_op = whifun_anat_mask(out_wanat_mask_MNI_path,out_anat_path,GM_path,WM_path,CSF_path);
        % anat_mask_mni_op = whifun_wanat_mask(now_anat_path);
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Anat Mask MNI\n');
        fprintf(log_fileID,'%s',  anat_mask_mni_op);
    end
    Subj_list_1.anat_mask_MNI = out_wanat_mask_MNI_path;
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Anatomical Normalization for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display

    return
end
disp(['Anatomical Normalization is done for ' Subj_list_1.name])

try

    now_func_path = dir(in_func_path) ;
    
    out_func_path = fullfile(now_func_path.folder,[Norm_pre,now_func_path.name]);
    norm_path = whifun_create_file(over_write,out_func_path);

    if isempty(norm_path)
        nt = Subj_list_1.nt_dis;
        norm_op = whifun_normalise(in_def_path,in_func_path,in_anat_path,nt,vox,Norm_pre,1); %func
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Normalization to MNI space\n');
        fprintf(log_fileID,'%s',  norm_op);
        
        % reslice_data(in_wanat_mask_MNI_path,out_func_path,1,1,out_func_mni_mask_path);
    else
        disp(['Normalization file found, hence skipping this step for ' Subj_list_1.name]);
    end
    Subj_list_1.func_MNI = out_func_path;

    % Create func mask
    now_func_path = dir(in_func_path) ;
    
    out_func_path = fullfile(now_func_path.folder,[Norm_pre,now_func_path.name]);
    [fol,name,ext] = fileparts(out_func_path);
    out_func_mni_mask_path = fullfile(fol,['func_mask_' name ext]);
    norm_path = whifun_create_file(over_write,out_func_mni_mask_path);
    in_wanat_mask_MNI_path = out_wanat_mask_MNI_path;
    if isempty(norm_path)
        reslice_data(in_wanat_mask_MNI_path,out_func_path,1,1,out_func_mni_mask_path);
    end


    Subj_list_1.func_mask_MNI = out_func_mni_mask_path;
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Normalization for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display
    Subj_list_1.error = 1;  % Remove participant from further preprocessing
    return

end

