function Collection = cogiro_importimu(Filename, varargin)
% COGIRO_IMPORTIMU imports IMU data for the CoGiRo cable robot
%
%   C = COGIRO_IMPORTIMU(FILENAME) reads file given by FILENAME, proccesses data,
%   and returns it in a timeseries-collection C.
%
%   C = COGIRO_IMPORTIMU(FILENAME, 'Name', 'Value') reads file given by
%   FILENAME with additional options specified by one or more Name,Value pair
%   arguments.
%
%   Inputs:
%   
%   FILENAME    File name of file to import. Can be a name of a file on the
%               MATLAB path or in the local working directory. Can basically be
%               anything that qualifies as a valid file. File must be created by
%               export from the IMU and its extension must be .lirmm
%
%   Outputs:
%   
%   C           Timeseries collection of timeseries with fields
%               - Position: timeseries of position data as acquired by the
%               IMU. Data is stored in columns
%                   [x, y, z, a, b, c]
%               or
%                   [x, y, z, roll, pitch, heading(yaw) ]
%               - Velocity: timeseries of velocity data as acquired by the
%               IMU. Data is stored in same columns as for C.POSITION
%               - Acceleration: timseries of acceleration data as acquired
%               by the IMU. No transformation is done an ddata is sorted same as
%               for C.Position
%               - CableForces: timeseries of cable forces as acquired by the
%               IMU. The columns are sorted in one-based index for the canals of
%               the IMU data i.e.,
%                   [can0, can1, can2, can3, can4, can5, can6, can7]
%               or in cable forces
%                   [f1, f2, f3, f4, f5, f6, f7, f8]
%
%   Optional Inputs -- specified as parameter value pairs
%
%   SamplingTime    Sampling time rate of the IMU system for creation of proper
%                   time information. Defaults to 100 ms.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-23
% Changelog:
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
valFcn_SamplingTime = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'SamplingTime');
addParameter(ip, 'SamplingTime', 100*1e-3, valFcn_SamplingTime);

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
dSamplingTime = ip.Results.SamplingTime;



%% Data assertion
assert(2 == exist(chFilename, 'file'), 'File cannot be found');
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.lirmm', chFile_Ext), 'Invalid file extension [%s] found. Must be [.lirmm].', chFile_Ext);



%% Read IMU data file
try
    aLoadedData = if_importImuDataFile(chFilename);
catch me
    error('Could not load file with error: %s', me.message);
end



%% Pre-process data
% How many data points do we have?
nTimeSamples = numel(aLoadedData(:,1));

vTime = (0:(nTimeSamples - 1)).*dSamplingTime;
aIsPose_Pos = zeros(nTimeSamples, 6);
aIsPose_Vel = zeros(nTimeSamples, 6);
aIsPose_Acc = zeros(nTimeSamples, 6);
aForces = zeros(nTimeSamples, 8);



%% Assign measurement data
%%% Position
% % X position (does not exist)
% aIsPose_Pos(:,1) = ;
% % Y position (does not exist)
% aIsPose_Pos(:,1) = ;
% % Z position (does not exist)
% aIsPose_Pos(:,3) = ;
% A position (does not exist)
aIsPose_Pos(:,4) = aLoadedData(:,5);
% B position (does not exist)
aIsPose_Pos(:,5) = aLoadedData(:,6);
% C position (does not exist)
aIsPose_Pos(:,6) = aLoadedData(:,7);


%%% Velocities
% % X velocity (does not exist)
% aIsPose_Vel(:,1) = ;
% % Y velocity (does not exist)
% aIsPose_Vel(:,2) = ;
% % Z velocity (does not exist)
% aIsPose_Vel(:,3) = ;
% A velocity
aIsPose_Vel(:,4) = aLoadedData(:,8);
% B velocity
aIsPose_Vel(:,5) = aLoadedData(:,9);
% C velocity
aIsPose_Vel(:,6) = aLoadedData(:,10);


%%% Accelerations
% X acceleration
aIsPose_Acc(:,1) = aLoadedData(:,2);
% Y acceleration
aIsPose_Acc(:,2) = aLoadedData(:,3);
% Z acceleration
aIsPose_Acc(:,3) = aLoadedData(:,4);
% % A acceleration
% aIsPose_Acc(:,4) = ;
% % B acceleration
% aIsPose_Acc(:,5) = ;
% % C acceleration
% aIsPose_Acc(:,6) = ;


