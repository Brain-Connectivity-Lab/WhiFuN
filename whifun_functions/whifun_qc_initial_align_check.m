function whifun_qc_initial_align_check(out_folder,template_path,Subj_list_1,slover_slices,slover_contour_range,slover_view,over_write)
% WHIFUN_QC_INITIAL_ALIGN_CHECK Creates quality control images for initial data alignment.
%
%   WHIFUN_QC_INITIAL_ALIGN_CHECK(out_folder, template_path, Subj_list_1, slover_slices, slover_contour_range, slover_view, over_write)
%   generates visual quality control reports to assess the initial alignment
%   of a subject's functional and anatomical data to a standard MNI template.
%
%   The function performs two main tasks:
%   1.  **Anatomical Alignment Check**: It creates QC images comparing the
%       subject's anatomical file to an MNI template.
%   2.  **Functional Alignment Check**: It creates QC images comparing the
%       first volume of the subject's functional file to the same MNI template.
%
%   For each alignment check, a helper function `store_ortho_slover_images`
%   is called to generate two types of plots:
%   -   **Orthoslice View**: A standard SPM `spm_check_registration` plot.
%   -   **SLover View**: A specialized overlay plot using `whifun_qc_coreg_slover`.
%
%   This function is a crucial early-stage quality control step to ensure that
%   the data has the expected orientation and is a good starting point for
%   subsequent processing steps like coregistration. The `over_write` flag
%   prevents redundant image generation.
%
%   Input Arguments:
%   out_folder           - The root directory for saving all QC output.
%   template_path        - The full path to the MNI template file.
%   Subj_list_1          - A single subject structure.
%   slover_slices        - A vector of slice locations to display.
%   slover_contour_range - A two-element vector for contour range.
%   slover_view          - The view to display slices in (e.g., 'axial').
%   over_write           - (Optional) A logical value (0 or 1) to force
%                          overwriting of existing QC images. Defaults to 0.
%
%   Author: Pratik Jain
%   See also WHIFUN_MULTIPLE_FILE_FOUND, WHIFUN_CREATE_FILE, WHIFUN_QC_COREG_ORTHOSLICE, WHIFUN_QC_COREG_SLOVER.


if ~exist('over_write','var')
    over_write = 0; % Default value for over_write if not provided
end

disp(['Anatomical and Functional initial alignment check for ' Subj_list_1.name])

% Initial anat file check
% Plot the anatomical image and check its intitial position with reference to the MNI template

now_anat_path = dir(Subj_list_1.nii_anat_native) ;
now_anat_path = whifun_multiple_file_found(now_anat_path,'anatomical');
image_2_path = template_path;


image_1_path = fullfile(now_anat_path.folder,now_anat_path.name);
out_ortho_path = fullfile(out_folder,'Native_Space','anat','Orthoslice_View',[Subj_list_1.name '_anat.png']);
out_slover_path = fullfile(out_folder,'Native_Space','anat',[slover_view '_View'],[Subj_list_1.name '_anat.png']);

store_ortho_slover_images(image_1_path,image_2_path,out_ortho_path,out_slover_path,slover_slices,slover_contour_range,slover_view,over_write)


% Initial func file check
% Plot the first functional image and check its intitial position with reference to the MNI template
now_func_path = dir(Subj_list_1.nii_func_native) ;
now_func_path = whifun_multiple_file_found(now_func_path,'functional');

image_1_path = fullfile(now_func_path.folder,[now_func_path.name ',1']);
out_ortho_path = fullfile(out_folder,'Native_Space','func','Orthoslice_View',[Subj_list_1.name '_func.png']);
out_slover_path = fullfile(out_folder,'Native_Space','func',[slover_view '_View'],[Subj_list_1.name '_func.png']);

store_ortho_slover_images(image_1_path,image_2_path,out_ortho_path,out_slover_path,slover_slices,slover_contour_range,slover_view,over_write)

disp(['Anatomical and Functional initial alignment check done for' Subj_list_1.name])


function store_ortho_slover_images(image_1_path,image_2_path,out_ortho_path,out_slover_path,slover_slices,slover_contour_range,slover_view,over_write)

anat_qc_ortho = whifun_create_file(over_write, out_ortho_path);
if isempty(anat_qc_ortho)
    whifun_qc_coreg_orthoslice(image_1_path,image_2_path,out_ortho_path);
end

anat_qc_slover = whifun_create_file(over_write, out_slover_path);
if isempty(anat_qc_slover)
    whifun_qc_coreg_slover(image_1_path,image_2_path,out_slover_path,slover_slices,slover_contour_range,slover_view)
end

