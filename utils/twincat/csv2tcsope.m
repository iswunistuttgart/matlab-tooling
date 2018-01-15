function tcs = csv2tcsope(File, varargin)
% CSV2TCSCOPE converts a TwinCat CSV scope file to a TCSCOPE object
%
%   TCS = CSV2TCSCOPE(FILENAME) imports the TwinCat scope data CSV from file
%   FILENAME into tcscope TCS with the following fields:
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
%
%   See also: datetime



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-15
% Changelog:
%   2018-01-15
%       * Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

% Required: File; char; non-empty
valFcn_File = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'File');
addRequired(ip, 'File', valFcn_File);

% Optional: Delimiter; char; non-empty
valFcn_Delimiter = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Delimiter');
addParameter(ip, 'Delimiter', '\t', valFcn_Delimiter);

% Parameter: CollectSignals; char; matches {'on', 'off', 'yes', 'no', 'please'}
valFcn_CollectSignals = @(x) any(validatestring(lower(x), {'on', 'yes', 'please', 'off', 'no'}, mfilename, 'CollectSignals'));
addParameter(ip, 'CollectSignals', false, valFcn_CollectSignals);

% Configuration for the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % CSV2TCSCOPE(FILE)
    % CSV2TCSCOPE(FILE, varargin)
    narginchk(1, Inf);
    
    % CSV2TCSCOPE(FILE)
    % TCSCOPE = CSV2TCSCOPE(FILE)
    nargoutchk(0, 1);
    
    % Concate all arguments
    varargin = [{File}, varargin];
    
    % And parse
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results locally
% File
chFile = fullpath(ip.Results.File);
% Delimiter between fields
chDelimiter = ip.Results.Delimiter;
% Whether to collect signals or not
chCollectSignals = parseswitcharg(ip.Results.CollectSignals);



%% Process the file
% Create a handle to the file
try
    hfSource = fopen(chFile);
    assert(hfSource~= -1, 'PHILIPPTEMPEL:MATLABTOOLING:TWINCAT:CSV2TSCOPE:InvalidFile', 'Cannot open source file.');
catch me
    throwAsCaller(me);
end

% Create a cleanup function 
finishup = onCleanup(@() in_oncleanup(hfSource));

try
    % First, read the whole file as a big cell array (each row of the file is a row
    % of the cell array)
    ceFile = textscan(hfSource, '%[^\n\r]', 'Delimiter', chDelimiter, 'EndOfLine', '\r\n');

    % Check we got data
    assert(~isempty(ceFile) && numel(ceFile{1}) ~= 0, 'PHILIPPTEMPEL:MATLABTOOLING:TWINCAT:CSV2TSCOPE:InvalidFile', 'No data found in file.');
    
    % Get the main cell array
    ceFile = ceFile{1};
catch me
    throwAsCaller(me);
end

% Now we will process the cell array i.e., infer the number of header rows, the
% number of data rows, and the number of recorded variables

% Number of lines of whole file
nLines_File = numel(ceFile);
% Number of lines of header
nLines_Header = 0;
% Number of lines of complete data
nLines_Data = 0;
% Number of variables
nSignals = 0;

% Loop over each data line
for iLine = 1:nLines_File
    % Get line as character array
    chLine = ceFile{iLine};
    
    % If the line contains 'EOF' its the end
    if strcmp(chLine, 'EOF')
        % So remove this line and break end the loop
        ceFile(iLine) = [];
        
        break
    end
    
    % Try to read the line assuming it consists of only numbers
    ceLine = textscan(chLine, '%f', 'Delimiter', chDelimiter, 'CollectOutput', false);
    
    % If the line was parsed successfully, remove the first dimension
    if ~isempty(ceLine)
        chLine = ceLine{1};
    end
    
    % If the line in floats is empty its a header line
    if isempty(chLine)
        nLines_Header = nLines_Header + 1;
    % Else its a data line
    else
        % Processing first data line, so infer the number of signals
        if nLines_Data == 0
            nSignals = numel(chLine)/2;
        end
        
        % If textscan converts invalid entries to floats, the become 'NaN'. So
        % we will check for any NaN inside the current line. If there is any
        % NaN, it's the end of the recorded data
        if any(isnan(chLine))
            break
        end
        
        % Increase counter of data items
        nLines_Data = nLines_Data + 1;
    end
