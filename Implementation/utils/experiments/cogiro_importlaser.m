function LTData = cogiro_importlaser(File, varargin)
% COGIRO_IMPORTLASER imports processed laser tracker data
%
%   LTDATA = COGIRO_IMPORTLASER(FILE) imports processed laser tracker data
%   from the file FILE. Must be a valid excel spreadsheet. Function assumes
%   the absolute spatial laser tracker data to be in sheet number 2 and the
%   column range to be F to H.
%
%   LTDATA = COGIRO_IMPORTLASER(FILE, SAMPLING) uses sampling time SAMPLING
%   for import and surpasses automatic detection of sampling time.
%
%   LTDATA = COGIRO_IMPORTLASER(FILE, SAMPLING, SHEETNO) uses sheet number
%   specified in SHEETNO to read data from. Defaults to 2.
%
%   LTDATA = COGIRO_IMPORTLASER(FILE, 'Name', 'Value', ...) reads processed
%   laser tracker data from file FILE with additional options specified by
%   one or more Name,Value pair arguments.
%
%   Inputs:
%
%   FILE            Path to file with laser tracker data. Must be a valid excel
%       spreadsheet. Function assumes the absolute spatial laser tracker data to
%       be present in sheet number 2 if not specified differently. Column range
%       F:H from spreadsheet will be imported
%
%   Outputs:
%
%   LTDATA          Time series or collection of three time series: POSITION,
%       VELOCITY, and ACCELERATION of the laser tracker target.
%
%   
%   Optional Inputs -- specified as parameter value pairs
%
%   Columns                 In which columns the to-be-extracted data are
%       contained. Defaults to [6, 7, 8].
%
%   FilterNoise             Switch whether to filter noise during import or not.
%       Noise filtering is done using the sgolayfilt filter with custom data.
%       Possible values for FILTERNOISE are
%           'on', 'yes'     Filter noise from data
%           'off', 'no'     Do not filter data
%
%   FilterNoiseOrder        Order of the sgolayfilt filter used to filter noise.
%       Defaults to 6.
%
%   FilterNoiseFramesize    Size of the frame used to filter noise. Defaults to
%       the odd integer closes to half the sampling time.
%
%   FilterEnd               Switch whether to filter recording at the end of the
%       data. Data filtering is done using the sgolayfilt with user-specifiable
%       filter parameters. Possible values for FILTEREND are
%           'on', 'yes'     Filter noise from data
%           'off', 'no'     Do not filter data
%
%   FilterEndThresh         Threshold to use to filter assume final data to be
%       of steady nature. By default, as many as the rounded number of
%       1/SamplingTime is used as window size which is used to compare data
%       against. Defaults to 5*1e-3 [m]
%
%   FilterFirst             Whether to automatically filter the first laser
%       tracker measurement data against the next five values ensuring that
%       there is no gap/discontinuity
%
%   FilterThresh            What threshold to use for filter the first value.%
%       Import function looks at the average of the next five measurements and
%       removes the first measurement, if and only if it is farther away than%
%           FILTERTHRESH. Defaults to 5e-3 [ m ].
%
%   IncludeGradient         Switch to include gradients of position to also
%       return velocity and acceleration as measured by the laser tracker. So
%       far, these values are determined by numerical differentiation. Defualts
%       to 'off'. Possible values for INCLUDEGRADIENT are
%           'on', 'yes'     Perform numeric differentation of data to obtain
%                           velocity and acceleration
%           'off', 'no'     No numeric differentiation is performed
%       If INCLUDEGRADIENT is set to 'on' or 'yes', the returned value of
%       COGIRO_IMPORTLASER is a time series collection of POSITION, VELOCITY,
%       and ACCELERATION.
%
%   Resampling      Sampling time used for resampling of the data. Defaults to
%       0 i.e., no resampling.
%
%   Sampling        Sampling time to use for generating the time vector.
%       Defaults to 7.2e-3 [s].
%
%   SheetNo         Which sheet to select form the spreadsheet. Defaults to 2.
%
%   See also: readtable sgolayfilt



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Rename argument 'Filename' to 'File
%       * Update check for existance of file etension in file name
%       * Add support for loading 'xls' files, too
%   2016-09-08
%       * Update help docs a bit
%       * Add parameter 'IncludeGradient' to include gradient of position for
%       numerical velocity and acceleration determination
%       * Add parameter 'Resampling' to perform internal resampling given a
%       specified resmapling time
%   2016-09-07
%       * Add ability to filter noise during import
%       * Add ability to filter the steady-state at the end
%   2016-09-01
%       * Update help block with missing 'FilterThres' parameter
%   2016-08-24
%       * Add option 'FilterFirst'
%   2016-08-23
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename. Char. Non-empty
valFcn_File = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'File');
addRequired(ip, 'File', valFcn_File);

