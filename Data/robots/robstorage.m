function [path] = robstorage()
% ROBSTORAGE returns the path to the storage location of robot configuration
% files
%
%   Outputs:
%
%   PATH        Path to the robot storage location folder.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-06
% Changelog:
%   2016-09-06
%       * Initial release



%% Do your code magic here

[path, ~, ~] = fileparts(mfilename('fullpath'));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
