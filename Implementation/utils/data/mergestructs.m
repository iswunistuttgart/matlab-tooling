function [s] = mergestructs(varargin)
% MERGESTRUCTS merges multiple structs into one
%
%   S = MERGESTRUCTS(S1, S2, ...) merges S2 and succeeding structs into S1. The
%   values of the latest struct will overwrite the previous structs respective
%   fields.
%
%   Inputs:
%
%   S1      Base struct that shall be merged into.
%
%   S2      Structure array that shall be merged into S1
%
%   Outputs:
%
%   S       Structure array merge of all other structures from S1 to SN



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-21
% Changelog:
%   2016-09-21
%       * Initial release



%% Assert arguments
narginchk(1, Inf);
% All arguments must be struct
assert(all(cellfun(@(x) isstruct(x), varargin)), 'PHILIPPTEMPEL:MATLAB_TOOLING:MERGESTRUCTS:InvalidType', 'All arguments must be struct');
% Any argument must be non-empty
assert(any(cellfun(@(x) ~isempty(fieldnames(x)), varargin)), 'PHILIPPTEMPEL:MATLAB_TOOLING:MERGESTRUCTS:EmptyStructs', 'At least one struct must be non-empty.');



%% Do your code magic here
% Get the base struct
s = varargin{1};
% Get all other structs
os = varargin(2:end);

% Loop over other structs
for iS = 1:numel(os)
    fns = fieldnames(os{iS});
    
    for iFn = 1:numel(fns)
        s.(fns{iFn}) = os{iS}.(fns{iFn});
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
