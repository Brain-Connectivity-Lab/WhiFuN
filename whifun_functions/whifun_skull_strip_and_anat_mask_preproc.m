function [Subj_list_1,out_ss_path,out_anat_mask_subj_space_path,out_wanat_mask_MNI_path] = whifun_skull_strip_and_anat_mask_preproc(quality_control_path,Subj_list_1,in_anat_path,skull_pre,log_fileID,over_write)
% WHIFUN_SKULL_STRIP_AND_ANAT_MASK_PREPROC Performs skull stripping and anatomical mask creation.
%
%   [Subj_list_1, out_ss_path, out_anat_mask_subj_space_path, out_wanat_mask_MNI_path] = whifun_skull_strip_and_anat_mask_preproc(...)
%   is a high-level function that manages three key preprocessing steps for
%   anatomical data: skull stripping, creating a brain mask in native space,
%   and creating a brain mask in MNI space.
%
%   The function first checks for the input anatomical file and resolves
%   ambiguities. It then performs the following steps, each with an
%   overwriting check:
%   1.  **Skull Stripping**: Calls `whifun_skullstrip` to remove non-brain tissue
%       from the bias-corrected anatomical image.
%   2.  **Anatomical Mask (Native Space)**: Calls `whifun_anat_mask` to
%       create a brain mask from the segmented tissue images (GM, WM, CSF)
%       in the subject's native space.
%   3.  **Anatomical Mask (MNI Space)**: Calls `whifun_anat_mask` again to
%       create a brain mask from the segmented tissue images in MNI space.
%
%   The function updates the subject structure with the paths to all the
%   generated files and logs the output of each step to a file. In case of
%   an error, it catches the exception, updates the subject's error flag,
%   and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_anat_path         - The path to the input anatomical NIfTI file.
%   skull_pre            - The prefix for the skull-stripped output file.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1                   - The updated subject structure.
%   out_ss_path                   - Full path to the skull-stripped file.
%   out_anat_mask_subj_space_path - Full path to the brain mask in native space.
%   out_wanat_mask_MNI_path       - Full path to the brain mask in MNI space.
%
%   Author: Pratik Jain
%   See also WHIFUN_MULTIPLE_FILE_FOUND, WHIFUN_CREATE_FILE, WHIFUN_SKULLSTRIP, WHIFUN_ANAT_MASK.

disp(['Skull Stripping started for ' Subj_list_1.name])

disp(['Currently Processing ' Subj_list_1.name])
try

    now_anat_path = dir(in_anat_path) ;
    if length(now_anat_path) > 1
        now_anat_path = whifun_multiple_file_found(now_anat_path,anat_func);
    end
    out_ss_path = fullfile(now_anat_path.folder,[skull_pre now_anat_path.name]);
    banat_path = whifun_create_file(over_write,out_ss_path);
    
    m_file = dir(fullfile(now_anat_path.folder, ['m' now_anat_path.name]));
    if isempty(banat_path)

        if length(m_file)>1
            m_not_needed_file = dir(fullfile(now_anat_path(1).folder, ['mwc' Subj_list_1.anat_name]));

            % convert structs into matrices
            A = struct2cell(m_file); A(2:end,:) = [];
            B = struct2cell(m_not_needed_file);  B(2:end,:) = [];
            % intersect the equivalent representation
            [~, ia] = intersect(A,B );
            m_file(ia) = [];
        end
        skull_op = whifun_skullstrip(m_file,now_anat_path,skull_pre);

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Skull Strip\n');
        fprintf(log_fileID,'%s',  skull_op);
    else
        disp('Skull Stripped file found, hence skipping this step');        
    end
    disp(['Skull Stripping done for ' Subj_list_1.name])
    Subj_list_1.skull_stripped_anat_native = out_ss_path;

    % Making mask for regression
    disp(['Making Mask for regression for ' Subj_list_1.name])

    out_anat_mask_subj_space_path = fullfile(now_anat_path.folder,['anat_mask_' now_anat_path.name]);
    anat_mask_path = whifun_create_file(over_write,out_anat_mask_subj_space_path);
    
    if isempty(anat_mask_path)

        anat_mask_op = whifun_anat_mask(m_file,now_anat_path,0);

        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Anat Mask\n');
        fprintf(log_fileID,'%s', anat_mask_op);
    end
    Subj_list_1.anat_mask_native = out_anat_mask_subj_space_path;

    % Making anat mask in MNI Space
    disp(['Making Anat mask in MNI Space for ' Subj_list_1.name])

    out_wanat_mask_MNI_path = fullfile(now_anat_path.folder,['wanat_mask_' now_anat_path.name]);
    wanat_mask_path = whifun_create_file(over_write, out_wanat_mask_MNI_path);
    
    if isempty(wanat_mask_path)

        anat_mask_mni_op = whifun_anat_mask(m_file,now_anat_path,1);
        fprintf(log_fileID,'#####################################################################################################################\n \n');
        fprintf(log_fileID, 'Anat Mask MNI\n');
        fprintf(log_fileID,'%s',  anat_mask_mni_op);
    end
    Subj_list_1.anat_mask_MNI = out_wanat_mask_MNI_path;
catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in Skull strip for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display


    return
end

