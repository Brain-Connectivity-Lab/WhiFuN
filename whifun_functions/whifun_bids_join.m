function out = whifun_bids_join(varargin)
%WHIFUN_BIDS_JOIN Joins multiple strings into an underscore-separated BIDS name.
%
%   OUT = WHIFUN_BIDS_JOIN(STR1, STR2, ...) takes a variable number of 
%   input strings or character arrays and concatenates them using an 
%   underscore ('_') delimiter. Empty inputs are automatically ignored.
%
%   INPUTS:
%       varargin - Any number of string or character array inputs 
%                  (e.g., 'sub-01', 'ses-pre', 'T1w').
%
%   OUTPUTS:
%       out      - A single character array of joined elements.
%
%   EXAMPLE:
%       name = whifun_bids_join('sub-01', 'ses-01', '', 'T1w');
%       % returns: 'sub-01_ses-01_T1w'
%
%   See also JOIN, STRING, CHAR.

% Initialize string array
strs = string(1);
p = 1;
for i = 1:nargin
    if ~isempty(varargin{i})
        strs(p) = varargin{i};
        p = p+1;
    end
end
out = char(join(strs,'_'));

end