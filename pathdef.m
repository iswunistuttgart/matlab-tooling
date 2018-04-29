function p = pathdef()
% PATHDEF returns the path definiton for this project
%
%   Outputs:
%
%   P                   Cell array of paths to automatically load



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-29
% Changelog:
%   2018-04-29
%       * Initial release



%% Do your code magic here

chPath = fileparts(mfilename('fullpath'));

p = {
    fullfile(chPath) ...
    , genpath(fullfile(chPath, 'utils'));
};


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
