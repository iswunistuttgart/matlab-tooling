function Collection = cogiro_importimu(Filename, SamplingTime)
% COGIRO_IMPORTIMU imports IMU data for the CoGiRo cable robot
%
%   C = COGIRO_IMPORTIMU(FILENAME) reads file given by FILENAME, proccesses data,
%   and returns it in a timeseries-collection C. By default, sampling time is
%   assumed to be 100 ms (milliseconds)
%
%   C = COGIRO_IMPORTIMU(FILENAME, SAMPLING) reads file at FILENAME with
%   specified sampling time SAMPLING. SAMPLING must be a numeric value greater
%   to zero
%
%   Inputs:
%   
%   FILENAME    File name of file to import. Can be a name of a file on the
%               MATLAB path or in the local working directory. Can basically be
%               anything that qualifies as a valid file. File must be created by
%               export from the IMU and its extension must be .lirmm
%
%   SAMPLING    Sampling time rate of the IMU system for creation of proper time
%               information.
%
%   Outputs:
%   
%   C           Timeseries collection of timeseries with fields
%               - IMU_Position: timeseries of position data as acquired by the
%               IMU. Data is stored in columns
%                   [x, y, z, a, b, c]
%               or
%                   [x, y, z, roll, pitch, heading(yaw) ]
%               - IMU_Velocity: timeseries of velocity data as acquired by the
%               IMU. Data is stored in same columns as for IMU_Position
%               - IMU_Acceleration: timseries of acceleration data as acquired
%               by the IMU. No transformation is done an ddata is sorted same as
%               for IMU_Position
%               - CableForces: timeseries of cable forces as acquired by the
%               IMU. The columns are sorted in one-based index for the canals of
%               the IMU data i.e.,
%                   [can0, can1, can2, can3, can4, can5, can6, can7]
%               or in cable forces
%                   [f1, f2, f3, f4, f5, f6, f7, f8]



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
    SamplingTime = 100*1e-3; % [ ms ]
end



%% Assert arguments
% Filename: char
assert(ischar(Filename), 'File name must be char');
assert(2 == exist(Filename, 'file'), 'File cannot be found');
[~, ~, chExtension] = fileparts(Filename);
assert(strcmpi('.lirmm', chExtension), 'Invalid file extension [%s] found. Must be [.lirmm].', chExtension);

% Sampling time: numeric, scalar, greater than zero
assert(isnumeric(SamplingTime), 'Sampling time must be numeric');
assert(isscalar(SamplingTime), 'Sampling time must be scalar');
assert(SamplingTime > 0, 'Sampling time must be positive');



%% Process Arguments
% Get the char of filename
chFilename = Filename;
% Get the double of sampling time
dSamplingTime = SamplingTime;



%% Read IMU data file
try
    aLoadedData = if_importImuDataFile(chFilename);
catch me
    error('Could not load file with error: %s', me.message);
end



%% Pre-process data
% How many data points do we have?
nDatapoints = numel(aLoadedData(:,1));

vTime = ascolumn(0:dSamplingTime:((nDatapoints - 1)*dSamplingTime));
aIsPose_Pos = zeros(nDatapoints, 6);
aIsPose_Vel = zeros(nDatapoints, 6);
aIsPose_Acc = zeros(nDatapoints, 6);
aForces = zeros(nDatapoints, 8);



%% Assign measurement data
%%% Position
% % X position (does not exist)
% aIsPose_Pos(:,1) = ;
% % Y position (does not exist)
% aIsPose_Pos(:,1) = ;
% % Z position (does not exist)
% aIsPose_Pos(:,3) = ;
% A position (does not exist)
aIsPose_Pos(:,4) = ascolumn(aLoadedData(:,5));
% B position (does not exist)
aIsPose_Pos(:,5) = ascolumn(aLoadedData(:,6));
% C position (does not exist)
aIsPose_Pos(:,6) = ascolumn(aLoadedData(:,7));


%%% Velocities
% % X velocity (does not exist)
% aIsPose_Vel(:,1) = ;
% % Y velocity (does not exist)
% aIsPose_Vel(:,2) = ;
% % Z velocity (does not exist)
% aIsPose_Vel(:,3) = ;
% A velocity
aIsPose_Vel(:,4) = ascolumn(aLoadedData(:,8));
% B velocity
aIsPose_Vel(:,5) = ascolumn(aLoadedData(:,9));
% C velocity
aIsPose_Vel(:,6) = ascolumn(aLoadedData(:,10));


%%% Accelerations
% X acceleration
aIsPose_Acc(:,1) = ascolumn(aLoadedData(:,2));
% Y acceleration
aIsPose_Acc(:,2) = ascolumn(aLoadedData(:,3));
% Z acceleration
aIsPose_Acc(:,3) = ascolumn(aLoadedData(:,4));
% % A acceleration
% aIsPose_Acc(:,4) = ;
% % B acceleration
% aIsPose_Acc(:,5) = ;
% % C acceleration
% aIsPose_Acc(:,6) = ;


%%% Cable forces
aForces(:,1) = ascolumn(aLoadedData(:,11));
aForces(:,2) = ascolumn(aLoadedData(:,12));
aForces(:,3) = ascolumn(aLoadedData(:,13));
aForces(:,4) = ascolumn(aLoadedData(:,14));
aForces(:,5) = ascolumn(aLoadedData(:,15));
aForces(:,6) = ascolumn(aLoadedData(:,16));
aForces(:,7) = ascolumn(aLoadedData(:,17));
aForces(:,8) = ascolumn(aLoadedData(:,18));



%% Create timeseries of data
tsIsPose_Pos = timeseries(aIsPose_Pos, vTime, 'Name', 'IMU_Position');
tsIsPose_Vel = timeseries(aIsPose_Vel, vTime, 'Name', 'IMU_Velocity');
tsIsPose_Acc = timeseries(aIsPose_Acc, vTime, 'Name', 'IMU_Acceleration');
tsForces = timeseries(aForces, vTime, 'Name', 'CableForces');



%% Assign return value
% Return collection is a collcetion of timeseries data
Collection = tscollection({tsIsPose_Pos, tsIsPose_Vel, tsIsPose_Acc, tsForces}, 'Name', Filename);


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
