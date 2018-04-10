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
% Date: 2018-04-10
% Changelog:
%   2018-04-10
%       * Change function to support loading a 'exppath.mat' file and retrieving
%       the folder path from there
%   2018-04-04
%       * Initial release



%% Do your code magic here

% By default, this file's folder is where experiments are stored
p = fileparts(fullfile(mfilename('fullpath')));

% Check if there is an `exppath` file on the path that we can load
if 2 == exist('exppath.mat', 'file')
    % Load the file
    stConfig = load('exppath.mat');
    % And check if there is a 'p' variable inside
    if isfield(stConfig, 'p')
        p = stConfig.p;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
