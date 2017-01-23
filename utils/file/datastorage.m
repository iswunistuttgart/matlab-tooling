function ds = datastorage()
% DATASTORAGE returns the path to the data storage of this project
%
%   Outputs:
%
%   DS                  Path to the data storage i.e., ../../data/ relative to
%       this file's location



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-04
% Changelog:
%   2017-01-04
%       * Initial release



%% Do your code magic here

ds = fullpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data'));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
