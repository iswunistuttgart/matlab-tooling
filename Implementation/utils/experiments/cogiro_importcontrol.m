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
%
%   FillMissing     Switch to fill in missing information by numerically
%       differentaiting the data found in the respective position or velocity
%       data. If for example velocity and acceleration data for the Z-axis
%       cannot be found but 'FillMissing' is 'on', then Z-velocity and
%       Z-acceleration will be filled in by means of gradient of position and
%       velocity, respectively, and smoothening filtering. Possible options are
%       'on', 'yes'     Fill in missing data
%       'off', 'no'     Do not fill in missing data
%
%   Resampling      Sampling time used for resampling of the data. Defaults to
%       0 i.e., no resampling.
%
%   Sampling    Sampling time rate of the IMU system for creation of proper time
%       information. Defaults to 1.2 ms.
%   
%   SplitCommands   Switch whether to split the commands as determiend by the
%       value of variable 'MainControl_Command_StartNewMove' or not. Possible
%       values are
%           'on','yes'      Split commands
%           'off','no'      Do not split commands
%       'SplitCommands' can be used in conjunction with the number of outputs as
%       follows
%       COLL = COGIRO_IMPORTCONTROL(FILENAME) returns a cell array of time
%       series collections for each commanded trajectory.
%       [POS, VEL, ACC] = COGIRO_IMPORTCONTROL(FILENAME) returns three cell
%       arrays of time series for each commanded trajectory. Additionally,
%       [POS, VEL, ACC, CMD] = COGIRO_IMPORTCONTROL(FILENAME) returns a cell
%       array of command time series, too.
%
%   See also: gradient sgolayfilt



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-08
% Changelog:
%   2016-09-08
%       * Add parameter 'Resampling' to perform internal resampling given a
%       specified resmapling time
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
addOptional(ip, 'Sampling', 0, valFcn_Sampling);

% Parameter: SplitCommands. Char. {'on', 'off', 'yes', 'no'}
valFcn_SplitCommands = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'SplitCommands'));
addParameter(ip, 'SplitCommands', 'off', valFcn_SplitCommands);

% Parameter: FillMissing. Char. {'on', 'off', 'yes', 'no'}
valFcn_FillMissing = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'FillMissing'));
addParameter(ip, 'FillMissing', 'off', valFcn_FillMissing);

% Optional 1: Sampling. Real. Positive
valFcn_Resampling = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'Resampling');
addParameter(ip, 'Resampling', 0, valFcn_Resampling);

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
% Fill missing data
chFillMissing = parseswitcharg(ip.Results.FillMissing);
% Resampling time
dResamplingTime = ip.Results.Resampling;



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

% Holds missing positional data
vMissingData = zeros(3, 6);

% Order of the sgolay filter for smoothing gradient of numerically derived
% velocity or acceleration
nFilterGradient_Order = 6;
% Frame size of sgolay filter for smoothing gradient of numerically derived
% velocity or acceleration
nFilterGradient_Framesize = 2*floor(floor(1/dSamplingTime/2)/2) + 1;



%% Assign data from imported data

%%% Command data
if isfield(stLoadedData, 'MainControl_Command_StartNewMove')
    vCommand = ascolumn(stLoadedData.MainControl_Command_StartNewMove(2,:));
end

%%% Position data
% X position
if isfield(stLoadedData, 'Xcurrent_0_')
    aSetPose_Pos(:,1) = ascolumn(stLoadedData.Xcurrent_0_(2,:));
else
    vMissingData(1,1) = 1;
end
% Y position
if isfield(stLoadedData, 'Xcurrent_1_')
    aSetPose_Pos(:,2) = ascolumn(stLoadedData.Xcurrent_1_(2,:));
else
    vMissingData(1,2) = 1;
end
% Z position
if isfield(stLoadedData, 'Xcurrent_2_')
    aSetPose_Pos(:,3) = ascolumn(stLoadedData.Xcurrent_2_(2,:));
else
    vMissingData(1,3) = 1;
end
% A position
if isfield(stLoadedData, 'Xcurrent_3_')
    aSetPose_Pos(:,4) = ascolumn(stLoadedData.Xcurrent_3_(2,:));
else
    vMissingData(1,4) = 1;
end
% B position
if isfield(stLoadedData, 'Xcurrent_4_')
    aSetPose_Pos(:,5) = ascolumn(stLoadedData.Xcurrent_4_(2,:));
else
    vMissingData(1,5) = 1;
end
% C position
if isfield(stLoadedData, 'Xcurrent_5_')
    aSetPose_Pos(:,6) = ascolumn(stLoadedData.Xcurrent_5_(2,:));
