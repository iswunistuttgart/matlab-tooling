function startup()
% STARTUP starts this project



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-29
% Changelog:
%   2018-04-29
%       * Move all path definitions to `pathdef.m`
%   2017-03-12
%       * Initial release



%% Do your code magic here

% Set random number generator to a set or pre-defined options
setrng()

% Copy all ExportSetup files to where MATLAB will look for them
try
    copyfile(fullfile(fileparts(mfilename('fullpath')), 'plot', 'ExportSetup', '*.txt'), fullfile(prefdir(0), 'ExportSetup'));
catch me
    warning(me.identifier, '%s', me.message);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
