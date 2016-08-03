function [PoseList] = parseGCode(Filename, varargin)
% PARSEGCODE 



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-03
% Changelog:
%   2016-08-03
%       * Initial release


%% Define input parser



%% Define the input parser
ip = inputParser;

% Require: Anchors. Must be a 3xN array
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Optional 1: SamplingTime. Scalar value between larger than 0
valFcn_SamplingTime = @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}, mfilename, 'SamplingTime');
addOptional(ip, 'SamplingTime', 1e-3, valFcn_SamplingTime);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{Filename}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Do your code magic here
% Filename
chFilename = ip.Results.Filename;
assert(2 == exist(chFilename, 'file'), 'File [%s] does not exist', chFilename);
% Sampling Time
dSamplingTime = ip.Results.SamplingTime;

% Read the G-Code file
try
    fidSource = fopen(chFilename);
    ceGCode = textscan(fidSource, '%s', 'Delimiter', '\n', 'Whitespace', ''); ceGCode = ceGCode{1};
    fclose(fidSource);
catch me
    if strcmp(me.identifier, 'MATLAB:FileIO:InvalidFid')
        throw(MException('PHILIPPTEMPEL:NewFunction:InvalidFid', 'Could not open source file for reading.'));
    end
    throwAsCaller(MException(me.identifier, me.message));
end

% List of commands
ceCommands = [];
% Holds variables that need to be replaced afterwards
aVariables = [];

% Process the file
for iLine = 1:numel(ceGCode)
    % Get the current line for easier access without additional whitespaces
    chLine = strtrim(ceGCode{iLine});
    
    % Get position of comment start
    nCommentStart = find('(' == chLine, 1);
    % If we have a comment starting somewhere in the line
    if ~isempty(nCommentStart)
        % Get position of comment end
        nCommentEnd = find(')' == chLine, 1);
        % If the comment does not end explicitely, it will end at the end of the
        % line
        if isempty(nCommentEnd)
            % Remove text from command from comment start till end of line
            chLine(nCommentStart:end) = '';
        else
            % Remove text from command from comment start till commend end
            chLine(nCommentStart:nCommentEnd) = '';
        end
    end
    
    % Remove any additional whitspace
    chLine = strtrim(chLine);
    
    % Skip completely empty lines
    if isempty(chLine)
        continue
    end
    
    display(chLine) % Temporary output
    
    % Whether a new command is started by this line of G-Code
    lNewCommand = 0;
    
    % Parse the g-code into a sequence of line-commands
    ceLineCommands = regexp(chLine, '\s*', 'split');
    
    % Loop over all line commands
    for iLineCommand = 1:numel(ceLineCommands)
        chLineCommand = ceLineCommands{iLineCommand};
        
        % Default feedrate is 0 [ mm / min ]
        nCommand_Feedrate = 0;
        % Default machine command is 0
        nCommand_MachineCode = 0;
        % Values commanded for each axis
        aCommand_Axes = zeros(1, 8);
        % Default command is seeking
        chCommand_Mode = 'seek';
        % Default positioning mode is absolute
        chCommand_Positioning = 'absolute';
        
        switch chLineCommand(1)
            % Motion command G01 G02 G03 G04 G90 G91
            case 'G'
                % We have a new command given here
                lNewCommand = true;
                % Get the command number
                nCommand = str2double(chLineCommand(2:end));
                
                % Switch the command mode
                switch nCommand
                    case 0
                        chCommand_Mode = 'seek';
                    case 1
                        chCommand_Mode = 'linear';
                    case 2
                        chCommand_Mode = 'arc_cw'
                    case 3
                        chCommand_Mode = 'arc_ccw';
                    case 4
                        chCommand_Mode = 'pause';
                    case 90
                        chCommand_Positioning = 'absolute';
                    case 91
                        chCommand_Positioning = 'relative';
                end
            % Line number
            case 'N'
                % Skip this entry
                continue
            % Special commands, no care taken
            case {'#', 'V', '%', '$'}
                % Skip this entry
                continue
            % Feed rate in [ mm / min ]
            case 'F'
                nCommand_Feedrate = str2double(chLineCommand(2:end));
            % Machine command
            case 'M'
                nCommand_MachineCode = str2double(chLineCommand(2:end));
            % Variable declaration
            case 'P'
                ceVariable = regexp(chLineCommand, 'P(?<name>\d*)=(?<value>\d*)', 'names');
                aVariables(end+1) = ceVariable;
            % Axis command (either Joint space or Cartesian)
            case 'W'
                stAxis = regexp(chLineCommand, 'W(?<axis>\d*)=(?<amount>\d*)', 'names');
                aCommand_Axes(str2double(stAxis.axis)) = str2double(stAxis.amount);
        end
        
        aCommand_Axes
    end
    
    if lNewCommand
        if strcmp(chCommand_Positioning, 'relative')
            
        else
            
        end
    end
end

ceCommands

aVariables




end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
