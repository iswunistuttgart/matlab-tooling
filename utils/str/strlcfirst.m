function [LCed] = strlcfirst(varargin)
% STRLCFIRST lower cases the frist character of the string(s)
%
%   Inputs:
%
%   STRING      Description of argument STRING
%
%   Outputs:
%
%   UCED        Description of argument UCED



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-11
% Changelog:
%   2016-09-11
%       * Fix bug that a cell array was returned when only one argument was
%       given
%   2016-09-05
%       * Initial release



%% Do your code magic here

LCed = varargin;

for iStr = 1:nargin
    LCed{iStr}(1) = lower(LCed{iStr}(1));
end

if nargin == 1
    LCed = LCed{1};
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
