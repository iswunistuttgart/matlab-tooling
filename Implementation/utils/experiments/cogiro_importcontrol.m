function Collection = cogiro_importcontrol(Filename, SamplingTime)
% COGIRO_IMPORTCONTROL imports the control command from the provided file
%
%   C = COGIRO_IMPORTCONTROL(FILENAME) imports control command information
%   stored in FILENAME and puts it into timeseries collection C.
%
%   C = COGIRO_IMPORTCONTROL(FILENAME, SAMPLING) reads file with the specified
%   sampling time if different to the default 1.2 ms (milliseconds).
%
%   Inputs:
%   
%   FILENAME    File name of file to import. Can be a name of a file on the
%               MATLAB path or in the local working directory. Can basically be
%               anything that qualifies as a valid file. File must be generated
%               by B&R control system and stored as a .MAT-file.
%
%   SAMPLING    Sampling time rate of the IMU system for creation of proper time
%               information.
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



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-06-15
% Changelog:
%   2016-06-15
%       * Add help doc
%       * Transform return value into a timseries collection
%   2016-06-14
%       * Initial release



%% Default arguments
if nargin < 2
    SamplingTime = 1.2*1e-3;
end


%% Pre-process arguments
Filename = fullpath(Filename);



%% Assert arguments
% Filename: char
assert(ischar(Filename), 'File name must be char');
assert(2 == exist(Filename, 'file'), 'File cannot be found');
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.mat', chFile_Ext), 'Invalid file extension [%s] found. Must be [.mat].', chFile_Ext);

% Sampling time: numeric, scalar, greater than zero
assert(isnumeric(SamplingTime), 'Sampling time must be numeric');
assert(isscalar(SamplingTime), 'Sampling time must be scalar');
assert(SamplingTime > 0, 'Sampling time must be positive');



%% Process argumets
chFilename = Filename;
dSamplingTime = SamplingTime;



%% Load control system data
% Load the file
try
    stLoadedData = load(chFilename);
catch me
    error('Could not load file with error: %s', me.message);
end

% Rename the loaded data
ceFieldames = fieldnames(stLoadedData);

% Loop over the fieldnames and rename them
for iFieldname = 1:numel(ceFieldames)
    if ~regexp(ceFieldames{iFieldname}, '^TARGET_DATA____')
        continue
    end
    
    % Remove unnecessary 'TARGET_DATA___' prefix from variable names
    stLoadedData.(strrep(ceFieldames{iFieldname}, 'TARGET_DATA____', '')) = stLoadedData.(ceFieldames{iFieldname});
    stLoadedData = rmfield(stLoadedData, ceFieldames{iFieldname});
end



%% Pre-process data
% Get the time from the experiment
nTimeSamples = max(size(stLoadedData.MainControl_Command_StartNewMove));
vExp_Time = (0:1:(nTimeSamples-1)).*dSamplingTime;

% Determine the number of measurements
nDatapoints = numel(vExp_Time);

% Initialize variables holding data
vTime = vExp_Time;
aSetPose_Pos = zeros(nDatapoints, 6);
aSetPose_Vel = zeros(nDatapoints, 6);
aSetPose_Acc = zeros(nDatapoints, 6);



%% Assign data from imported data

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
% Position data
tsSetPose_Pos = timeseries(aSetPose_Pos, vTime, 'Name', 'SetPose_Position');
tsSetPose_Pos.UserData.Name = chFile_Name;
tsSetPose_Pos.UserData.Source = chFilename;
% Velocity data
tsSetPose_Vel = timeseries(aSetPose_Vel, vTime, 'Name', 'SetPose_Velocity');
tsSetPose_Vel.UserData.Name = chFile_Name;
tsSetPose_Vel.UserData.Source = chFilename;
% Acceleratio data
tsSetPose_Acc = timeseries(aSetPose_Acc, vTime, 'Name', 'SetPose_Acceleration');
tsSetPose_Acc.UserData.Name = chFile_Name;
tsSetPose_Acc.UserData.Source = chFilename;



%% Create a collection of timeseries
Collection = tscollection({tsSetPose_Pos, tsSetPose_Vel, tsSetPose_Acc}, 'Name', chFile_Name);


end