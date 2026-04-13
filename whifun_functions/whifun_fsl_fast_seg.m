function [gm_prob_path, wm_prob_path, csf_prob_path,t1_input_brain] = whifun_fsl_fast_seg(t1_path, out_dir, do_skullstrip)
% WHIFUN_FSL_FAST_SEG Performs anatomical segmentation with optional skull stripping using FSL.
%
%   [gm_prob_path, wm_prob_path, csf_prob_path] = WHIFUN_FSL_FAST_SEG(t1_path, out_dir, do_skullstrip)
%   is a MATLAB wrapper function that automates the process of performing
%   anatomical segmentation using FSL's `fast` tool. It also provides an
%   option to run FSL's `bet` for skull stripping prior to segmentation.
%
%   The function performs the following steps:
%   1.  **Skull Stripping (optional)**: If `do_skullstrip` is true, it uses `bet`
%       to remove non-brain tissue from the T1 image, saving a new file with
%       `_brain` appended to its name.
%   2.  **Segmentation**: It then runs `fast` on either the original T1
%       image or the skull-stripped version to segment the brain into three
%       tissue types: Gray Matter (GM), White Matter (WM), and Cerebrospinal
%       Fluid (CSF).
%   3.  **File Management**: It ensures the output directory exists and defines
%       the expected output paths for the GM, WM, and CSF partial volume
%       estimate files, which are saved in `nii.gz` format.
%
%   Input Arguments:
%   t1_path       - The full path to the input T1-weighted anatomical image.
%   out_dir       - The path to the directory where the output segmentation
%                   files will be saved.
%   do_skullstrip - (Optional) A logical value. If true (default), it performs
%                   skull stripping using `bet` before segmentation. If false,
%                   it skips the skull stripping step.
%
%   Output Arguments:
%   gm_prob_path  - The full path to the Gray Matter partial volume estimate file.
%   wm_prob_path  - The full path to the White Matter partial volume estimate file.
%   csf_prob_path - The full path to the Cerebrospinal Fluid partial volume
%                   estimate file.
%
%   Note: This function requires FSL to be installed and correctly configured
%         in the system's PATH.
%
%   Author: Pratik Jain
%   See also SYSTEM, FILEPARTS, MKDIR.
    % Default: skull strip
    if nargin < 3
        do_skullstrip = true;
    end

    % Get filename without extension
    [fold, name, ~] = fileparts(t1_path);
    [~, name, ~] = fileparts(name);
    if nargin < 2
        out_dir = fold;
    end

        % Ensure output directory exists
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % Define FAST output prefix
    out_prefix = fullfile(out_dir, name);

    % Optionally run BET (skull stripping)
    if do_skullstrip
        bet_out = fullfile(out_dir, [name '_brain']);
        cmd_bet = sprintf('bet %s %s -R -f 0.5 -g 0 -m', t1_path, bet_out);
        status = system(cmd_bet);
        if status ~= 0
            error('FSL BET (skull stripping) failed!');
        end
        t1_input = [bet_out '.nii.gz'];
        t1_input_brain = [bet_out '_mask.nii.gz'];
    else
        t1_input = t1_path;
        [t1,head] = whifun_niftiread(t1_path);
        t1_brain_mask = t1 > 0;
        niftisave(double(t1_brain_mask),fullfile(fold,[name '_mask.nii.gz']),head);
        t1_input_brain = fullfile(fold,[name '_mask.nii.gz']);
    end

    % Build system command for FSL FAST
    % -t 1 -> T1 image
    % -n 3 -> 3 tissue classes
    % -o prefix -> output prefix
    cmd_fast = sprintf('fast -t 1 -n 3 -o %s %s', out_prefix, t1_input);

    % Run FAST
    status = system(cmd_fast);
    if status ~= 0
        error('FSL FAST command failed!');
    end

    % FAST outputs: <prefix>_pve_0.nii.gz (CSF), _pve_1 (GM), _pve_2 (WM)
    % gm_prob_path = fullfile(out_dir,[out_prefix '_pve_1.nii.gz']);
    % wm_prob_path  = fullfile(out_dir,[out_prefix '_pve_2.nii.gz']);
    % csf_prob_path  = fullfile(out_dir,[out_prefix '_pve_0.nii.gz']);
    gm_prob_path = fullfile([out_prefix '_pve_1.nii.gz']);
    wm_prob_path  = fullfile([out_prefix '_pve_2.nii.gz']);
    csf_prob_path  = fullfile([out_prefix '_pve_0.nii.gz']);
end

