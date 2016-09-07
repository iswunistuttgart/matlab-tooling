function [varargout] = cogiro_importcontrol(Filename, varargin)
% COGIRO_IMPORTCONTROL imports the control command from the provided file
%
%   C = COGIRO_IMPORTCONTROL(FILENAME) imports control command information
%   stored in FILENAME and puts it into timeseries collection C.
%
%   C = COGIRO_IMPORTCONTROL(FILENAME, 'Name', 'Value') imports control command
%   information in FILENAME with additional options specified by one or more
%   Name,Value pair arguments.
%
%   [POS, VEL, ACC] = COGIRO_IMPORTCONTROL(FILENAME, ...) returns the data split
%   into position POS, velocity VEL, and acceleration ACC data. All returned
%   data will be a time series for the given command data. If optional input
%   'SplitCommands' is given, each data will be a cell array of time series.
%
%   [POS, VEL, ACC, CMD] = COGIRO_IMPORTCONTROL(FILENAME, ...) additionally
%   returns time series of the command. All returned data will be a time series
%   for the given command data. If optional input 'SplitCommands' is given, each
%   data will be a cell array of time series.
%
%   Inputs:
%   
%   FILENAME    File name of file to import. Can be a name of a file on the
%               MATLAB path or in the local working directory. Can basically be
%               anything that qualifies as a valid file. File must be generated
%               by B&R control system and stored as a .MAT-file.
%
%   Outputs:
%   
%   C           Timeseries collection of timeseries with fields
%               - SetPose_Position: timeseries of command value for the
%               Cartesian set position of the cable robot's mobile platform's
%               point of reference. The columns of SetPose_Position are
%                   [x, y, z, a, b, c]
%               or
%                   [x, y, z, roll, pitch, heading(yaw) ].
%               - SetPose_Velocity: timeseries of commanded Cartesian velocities
%               as obtained form numeric differentiation by the control system
%               of SetPose_Position. Columns are sorted same as for
%               SetPose_Position.
%               - SetPose_Acceleration: timeseries of commanded Cartesian
%               acceleration as obtained from numeric differentiation by the
%               control system of SetPose_Velocity. Columns are sorted same as
%               for SetPos_Position.
%
%
%   Optional Inputs -- specified as parameter value pairs
%   Sampling    Sampling time rate of the IMU system for creation of proper time
%               information. Defaults to 1.2 ms.
%   
%   SplitCommands   Switch whether to split the commands as determiend by the
%                   value of variable 'MainControl_Command_StartNewMove' or not.
%                   Possible values are
%                   'on','yes'      Split commands
%                   'off','no'      Do not split commands
%                   'SplitCommands' can be used in conjunction with the number
%                   of outputs as follows
%                   COLL = COGIRO_IMPORTCONTROL(FILENAME) returns a cell array
%                   of time series collections for each commanded trajectory.
%                   [POS, VEL, ACC] = COGIRO_IMPORTCONTROL(FILENAME) returns
%                   three cell arrays of time series for each commanded
%                   trajectory. Additionally,
%                   [POS, VEL, ACC, CMD] = COGIRO_IMPORTCONTROL(FILENAME)
%                   returns a cell array of command time series, too.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-01
% Changelog:
%   2016-09-01
%       * Update help block with missing param/value pair
%       * Add support for returning split commands into separate variables
%   2016-08-23
%       * Introduce inputParser to function
%   2016-06-15
%       * Add help doc
%       * Transform return value into a timseries collection
%   2016-06-14
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename. Char. Non-empty
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: SamplingTime. Real. Positive
valFcn_Sampling = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'Sampling');
addParameter(ip, 'Sampling', 0, valFcn_Sampling);

% Optional 2: SplitCommands. Char. {'on', 'off', 'yes', 'no'
valFcn_SplitCommands = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'SplitCommands'));
addParameter(ip, 'SplitCommands', 'off', valFcn_SplitCommands);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Filename}, varargin];
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
% Filename
chFilename = fullpath(ip.Results.Filename);
% Sampling Time
dSamplingTime = ip.Results.Sampling;
% Split commands
chSplitCommands = parseswitcharg(ip.Results.SplitCommands);



