function [Subj_list,try_again] = whifun_create_Subj_list(output_folder,data_path,final_func_MNI,GM_MNI,WM_MNI,CSF_MNI,varargin)

%% ---------------- Input Parser ----------------
p = inputParser;
p.FunctionName = 'whifun_create_preproc_files_cell';

% Optional with defaults
addParameter(p,'motion_txt','');
addParameter(p,'anat_mask_MNI','');
addParameter(p,'func_MNI','');
addParameter(p,'anat_MNI','');
addParameter(p,'func_mask_MNI','');
addParameter(p,'MNI_template','');

parse(p,varargin{:});

% Assign parsed inputs
motion_txt     = p.Results.motion_txt;
anat_mask_MNI  = p.Results.anat_mask_MNI;
func_MNI       = p.Results.func_MNI;
anat_MNI       = p.Results.anat_MNI;
func_mask_MNI  = p.Results.func_mask_MNI;
MNI_template   = p.Results.MNI_template;

if ~exist(output_folder,'dir')
    mkdir(output_folder)
end
spm_path = which('spm.m');
if isempty(spm_path)
    error('SPM toolbox not found. Please check the SPM path. Add path to the folder that contains spm.m file');
end

whifun_func_path = which('whifun.m');
if isempty(whifun_func_path)
    error('Whifun toolbox not found. Please check the Whifun path. Add path to the folder that contains whifun.m file');
end
whifun_path = fileparts(whifun_func_path);

addpath(fullfile(whifun_path,'whifun_functions'))
finalData = whifun_create_preproc_files_cell(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI,...
    'motion_txt',motion_txt,...
    'anat_mask_MNI',anat_mask_MNI, ...
    'func_MNI',func_MNI,...
    'anat_MNI',anat_MNI,...
    'func_mask_MNI',func_mask_MNI,...
    'MNI_template',MNI_template);

[Subj_list,output_folder] = whifun_create_Subj_list_gui(output_folder,data_path,'All',finalData);

whifun_save_parameters(output_folder,'parameters.mat',...
                                data_path,output_folder,0,...
                                '','','','','','',...
                                0,5,0.2,0.2,0,0.95,'Mean CSF',0,1,0,0.01,0.15,'WM-GM Seperate',"4","3")
if isempty(Subj_list)
    error('No Subject files found, Please check the ''Preproccessed file paths'' ')

end
Subj_list = whifun_create_fields(Subj_list);
for i = 1:length(Subj_list)
    Subj_list(i).error = 0;
    Subj_list(i).manual_ex = 0;
    Subj_list(i).motion_ex = 0;
end
my_writetable(struct2table(Subj_list),fullfile(output_folder,"Subj_list.csv"))

%% Check the created Subj_list.csv
Sub_info_properties = Sub_info(output_folder);
msgbox('Please check the fields in Subj_list.csv an ensure that they are correct?','Verify Subj_list.csv');

uiwait(Sub_info_properties.ParticipantsInformationUIFigure)

resp_ = questdlg('Do you want to continue with this Subj_list.csv?','Continue?','yes','no','yes');

switch resp_
    case 'no'
        try_again = 1;
    case 'yes'
        try_again = 0;
end