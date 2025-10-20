function whifun_calc(output_path, expression, varargin)
% whifun_calc(output_path, expression, nifti1, nifti2, ...)
%
% Calculates a mathematical expression using multiple NIfTI images.
%
% Example:
%   whifun_calc('out.nii', 'i1 + i2 + i3', 'sub1.nii', 'sub2.nii', 'sub3.nii')
%
% Inputs:
%   output_path : path to save the output NIfTI file
%   expression  : expression to evaluate (e.g., 'i1 + i2 - i3')
%   varargin    : list of NIfTI image file paths (all in same grid/space)
%
% The variables in the expression must be named i1, i2, i3, ... corresponding
% to the order of NIfTI inputs.

    if nargin < 3
        error('Usage: whifun_calc(output_path, expression, nifti1, nifti2, ...)');
    end

    nImgs = numel(varargin);
    vols = cell(1, nImgs);

    % --- Load all input NIfTI images ---
    for k = 1:nImgs
        if ~isfile(varargin{k})
            error('File not found: %s', varargin{k});
        end
        V = spm_vol(varargin{k});
        Y = spm_read_vols(V);
        vols{k} = Y;
        if k == 1
            refV = V; % use first image header as reference
            refSize = size(Y);
        else
            if ~isequal(size(Y), refSize)
                error('All input images must have the same dimensions.');
            end
        end
        assignin('caller', sprintf('i%d', k), Y); 
    end

    % --- Prepare workspace for evaluation ---
    exprVars = cellfun(@(x) sprintf('i%d', x), num2cell(1:nImgs), 'UniformOutput', false);
    for k = 1:nImgs
        eval([exprVars{k} ' = vols{k};']);
    end

    % --- Evaluate the expression ---
    try
        result = eval(expression);
    catch ME
        error('Error evaluating expression: %s\nMATLAB error: %s', expression, ME.message);
    end

    % --- Save result as NIfTI ---
    outV = refV;
    outV.fname = output_path;
    spm_write_vol(outV, result);

    fprintf('Output saved to: %s\n', output_path);
end
