function finalData = whifun_create_preproc_files_cell(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI, varargin)
% assembleInputs Create a 10x2 cell with variable names and values.
%   finalData = assembleInputs(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI)
%   assembleInputs(..., motion_txt, anat_mask_MNI, func_MNI, anat_MNI,
%   func_mask_MNI, MNI_template)
%
% Compulsory inputs (in order):
%   final_func_MNI, GM_MNI, WM_MNI, CSF_MNI
% Optional inputs (in order). If omitted, they default to empty string:
%   motion_txt, anat_mask_MNI, func_MNI, anat_MNI, func_mask_MNI, MNI_template
%
% Output:
%   finalData - 10x2 cell: first column variable names (strings), second
%               column variable values.

% Validate number of compulsory inputs
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
motion_txt= p.Results.motion_txt;
anat_mask_MNI         = p.Results.anat_mask_MNI;
func_MNI      = p.Results.func_MNI;
anat_MNI  = p.Results.anat_MNI;
func_mask_MNI    = p.Results.func_mask_MNI;
MNI_template   = p.Results.MNI_template;

% Define variable names in desired order (10 variables)
varNames = { ...
    'final_func_MNI'; ...
    'GM_MNI'; ...
    'WM_MNI'; ...
    'CSF_MNI'; ...
    'motion_txt'; ...
    'anat_mask_MNI'; ...
    'func_MNI'; ...
    'anat_MNI'; ...
    'func_mask_MNI'; ...
    'MNI_template' ...
    };

% Collect provided values
vals = cell(10,1);
% Mandatory ones
vals{1} = final_func_MNI;
vals{2} = GM_MNI;
vals{3} = WM_MNI;
vals{4} = CSF_MNI;
vals{5} = motion_txt;
vals{6} = anat_mask_MNI;
vals{7} = func_MNI;
vals{8} = anat_MNI;
vals{9} = func_mask_MNI;
vals{10} = MNI_template;
% Build final 10x2 cell
finalData = [varNames vals];

end