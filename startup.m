function startup()
% STARTUP inits this project



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-04
% Changelog:
%   2018-04-04
%       * Initial release



%% Do your code magic here

chPath = fileparts(mfilename('fullpath'));

cePaths = {
    fullfile(chPath);
    fullfile(chPath, 'classes');
};

addpaths(cePaths{:});


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
