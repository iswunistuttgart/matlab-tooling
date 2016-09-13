function TwinCatScope = ipanema_importscope(Filename, varargin)
% IPANEMA_IMPORTSCOPE imports a TwinCat scope file into MATLAB
%
%   SCOPE = IPANEMA_IMPORTSCOPE(FILENAME) imports the scope data form file
%   FILENAME into structure SCOPE with the following fields:
%       .Name           Name of the scope as defined in the CSV file
%       .File           Fully qualified file name this scope data is read from
%       .StartRecord    Structure keeing information about the start record with
%                       following fields
%           .TimeStamp      Timestamp that this file's scope data was started
%           .DateTime       Date time object representing the date and time the
%                           recording was started
%       .EndRecord      
%           .TimeStamp      Timestamp that this file's scope data was stopped
%           .DateTime       Date time object representing the date and time the
%                           recording was stopped
%       .Data           Collection of time series of each data found. The names
%                       of the time series correspond to MATLAB identifiers of
%                       the imported data with the following conversion chart:
%                           " "     => "_"
%                           "."     => "__"
%                           "_"     => "_"
%                           "-"     => ""
%                           "("     => "_"
%                           ")"     => "_"
%                           ")("    => "_"
%                           "()"    => "_"
%                           "["     => "_"
%                           "]"     => ""
%                           "[]"    => "_"
%                           "]["    => "_"



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-13
% Changelog:
%   2016-09-13
%       * Update to return time series collectionts
%       * Rename to ipanema_importscope


%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