% Optional 1: Sampling. Real. Positive
valFcn_Sampling = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'Sampling');
addOptional(ip, 'Sampling', 0, valFcn_Sampling);

% Optional 2: Sheet Number. Real. Not zero. Positive.
valFcn_SheetNo = @(x) validateattributes(x, {'numeric', 'cell'}, {'nonempty', 'real', 'nonzero', 'positive'}, mfilename, 'SheetNo');
addOptional(ip, 'SheetNo', 2, valFcn_SheetNo);

% Parameter: Columns to extract
valFcn_Columns = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonzero', 'positive'}, mfilename, 'Columns');
addParameter(ip, 'Columns', [6, 7, 8], valFcn_Columns);

% Parameter: Filter noise. Char. Matches {'on', 'off', 'yes', 'no'}
valFcn_FilterNoise = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'FilterNoise'));
addParameter(ip, 'FilterNoise', 'off', valFcn_FilterNoise);

% Parameter: Filter start threshold. Numeric. Real. Positive.
valFcn_FilterNoiseOrder = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonzero', 'positive', 'int'}, mfilename, 'FilterNoiseOrder');
addParameter(ip, 'FilterNoiseOrder', 6, valFcn_FilterNoiseOrder);

% Parameter: Filter start threshold. Numeric. Real. Positive.
valFcn_FilterNoiseFramesize = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonzero', 'positive', 'int'}, mfilename, 'FilterNoiseFramesize');
addParameter(ip, 'FilterNoiseFramesize', 0, valFcn_FilterNoiseFramesize);

% Parameter: Filter start. Char. Matches {'on', 'off', 'yes', 'no'}
valFcn_FilterFirst = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'FilterFirst'));
addParameter(ip, 'FilterFirst', 'off', valFcn_FilterFirst);

% Parameter: Filter start threshold. Numeric. Real. Positive.
valFcn_FilterFirstThreshold = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonzero', 'positive'}, mfilename, 'FilterFirstThresh');
addParameter(ip, 'FilterFirstThresh', 5*1e-3, valFcn_FilterFirstThreshold);

% Parameter: Filter static end values. Char. Matches {'on', 'off', 'yes', 'no'}
valFcn_FilterEnd = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'FilterEnd'));
addParameter(ip, 'FilterEnd', 'off', valFcn_FilterEnd);

% Parameter: Filter static end values treshold. Numeric. Real. Positive.
valFcn_FilterEndThreshold = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonzero', 'positive'}, mfilename, 'FilterEndThresh');
addParameter(ip, 'FilterEndThresh', 1.5e-3, valFcn_FilterEndThreshold);

% Parameter: Include gradients. Char. Matches {'on', 'off', 'yes', 'no'}
valFcn_IncludeGradient = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'IncludeGradient'));
addParameter(ip, 'IncludeGradient', 'off', valFcn_IncludeGradient);

% Optional 1: Sampling. Real. Positive
valFcn_Resampling = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'Resampling');
addParameter(ip, 'Resampling', 0, valFcn_Resampling);


% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{File}, varargin];
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse variables of the input parser to local parser
% Filename
chFile = fullpath(ip.Results.File);
% Sampling Time
dSamplingTime = ip.Results.Sampling;
% Sheet number
dSheetNumber = ip.Results.SheetNo;
% Columns
vColumns = ip.Results.Columns;
% Filter noise from measurement
chFilterNoise = parseswitcharg(ip.Results.FilterNoise);
% Order of the noise filter
nFilterNoise_Order = ip.Results.FilterNoiseOrder;
% Frame size of noise filter
nFilterNoise_Framesize = ip.Results.FilterNoiseFramesize;
% Filter first pose measurement
chFilterFirst = parseswitcharg(ip.Results.FilterFirst);
% Threshold to filtering the first pose measurement
dFilterFirst_Threshold = ip.Results.FilterFirstThresh;
% Filter static pose measurement
chFilterEnd = parseswitcharg(ip.Results.FilterEnd);
% Threshold to filtering satic pose measurement
dFilterEnd_Threshold = ip.Results.FilterEndThresh;
% Include gradient?
chIncludeGradient = parseswitcharg(ip.Results.IncludeGradient);
% Resampling time
dResamplingTime = ip.Results.Resampling;
% Default for sgolay filter frame size
if nFilterNoise_Framesize == 0
    % Get the odd number larger than half the sampling time width
    nFilterNoise_Framesize = 2*floor(floor(1/dSamplingTime/2)/2) + 1;
