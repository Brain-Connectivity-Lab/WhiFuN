function Subj_list_all = whifun_create_fields(Subj_list_all)
% WHIFUN_CREATE_FIELDS Adds a set of standard fields to a subject list structure array.
%
%   Subj_list_all = WHIFUN_CREATE_FIELDS(Subj_list_all) is a utility function
%   that ensures a subject list structure array contains all the necessary
%   fields required for a neuroimaging preprocessing workflow.
%
%   This function calls an internal helper function `create_field` for
%   a predefined list of fields. If a field does not exist in the structure,
%   it is added to the first element of the array with an empty value. This
%   pre-allocation is a robust way to prepare a subject list for subsequent
%   data storage without throwing errors.
%
%   The fields added by this function include:
%   - **Exclusion flags**: `error`, `motion_ex`, `manual_ex`
%   - **Functional data dimensions**: `x_func`, `y_func`, `z_func`, `nt` (number of time points), `TR`
%   - **Anatomical data dimensions**: `x_Anat`, `y_Anat`, `z_Anat`
%   - **Timing**: `time_preprocess_min`
%
%   Input Arguments:
%   Subj_list_all - A structure array containing subject data.
%
%   Output Arguments:
%   Subj_list_all - The same structure array, with any missing fields from
%                   the predefined list added.
%
%   Example:
%      % Assuming a subject list `Subj_list` is created with only `name` and `age` fields.
%      % Subj_list = struct('name', {'sub-01', 'sub-02'}, 'age', {25, 30});
%
%      % This function will add all the specified fields to the structure.
%      % Subj_list = whifun_create_fields(Subj_list);
%
%   Author: Pratik Jain
%   See also ISFIELD.

Subj_list_all = create_field(Subj_list_all,'error');
Subj_list_all = create_field(Subj_list_all,'motion_ex');
Subj_list_all = create_field(Subj_list_all,'manual_ex');
Subj_list_all = create_field(Subj_list_all,'comments');
Subj_list_all = create_field(Subj_list_all,'x_func');
Subj_list_all = create_field(Subj_list_all,'y_func');
Subj_list_all = create_field(Subj_list_all,'z_func');
Subj_list_all = create_field(Subj_list_all,'nt');
Subj_list_all = create_field(Subj_list_all,'TR');
Subj_list_all = create_field(Subj_list_all,'x_Anat');
Subj_list_all = create_field(Subj_list_all,'y_Anat');
Subj_list_all = create_field(Subj_list_all,'z_Anat');
Subj_list_all = create_field(Subj_list_all,'time_preprocess_min');
end



function Subj_list_all = create_field(Subj_list_all,field_)

    if ~isfield(Subj_list_all, field_)
        Subj_list_all(1).(field_) = ' ';
        
    end
end
