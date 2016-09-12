function [varargout] = robload(Name, varargin)
% ROBLOAD loads a given robot configuration
%
%   Inputs:
%
%   NAME        Name of robot to load



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-10
% Changelog:
%   2016-09-10
%       * Fix failing assignment of return valye
%   2016-09-06
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Anchors. Must be a 3xN array
valFcn_Name = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Name');
addRequired(ip, 'Name', valFcn_Name);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Name}, varargin];
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse IP variables and create local variables
% Name of robot to load
chName = ip.Results.Name;
% Get path to robot storage folder
chPath_Store = robstorage();



%% Find the robot file
% Find files inside the robot storage that match the robot name
stFiles = dir(fullfile(chPath_Store, sprintf('%s*', chName)));

% Ensure we found files
assert(~isempty(stFiles), 'PHILIPPTEMPEL:ROBLOAD:noRobotFound', 'No robot configuration found for robot [%s].', chName);

% Filter files that do not match the patter 'Name_yyyymmdd_HHMMSSFFF' => the
% length of the filename must be length(chName) + [0, 19] + 4 (4 for the file
% extension).
loFilter = cellfun(@(name) any(length(name) == (length(chName) + [0, 19] + 4)), {stFiles(:).name});

% And remove all non-matching files
stFiles = stFiles(loFilter);

% Sort the files from newest to oldest
[~, nSortedIdx] = sort([stFiles.datenum], 'descend');

% Get the newest file
iFile = nSortedIdx(1);

% Load the data file
stData = load(fullfile(chPath_Store, stFiles(iFile).name));



%% Assign output quantities
% If no output is given, we will assign all variables in the caller's workspace
if nargout == 0
    % Get variable names
    ceVariableNames = fieldnames(stData);
    % Loop over all variables and assign them in the caller's workspace
    for iData = 1:numel(ceVariableNames)
        assignin('caller', ceVariableNames{iData}, stData.(ceVariableNames{iData}));
    end
end

% If one output, we will assign the loaded struct to it
if nargout > 0
    varargout{1} = stData;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
