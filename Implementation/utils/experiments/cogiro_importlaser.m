function LTData = cogiro_importlaser(Filename, SamplingTime)

%% Default arguments
if nargin < 2
    SamplingTime = 7.2*1e-3;
end

% if nargin < 3
%     StartRow = 2;
% end

% if nargin < 4
%     EndRow = Inf;
% end


%% Pre-process arguments
Filename = fullpath(Filename);



%% Assertion
% Filename: char
assert(ischar(Filename), 'File name must be char');
assert(2 == exist(Filename, 'file'), 'File cannot be found');
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.xlsx', chFile_Ext), 'Invalid file extension [%s] found. Must be [.xlsx].', chFile_Ext);

% % Ensure we select a valid range of data
% assert(EndRow > StartRow, 'End row must be larger than start row');

% Sampling time: numeric, scalar, greater than zero
assert(isnumeric(SamplingTime), 'Sampling time must be numeric');
assert(isscalar(SamplingTime), 'Sampling time must be scalar');
assert(SamplingTime > 0, 'Sampling time must be positive');



%% Initialize variables.
% Sampling Time
dSamplingTime = SamplingTime;
% Filename
chFilename = Filename;
% Delimiter char
chDelimiter = ',';
% % Start row of import
% nStartRow = StartRow;
% % End row of import
% nEndRow = EndRow;



%% Read data and process
% Read file as table
try
    taData = readtable(chFilename, 'Sheet', 2);
catch me
    error('Could not load file with error: %s', me.message);
end

% Get the first column's name
chFirstColName = taData(1,1).Properties.VariableNames{1};
% Select only the rows that have values other than NaN
vSelector = find(~isnan(taData.(chFirstColName)));
% Number of time samples equals the number of rows we select
nTimeSamples = numel(vSelector);

% Create time vector
vTime = (0:nTimeSamples - 1).*dSamplingTime;

% Stores the measured poses [x, y, z, r, p, y]
aPoses = zeros(nTimeSamples, 6);
% Push in X-data
if ismember('X_axis_mm__1', taData.Properties.VariableNames)
    aPoses(:,1) = taData.X_axis_mm__1(vSelector);
end
% Push in Y-Data
if ismember('Y_axis_mm__1', taData.Properties.VariableNames)
    aPoses(:,2) = taData.Y_axis_mm__1(vSelector);
end
% Push in Z-Data
if ismember('Z_axis_mm__1', taData.Properties.VariableNames)
    aPoses(:,3) = taData.Z_axis_mm__1(vSelector);
end



%% Create output variable
LTData = timeseries(aPoses, vTime, 'Name', 'Position');
LTData.UserData.Name = chFile_Name;
LTData.UserData.Source = chFilename;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
