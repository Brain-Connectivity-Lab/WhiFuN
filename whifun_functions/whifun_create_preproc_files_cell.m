function finalData = whifun_create_preproc_files_cell(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI, varargin)
%WHIFUN_CREATE_PREPROC_FILES_CELL Aggregates preprocessing file paths into a structured cell array (Used for creating a Subj_List.csv file from already preprocessed dataset).
%
%   finalData = WHIFUN_CREATE_PREPROC_FILES_CELL(final_func_MNI, GM_MNI, WM_MNI, CSF_MNI)
%   takes the four mandatory preprocessed neuroimaging inputs and outputs a 10x2 
%   cell array mapping standard variable names to their provided values. Unspecified 
%   optional parameters will default to empty strings.
%
%   finalData = WHIFUN_CREATE_PREPROC_FILES_CELL(..., 'Param1', Value1, 'Param2', Value2, ...)
%   allows you to specify any of the six optional parameters using Name-Value 
%   pairs.
%
%   This function is useful for cleanly bundling various paths or data objects 
%   into a single structured variable to pass to subsequent pipeline steps.
%
%   Mandatory Inputs:
%       final_func_MNI - String/char array path to the final functional MNI image.
%       GM_MNI         - String/char array path to the MNI Gray Matter map.
%       WM_MNI         - String/char array path to the MNI White Matter map.
%       CSF_MNI        - String/char array path to the MNI CSF map.
%
%   Optional Name-Value Pair Inputs:
%       'motion_txt'    - Path to the motion parameters text file.
%       'anat_mask_MNI' - Path to the anatomical brain mask in MNI space.
%       'func_MNI'      - Path to the functional MNI image (intermediate).
%       'anat_MNI'      - Path to the anatomical MNI image.
%       'func_mask_MNI' - Path to the functional mask in MNI space.
%       'MNI_template'  - Path to the specific MNI template used.
%
%   Outputs:
%       finalData       - A 10x2 cell array. The first column contains the 
%                         hardcoded variable names as strings, and the second 
%                         column contains the assigned values.
%
%   Example:
%       % Passing mandatory inputs and a few optional ones
%       bundle = whifun_create_preproc_files_cell('func.nii', 'gm.nii', 'wm.nii', 'csf.nii', ...
%                                                 'motion_txt', 'rp_motion.txt', ...
%                                                 'anat_MNI', 'wT1.nii');
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