%%% Cable forces
aForces(:,1) = aLoadedData(:,11);
aForces(:,2) = aLoadedData(:,12);
aForces(:,3) = aLoadedData(:,13);
aForces(:,4) = aLoadedData(:,14);
aForces(:,5) = aLoadedData(:,15);
aForces(:,6) = aLoadedData(:,16);
aForces(:,7) = aLoadedData(:,17);
aForces(:,8) = aLoadedData(:,18);



%% Create timeseries of data
% Position data
tsIsPose_Pos = timeseries(aIsPose_Pos, vTime, 'Name', 'Position');
tsIsPose_Pos.UserData.Name = chFile_Name;
tsIsPose_Pos.UserData.Source = chFilename;
% Velocity data
tsIsPose_Vel = timeseries(aIsPose_Vel, vTime, 'Name', 'Velocity');
tsIsPose_Vel.UserData.Name = chFile_Name;
tsIsPose_Vel.UserData.Source = chFilename;
% Acceleration data
tsIsPose_Acc = timeseries(aIsPose_Acc, vTime, 'Name', 'Acceleration');
tsIsPose_Acc.UserData.Name = chFile_Name;
tsIsPose_Acc.UserData.Source = chFilename;
% Cable forces
tsForces = timeseries(aForces, vTime, 'Name', 'CableForces');
tsForces.UserData.Name = chFile_Name;
tsForces.UserData.Source = chFilename;



%% Assign return value
% Return collection is a collcetion of timeseries data
Collection = tscollection({tsIsPose_Pos, tsIsPose_Vel, tsIsPose_Acc, tsForces}, 'Name', chFile_Name);


end


function ImuData = if_importImuDataFile(Filename, StartRow, EndRow)

%% Input defaults
if nargin < 2
    StartRow = 2;
end

if nargin < 3
    EndRow = Inf;
end



%% Assert arguments
assert(ischar(Filename), 'Filename must be char');

assert(isnatural(StartRow) && StartRow < EndRow, 'StartRow must be a positive natural number and smaller than EndRow');

assert(( isinf(EndRow) || isnatural(EndRow) ) && EndRow > StartRow, 'EndRow must be a positive natural number (or Inf) and larger than StartRow');



%% Initialize variables.
chDelimiter = ';';



%% Process inputs
% Filename: char
chFilename = Filename;
% Start row: integer
nStartRow = StartRow;
% End row: integer, unbound
nEndRow = EndRow;



%% Format string for each line of text:
%   column1: double (%f) time step (dependent on sampling time
%	column2: double (%f) ax
%   column3: double (%f) ay
%	column4: double (%f) az
%   column5: double (%f) roll
%	column6: double (%f) pitch
%   column7: double (%f) heading
%	column8: double (%f) gx
%   column9: double (%f) gy
%	column10: double (%f) gz
%   column11: double (%f) can0 (f1)
%	column12: double (%f) can1 (f2)
%   column13: double (%f) can2 (f3)
%	column14: double (%f) can3 (f4)
%   column15: double (%f) can4 (f5)
%	column16: double (%f) can5 (f6)
%   column17: double (%f) can6 (f7)
%	column18: double (%f) can7 (f8)
% For more information, see the TEXTSCAN documentation.
chFormatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';



%% Open the text file.
hFile = fopen(chFilename,'r');



%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this code. If
% an error occurs for a different file, try regenerating the code from the
% Import Tool.
ceDataArray = textscan(hFile, chFormatSpec, nEndRow(1) - nStartRow(1) + 1, 'Delimiter', chDelimiter, 'HeaderLines', nStartRow(1) - 1, 'ReturnOnError', false);
for block = 2:length(nStartRow)
    frewind(hFile);
    ceDataArrayBlock = textscan(hFile, chFormatSpec, nEndRow(block) - nStartRow(block) + 1, 'Delimiter', delimiter, 'HeaderLines', nStartRow(block) - 1, 'ReturnOnError', false);
    for col = 1:length(ceDataArray)
        ceDataArray{col} = [ceDataArray{col};ceDataArrayBlock{col}];
    end
end



%% Close the text file.
fclose(hFile);



%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for unimportable
% data, select unimportable cells in a file and regenerate the script.



%% Allocate imported array to column variable names
ImuData = [ceDataArray{1:end-1}];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
