function [] = robsave(varargin)
% ROBSAVE saves a robot configuration to the storage of all robots
%
%   ROBSAVE saves the configruation variables found in the workspace under the
%   name found in variable 'Robot_Name' in the global robots storage folder of
%   this matlab tooling kit.
%
%   ROBSAVE(NAME) saves configuration variables found in the workspace under
%   name NAME.
%
%   ROBSAVE(NAME, VARIABLES) saves only configuration variables listed in cell
%   array VARIABLES.
%
%   ROBSAVE(NAME, VARIABLES, OVERWRITE) sets the overwrite toggle to OVERWRITE
%   which can be any of the following list
%       'on', 'yes'     Overwrites target file
%       'off', 'no'     Does not overwrite target file
%   If a target file is found and OVERWRITE is set to 'off' or 'no', the current
%   timestamp will be appended to the file.
%
%   ROBSAVE('Name', 'Value', ...) uses name-value pair syntax.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Name        Name of the robot to save current configuration as
%
%   Variables   If variables should not be taken from the workspace but given by
%       the user, this cell array must contain the variables' names.
%
%   Overwrite   Switch to enable or disable overwriting. Possible values are
%           'on', 'yes'     Overwrite target file
%           'off', 'no'     Do not overwrite target file but append current
%                           timestamp to the filename



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Update script to work nicer with overwriting and not overwriting
%       target file
%   2016-09-06
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Anchors. Must be a 3xN array
valFcn_Name = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Name');
addParameter(ip, 'Name', '', valFcn_Name);

% Optional 1: AnchorSpec. One-dimensional or two-dimensional cell-array
valFcn_Variables = @(x) validateattributes(x, {'struct'}, {}, mfilename, 'Variables');
addParameter(ip, 'Variables', {}, valFcn_Variables);

% Overwrite: Char. Matches {'on', 'off', 'yes', 'no'}. Defaults 'no';
valFcn_Overwrite = @(x) any(validatestring(x, {'on', 'off', 'yes', 'no'}, mfilename, 'Overwrite'));
addParameter(ip, 'Overwrite', 'off', valFcn_Overwrite);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse IP variables and create other, local variables

% Name of robot
chName = ip.Results.Name;
% Variables to save
stVariables = ip.Results.Variables;
% Overwrite toggle
chOverwrite = ip.Results.Overwrite;
% Get path to robot storage
chPath_Store = robstorage();

% Ensure target folder exists
if ~exist(chPath_Store, 'dir')
    mkdir(chPath_Store);
end
% Ensure we have a name of the robot
if isempty(chName)
    % Get robot name from workspace stored in variable 'Robot_Name'
    stRobotName = evalin('caller', 'whos(''Robot_Name'');');
    % If we have found some variable, we only need to parse it
    if ~isempty(stRobotName)
        chName = evalin('caller', stRobotName(1).name);
    end
end
% Ensure we have variables
if isempty(stVariables)
    % Get all variables in workspace
    stVariables = evalin('base', 'whos(''*'');');
    % And get the names of all variables
    stVariables = {stVariables(:).name};
end

% Filename of stored file
chFilename = fullfile(chPath_Store, chName);



%% Additional assertion

% We need variables to save...
assert(~isempty(stVariables), 'PHILIPPTEMPEL:ROBSAVE:noVariablesFound', 'No variables given and no variables found in caller workspace');



%% Do your code magic here

% Keeps a copy of each variable to save later on
stStore = struct();

% Loop over all variables and store them to a local struct
for iVar = 1:numel(stVariables)
    stStore.(stVariables{iVar}) = evalin('caller', stVariables{iVar});
end

% If we shall overwrite
if strcmp('on', chOverwrite)
    % And finally, save the file from the struct we have created above
    save(chFilename, '-struct', 'stStore');
% Do not overwrite the filename
else
    tsave(chFilename, '-struct', 'stStore');
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
