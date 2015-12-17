function TwinCatScope = importTwincatCsv(Filename, varargin)



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% Necessary: Filename
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% We might want the pulley radius to be defined if using advanced
% kinematics
valFcn_Delimiter = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Delimiter');
addOptional(ip, 'Delimiter', '\t', valFcn_Delimiter);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Filename, varargin{:});



%% Create local variables
% Struct holding the imported data
stScopeData = struct();
stScopeData.Name = '';
stScopeData.File = '';
stScopeData.StartRecord = struct();
stScopeData.EndRecord = struct();
stScopeData.Data = struct();

% Counter to know how many variables we have
nVariablesCount = 0;
% Keeps all the sampled time data
maSampledTime = zeros(0, nVariablesCount);
% Keeps all the sampled data data
maSampledData = zeros(0, nVariablesCount);
% Keeps the variable names
ceVariablesNames = cell(nVariablesCount);
% Keeps the sampling times of each variable
maSamplingTimes = zeros(nVariablesCount);
% Keeps the scaling factors of each variable
maScaleFactors = zeros(nVariablesCount);

% Filename
chFilename = ip.Results.Filename;
% Delimiter between fields
chDelimiter = ip.Results.Delimiter;
% Start row of data in CSV
nRowStart = 19;
% End row of data in CSV
nRowEnd = -1;

% Create a handle to the file
hFile = fopen(Filename);

% Create a cleanup function 
finishup = onCleanup(@() iif(ishandle(hFile), fclose(hFile), true, true));

% Holds a counter to the current line
iCurrLine = 0;

while ~feof(hFile)
    % Get the current line
    line = deblank(fgetl(hFile));
    
    % Advance the line counter
    iCurrLine = iCurrLine + 1;
    
    % Skip empty lines or last line (lsat line contains 'EOF'
    if isempty(line) || strcmp(line, 'EOF')
        continue;
    end
    
    % Header lines are in the first 22 lines
    if iCurrLine < 22
        lineData = textscan(line, '%s', 'Delimiter', '\t');
        if isempty(lineData)
            continue
        end
        lineData = lineData{1};
        % First four lines contain 'Name', 'File', 'StartRecord', and
        % 'EndRecord'
        switch iCurrLine
            % "Name"
            case 1
                stScopeData.Name = lineData{2};
            % "File"
            case 2
                stScopeData.File = lineData{2};
            % "StartRecord"
            case 3
                stScopeData.StartRecord.Timestamp = lineData{2};
                stScopeData.StartRecord.Date = lineData{3};
                stScopeData.StartRecord.Time = lineData{4};
            % "EndRecord"
            case 4
                stScopeData.EndRecord.Timestamp = lineData{2};
                stScopeData.EndRecord.Date = lineData{3};
                stScopeData.EndRecord.Time = lineData{4};
            % Variables Names
            case 7
                nVariablesCount = numel(lineData)/2;
                maSampledTime = zeros(0, nVariablesCount);
                maSampledData = zeros(0, nVariablesCount);
                ceVariablesNames = cell(nVariablesCount, 1);
                maSamplingTimes = zeros(nVariablesCount, 1);
                maScaleFactors = zeros(nVariablesCount, 1);
                
                for iVariable = 1:nVariablesCount
                    ceVariablesTheName = lineData{2*iVariable};
                    ceVariablesNames{iVariable} = strrep(strrep(ceVariablesTheName, '[', ''), ']', '');
                end
            % Sampling Rates
            case 10
                for iVariable = 1:nVariablesCount
                    chVariablesTheSampling = lineData{2*iVariable};
                    maSamplingTimes(iVariable) = str2double(chVariablesTheSampling);
                end
            % Scale factors
            case 19
                for iVariable = 1:nVariablesCount
                    chVariablesTheSampling = lineData{2*iVariable};
                    maScaleFactors(iVariable) = str2double(chVariablesTheSampling);
                end
            otherwise
                continue;
        end
    % Actual parsing of the values
    else
        % Read the sampled time and 
        lineData = textscan(line, '%f%f', 'Delimiter', '\t');
        
        % Get the sample time and convert it from [ms] to [s]
        maTheSampledTime = lineData{1}.*1e-3;
        maTheSampledData = lineData{2};
        
        maSampledTime = [maSampledTime; maTheSampledTime.'];
        maSampledData = [maSampledData; maTheSampledData.'];
    end
end

% Close the file if it's still open since we're done processing it
if ishandle(hFile)
    fclose(hFile);
end



%% Post processing i.e., build up the content of stScopeData.Data
for iVariable = 1:nVariablesCount
    % Create a time series object
    tsTheTimeseries = timeseries(maSampledData(:,iVariable), maSampledTime(:,iVariable), 'Name', ceVariablesNames{iVariable});
    
    % Create a struct of user data and assign the sample time to it
    stUserData = struct();
    stUserData.SamplingTime = maSamplingTimes(iVariable);
    % Assign the user data to the timeseries
    tsTheTimeseries.UserData = stUserData;
    
    % And assign the timeseries to the scope data's data field with the proper
    % variable name
    stScopeData.Data.(ceVariablesNames{iVariable}) = tsTheTimeseries;
end



%% Assign output quantities
% Imported data
TwinCatScope = stScopeData;



end