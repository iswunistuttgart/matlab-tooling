function p = exppath()
% EXPPATH returns the path of the EXPERIMENTS project location
%
%   P = EXPPATH() returns the path of the EXPERIMENTS project location
%
%   Outputs
%
%   P                   Path to the EXPERIMENTS project i.e., to this file's
%                       parent folder.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-04
% Changelog:
%   2018-04-04
%       * Initial release



%% Do your code magic here

p = fileparts(fullfile(mfilename('fullpath')));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