end
% Make sure the filter frame size is at least the filter order
if nFilterNoise_Framesize < nFilterNoise_Order
    nFilterNoise_Framesize = nFilterNoise_Order;
end
% Ensure frame size is an odd number
nFilterNoise_Framesize = 2*floor(nFilterNoise_Framesize/2) + 1;



%% Data assertion
% Get the file name and its extension
[~, chFile_Name, chFile_Ext] = fileparts(chFile);
% No file extension found? Then fall back to '.mat'
if isempty(chFile_Ext)
    % Default file extension
    chFile_Ext = '.xlsx';
    % Append file extension to the filename
    chFile = sprintf('%s%s', chFile, chFile_Ext);
end
% File must exist
assert(2 == exist(chFile, 'file'), 'PHILIPPTEMPEL:COGIRO_IMPORTLASER:invalidFileName', 'File [%s] cannot be found.', escapepath(chFile));
% File extension must be any of the following
ceValidFilextensions = {'.xls', '.xlsx'};
assert(any(strcmpi(ceValidFilextensions, chFile_Ext)), 'PHILIPPTEMPEL:COGIRO_IMPORTLASER:invalidFileExt', 'Invalid file extension [%s] found. Must be [%s].', chFile_Ext, strjoin(ceValidFilextensions, ', '));



%% Read data and process
% Read file as table
try
    taData = readtable(chFile, 'Sheet', dSheetNumber, 'FileType', 'spreadsheet');
catch me
    error('PHILIPPTEMPEL:COGIRO_IMPORTLASER:fileLoadFailure', 'Could not load file with error: %s', me.message);
end

% Identify where data is NaN
aDataIsNan = isnan(taData{:,:});
% Determine row number of last non-NaN value
nLastVal = size(aDataIsNan,1);
for iCol = 1:size(aDataIsNan,2)
    % Skip columns that are ONLY NaN or not a single NaN
    if all(aDataIsNan(:,iCol)) || all(~aDataIsNan(:,iCol))
        continue
    end
    nLastVal = min(nLastVal, find(aDataIsNan(:,iCol), 1, 'first') - 1);
end
% Select only the rows that have values other than NaN
vSelector = 1:1:nLastVal;
% Number of time samples equals the number of rows we select
nTimeSamples = numel(vSelector);

% If no sampling time was given, we will guess so from the first column of
% taData which is Time_Step
if dSamplingTime == 0
    dSamplingTime = round(mean(diff(taData{vSelector(2:end),1}))./1000, 4);
end
% Create time vector
vTime = (0:nTimeSamples - 1).*dSamplingTime;

% Stores the measured poses [x, y, z, r, p, y]
aPoses_Pos = zeros(nTimeSamples, 6);
aPoses_Pos(:,1) = taData(vSelector,vColumns(1)).(taData(vSelector,vColumns(1)).Properties.VariableNames{1});
aPoses_Pos(:,2) = taData(vSelector,vColumns(2)).(taData(vSelector,vColumns(2)).Properties.VariableNames{1});
aPoses_Pos(:,3) = taData(vSelector,vColumns(3)).(taData(vSelector,vColumns(3)).Properties.VariableNames{1});
% Convert [ mm ] to [ m ]
aPoses_Pos = aPoses_Pos./1000;
% Keeps the velocity and acceleration
aPoses_Vel = zeros(nTimeSamples, 6);
aPoses_Acc = zeros(nTimeSamples, 6);


% Filter the first row if it is too far away from the average over the next five
% measurements
if strcmp('on', chFilterFirst)
    % Get first pose measurement
    vFirstPose = aPoses_Pos(1,:);
    
    % Average over at most the next five measurements
    vAvgComing = mean(aPoses_Pos(1+(1:min(5, nTimeSamples)),:));
    
    % If any of the first pose measurements is farther away than the default or
    % user-specified threshold, we will remove the first pose measurement
    if any((vAvgComing - vFirstPose) > dFilterFirst_Threshold)
        aPoses_Pos(1,:) = [];
        vTime(end) = [];
    end
end

% Filter noise from data?
if strcmp('on', chFilterNoise)
    % If noise filter frame size was not set, we calculate the frame size from
    % half the sampling time
    % Filter data using a 6th order sgolayfilter with a frame size depending on the
    % sampling time
    aPoses_Pos = sgolayfilt(aPoses_Pos, nFilterNoise_Order, nFilterNoise_Framesize);
end

