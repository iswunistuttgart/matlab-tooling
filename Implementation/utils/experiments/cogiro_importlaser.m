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
%   Optional Inputs -- specified as parameter value pairs
%   SamplingTime    Sampling to use for generating the time vector. Defaults to
%                   7.2 [ms].
%
%   SheetNo         Which sheet to select form the spreadsheet. Defaults to 2.
%
%   Columns         In which columns the to-be-extracted data is contained.
%                   Defaults to [6, 7, 8].
%
%   See also: readtable



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-23
% Changelog:
%   2016-08-23
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Filename. Char. Non-empty
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: SamplingTime. Real. Positive
valFcn_SamplingTime = @(x) validateattributes(x, {'numeric'}, {'real', 'positive'}, mfilename, 'SamplingTime');
addParameter(ip, 'SamplingTime', 7.2*1e-3, valFcn_SamplingTime);

% Optional 2: Sheet Number. Real. Not zero. Positive.
valFcn_SheetNo = @(x) validateattributes(x, {'numeric', 'cell'}, {'nonempty', 'real', 'nonzero', 'positive'}, mfilename, 'SheetNo');
addParameter(ip, 'SheetNo', 2, valFcn_SheetNo);

% Optional 3: Columns to extract
valFcn_Columns = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonzero', 'positive'}, mfilename, 'Columns');
addParameter(ip, 'Columns', [6, 7, 8], valFcn_Columns);

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



%% Data assertion
assert(2 == exist(chFilename, 'file'), 'File cannot be found');
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(Filename);
assert(strcmpi('.xlsx', chFile_Ext), 'Invalid file extension [%s] found. Must be [.xlsx].', chFile_Ext);



%% Read data and process
% Read file as table
try
    taData = readtable(chFilename, 'Sheet', dSheetNumber, 'FileType', 'spreadsheet');
catch me
    error('Could not load file with error: %s', me.message);
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

% Create time vector
vTime = (0:nTimeSamples - 1).*dSamplingTime;

% Stores the measured poses [x, y, z, r, p, y]
aPoses = zeros(nTimeSamples, 6);
aPoses(:,1) = taData(vSelector,vColumns(1)).(taData(vSelector,vColumns(1)).Properties.VariableNames{1});
aPoses(:,2) = taData(vSelector,vColumns(2)).(taData(vSelector,vColumns(2)).Properties.VariableNames{1});
aPoses(:,3) = taData(vSelector,vColumns(3)).(taData(vSelector,vColumns(3)).Properties.VariableNames{1});



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
