function [PoseList, varargout] = loadPoseList(Filename, varargin)
% LOADPOSELIST - Loads pose list from the specified filename
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-09-01
% Changelog:
%   2015-09-01
%       * Major refactor
%       * Update to return as different types
%   2015-06-18
%       * Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% We need the filename
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty', }, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Allow the user to provide the time range in case it isn't provided in the file
valFcn_Sampletime = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'positive'}, mfilename, 'Sampletime');
addOptional(ip, 'Sampletime', 0, valFcn_Sampletime);

% Allow the user to chose how he'd like to thave the data returned. We are
% supporting array, struct, and timeseries (so far)
valFcn_ReturnAs = @(x) any(validatestring(lower(x), {'timeseries', 'struct', 'array'}, mfilename, 'ReturnAs'));
addParameter(ip, 'ReturnAs', 'array', valFcn_ReturnAs);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Filename, varargin{:});



%% Parse variables so we can use them natively
% Get the filename
chFilename = ip.Results.Filename;
% Get the sampletime parameter
dSampletime = ip.Results.Sampletime;
% Extract and lower the return-as parameter
chReturnAs = lower(ip.Results.ReturnAs);


% Which variables to extract from the poselists given?
ceExtractVariableTime = {'t', 'time'};
ceExtractVariablePose = {'x', 'y', 'z', 'R11', 'R_11', 'R12', 'R_12', 'R13', 'R_13', 'R21', 'R_21', 'R22', 'R_22', 'R23', 'R_23', 'R31', 'R_31', 'R32', 'R_32', 'R33', 'R_33'};
% ceExtractVariablesInOrder = {'time', 't', 'x', 'y', 'z', 'R11', 'R_11', 'R12', 'R_12', 'R13', 'R_13', 'R21', 'R_21', 'R22', 'R_22', 'R23', 'R_23', 'R31', 'R_31', 'R32', 'R_32', 'R33', 'R_33'};
% Supported file types
ceSupportedExtensions = {'.csv', '.txt'};

% Holds the data of parsed time and of the poses
vTime = [];
aPoses = [];



%% Do the magic
% First, check if the file is given relative to the working directory or as an
% absolute path
[chFilePath, chFileName, chFileExt] = fileparts(chFilename);
if isempty(chFilePath)
    chFilePath = pwd;
end

% Now check if there is a file extension given. If not, we will fall back to the
% very first match
if isempty(chFileExt)
    for iExt = 1:numel(ceSupportedExtensions)
        if exist(fullfile([fileNameOrPath, ceSupportedExtensions{iExt}]), 'file')
            chFileExt = ceSupportedExtensions{iExt};
            
            break;
        end
    end
% The provided file has a file extension, so let's check that value
else
    % If the value of fileExt is not a member of the cell array
    % supportedExtensions it means we are having us an unsupported file
    % extension
    assert(any(find(ismember(ceSupportedExtensions, chFileExt))), 'Unsupported file extension ''%s'' found. Please consider exporting as any of the following formats: %s', chFileExt, strjoin(ceSupportedExtensions, ', '));
%     if isempty(find(ismember(ceSupportedExtensions, chFileExt), 1))
%         throw(MException('PHILIPPTEMPEL:loadPoseList:invalidFileExtension', ));
%     end
end

% Build the qualified file name as we have inferred above
chQualifiedFile = fullfile(chFilePath, [chFileName, chFileExt]);

% Import the data using MATLAB's default importdata function
[xData, ~, ~] = importdata(chQualifiedFile);

% Now process the data, depending on if it was imported as a struct
if isstruct(xData)
    %%% xData.colheaders stores the header while xData.Data stores the actual
    %%% data
    
    % Assert we have have column data imported
    assert(isfield(xData, 'colheaders'), 'Imported data did not provide any column headers');
    
    % Next, check if there is a column called 't' or 'time'
    ixTime = 0;
    for iExtractTimeVar = 1:numel(ceExtractVariableTime)
        idx = find(strcmp(ceExtractVariableTime{iExtractTimeVar}, xData.colheaders), 1, 'first');
        if ~isempty(idx)
            ixTime = idx;
            break;
        end
    end
    
    % Assert we have 
    assert(ixTime ~= 0 || dSampletime > 0, 'No time information found in given file and no sample time given to the script. Please call the function again with the ''Sampletime'' option');
    
    % Get the indices for the poses as they are stored inside xData.colheaders
    ixPose = zeros(1,12);
    iCol = 1;
    for iExtractPoseVar = 1:numel(ceExtractVariablePose)
        ceExtractVariablePose{iExtractPoseVar};
        idx = find(strcmp(xData.colheaders, ceExtractVariablePose{iExtractPoseVar}));
        if ~isempty(idx)
            ixPose(iCol) = idx;
            iCol = iCol + 1;
        end
    end
    
    % User may override the sample time,  so let's make this preced over
    % extracting the time data from xData.data
    if dSampletime > 0
        vTime = 0:dSampletime:((size(xData.data, 1)-1)*dSampletime);
        vTime = reshape(vTime, numel(vTime), 1);
    else
        vTime = xData.data(:,ixTime);
        % Adjust the sample time for now as it is not being created correctly by
        % WireCenter
        if ( vTime(2) - vTime(1) ) == 1
            vTime = vTime.*1e-3;
        end
    end
    % And extract the entries for the pose from xData.data
    aPoses = xData.data(:,ixPose);
% ... Or data is imported as an array
elseif ismatrix(xData)
    assert(size(xData, 2) <= 13, 'Too much information to import');
    % If we have columns than we need, we assume the time information is missing
    assert(size(xData,2) == 13 || ( ( size(xData, 2) < 13 ) && ( dSampletime > 0 )), 'No time information found in given file and no sample time given to the script. Please call the function again with the ''Sampletime'' option');
    % Got 13 columns
    if size(xData, 2) == 13
        vTime = xData(:,1);
        aPoses = xData(:,2:13);
    % Got less than 13 columns, i.e., 12
    else
        % Interpolate the time information
        vTime = 0:dSampletime:((size(xData, 1)-1)*dSampletime);
        vTime = reshape(vTime, numel(vTime), 1);
        % Poses are given in the data
        aPoses = xData;
    end
end


%% Output assignment
% Finally create the return value of this method depending on the requested
% return as type
switch chReturnAs
    case 'array'
        PoseList = horzcat(vTime, aPoses);
    case 'struct'
        PoseList = struct();
        PoseList.Time = vTime;
        PoseList.Pose = aPoses;
    case 'timeseries'
        PoseList = timeseries(aPoses, vTime, 'Name', 'PoseList');
end


end