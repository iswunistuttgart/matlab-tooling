function varargout = mat2tex(m, varargin)
% MAT2TEX converts a matrix to LaTeX compatible tabular syntax
%
%   MAT2TEX(MAT) creates LaTeX-syntax for the NxM matrix MAT.
%
%   MAT2TEX(MAT, 'Name', 'Value', ...) allows setting optional inputs using
%   name/value pairs.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   File                Name or path to file into which to write the content of
%       the created LaTeX syntax. Must be a character array.
%
%   Table               Switch to enable wrapping the tabular environment into a
%       table environment. Is automatically switched to 'on' if a CAPTION or
%       LABEL is given. Defaults to 'off'. Possible options are:
%           'on', 'yes'         Wrap 'tabular' into a 'table' environment
%           'off', 'no'         Only return the 'tabular' environment
%
%   Caption             Caption to write for the table. According to best
%       practices the caption is typeset above the table. Must be a character
%       array.
%
%   Label               Tag of label to be typeset into the table environment.
%       Will be set above the tabular and below a possible caption. Must be a
%       character array.
%
%   ColNames            1xM cell array of column names that should automatically
%       be typeset i.e., prepended to the table.
%
%   RowNames            1xN cell array of row names that should automatically
%       be typeset i.e., prepended to the table.
%
%   ColumnAlignment     1x1 or 1xN cell array of alignments for all cells or
%       each cell respectively. Will not be checked for valid LaTeX syntax as
%       there are just too many possible column alignments availab.e
%
%   Inputs:
%
%   MAT                 Matrix to be exported to a LaTeX tabular.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-30
% Changelog:
%   2016-12-30
%       * Add option 'Table'
%       * Update help doc
%   2016-12-28
%       * Initial release


%% Assert arguments
narginchk(1, Inf);
nargoutchk(0, 1);



%% Define the input parser
ip = inputParser;

% Matrix: required; numeric, cell; 2d
valFcn_Matrix = @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}, mfilename, 'Matrix');
addRequired(ip, 'Matrix', valFcn_Matrix);

% File: optional; cell; non-empty
valFcn_File = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'File');
addParameter(ip, 'File', '', valFcn_File);

% Table: parameter; char; matches {'on', 'off', 'yes', 'no'}
valFcn_TableEnv = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'Table'));
addParameter(ip, 'Table', 'off', valFcn_TableEnv);

% Caption: parameter; char; non-empty
valFcn_Caption = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Caption');
addParameter(ip, 'Caption', '', valFcn_Caption);

% Label: parameter; char; non-empty
valFcn_Label = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Label');
addParameter(ip, 'Label', '', valFcn_Label);

% ColNames: parameter; cell; non-empty
valFcn_ColNames = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row', 'numel', size(m, 2)}, mfilename, 'ColNames');
addParameter(ip, 'ColNames', {}, valFcn_ColNames);

% RowNames: parameter; cell; non-empty
valFcn_RowNames = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row', 'numel', size(m, 1)}, mfilename, 'RowNames');
addParameter(ip, 'RowNames', {}, valFcn_RowNames);

% ColumnAlignment: parameter; cell; non-empty
valFcn_ColumnAlignment = @(x) validateattributes(x, {'char', 'cell'}, {'nonempty'}, mfilename, 'ColumnAlignment');
addParameter(ip, 'ColumnAlignment', {}, valFcn_ColumnAlignment);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{m}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Get the matrix: can be a cell or double
ceMatrix = num2cell(ip.Results.Matrix);
% Filename
chFilename = ip.Results.File;
% Caption of the table
chCaption = ip.Results.Caption;
% Label to set
chLabel = ip.Results.Label;
% Row names
ceRowNames = ip.Results.RowNames;
% Column names
ceColNames = ip.Results.ColNames;
% Get the column alignment
ceColumnAlignment = ip.Results.ColumnAlignment;
% Wrap into 'table' env or keep a plain 'tabular'?
chTableEnv = parseswitcharg(ip.Results.Table);



