function [numargs, pvargs] = pvparams(varargin)
%% PVPARAMS Split variable arguments into numeric and name/value pairs
%
%   [NUMARGS, PVARGS] = PVPARAMS(VARARGIN) splits the list of variable arguments
%   into a list of numeric arguments NUMARGS and of name/value pairs PVARGS.
%
%   Outputs:
%
%   NUMARGS             Cell array of numeric args extracted from VARARGIN.
%
%   PVARGS              Cell array of name/value args extracted from VARARGIN.
%
%   See also
%   PARSEPARAMS



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2019-01-27
% Changelog:
%   2019-01-27
%       * Initial release



%% Split stuff

% Gather if argument is is a char or string
idxChars = cellfun(@matlab.graphics.internal.isCharOrString, varargin);

% Find the first char or string argument
charindx = find(idxChars);

% None found => all numeric args
if isempty(charindx)
  numargs = varargin;
  pvargs = varargin(1:0);
% Found one, split arguments
else
  numargs = varargin(1:charindx(1)-1);
  pvargs = varargin(charindx(1):end);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
