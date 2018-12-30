function b = packageroot(varargin)
%% PACKAGEROOT Determine the root directory of the given package.
%
%   B = PACKAGEROOT(P1, P2, ..., Pn) returns the base directories of package
%   classes P1, P2, ..., Pn.
%
%   Inputs:
%
%   PI                  Name of package or class inside to get.
%
%   Outputs:
%
%   B                   1xN cell array of package class base directories.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Initial release



%% Validate arguments
narginchk(1, Inf);
nargoutchk(0, 1);

% Validate all arguments are chars
cellfun(@(pp) validateattributes(pp, {'char'}, {'nonempty'}, mfilename, 'P'), varargin);



%% Do your code magic here

% Holds all package bases
b = cell(1, nargin);

% Go through
for ip = 1:nargin
  % Get folder hierarchy
  try
    p = strsplit(fileparts(which(varargin{ip})), filesep);
    % Remove all package and class folder parts
    p(contains(p, {'@', '+'})) = [];
    p(cellfun(@isempty, p)) = deal({filesep});
    % Push to cell array
    b{ip} = fullfile(p{:});
  catch me
    warning(me.identifier, '%s', me.message);
  end
end



%% Assign output arguments

% For a single package name given, return only this results
if nargin == 1
  b = b{1};
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
