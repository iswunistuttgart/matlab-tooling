function LTData = cogiro_importlaser(Filename, varargin)
% COGIRO_IMPORTLASER imports processed laser tracker data
%
%   LTDATA = COGIRO_IMPORTLASER(FILENAME) imports processed laser tracker data
%   from the file FILENAME. Must be a valid excel spreadsheet. Function assumes
%   the absolute spatial laser tracker data to be in sheet number 2 and the
%   column range to be F to H.
%
%   LTDATA = COGIRO_IMPORTLASER(FILENAME, 'Name', 'Value') reads processed laser
%   tracker data from file FILENAME with additional options specified by one or
%   more Name,Value pair arguments.
%
%   Inputs:
%
%   FILENAME        Path to file with laser tracker data. Must be a valid excel
%                   spreadsheet. Function assumes the absolute spatial laser
%                   tracker data to be present in sheet number 2 if not
%                   specified differently. Column range F:H from spreadsheet
%                   will be imported
%
%   Outputs:
%
%   LTDATA          Timeseries of the spatial position data in order of [X,Y,Z].
%
%   Optional Inputs -- specified as parameter value pairsx
%
%   Columns         In which columns the to-be-extracted data is contained.
%                   Defaults to [6, 7, 8].
%
%   FilterFirst     Whether to automatically filter the first laser tracker
%                   measurement data against the next three rows ensuring that
%                   there is no gap/discontinuity
%   SamplingTime    Sampling to use for generating the time vector. Defaults to
%                   7.2 [ms].
%
%   SheetNo         Which sheet to select form the spreadsheet. Defaults to 2.
%
%   See also: readtable



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-24
% Changelog:
%   2016-08-24
%       * Add option 'FilterFirst'
%   2016-08-23
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename. Char. Non-empty
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: SamplingTime. Real. Positive
valFcn_SamplingTime = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'SamplingTime');
addParameter(ip, 'SamplingTime', 0, valFcn_SamplingTime);

% Optional 2: Sheet Number. Real. Not zero. Positive.
valFcn_SheetNo = @(x) validateattributes(x, {'numeric', 'cell'}, {'nonempty', 'real', 'nonzero', 'positive'}, mfilename, 'SheetNo');
addParameter(ip, 'SheetNo', 2, valFcn_SheetNo);

% Optional 3: Columns to extract
valFcn_Columns = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonzero', 'positive'}, mfilename, 'Columns');
addParameter(ip, 'Columns', [6, 7, 8], valFcn_Columns);

% Optional 4: Filter start. Char. Matches {'on', 'off', 'yes', 'no'}
valFcn_FilterFirst = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'FilterFirst'));
addParameter(ip, 'FilterFirst', 'off', valFcn_FilterFirst);

% Optional 5: Filter start threshold. Numeric. Real. Positive.
valFcn_FilterFirstThreshold = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonzero', 'positive'}, mfilename, 'FilterFirstThreshold');
addParameter(ip, 'FilterFirstThreshold', 5*1e-3, valFcn_FilterFirstThreshold);


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
% Sheet number
dSheetNumber = ip.Results.SheetNo;
% Columns
vColumns = ip.Results.Columns;
% Filter first pose measurement
chFilterFirst = in_charToValidArgument(ip.Results.FilterFirst);
% Threshold to filtering the first pose measurement
dFilterFirstThreshold = ip.Results.FilterFirstThreshold;



%% Data assertion
assert(2 == exist(chFilename, 'file'), 'PHILIPPTEMPEL:COGIRO_IMPORTLASER:invalidFileName', 'File cannot be found');
[~, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.xlsx', chFile_Ext), 'PHILIPPTEMPEL:COGIRO_IMPORTLASER:invalidFileExt', 'Invalid file extension [%s] found. Must be [.xlsx].', chFile_Ext);



%% Read data and process
% Read file as table
try
    taData = readtable(chFilename, 'Sheet', dSheetNumber, 'FileType', 'spreadsheet');
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
aPoses = zeros(nTimeSamples, 6);
aPoses(:,1) = taData(vSelector,vColumns(1)).(taData(vSelector,vColumns(1)).Properties.VariableNames{1});
aPoses(:,2) = taData(vSelector,vColumns(2)).(taData(vSelector,vColumns(2)).Properties.VariableNames{1});
aPoses(:,3) = taData(vSelector,vColumns(3)).(taData(vSelector,vColumns(3)).Properties.VariableNames{1});
% Convert [ mm ] to [ m ]
aPoses = aPoses./1000;


% Filter the first row if it is too far away from the average over the next five
% measurements
if strcmp('on', chFilterFirst)
    % Get first pose measurement
    vFirstPose = aPoses(1,:);
    
    % Average over at most the next five measurements
    vAvgComing = mean(aPoses(1+(1:min(5, nTimeSamples)),:));
    
    % If any of the first pose measurements is farther away than the default or
    % user-specified threshold, we will remove the first pose measurement
    if any((vAvgComing - vFirstPose) > dFilterFirstThreshold)
        aPoses(1,:) = [];
        vTime(end) = [];
    end
end



%% Create output variable
LTData = timeseries(aPoses, vTime, 'Name', 'Position');
LTData.UserData.Name = chFile_Name;
LTData.UserData.Source = chFilename;


end



function out = in_charToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