end

% Rewind file pointer
frewind(hfSource);



%% Process data
% Prepare scope data structure items to be of correct size and type
% stScopeDataN = struct();
stSignalData = struct();
stSignalData.ScopeName = '';
stSignalData.Name = '';
stSignalData.File = '';
stSignalData.Data = zeros(nLines_Data, 1);
stSignalData.Time = zeros(nLines_Data, 1);
stSignalData.StartRecord_DateTime = [];
stSignalData.StartRecord_Timestamp = [];
stSignalData.EndRecord_DateTime = [];
stSignalData.EndRecord_Timestamp = [];
stSignalData.NetId = '';
stSignalData.Port = [];
stSignalData.SampleTime = [];
stSignalData.SymbolBased = [];
stSignalData.SymbolName = '';
stSignalData.SymbolName_Base = '';
stSignalData.SymbolComment = '';
stSignalData.IndexGroup = [];
stSignalData.IndexOffset = [];
stSignalData.DataType = '';
stSignalData.VariableSize = [];
stSignalData.Offset = 1;
stSignalData.ScaleFactor = 1;
stSignalData.BitMask = '';
stSignalData = repmat(stSignalData, 1, nSignals);

% Keeps all the sampled time data
aData_Times = zeros(nLines_Data, nSignals);
% Keeps all the sampled data data
aData_Values = zeros(nLines_Data, nSignals);

% Process header
ceHeader = ceFile(1:nLines_Header);
% Loop over header
for iHeader = 1:nLines_Header
    % Parse the data cell as floats
    ceLine = textscan(ceHeader{iHeader}, repmat('%s', 1, 2*nSignals), 'Delimiter', chDelimiter, 'CollectOutput', true);
    
    % If data got split, reduce dimensions
    if ~isempty(ceLine)
        ceLine = ceLine{1};
    end
    
    % Depending on the content of the first cell of the line, we will
    % differently be dealing with the data
    switch lower(ceLine{1})
        % Name of scope
        case 'name'
            % 'Name' could be either the scope name or the variable name
            % Thus, check if every second item of ceLine is set, then it's the
            % variables names
            
            % If the sum of non-empty cells of every second cell is less than
            % the variables count, we are looking at the scope name
            if sum(~cellfun(@isempty, ceLine(2:2:end))) == 1
                [stSignalData(:).ScopeName] = deal(ceLine{2});
            else
                [stSignalData(:).Name] = deal(ceLine{2:2:end});
            end
            
        % Filename of Scope
        case 'file'
            [stSignalData(:).File] = deal(ceLine{2});
        
        % StartRecord
        case 'startrecord'
            try
                [stSignalData(:).StartRecord_DateTime] = deal(datetime(sprintf('%s %s', ceLine{3}, ceLine{4}), 'InputFormat', 'eeee, dd MMMM, yyyy HH:mm:ss'));
                [stSignalData(:).StartRecord_Timestamp] = deal(ceLine{2});
            catch me
                warning('PHILIPPTEMPEL:MATLABTOOLING:TWINCAT:CSV2TSCOPE:DateTimeParsingFailed', 'Could not parse date time for %s', 'StartRecord');
            end
            
        % EndRecord
        case 'endrecord'
            try
                [stSignalData(:).EndRecord_DateTime] = deal(datetime(sprintf('%s %s', ceLine{3}, ceLine{4}), 'InputFormat', 'eeee, dd MMMM, yyyy HH:mm:ss'));
                [stSignalData(:).EndRecord_Timestamp] = deal(ceLine{2});
            catch me
                warning('PHILIPPTEMPEL:MATLABTOOLING:TWINCAT:CSV2TSCOPE:DateTimeParsingFailed', 'Could not parse date time for %s', 'EndRecord');
            end

        % Char
        case 'netid'
            [stSignalData(:).NetId] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'port'
            [stSignalData(:).Port] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'sampletime[ms]'
            [stSignalData(:).SampleTime] = deal(ceLine{2:2:end});
            
        % Logical
        case 'symbolbased'
            [stSignalData(:).SymbolBased] = deal(ceLine{2:2:end});
            
        % Char
        case 'symbolname'
            [stSignalData(:).SymbolName] = deal(ceLine{2:2:end});
            
        % Char
        case 'symbolcomment'
            [stSignalData(:).SymbolComment] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'indexgroup'
            [stSignalData(:).IndexGroup] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'indexoffset'
            [stSignalData(:).IndexOffset] = deal(ceLine{2:2:end});
            
        % Char
        case 'data-type'
            [stSignalData(:).DataType] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'variablesize'
            [stSignalData(:).VariableSize] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'offset'
            [stSignalData(:).Offset] = deal(ceLine{2:2:end});
            
        % Numeric
        case 'scalefactor'
            [stSignalData(:).ScaleFactor] = deal(ceLine{2:2:end});
            
        % Char
        case 'bitmask'
            [stSignalData(:).BitMask] = deal(ceLine{2:2:end});
    end
