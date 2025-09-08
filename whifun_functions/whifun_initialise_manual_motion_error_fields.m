function Subj_list_1 = whifun_initialise_manual_motion_error_fields(Subj_list_1)
% WHIFUN_INITIALISE_MANUAL_MOTION_ERROR_FIELDS Initializes exclusion fields for a subject.
%
%   Subj_list_1 = WHIFUN_INITIALISE_MANUAL_MOTION_ERROR_FIELDS(Subj_list_1)
%   initializes the `error`, `motion_ex`, and `manual_ex` fields of a single
%   subject structure `Subj_list_1`.
%
%   This function is a utility to ensure that these tracking fields are
%   properly set to a default value (0) before a subject is processed. It
%   prevents potential errors that could arise from trying to access or
%   modify a field that is empty or non-existent.
%
%   The function performs the following actions:
%   1. Sets the `error` field to 0. This flag is used to track processing
%      errors for the subject.
%   2. Checks if the `motion_ex` field is empty. If it is, it sets the value
%      to 0. This flag is used to mark subjects with excessive motion.
%   3. Checks if the `manual_ex` field is empty. If it is, it sets the value
%      to 0. This flag is for manually marking a subject for exclusion.
%
%   Input Arguments:
%   Subj_list_1 - A single structure from a subject list array.
%
%   Output Arguments:
%   Subj_list_1 - The same subject structure with the `error`, `motion_ex`,
%                 and `manual_ex` fields initialized to 0 if they were
%                 previously empty.
%
%   Example:
%      % Assume 'my_subject' is a structure where 'motion_ex' and 'manual_ex'
%      % might be empty or missing.
%      % my_subject = struct('name', 'sub-01', 'motion_ex', [], 'manual_ex', []);
%
%      % Initialize the fields using the function
%      % my_subject = whifun_initialise_manual_motion_error_fields(my_subject);
%
%      % Now, my_subject.motion_ex will be 0, and my_subject.manual_ex will be 0.
%
%   Author: Pratik Jain
%   See also ISEMPTY.

Subj_list_1.error = 0;
if isempty(Subj_list_1.motion_ex)
    Subj_list_1.motion_ex = 0;
end
if isempty(Subj_list_1.manual_ex)
    Subj_list_1.manual_ex = 0;
end