% Required: Filename. Char. Non-empty.
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional: Delimiter. Char. Non-empty.
valFcn_Delimiter = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Delimiter');
addOptional(ip, 'Delimiter', '\t', valFcn_Delimiter);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Filename}, varargin];
    
    parse(ip, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse IP results locally
% Filename
chFilename = fullpath(ip.Results.Filename);
% Delimiter between fields
chDelimiter = ip.Results.Delimiter;
% Start row of data in CSV
nRowStart = 19;
% End row of data in CSV
nRowEnd = -1;



%% Create local variables
% Struct holding the imported data
stScopeData = struct();
stScopeData.Name = '';
stScopeData.File = '';
stScopeData.StartRecord = struct();
stScopeData.EndRecord = struct();
stScopeData.Data = struct();

% Create a handle to the file
hfSource = fopen(chFilename);

% First, find lines count so we know how big all arrays will be
nLines = 0;
while ~feof(hfSource)
    ceLine = fgetl(hfSource);
    if strcmp(ceLine, 'EOF')
        break;
    end
    nLines = nLines + 1;
end
% Calculate the number of samples from:
% "Lines Read" - "Lines Header"
nSamples = nLines - 22;
% Rewind the file pointer to the head
frewind(hfSource);

% Counter to know how many variables we have
nVariablesCount = 0;
% Keeps all the sampled time data
maSampledTime = zeros(nSamples, 0);
% Keeps all the sampled data data
maSampledData = zeros(nSamples, 0);
% Keeps the variable names
ceVariablesNames = {};
% Keeps the sampling times of each variable
maSamplingTimes = [];
% Keeps the scaling factors of each variable
maScaleFactors = [];
% Cell array of strings to replace, one per line as {'old', 'new'}
ceStrreps = {...
    ' ', '_'; ...
    '.', '__'; ...
    '_', '_'; ...
    '-', ''; ...
    ')(', '_'; ...
    '()', '_'; ...
    '(', '_'; ...
    ')', '_'; ...
    '[]', '_'; ...
    '][', '_'; ...
    '[', '_'; ...
    ']', ''; ...
};
nStrreps = size(ceStrreps, 1);

% Create a cleanup function 
finishup = onCleanup(@() in_oncleanup(hfSource));

% Holds a counter to the current line
iCurrLine = 0;

while ~feof(hfSource)
    % Advance the line counter
    iCurrLine = iCurrLine + 1;
    
    try
        % Get the current line
        ceLine = deblank(fgetl(hfSource));

        % Skip empty lines or last line (lsat line contains 'EOF'
        if isempty(ceLine) || strcmp(ceLine, 'EOF')
            continue;
        end
        
        % Header lines are in the first 22 lines
        if iCurrLine < 22
            % Split the line into its cells
            ceLineData = textscan(ceLine, '%s', 'Delimiter', chDelimiter);
            % Got no cells? Then skip to the next line
            if isempty(ceLineData)
                continue
            end
            ceLineData = ceLineData{1};
            
            % First four lines contain 'Name', 'File', 'StartRecord', and
            % 'EndRecord'
            switch iCurrLine
                % "Name"
                case 1
                    stScopeData.Name = ceLineData{2};
                % "File"
                case 2
                    stScopeData.File = ceLineData{2};
                % "StartRecord"
                case 3
                    stScopeData.StartRecord.Timestamp = ceLineData{2};
                    try
                        stScopeData.StartRecord.DateTime = datetime(sprintf('%s %s', ceLineData{3}, ceLineData{4}), 'InputFormat', 'eeee, dd MMMM, yyyy HH:mm:ss');
                    catch me
                        warning('PHILIPPTEMPEL:MATLAB_TOOLING:IPANEMA_IMPORTSCOPE:DateTimeParsingFailed', 'Could not parse date time for %s', 'StartRecord');
                    end
                % "EndRecord"
                case 4
                    stScopeData.EndRecord.Timestamp = ceLineData{2};
                    try
                        stScopeData.EndRecord.DateTime = datetime(sprintf('%s %s', ceLineData{3}, ceLineData{4}), 'InputFormat', 'eeee, dd MMMM, yyyy HH:mm:ss');
                    catch me
                        warning('PHILIPPTEMPEL:MATLAB_TOOLING:IPANEMA_IMPORTSCOPE:DateTimeParsingFailed', 'Could not parse date time for %s', 'EndRecord');
                    end
                % Variables Names
                case 7
                    nVariablesCount = numel(ceLineData)/2;
                    maSampledTime = zeros(nSamples, nVariablesCount);
                    maSampledData = zeros(nSamples, nVariablesCount);
                    ceVariablesNames = cell(nVariablesCount, 1);
                    maSamplingTimes = zeros(nVariablesCount, 1);
                    maScaleFactors = zeros(nVariablesCount, 1);

                    for iVariable = 1:nVariablesCount
                        ceVariablesNames{iVariable} = ceLineData{2*iVariable};
                    end

                    for iReplace = 1:nStrreps
                        ceVariablesNames = strrep(ceVariablesNames, ceStrreps{iReplace,1}, ceStrreps{iReplace,2});
                    end

                % Sampling Rates
                case 10
                    for iVariable = 1:nVariablesCount
                        maSamplingTimes(iVariable) = str2double(ceLineData{2*iVariable})/1000;
                    end
                % Scale factors
                case 19
                    for iVariable = 1:nVariablesCount
                        maScaleFactors(iVariable) = str2double(ceLineData{2*iVariable});
                    end
                otherwise
                    continue;
            end
        % Actual parsing of the values
        else
            % Read the sampled time and 
            ceLineData = textscan(ceLine, '%f%f', 'Delimiter', chDelimiter);

            % Break if the line we have read contains empty cells
            if numel(ceLineData{1}) ~= numel(ceVariablesNames)
                continue
            end

            % Get the sample time and convert it from [ms] to [s]
            maTheSampledTime = ceLineData{1}/1000;
            maTheSampledData = ceLineData{2};
            
            maSampledTime(iCurrLine - 22 + 1,:) = maTheSampledTime;
            maSampledData(iCurrLine - 22 + 1,:) = maTheSampledData;
        end
    catch me
        warning('PHILIPPTEMPEL:MATLAB_TOOLING:IPANEMA_IMPORTSCOPE:LineProcessingFailed', 'Failed processing line %i', iCurrLine);
    end
end



%% Post processing i.e., build up the content of stScopeData.Data
% Check for rows that contain NaN in any of the Times or Data
[nFirstNaN, ~] = find(isnan(maSampledTime), 1, 'first');
% If we found any rows with NaN, we will make sure that we will loop until the
% row just one before then
if ~isempty(nFirstNaN)
    nEndIndex = nFirstNaN - 1;
% No NaN found, so we can loop over all data samples
else
    nEndIndex = size(maSampledTime, 1);
end

% Create a time series collection for all scope data
tcData = tscollection({}, 'Name', stScopeData.Name);

% Loop over each variable and extract the allowed time and data range
for iVariable = 1:nVariablesCount
    % Create a time series object
    tsData = timeseries(maSampledData(1:nEndIndex,iVariable), maSampledTime(1:nEndIndex,iVariable), 'Name', ceVariablesNames{iVariable});
    % Create user data for the time series
    tsData.UserData = struct();
    tsData.UserData.SamplingTime = maSamplingTimes(iVariable);
    
    % Append the time series to the time series collection
    tcData = addts(tcData, tsData);
end

% And store the time series collection with the scope data
stScopeData.Data = tcData;



%% Assign output quantities
% Imported data
TwinCatScope = stScopeData;



end


function in_oncleanup(hfSource)
    if ishandle(hfSource)
        try
            fclose(hfSource);
        catch me
            warning(me.identifier, me.message);
        end
    end
end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