end

% Push data into a array of data samples
ceData = ceFile(nLines_Header + (1:nLines_Data));
for iData = 1:nLines_Data
    % Parse the data cell as floats
    aData = cell2mat(textscan(ceData{iData}, repmat('%f', 1, 2*nSignals)));
    % Get the data time samples
%     stSignalData(:).Time(iData) = aData(1:2:end);
    aData_Times(iData,:) = aData(1:2:end);
    % And get the data values
%     stSignalData.Data(iData) = aData(2:2:end);
    aData_Values(iData,:) = aData(2:2:end);
end


%% Collect signals

% Collect signals by symbol name?
if strcmp('on', chCollectSignals)
    % Let's try to find signals that come from the same root variable i.e., are from
    % a TwinCat array. We do this by inspecting the SymbolName

    % Make every signal name unique i.e., remove any array indexing at the end
    % (e.g., turns 'Signal[0]' into 'Signal'
    ceUniqueSymbolNames = unique(regexprep({stSignalData.SymbolName}, '(.*)\[\d+\]$', '$1'));
    % S
    nUniqueSignals = numel(ceUniqueSymbolNames);
    stSignalCombinations = repmat(struct('CommonSymbolName', '', 'Name', '', 'Signals', []), 1, nUniqueSignals);

    % Get the indices of each signal matching the given common symbol name
    for iSymbol = 1:nUniqueSignals
        chSymbolName = regexp(ceUniqueSymbolNames{iSymbol}, '.*\.([^\.]\w+)$', 'tokens');
        stSignalCombinations(iSymbol).CommonSymbolName = ceUniqueSymbolNames{iSymbol};
        stSignalCombinations(iSymbol).Name = chSymbolName{1}{1};
        stSignalCombinations(iSymbol).Signals = find(~cellfun(@isempty, regexp({stSignalData.SymbolName}, [ceUniqueSymbolNames{iSymbol} , '(\[\d+\])?$'])));
    end
    
    stSignalData_Unique = struct();
    stSignalData_Unique.ScopeName = '';
    stSignalData_Unique.Name = '';
    stSignalData_Unique.File = '';
    stSignalData_Unique.Data = zeros(nLines_Data, 1);
    stSignalData_Unique.Time = zeros(nLines_Data, 1);
    stSignalData_Unique.StartRecord_DateTime = [];
    stSignalData_Unique.StartRecord_Timestamp = [];
    stSignalData_Unique.EndRecord_DateTime = [];
    stSignalData_Unique.EndRecord_Timestamp = [];
    stSignalData_Unique.NetId = '';
    stSignalData_Unique.Port = [];
    stSignalData_Unique.SampleTime = [];
    stSignalData_Unique.SymbolBased = [];
    stSignalData_Unique.SymbolName = '';
    stSignalData_Unique.SymbolName_Base = '';
    stSignalData_Unique.SymbolComment = '';
    stSignalData_Unique.IndexGroup = [];
    stSignalData_Unique.IndexOffset = [];
    stSignalData_Unique.DataType = '';
    stSignalData_Unique.VariableSize = [];
    stSignalData_Unique.Offset = 1;
    stSignalData_Unique.ScaleFactor = 1;
    stSignalData_Unique.BitMask = '';
    stSignalData_Unique = repmat(stSignalData_Unique, 1, nUniqueSignals);
    
    for iSymbol = 1:nUniqueSignals
        % Get indices of all signals
        idxSignals = stSignalCombinations(iSymbol).Signals;
        
        % Copy all base information everything from the first matching signal
        stSignalData_Unique(iSymbol) = stSignalData(idxSignals(1));
        % Adjust the signal name
        stSignalData_Unique(iSymbol).Name = stSignalCombinations(iSymbol).Name;
        % And adjust the symbol name
        if numel(idxSignals) == 1
            stSignalData_Unique(iSymbol).SymbolName = stSignalData(idxSignals).SymbolName;
        else
            stSignalData_Unique(iSymbol).SymbolName = {stSignalData(idxSignals).SymbolName};
        end
        
        % Now, merge the signal data
        stSignalData_Unique(iSymbol).Data = horzcat(stSignalData(idxSignals).Data);
    end
    
    % And copy the collected signal data to the actual signal data
    stSignalData = stSignalData_Unique;
    
    % Also, change the count of signals
    nSignals = nUniqueSignals;
end



%% Populate the TwinCat scope object

% Create an empty object
tcsScope = tcscope({}, 'Name', stSignalData(1).ScopeName);

% Loop over each variable and push it to the scope
for iVar = 1:nSignals
    % Create a TwinCat signal object
    tcsSignal = tcsignal(aData_Values(:,iVar), aData_Times(:,iVar), 'Name', stSignalData(iVar).Name);
    % Assign all signal properties
    tcsSignal.NetId = stSignalData(iVar).NetId;
    tcsSignal.Port = str2double(stSignalData(iVar).Port);
    tcsSignal.SampleTime = str2double(stSignalData(iVar).SampleTime);
    tcsSignal.SymbolBased = strcmp(stSignalData(iVar).SymbolBased, 'True');
    tcsSignal.SymbolName = stSignalData(iVar).SymbolName;
    tcsSignal.SymbolComment = stSignalData(iVar).SymbolComment;
    tcsSignal.IndexGroup = stSignalData(iVar).IndexGroup;
    tcsSignal.IndexOffset = str2double(stSignalData(iVar).IndexOffset);
    tcsSignal.DataType = stSignalData(iVar).DataType;
    tcsSignal.VariableSize = str2double(stSignalData(iVar).VariableSize);
    tcsSignal.Offset = str2double(stSignalData(iVar).Offset);
    tcsSignal.ScaleFactor = str2double(stSignalData(iVar).ScaleFactor);
    tcsSignal.BitMask = stSignalData(iVar).BitMask;
    tcsSignal.StartRecord = str2double(stSignalData(iVar).StartRecord_Timestamp);
    tcsSignal.EndRecord = str2double(stSignalData(iVar).EndRecord_Timestamp);

    % Push the signal into the scope collection
    tcsScope = addts(tcsScope, tcsSignal);
end



%% Assign output quantities
% Imported data
tcs = tcsScope;


end


function in_oncleanup(hfSource)
%% IN_ONCLEANUP performs cleanup tasks


% Check if given function handle is a handle
if ishandle(hfSource)
    % Try to close the file
    try
        fclose(hfSource);
    % Otherwise display warning message to the user
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