else
    vMissingData(1,6) = 1;
end

%%% Velocity data
% X velocity
if isfield(stLoadedData, 'Vcurrent_0_')
    aSetPose_Vel(:,1) = ascolumn(stLoadedData.Vcurrent_0_(2,:));
else
    vMissingData(2,1) = 1;
end
% Y velocity
if isfield(stLoadedData, 'Vcurrent_1_')
    aSetPose_Vel(:,2) = ascolumn(stLoadedData.Vcurrent_1_(2,:));
else
    vMissingData(2,2) = 1;
end
% Z velocity
if isfield(stLoadedData, 'Vcurrent_2_')
    aSetPose_Vel(:,3) = ascolumn(stLoadedData.Vcurrent_2_(2,:));
else
    vMissingData(2,3) = 1;
end
% A velocity
if isfield(stLoadedData, 'Vcurrent_3_')
    aSetPose_Vel(:,4) = ascolumn(stLoadedData.Vcurrent_3_(2,:));
else
    vMissingData(2,3) = 1;
end
% B velocity
if isfield(stLoadedData, 'Vcurrent_4_')
    aSetPose_Vel(:,5) = ascolumn(stLoadedData.Vcurrent_4_(2,:));
else
    vMissingData(2,5) = 1;
end
% C velocity
if isfield(stLoadedData, 'Vcurrent_5_')
    aSetPose_Vel(:,6) = ascolumn(stLoadedData.Vcurrent_5_(2,:));
else
    vMissingData(2,6) = 1;
end

%%% Acceleration data
% X acceleration
if isfield(stLoadedData, 'Acurrent_0_')
    aSetPose_Acc(:,1) = ascolumn(stLoadedData.Acurrent_0_(2,:));
else
    vMissingData(3,1) = 1;
end
% Y acceleration
if isfield(stLoadedData, 'Acurrent_1_')
    aSetPose_Acc(:,2) = ascolumn(stLoadedData.Acurrent_1_(2,:));
else
    vMissingData(3,2) = 1;
end
% Z acceleration
if isfield(stLoadedData, 'Acurrent_2_')
    aSetPose_Acc(:,3) = ascolumn(stLoadedData.Acurrent_2_(2,:));
else
    vMissingData(3,3) = 1;
end
% A acceleration
if isfield(stLoadedData, 'Acurrent_3_')
    aSetPose_Acc(:,4) = ascolumn(stLoadedData.Acurrent_3_(2,:));
else
    vMissingData(3,4) = 1;
end
% B acceleration
if isfield(stLoadedData, 'Acurrent_4_')
    aSetPose_Acc(:,5) = ascolumn(stLoadedData.Acurrent_4_(2,:));
else
    vMissingData(3,5) = 1;
end
% C acceleration
if isfield(stLoadedData, 'Acurrent_5_')
    aSetPose_Acc(:,6) = ascolumn(stLoadedData.Acurrent_5_(2,:));
else
    vMissingData(3,6) = 1;
end



%% Fill in missing data
if strcmp('on', chFillMissing)
    % Split missing data for position, velocity, and acceleration
    vMissingData_Pos = vMissingData(1,:);
    vMissingData_Vel = vMissingData(2,:);
    vMissingData_Acc = vMissingData(3,:);
    
    % Loop over missing velocity data
    for iIdx_Acc = 1:numel(vMissingData_Vel)
        % Skip if the velocity data exists
        if vMissingData_Vel(iIdx_Acc) == 0
            continue
        end
        
        % If we have position data for the velocity index
        if vMissingData_Pos(iIdx_Acc) == 0
            % We can get the velocity from deriving the position
            aSetPose_Vel(:,iIdx_Acc) = sgolayfilt(gradient(aSetPose_Pos(:,iIdx_Acc), dSamplingTime), nFilterGradient_Order, nFilterGradient_Framesize);
            % Ensure we know from here on that we have the velocity data
            vMissingData_Vel(iIdx_Acc) = 0;
        end
    end
    
    % Loop over missing velocity data
    for iIdx_Acc = 1:numel(vMissingData_Acc)
        % Skip if the acceleration data exists
        if vMissingData_Acc(iIdx_Acc) == 0
            continue
        end
        
        % If we have velocity data for the acceleration index
        if vMissingData_Vel(iIdx_Acc) == 0
            % We can get the acceleration from deriving the velocity
            aSetPose_Acc(:,iIdx_Acc) = sgolayfilt(gradient(aSetPose_Vel(:,iIdx_Acc), dSamplingTime), nFilterGradient_Order, nFilterGradient_Framesize);
        end
    end
