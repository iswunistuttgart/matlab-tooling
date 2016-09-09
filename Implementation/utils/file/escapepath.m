function [Escaped] = escapepath(Path)
% ESCAPEPATH 
%
%   Inputs:
%
%   PATH            Description of argument PATH
%
%   Outputs:
%
%   ESCAEPED        Description of argument ESCAEPED



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Initial release



%% Do your code magic here

Escaped = strrep(Path, '\', '\\');


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
