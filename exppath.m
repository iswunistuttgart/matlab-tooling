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
%       * Support loading a 'exppath.mat' file and retrieving the folder path
%       from there
%       * Add support for loading folder path from a variable 'p' in the
%       caller's workspace
%   2018-04-04
%       * Initial release



%% Do your code magic here

% By default, this file's folder is where experiments are stored
p_ = fileparts(fullfile(mfilename('fullpath')));

% Check if there is an `exppath` file on the path that we can load
if 2 == exist('exppath.mat', 'file')
    % Load the file
    stConfig = load('exppath.mat');
    % And check if there is a 'p' variable inside
    if isfield(stConfig, 'p')
        p_ = stConfig.p;
    end
end

% Check if there's an exppath variable in the workspace
q = evalin('caller', 'whos()');
if numel(q) && any(strcmp('p', {q.name}))
    p_ = evalin('base', q(strcmp('p', {q.name})).name);
end



%% Assign output quantities
p = p_;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
