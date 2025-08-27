function Subj_list_1 = whifun_motion_ex_manual_ex(Subj_list_1)

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