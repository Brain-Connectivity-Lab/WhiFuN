function Subj_list_1 = whifun_motion_ex_manual_ex(Subj_list_1)
%WHIFUN_MOTION_EX_MANUAL_EX Initializes or validates subject exclusion flags
%   for motion-based or manual exclusion.
%
%   SUBJ_LIST_1 = WHIFUN_MOTION_EX_MANUAL_EX(SUBJ_LIST_1)
%
%   This utility function ensures that the `motion_ex` (motion exclusion) and
%   `manual_ex` (manual exclusion) fields exist in the subject structure
%   and are initialized to 0 (meaning the subject is *included*) if they
%   are either missing or empty. It also initializes an `error` flag to 0.
%
%   Input Arguments:
%   SUBJ_LIST_1 - A scalar structure containing a single subject's information.
%                 Must contain the field 'name'.
%
%   Output Arguments:
%   SUBJ_LIST_1 - The updated structure with the following fields ensured:
%                 - .error: Initialized to 0.
%                 - .motion_ex: Initialized to 0 if missing or empty.
%                 - .manual_ex: Initialized to 0 if missing or empty.
%
%   Author: Pratik Jain

disp(['Currently Checking ' Subj_list_1.name])
Subj_list_1.error = 0;

if ~isfield(Subj_list_1,'motion_ex')
    Subj_list_1.motion_ex = 0;
elseif isempty(Subj_list_1.motion_ex)
    Subj_list_1.motion_ex = 0;
end

if ~isfield(Subj_list_1,'manual_ex')
    Subj_list_1.manual_ex = 0;
elseif isempty(Subj_list_1.manual_ex)
    Subj_list_1.manual_ex = 0;
end