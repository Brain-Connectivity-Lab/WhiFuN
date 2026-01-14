function Subj_list_all = whifun_create_fields_preproc(Subj_list_all)
% WHIFUN_CREATE_FIELDS_PREPROC Adds preprocessing-specific fields to a subject list.
%
%   Subj_list_all = WHIFUN_CREATE_FIELDS_PREPROC(Subj_list_all) is a utility
%   function that ensures a subject list structure array contains all the
%   necessary fields for tracking files and data generated during a
%   neuroimaging preprocessing pipeline.
%
%   This function calls an internal helper function `create_field` for
%   a comprehensive list of fields. If a field does not exist in the
%   structure, it is added to the first element of the array with an empty
%   value. This pre-allocation is a robust way to prepare a subject list for
%   subsequent data storage without throwing errors.
%
%   The fields added by this function include:
%   - **File paths**: `nii_func`, `nii_anat`, `motion_txt`
%     `initial_vol_cut`, `realigned`,
%     `bias_corrected`, `skull_stripped`, `coregistered_func`,
%     `nuisance_regressed`, `filtered`, `smoothed`, `func_MNI`, `anat_MNI`
%   - **Segmentation and masks** paths: `GM_native`, `WM_native`, `CSF_native`,
%     `GM_MNI`, `WM_MNI`, `CSF_MNI`, `deformation_field`,
%     `anat_mask_native`, `anat_mask_MNI`, `CSF_mask_func`
%
%   Input Arguments:
%   Subj_list_all - A structure array containing subject data.
%
%   Output Arguments:
%   Subj_list_all - The same structure array, with any missing fields from
%                   the predefined list added.
%
%   Example:
%      % Assuming a subject list `Subj_list` is loaded from a Subj_list CSV file.
%
%      % This function will add all the specified preprocessing fields.
%      % Subj_list = whifun_create_fields_preproc(Subj_list);
%
%   Author: Pratik Jain
%   See also ISFIELD.


Subj_list_all = create_field(Subj_list_all,'nii_func_native');
Subj_list_all = create_field(Subj_list_all,'nii_anat_native');

Subj_list_all = create_field(Subj_list_all,'initial_func_native');
Subj_list_all = create_field(Subj_list_all,'nt_dis');

Subj_list_all = create_field(Subj_list_all,'realigned_func_native');
Subj_list_all = create_field(Subj_list_all,'motion_txt');

Subj_list_all = create_field(Subj_list_all,'bias_corrected_anat_native');
Subj_list_all = create_field(Subj_list_all,'GM_native');
Subj_list_all = create_field(Subj_list_all,'WM_native');
Subj_list_all = create_field(Subj_list_all,'CSF_native');
Subj_list_all = create_field(Subj_list_all,'GM_MNI');
Subj_list_all = create_field(Subj_list_all,'WM_MNI');
Subj_list_all = create_field(Subj_list_all,'CSF_MNI');
Subj_list_all = create_field(Subj_list_all,'deformation_field');


Subj_list_all = create_field(Subj_list_all,'skull_stripped_anat_native');
Subj_list_all = create_field(Subj_list_all,'anat_mask_native');
Subj_list_all = create_field(Subj_list_all,'anat_mask_MNI');

Subj_list_all = create_field(Subj_list_all,'coregistered_func_native');
Subj_list_all = create_field(Subj_list_all,'CSF_mask_func_native');

Subj_list_all = create_field(Subj_list_all,'before_nuisance_regressed_func_native');
Subj_list_all = create_field(Subj_list_all,'nuisance_regressed_func_native');
Subj_list_all = create_field(Subj_list_all,'nuisance_regression_csf_covariates');
Subj_list_all = create_field(Subj_list_all,'func_mask_MNI');
Subj_list_all = create_field(Subj_list_all,'func_mask_native');


Subj_list_all = create_field(Subj_list_all,'filtered_func_native');
Subj_list_all = create_field(Subj_list_all,'smoothed_func');
Subj_list_all = create_field(Subj_list_all,'func_MNI');
Subj_list_all = create_field(Subj_list_all,'anat_MNI');
Subj_list_all = create_field(Subj_list_all,'MNI_template');
Subj_list_all = create_field(Subj_list_all,'final_func_MNI');



end

function Subj_list_all = create_field(Subj_list_all,field_)
    if ~isfield(Subj_list_all, field_)
        Subj_list_all(1).(field_) = [];
    end
end