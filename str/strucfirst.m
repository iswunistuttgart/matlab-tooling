function [UCed] = strucfirst(varargin)
% STRUCFIRST upper cases the frist character of the string(s)
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
% Date: 2016-09-05
% Changelog:
%   2016-09-05
%       * Initial release



%% Do your code magic here

UCed = varargin;

for iStr = 1:nargin
    UCed{iStr}(1) = upper(UCed{iStr}(1));
end

if nargin == 1
    UCed = UCed{1};
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
