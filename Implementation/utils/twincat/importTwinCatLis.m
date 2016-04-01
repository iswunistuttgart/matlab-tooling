function [PulleyPositions, AttachmentPositions, CableLengthOffsets] = importTwinCatLis(Filename, varargin)


%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% Necessary: Filename
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% % Motion pattern is required
% valFcn_MotionPattern = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'MotionPattern');
% addRequired(ip, 'MotionPattern', valFcn_MotionPattern);
% 
% % Number of cables is required
% valFcn_NumberOfCables = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'finite', 'positive'}, mfilename, 'NumberOfCables');
% addRequired(ip, 'NumberOfCables', valFcn_NumberOfCables);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Filename, varargin{:});



%% Local variables
% Filename of lis file
chFilename = ip.Results.Filename;
% Number of Cables
nNumberOfCables = 8;
% Pulley positions
aPulleyPostiions = zeros(3, nNumberOfCables);
% Cable attachment positions
aAttachmentPositions = zeros(3, nNumberOfCables);
% Cable length offsets
aCableLengthOffsets = zeros(1, nNumberOfCables);

%{
% Motion pattern
chMotionPattern = ip.Results.MotionPattern;
% Number of Cables
nNumberOfCables = ip.Results.NumberOfCables;

% Determine degrees of freedom based on motion pattern
switch chMotionPattern
    case '1T'
        nDegreesOfFreedom = 1;
        nDegreesOfCoordinates = 1;
    case '2T'
        nDegreesOfFreedom = 2;
        nDegreesOfCoordinates = 2;
    case '3T'
        nDegreesOfFreedom = 3;
        nDegreesOfCoordinates = 3;
    case '1R2T'
        nDegreesOfFreedom = 3;
        nDegreesOfCoordinates = 2;
    case '2R3T'
        nDegreesOfFreedom = 5;
        nDegreesOfCoordinates = 3;
    case '3R3T'
        nDegreesOfFreedom = 6;
        nDegreesOfCoordinates = 3;
    otherwise
        error('Invalid motion pattern %s given', chMotionPattern);
end
%}

% Create a handle to the file
hFile = fopen(chFilename);
% Ensure the file is open
if ~hFile
    error('Could not open file %s', chFilename);
end

% Create a cleanup function 
finishup = onCleanup(@() iif(ishandle(hFile), fclose(hFile), true, true));

% Stores the trafo parameters
aTrafoParameters = [];


%% Importing data
% Loop over every line of the file
while ~feof(hFile)
    % Get the current line
    chLine = deblank(fgetl(hFile));
    
    % Skip empty lines or lines that only contain 'Ende' in it (EOF of
    % .lis-files)
    if isempty(chLine) || strcmp(chLine, 'Ende')
        continue
    end
    
    % Skip comments
    if strcmp(chLine(1), '#')
        continue
    end
    
    % If the line starts with "trafo[*].param[*]"
    if regexp(chLine, '^trafo\[\d+\]\.param\[\d+\]')
        ceAmount = textscan(chLine, 'trafo[%*d].param[%*d] %f ');
%         chLine
        
        if ~isempty(ceAmount)
            aTrafoParameters = [aTrafoParameters; ceAmount{1}];
        end
    end
end

%% Post processing
% Cut down to only the first set of transformation parameters
if numel(aTrafoParameters) > 7*nNumberOfCables
    aTrafoParameters = aTrafoParameters(1:7*nNumberOfCables);
end

% For each cable, assign the proper quantities to the respective array
for iCable = 1:nNumberOfCables
    % Get the row offset
    iRowOfffset = (iCable - 1)*6;
    % Pulley position is always the items 1:3
    aPulleyPostiions(:,iCable) = aTrafoParameters((1:3) + iRowOfffset).*1e-7;
    % Attachment points are the items 4:6
    aAttachmentPositions(:,iCable) = aTrafoParameters((4:6) + iRowOfffset).*1e-7;
    % Cable length offsets are within the last nNubmerOfCables items
    aCableLengthOffsets(iCable) = aTrafoParameters(iCable + 6*nNumberOfCables);
end


%% Assign output quantities
% First output: pulley positions
PulleyPositions = aPulleyPostiions;

% Second output: cable attachment points
AttachmentPositions = aAttachmentPositions;

% Third output: cable length offsets
CableLengthOffsets = aCableLengthOffsets;

end