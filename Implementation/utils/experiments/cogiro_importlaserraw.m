function LTData = cogiro_importlaserraw(Filename, StartRow, EndRow)

%% Default arguments
if nargin < 2
    StartRow = 3;
end

if nargin < 3
    EndRow = Inf;
end



%% Initialize variables.
% Filename
chFilename = Filename;
% Delimiter char
chDelimiter = ',';
% Start row of import
nStartRow = StartRow;
% End row of import
nEndRow = EndRow;



%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%s%s%s%[^\n\r]';



%% Open the text file.
hfData = fopen(chFilename,'r');



%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this code. If
% an error occurs for a different file, try regenerating the code from the
% Import Tool.
ceDataArray = textscan(hfData, formatSpec, nEndRow(1)-nStartRow(1)+1, 'Delimiter', chDelimiter, 'HeaderLines', nStartRow(1)-1, 'ReturnOnError', false);
for block=2:length(nStartRow)
    frewind(hfData);
    ceDataArrayBlock = textscan(hfData, formatSpec, nEndRow(block)-nStartRow(block)+1, 'Delimiter', chDelimiter, 'HeaderLines', nStartRow(block)-1, 'ReturnOnError', false);
    for iCol=1:length(ceDataArray)
        ceDataArray{iCol} = [ceDataArray{iCol};ceDataArrayBlock{iCol}];
    end
end



%% Close the text file.
fclose(hfData);



%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
ceRaw = repmat({''},length(ceDataArray{1}),length(ceDataArray)-1);
for iCol = 1:length(ceDataArray)-1
    ceRaw(1:length(ceDataArray{iCol}),iCol) = ceDataArray{iCol};
end
numericData = NaN(size(ceDataArray{1},1),size(ceDataArray,2));

for iCol = [1,2,3,4]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = ceDataArray{iCol};
    for row = 1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, iCol) = numbers{1};
                ceRaw{row, iCol} = numbers{1};
            end
        catch me
        end
    end
end



%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),ceRaw); % Find non-numeric cells
ceRaw(R) = {NaN}; % Replace non-numeric cells



%% Create output variable
LTData = cell2mat(ceRaw);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
