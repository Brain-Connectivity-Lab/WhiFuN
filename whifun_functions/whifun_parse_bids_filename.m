function info = whifun_parse_bids_filename(fname)
% WHIFUN_PARSE_BIDS_FILENAME
% Extract BIDS/fMRIPrep entities from a filename
%
% INPUT
%   fname : string or char
%
% OUTPUT
%   info : struct with fields:
%          sub, ses, task, run, space, desc, suffix, extension

    if isstring(fname)
        fname = char(fname);
    end

    % Remove path if present
    [~, name, ext] = fileparts(fname);

    % Handle .nii.gz
    if strcmp(ext, '.gz')
        [~, name, ext2] = fileparts(name);
        ext = [ext2 ext];  % '.nii.gz'
    end

    info = struct( ...
        'sub',    extract_entity(name, 'sub'), ...
        'ses',    extract_entity(name, 'ses'), ...
        'task',   extract_entity(name, 'task'), ...
        'run',    extract_entity(name, 'run'), ...
        'space',  extract_entity(name, 'space'), ...
        'desc',   extract_entity(name, 'desc'), ...
        'suffix', extract_suffix(name), ...
        'extension', ext ...
    );
end

% ---------------------------------------------------------
function val = extract_entity(str, key)
% Extract BIDS entity value (e.g., sub-01 → 01)

    expr = [key '-([^_]+)'];
    tok = regexp(str, expr, 'tokens', 'once');

    if isempty(tok)
        val = '';
    else
        val = [key, '-',tok{1}];
    end
end

% ---------------------------------------------------------
function suffix = extract_suffix(str)
% Extract BIDS suffix (e.g., bold, T1w)

    parts = strsplit(str, '_');
    suffix = parts{end};
end