% Filter static values at the beginning and at the end
if strcmp('on', chFilterEnd)
    % Get gradient of data along the y-axis
    [~, aGradients] = gradient(aPoses_Pos, dSamplingTime);
    % Filter the gradient to get it smoothed out: order 2; window width 131
    aGradients_Filter = sgolayfilt(aGradients, 2, 131);
    % Filter gradient values that are smaller than the the threshold
    vGradients_Selected = all(abs(aGradients_Filter) <= dFilterEnd_Threshold, 2);
    % Get vector of consecutive lengths and values
    [vConsecutive_Lengths, vConsecutive_Values] = runLengthEncode(asrow(vGradients_Selected));
    
    % Flip the arrays containing the consecutive indices, so we will be looking
    % at the data from the back
%     vConsecutive_Lengths = fliplr(vConsecutive_Lengths);
%     vConsecutive_Values = fliplr(vConsecutive_Values);
    
    % Determine the indices of switches to zero
    vZeros = vConsecutive_Lengths(vConsecutive_Values == 0);
    % Get the indices of switches to one
    vOnes = vConsecutive_Lengths(vConsecutive_Values == 1);
    % Find the first index of switch
    idxConsecutiveOnes = find(vOnes >= round(0.5*1/dSamplingTime), 1, 'first');
    % If we found a range of consecutive values...
    if ~isempty(idxConsecutiveOnes) && numel(vZeros) > 1 && numel(vOnes) > 2
        % We will count the number of values before then
        idxConsecutive = sum(vZeros(1:(idxConsecutiveOnes))) + sum(vOnes(1:(idxConsecutiveOnes-1)));
        % Extract data according to the index we have found
        vTime = vTime(1:idxConsecutive);
        aPoses_Pos = aPoses_Pos(1:idxConsecutive,:);
        aPoses_Vel = aPoses_Vel(1:idxConsecutive,:);
        aPoses_Acc = aPoses_Acc(1:idxConsecutive,:);
    end
end

% Include gradient in data?
if strcmp('on', chIncludeGradient)
    % Get velocity as numerical gradient from position
    [~, aPoses_Vel] = gradient(aPoses_Pos, dSamplingTime);
    % Run sgolay filter on data
    aPoses_Vel = sgolayfilt(aPoses_Vel, nFilterNoise_Order, nFilterNoise_Framesize);
    % And now a median fiter on the data to remove outliers especially on the
    % edges
    aPoses_Vel = medfilt1(aPoses_Vel, 5);
    
    % Determine a frame size for the acceleration filter
    nFilterNoiseAcc_Framesize = max([nFilterNoise_Framesize, 2*floor(floor(nFilterNoise_Framesize/6)/2)+1]);

    % Get acceleration as numerical gradient from velocity
    [~, aPoses_Acc] = gradient(aPoses_Vel, dSamplingTime);
    % Run sgolay filter on data
    aPoses_Acc = sgolayfilt(aPoses_Acc, nFilterNoise_Order, nFilterNoiseAcc_Framesize);
    % And now a median fiter on the data to remove outliers especially on the
    % edges
    aPoses_Acc = medfilt1(aPoses_Acc, 5);
end



%% Collect all data
tsPos = timeseries(aPoses_Pos, vTime, 'Name', 'Position');
tsVel = timeseries(aPoses_Vel, vTime, 'Name', 'Velocity');
tsAcc = timeseries(aPoses_Acc, vTime, 'Name', 'Acceleration');
tsPos.UserData.Name = chFile_Name;
tsPos.UserData.Source = chFile;
tsVel.UserData.Name = chFile_Name;
tsVel.UserData.Source = chFile;
tsAcc.UserData.Name = chFile_Name;
tsAcc.UserData.Source = chFile;

% Resampling necessary?
if dResamplingTime > 0
    % Determine new time vector
    vNewTime = (0:(tsPos.TimeInfo.End/dSamplingTime)).*dSamplingTime;
    % Perform resampling of all data
    tsPos = resample(tsPos, vNewTime);
    tsVel = resample(tsVel, vNewTime);
    tsAcc = resample(tsAcc, vNewTime);
end





%% Create output variable
% If gradients are requested
if strcmp('on', chIncludeGradient)
    % We will return a collection of time series
    LTData = tscollection({tsPos, tsVel, tsAcc}, 'Name', 'Lasertracker');
% No gradients requested (for reasons of BC)
else
    % Create a time series of just the position data
    LTData = tsPos;
end


end


function [lengths, values] = runLengthEncode(data)

startPos = find(diff([data(1)-1, data]));
lengths = diff([startPos, numel(data)+1]);
values = data(startPos);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