%% Process
% How many rows and cols of data do we have?
[nRows, nCols] = size(ceMatrix);
% Keeps the created table
ceTabular = cell(nRows, 1);
% Create the col names cell array
if ~isempty(ceColNames)
    ceColNames = cellfun(@in_processCell, ceColNames, 'UniformOutput', false);
    % Pad the column names if they were not enough
    if numel(ceColNames) < nCols
        ceColNames(end:nCols) = '';
    end
    % If there is also a row-names column, we need to prepend an empty cell to
    % the column names
    if ~isempty(ceRowNames)
        ceColNames = horzcat({''}, ceColNames);
    end
end
% Keeps the variable names
if ~isempty(ceRowNames)
    ceRowNames = cellfun(@in_processCell, ceRowNames, 'UniformOutput', false);
    % Pad the column names if they were not enough
    if numel(ceRowNames) < nRows
        ceRowNames(end:nRows) = '';
    end
end
% Prepare the column alignment
if isempty(ceColumnAlignment)
    ceColumnAlignment = repmat({'l'}, nCols + ~isempty(ceRowNames), 1);
elseif numel(ceColumnAlignment) < nCols
    ceColumnAlignment = repmat(ceColumnAlignment, 1, ceil(nCols/numel(ceColumnAlignment)));
end


% Loop over each row of data
for iRow = 1:nRows
    % Holds the current cell
    ceRow = cell(1, nCols);
    
    % Loop over each column
    for iCol = 1:nCols
        ceRow{iCol} = in_processCell(ceMatrix{iRow,iCol});
    end
    
    % If the row should have a name, we will append it
    if ~isempty(ceRowNames)
        ceRow = horzcat(in_processCell(ceRowNames{iRow}), ceRow);
    end
    
    ceTabular{iRow} = strjoin(ceRow, ' & ');
end

% Now prepare the full table
if ~isempty(ceColNames)
    ceTabular = vertcat(strjoin(ceColNames, ' & '), ceTabular);
end

% Now the table cell contains all the table data in itself, so we can create the
% table and tabular environment

chTable = '';

% Open the table environment
if strcmp(chTableEnv, 'on')
    chTable = sprintf('%s\n', '\begin{table}');
    % Make the table centered
    chTable = [chTable, sprintf('  %s\n', '\centering')];
end
% Write a caption?
if ~isempty(chCaption)
    chTable = [chTable, sprintf('  %s\n', sprintf('  \caption{%s}', chCaption))];
end
% Write a label?
if ~isempty(chLabel)
    chTable = [chTable, sprintf('  %s{%s}\n', '\label', chLabel)];
end

% Open the tabular
chTable = [chTable, repmat(' ', 1, 2*strcmp(chTableEnv, 'on')), sprintf('%s{%s}\n', '\begin{tabular}', strjoin(ceColumnAlignment, ' '))];

% Plug in the tabular content
chTable = [chTable, repmat(' ', 1, 2*(1 + strcmp(chTableEnv, 'on'))), sprintf('%s \\\\\n', strjoin(ceTabular, [' \\\\\n', repmat(' ', 1, 2*(1 + strcmp(chTableEnv, 'on')))]))];

% Close the tabular
chTable = [chTable, repmat(' ', 1, 2*strcmp(chTableEnv, 'on')), sprintf('%s\n', '\end{tabular}')];

if strcmp(chTableEnv, 'on')
    % Close the table
    chTable = [chTable, sprintf('%s\n', '\end{table}')];
end

% If no arguments are to be returned, we will display the table (write later on)
if nargout == 0 && isempty(chFilename)
    sprintf(strrep(chTable, '\', '\\'))
end

% Write to file?
if ~isempty(chFilename)
    try
        % Open file
        fhFile = fopen(chFilename, 'w');
        % Write to file
        fprintf(fhFile, strrep(chTable, '\', '\\'));
        % Close file
        fclose(fhFile);
    catch me
        throwAsCall(addcause(MException('PHILIPPTEMPEL:MATLABTOOLING:DATA:MAT2TEX:InvalidFile', 'Error opening target file.'), me));
    end
end

% First return argument is the table content
if nargout > 0
    varargout{1} = chTable;
end



end


function cl = in_processCell(cl)

if iscell(cl)
    cl = cl{:};
end
    
if ischar(cl)
    cl = sprintf('%s', cl);
elseif isnan(cl)
    cl = 'NaN';
elseif isnumeric(cl)
    cl = num2str(cl, '$%.3f$');
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