end



%% Turn into timeseries
% Command data
tsCmd = timeseries(vCommand, vTime, 'Name', 'Command');
tsCmd.UserData.Name = chFile_Name;
tsCmd.Userdata.Source = chFilename;
% Position data
tsPos = timeseries(aSetPose_Pos, vTime, 'Name', 'Position');
tsPos.UserData.Name = chFile_Name;
tsPos.UserData.Source = chFilename;
% Velocity data
tsVel = timeseries(aSetPose_Vel, vTime, 'Name', 'Velocity');
tsVel.UserData.Name = chFile_Name;
tsVel.UserData.Source = chFilename;
% Acceleration data
tsAcc = timeseries(aSetPose_Acc, vTime, 'Name', 'Acceleration');
tsAcc.UserData.Name = chFile_Name;
tsAcc.UserData.Source = chFilename;

% Resampling necessary?
if dResamplingTime > 0
    % Determine new time vector
    vNewTime = (0:(tsCmd.Length - 1)).*dResamplingTime;
    % Perform resampling of all data
    tsCmd = resample(tsCmd, vNewTime);
    tsPos = resample(tsPos, vNewTime);
    tsVel = resample(tsVel, vNewTime);
    tsAcc = resample(tsAcc, vNewTime);
end



%% Split commands?
if strcmp('on', chSplitCommands)
    % When commands where changed i.e., from 0 to 1 or from 1 to zero
    vCommandChange = diff(tsCmd.Data);
    
    % Get inices of command "ON"
    vCommands_On = find(vCommandChange == 1);
    % Get indices of command "OFF"
    vCommands_Off = find(vCommandChange == -1);
    
    % Ensure we have enough OFFs as ONs
    if numel(vCommands_Off) < numel(vCommands_On)
        % Add the last index of the time as the last time a command was turned
        % off
        vCommands_Off = [vCommands_Off; numel(tsCmd.Time)];
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
        tsCommand_Cmd = getsampleusingtime(tsCmd, tsCmd.Time(vCommand_Selector(1)), tsCmd.Time(vCommand_Selector(end)));
        tsCommand_Cmd.Time = tsCommand_Cmd.Time - tsCmd.Time(vCommand_Selector(1));
        tsCommand_Cmd.Name = 'Command';
        tsCommand_Cmd.TimeInfo.UserData.RelStartTime = tsCmd.Time(vCommand_Selector(1));
        tsCommand_Cmd.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded position
        tsCommand_Pos = getsampleusingtime(tsPos, tsPos.Time(vCommand_Selector(1)), tsPos.Time(vCommand_Selector(end)));
        tsCommand_Pos.Time = tsCommand_Pos.Time - tsPos.Time(vCommand_Selector(1));
        tsCommand_Pos.Name = 'Position';
        tsCommand_Pos.TimeInfo.UserData.RelStartTime = tsPos.Time(vCommand_Selector(1));
        tsCommand_Pos.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded velocity
        tsCommand_Vel = getsampleusingtime(tsVel, tsVel.Time(vCommand_Selector(1)), tsVel.Time(vCommand_Selector(end)));
        tsCommand_Vel.Time = tsCommand_Vel.Time - tsVel.Time(vCommand_Selector(1));
        tsCommand_Vel.Name = 'Velocity';
        tsCommand_Vel.TimeInfo.UserData.RelStartTime = tsVel.Time(vCommand_Selector(1));
        tsCommand_Vel.TimeInfo.Increment = dSamplingTime;
        
        % Build a time series for the commanded acceleration
        tsCommand_Acc = getsampleusingtime(tsAcc, tsAcc.Time(vCommand_Selector(1)), tsAcc.Time(vCommand_Selector(end)));
        tsCommand_Acc.Time = tsCommand_Acc.Time - tsAcc.Time(vCommand_Selector(1));
        tsCommand_Acc.Name = 'Acceleration';
        tsCommand_Acc.TimeInfo.UserData.RelStartTime = tsAcc.Time(vCommand_Selector(1));
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
        varargout{1} = tscollection({tsCmd, tsPos, tsVel, tsAcc}, 'Name', chFile_Name);
    end

    % [Pos, Vel, Acc] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 3
        varargout{1} = tsPos;
        varargout{2} = tsVel;
        varargout{3} = tsAcc;
    end

    % [Pos, Vel, Acc, Cmd] = COGIRO_IMPORTCONTROL(FILENAME)
    if nargout >= 4
        varargout{4} = tsCmd;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