%% Process number of return arguments
% If the commands shall be split, we allow only one argument to be returned:
% collection of collection of commands
% if strcmp(chSplitCommands, 'on')
%     nargoutchk(1, 1);
% end
% If not commands split but more than one output argument requested ...
if nargout > 1
    % Make sure it are three or four i.e., [Pos,Vel,Acc] or [Pos,Vel,Acc,Cmd]
    nargoutchk(3, 4)
end



%% Data assertion
assert(2 == exist(chFilename, 'file'), 'PHILIPPTEMPEL:COGIRO_IMPORTCONTROL:invalidFileName', 'File cannot be found');
[~, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.mat', chFile_Ext), 'PHILIPPTEMPEL:COGIRO_IMPORTCONTROL:invalidFileExt', 'Invalid file extension [%s] found. Must be [.mat].', chFile_Ext);



%% Load control system data
% Load the file
try
    stLoadedData = load(chFilename);
catch me
    error('PHILIPPTEMPEL:COGIRO_IMPORTCONTROL:fileLoadFailure', 'Could not load file with error: %s', me.message);
end

% Rename the loaded data
ceFieldnames = fieldnames(stLoadedData);

% Loop over the fieldnames and rename them
for iFieldname = 1:numel(ceFieldnames)
    if ~regexp(ceFieldnames{iFieldname}, '^TARGET_DATA____')
        continue
    end
    
    % Remove unnecessary 'TARGET_DATA___' prefix from variable names
    stLoadedData.(strrep(ceFieldnames{iFieldname}, 'TARGET_DATA____', '')) = stLoadedData.(ceFieldnames{iFieldname});
    stLoadedData = rmfield(stLoadedData, ceFieldnames{iFieldname});
end
% Get the new fieldnames
ceFieldnames = fieldnames(stLoadedData);



%% Pre-process data
% Get the time from the experiment
nTimeSamples = max(size(stLoadedData.(ceFieldnames{iFieldname})));
% If no sampling time was provided, we will take the data from the first row of
% the first entry of the imported data
if dSamplingTime == 0
    dSamplingTime = round(mean(diff(stLoadedData.(ceFieldnames{1})(1,:))), 4);
end
vExp_Time = (0:1:(nTimeSamples-1)).*dSamplingTime;

% Initialize variables holding data
vTime = vExp_Time;
vCommand = zeros(nTimeSamples, 1);
aSetPose_Pos = zeros(nTimeSamples, 6);
aSetPose_Vel = zeros(nTimeSamples, 6);
aSetPose_Acc = zeros(nTimeSamples, 6);



%% Assign data from imported data

%%% Command data
if isfield(stLoadedData, 'MainControl_Command_StartNewMove')
    vCommand = ascolumn(stLoadedData.MainControl_Command_StartNewMove(2,:));
end

%%% Position data
% X position
if isfield(stLoadedData, 'Xcurrent_0_')
    aSetPose_Pos(:,1) = ascolumn(stLoadedData.Xcurrent_0_(2,:));
end
% Y position
if isfield(stLoadedData, 'Xcurrent_1_')
    aSetPose_Pos(:,2) = ascolumn(stLoadedData.Xcurrent_1_(2,:));
end
% Z position
if isfield(stLoadedData, 'Xcurrent_2_')
    aSetPose_Pos(:,3) = ascolumn(stLoadedData.Xcurrent_2_(2,:));
end
% A position
if isfield(stLoadedData, 'Xcurrent_3_')
    aSetPose_Pos(:,4) = ascolumn(stLoadedData.Xcurrent_3_(2,:));
end
% B position
if isfield(stLoadedData, 'Xcurrent_4_')
    aSetPose_Pos(:,5) = ascolumn(stLoadedData.Xcurrent_4_(2,:));
end
% C position
if isfield(stLoadedData, 'Xcurrent_5_')
    aSetPose_Pos(:,6) = ascolumn(stLoadedData.Xcurrent_5_(2,:));
end

%%% Velocity data
% X velocity
if isfield(stLoadedData, 'Vcurrent_0_')
    aSetPose_Vel(:,1) = ascolumn(stLoadedData.Vcurrent_0_(2,:));
end
% Y velocity
if isfield(stLoadedData, 'Vcurrent_1_')
    aSetPose_Vel(:,2) = ascolumn(stLoadedData.Vcurrent_1_(2,:));
end
% Z velocity
if isfield(stLoadedData, 'Vcurrent_2_')
    aSetPose_Vel(:,3) = ascolumn(stLoadedData.Vcurrent_2_(2,:));
end
% A velocity
if isfield(stLoadedData, 'Vcurrent_3_')
    aSetPose_Vel(:,4) = ascolumn(stLoadedData.Vcurrent_3_(2,:));
end
% B velocity
if isfield(stLoadedData, 'Vcurrent_4_')
    aSetPose_Vel(:,5) = ascolumn(stLoadedData.Vcurrent_4_(2,:));
end
% C velocity
if isfield(stLoadedData, 'Vcurrent_5_')
    aSetPose_Vel(:,6) = ascolumn(stLoadedData.Vcurrent_5_(2,:));
end

%%% Acceleration data
% X acceleration
if isfield(stLoadedData, 'Acurrent_0_')
    aSetPose_Acc(:,1) = ascolumn(stLoadedData.Acurrent_0_(2,:));
end
% Y acceleration
if isfield(stLoadedData, 'Acurrent_1_')
    aSetPose_Acc(:,2) = ascolumn(stLoadedData.Acurrent_1_(2,:));
end
% Z acceleration
if isfield(stLoadedData, 'Acurrent_2_')
    aSetPose_Acc(:,3) = ascolumn(stLoadedData.Acurrent_2_(2,:));
end
% A acceleration
if isfield(stLoadedData, 'Acurrent_3_')
    aSetPose_Acc(:,4) = ascolumn(stLoadedData.Acurrent_3_(2,:));
end
% B acceleration
if isfield(stLoadedData, 'Acurrent_4_')
    aSetPose_Acc(:,5) = ascolumn(stLoadedData.Acurrent_4_(2,:));
end
% C acceleration
if isfield(stLoadedData, 'Acurrent_5_')
    aSetPose_Acc(:,6) = ascolumn(stLoadedData.Acurrent_5_(2,:));
end



%% Turn into timeseries
% Command data
tsCommand = timeseries(vCommand, vTime, 'Name', 'Command');
tsCommand.UserData.Name = chFile_Name;
tsCommand.Userdata.Source = chFilename;
% Position data
tsPosition = timeseries(aSetPose_Pos, vTime, 'Name', 'Position');
tsPosition.UserData.Name = chFile_Name;
tsPosition.UserData.Source = chFilename;
% Velocity data
tsVelocity = timeseries(aSetPose_Vel, vTime, 'Name', 'Velocity');
tsVelocity.UserData.Name = chFile_Name;
tsVelocity.UserData.Source = chFilename;
% Acceleration data
tsAcceleration = timeseries(aSetPose_Acc, vTime, 'Name', 'Acceleration');
tsAcceleration.UserData.Name = chFile_Name;
tsAcceleration.UserData.Source = chFilename;



%% Split commands?
if strcmp('on', chSplitCommands)
    % When commands where changed i.e., from 0 to 1 or from 1 to zero
    vCommandChange = diff(tsCommand.Data);
    
    % Get inices of command "ON"
    vCommands_On = find(vCommandChange == 1);
    % Get indices of command "OFF"
    vCommands_Off = find(vCommandChange == -1);
    
    % Ensure we have enough OFFs as ONs
    if numel(vCommands_Off) < numel(vCommands_On)
        % Add the last index of the time as the last time a command was turned
        % off
        vCommands_Off = [vCommands_Off; numel(tsCommand.Time)];
    end
    
    % How many commands do we have?
    nCommands = numel(vCommands_On);
    
    % Cell array to hold all the collections
    ceCollection = cell(nCommands, 1);
    
    % Loop over all commands
    for iCommand = 1:nCommands
        % Get the indices selector for the given command
        vCommand_Selector = vCommands_On(iCommand):1:vCommands_Off(iCommand);
        
        % Build a time series for the command
        tsCommand_Cmd = getsampleusingtime(tsCommand, tsCommand.Time(vCommand_Selector(1)), tsCommand.Time(vCommand_Selector(end)));
        tsCommand_Cmd.Time = tsCommand_Cmd.Time - tsCommand.Time(vCommand_Selector(1));
        tsCommand_Cmd.Name = 'Command';
        tsCommand_Cmd.TimeInfo.UserData.RelStartTime = tsCommand.Time(vCommand_Selector(1));
        tsCommand_Cmd.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded position
        tsCommand_Pos = getsampleusingtime(tsPosition, tsPosition.Time(vCommand_Selector(1)), tsPosition.Time(vCommand_Selector(end)));
        tsCommand_Pos.Time = tsCommand_Pos.Time - tsPosition.Time(vCommand_Selector(1));
        tsCommand_Pos.Name = 'Position';
        tsCommand_Pos.TimeInfo.UserData.RelStartTime = tsPosition.Time(vCommand_Selector(1));
        tsCommand_Pos.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded velocity
        tsCommand_Vel = getsampleusingtime(tsVelocity, tsVelocity.Time(vCommand_Selector(1)), tsVelocity.Time(vCommand_Selector(end)));
        tsCommand_Vel.Time = tsCommand_Vel.Time - tsVelocity.Time(vCommand_Selector(1));
        tsCommand_Vel.Name = 'Velocity';
        tsCommand_Vel.TimeInfo.UserData.RelStartTime = tsVelocity.Time(vCommand_Selector(1));
        tsCommand_Vel.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded acceleration
        tsCommand_Acc = getsampleusingtime(tsAcceleration, tsAcceleration.Time(vCommand_Selector(1)), tsAcceleration.Time(vCommand_Selector(end)));
        tsCommand_Acc.Time = tsCommand_Acc.Time - tsAcceleration.Time(vCommand_Selector(1));
        tsCommand_Acc.Name = 'Acceleration';
        tsCommand_Acc.TimeInfo.UserData.RelStartTime = tsAcceleration.Time(vCommand_Selector(1));
        tsCommand_Acc.TimeInfo.Increment = dSamplingTime;
        
        % And create and push a time series collection to the cell of all
        ceCollection{iCommand} = tscollection({tsCommand_Cmd, tsCommand_Pos, tsCommand_Vel, tsCommand_Acc}, 'Name', sprintf('%s_cmd%i', chFile_Name, iCommand));
    end
end



%% Create a collection of timeseries
% One output: collection of all data
if strcmp('on', chSplitCommands)
    % [Coll] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout == 1
        varargout{1} = ceCollection;
    end
    
    % Extract position etc from gathered data
    cePos = cell(nCommands, 1);
    ceVel = cell(nCommands, 1);
    ceAcc = cell(nCommands, 1);
    ceCmd = cell(nCommands, 1);
    for iCommand = 1:numel(ceCollection)
        cePos{iCommand} = ceCollection{iCommand}.Position;
        ceVel{iCommand} = ceCollection{iCommand}.Velocity;
        ceAcc{iCommand} = ceCollection{iCommand}.Acceleration;
        ceCmd{iCommand} = ceCollection{iCommand}.Command;
    end
    
    % [Pos, Vel, Acc] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 3
        varargout{1} = cePos;
        varargout{2} = ceVel;
        varargout{3} = ceAcc;
    end
    
    % [Pos, Vel, Acc, Cmd] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 4
        varargout{4} = ceCmd;
    end
else
    % [Coll] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout == 1
        varargout{1} = tscollection({tsCommand, tsPosition, tsVelocity, tsAcceleration}, 'Name', chFile_Name);
    end

    % [Pos, Vel, Acc] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 3
        varargout{1} = tsPosition;
        varargout{2} = tsVelocity;
        varargout{3} = tsAcceleration;
    end

    % [Pos, Vel, Acc, Cmd] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 4
        varargout{4} = tsCommand;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
