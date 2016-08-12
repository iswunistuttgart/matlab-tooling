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



%% Assign local variables
% Filename
chFilename = ip.Results.Filename;
assert(2 == exist(chFilename, 'file'), 'File [%s] does not exist', chFilename);
% Sampling Time
dSamplingTime = ip.Results.SamplingTime;
% Interpolation method
chInterpolate = 'straight';



%% Read G-Code file
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



%% Parse commands
% Array of structures of commands
% aCommands(i).AxesValues = zeros(8, 1); % <double>
% aCommands(i).Feedrate = []; % <double>
% aCommands(i).MachineCommand = []; % <double>
% aCommands(i).Mode = {'seek', 'linear', 'arc_cw', 'arc_ccw', 'pause'}; % char
% aCommands(i).Positioning = {'absolute', 'relative'}; % char
aCommands = [];
% Holds variables that need to be replaced afterwards
aVariables = [];

% Loop over all lines of the g-code file
for iLine = 1:numel(ceGCode)
    % Get the current line without additional whitespaces for easier access
    chLine = strtrim(ceGCode{iLine});
    
    %%% Remove comments
    % Get position of comment start character '('
    nCommentStart = find('(' == chLine, 1);
    % If we have a comment starting somewhere in the line
    if ~isempty(nCommentStart)
        % Get position of comment end character ')'
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
    
    % Per default the line does not give a new command
    lNewCommand = 0;
    
    %%% Parse the line
    % Split the command line at whitespaces
    ceLineCommands = regexp(chLine, '\s*', 'split');
        
    % Default values for the current line's command
    chFeedrate = '1000'; % [ mm / min ] <double>
    aAxesValues = repmat({''}, 1, 8); % [ mm ] <char>
    dMachineCommand = 0; % [ ]
    chMode = 'seek'; % <char>
    chPositioning = 'relative'; % <char>
    
    %%% Loop over all line commands
    for iLineCommand = 1:numel(ceLineCommands)
        % Quicker access to the actual line command
        chLineCommand = ceLineCommands{iLineCommand};
        
        % Get the first character of the line command
        chCommand = chLineCommand(1);
        
        % Depending on what this command is, we will do different things
        switch chCommand
            % Feedrate
            case 'F'
                chFeedrate = chLineCommand(2:end);
            % Motion command
            case 'G'
                % We have a new command given here
                lNewCommand = 1;
                % Get the command number
                nCommand = str2double(chLineCommand(2:end));
                
                % Switch the command mode
                switch nCommand
                    case 0
                        chMode = 'seek';
                    case 1
                        chMode = 'linear';
                    case 2
                        chMode = 'arc_cw';
                    case 3
                        chMode = 'arc_ccw';
                    case 4
                        chMode = 'pause';
                        chPositioning = 'relative';
                        chFeedrate = ceLineCommands{2};
                    case 90
                        chPositioning = 'absolute';
                    case 91
                        chPositioning = 'relative';
                end
            % Machine command
            case 'M'
                dMachineCommand = str2double(chLineCommand(2:end));
            % Programmed variable
            case 'P'
                ceVariable = regexp(chLineCommand, 'P(?<name>\d*)=(?<value>\d*)', 'names');
                iVariable = numel(aVariables) + 1;
                aVariables(iVariable).Name = ['P' , ceVariable.name];
                aVariables(iVariable).Value = ceVariable.value;
            % Axis command (either Joint space or Cartesian)
            case 'W'
                % Regexp-split the 
                stAxis = regexp(chLineCommand, 'W(?<axis>[^\=]*)=(?<amount>[^\ ]*)', 'names');
                
                aAxesValues{str2double(stAxis.axis)} = stAxis.amount; % <double>:<char>
            % Anything else is not taken care of e.g.,
            % E: Feedrate at block end
            % H: 
            % N: Line number
            % S: Spindle speed
            % T: Tool select
            % V: 
            % #: Special functions
            % %: 
            % $: 
            otherwise
                continue
        end
    end
    
    % If a new command was introduced by the line, we will append it to the list
    % of commands
    if lNewCommand
        iCommand = numel(aCommands) + 1;

        % Append new command to list of commands
        aCommands(iCommand).AxesValues = aAxesValues; %#ok<*AGROW>
        aCommands(iCommand).FeedRate = chFeedrate;
        aCommands(iCommand).MachineCommand = dMachineCommand;
        aCommands(iCommand).Mode = chMode;
        aCommands(iCommand).Positioning = chPositioning;
        
        % DEBUG OUTPUT
        display(aCommands(iCommand), 'Current Command');
        % DEBUG OUTPUT
    end
end



%% Translate Commands
% Replace variables
if ~isempty(aVariables)
    for iVariable = 1:numel(aVariables)
        for iCom = 1:numel(aCommands)
            % Replace variables in axes commands
            aCommands(iCom).AxesValues = strrep(aCommands(iCom).AxesValues, aVariables(iVariable).Name, aVariables(iVariable).Value);
            % Replace variables in feed rate
            aCommands(iCom).FeedRate = strrep(aCommands(iCom).FeedRate, aVariables(iVariable).Name, aVariables(iVariable).Value);
        end
    end
end

%%% Fill empty slots and turn relative into absolute
% Keeps the previous axes values
cePreviousAxesValues = repmat({'0'}, 1, 8);
% Loop over all commands (again)
for iCom = 1:numel(aCommands)
    % Indices of full cells
    vFullCells = cellfun(@(x) ~isempty(x), aCommands(iCom).AxesValues);
    % Number of full cells
    nFullCells = numel(vFullCells);
    % Indices of empty cells
    vEmptyCells = cellfun(@(x) isempty(x), aCommands(iCom).AxesValues);
    % Number of empty cells
    nEmptyCells = numel(find(vEmptyCells));
    
    % If we are in pause mode...
    if strcmp(aCommands(iCom).Mode, 'pause') || strcmp(aCommands(iCom).Positioning, 'absolute')
        % Copy the previous command's values
        aCommands(iCom).AxesValues(vEmptyCells) = cePreviousAxesValues(vEmptyCells);
    % For relative motion
    else
        % Update the empty cells (if exist)
        if nEmptyCells
            aCommands(iCom).AxesValues(vEmptyCells) = cePreviousAxesValues(vEmptyCells);
        end
        
        % Update non-empty cells (if exist)
        if nFullCells
            for iFullCell = 1:nFullCells
                aCommands(iCom).AxesValues(vFullCells(iFullCell)) = strjoin({cePreviousAxesValues(vFullCells(iFullCell)), aCommands(iCom).AxesValues(vFullCells(iFullCell))}, '+');
            end
        end
    end
    
    % DEBUG OUTPUT
    display(aCommands(iCom).AxesValues, 'AxesValues after adjusting rel/abs');
    % DEBUG OUTPUT
    
    % Store the current axes values for the next loop
    cePreviousAxesValues = aCommands(iCom).AxesValues;
end

%%% Evalutae commands i.e., turn sums or diffs into actual values
for iCom = 1:numel(aCommands)
    % Cast all cell values of AxesValues to doubles and scale them correctly:
    % W1, W2, W3 from [ mm ] to [ m ]
    % W4, W5, W6 from [ deg ] to [ rad ]
    aCommands(iCom).AxesValues = cellfun(@eval, aCommands(iCom).AxesValues(1:6))./[1000 1000 1000 180*pi 180*pi 180*pi];
    % Cast feedrate to double and convert it from [ mm / min ] to [ m / s ]
    aCommands(iCom).FeedRate = in_feed2vel(eval(aCommands(iCom).FeedRate));
    
    % DEBUG OUTPUT
    display(aCommands(iCom).AxesValues, 'AxesValues after casting to double');
    display(aCommands(iCom).FeedRate, 'FeedRate after casting to double');
    % DEBUG OUTPUT
end



%% Create the pose list
vTime = [];
aPoses = [];
dTime_Current = 0;
% stLastCmd = struct(
%     'AxesValues' = zeros(1, 8);
%     'FeedRate' = 0;
%     'MachineCommand' = 0;
%     'Mode' = 'pause';
%     'Positioning' = 'absolute';
% );
vPose_Current = zeros(1, 3+9);

for iCmd = 1:numel(aCommands)
    stCommand = aCommands(iCmd);
    vTime_Cmd = 0;
    vPose_Cmd = [0,0,0, 1,0,0, 0,1,0, 0,0,1];

    % @TODO: Adjust such that it will be using the last command not the last
    % pose as we need the XYZABC values to work on for proper interpolation
    switch lower(stCommand.Mode)
        case 'pause'
            [vTime_Cmd, vPose_Cmd] = in_interpPause(dTime_Current, vPose_Current, stCommand, dSamplingTime);
        case 'seek'
            [vTime_Cmd, vPose_Cmd] = in_interpSeek(dTime_Current, vPose_Current, stCommand, dSamplingTime);
        case 'linear'
            switch chInterpolate
                case 'bezier'
                    [vTime_Cmd, vPose_Cmd] = in_interpLinear_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime);
                otherwise
                    [vTime_Cmd, vPose_Cmd] = in_interpLinear_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime);
            end
        case 'arc_cw'
            switch chInterpolate
                case 'bezier'
                    [vTime_Cmd, vPose_Cmd] = in_interpArcCw_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime);
                otherwise
                    [vTime_Cmd, vPose_Cmd] = in_interpArcCw_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime);
            end
        case 'arc_ccw'
            switch chInterpolate
                case 'bezier'
                    [vTime_Cmd, vPose_Cmd] = in_interpArcCcw_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime);
                otherwise
                    [vTime_Cmd, vPose_Cmd] = in_interpArcCcw_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime);
            end
    end

    % Append new time and new pose value
    vTime = [vTime, vTime_Cmd];
    aPoses = [aPoses; vPose_Cmd];

    % Push back last time and last pose value
    dTime_Current = vTime(end);
    vPose_Current = aPoses(end,:);
%     stLastCmd = stCommand.AxesValues;
end



%% Assign output quantities

PoseList = timeseries(aPoses, vTime);


end


function v = in_feed2vel(f)

v = f./1000./60;

end


function [vTime_Cmd, vPose_Cmd] = in_interpPause(dTime_Current, vPose_Current, stCommand, dSamplingTime)

vTime_Cmd = dTime_Current + (0:dSamplingTime:stCommand.FeedRate);
vPose_Cmd = repmat(vPose_Current, numel(vTime_Cmd), 1);

end

function [vTime_Cmd, vPose_Cmd] = in_interpSeek(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end


function [vTime_Cmd, vPose_Cmd] = in_interpLinear_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime)
% Get direction of linear and angular motion
vDirection_Lin = stCommand.AxesValues(1:3) - vPose_Current(1:3);
vDirection_Rot = stCommand.AxesValues(4:6) - vPose_Current(4:6);
% Get length of all linear and angular motions
dLength_Lin = norm(vDirection_Lin);
dLength_Rot = max(max(abs(vDirection_Rot(1)), abs(vDirection_Rot(2))), abs(vDirection_Rot(3)));
% Determine transition time for linear and angular motion
dTransitionTime_Lin = round(dLength_Lin./stCommand.FeedRate, 5); % [ s ]
dTransitionTime_Rot = round(dLength_Rot./stCommand.FeedRate*2, 5); % [ s ] % [ 30.000 deg / min ] = [ 500 deg / s]
% Determine the actual transition time
vTime_Cmd = dTime_Current + (0:dSamplingTime:max(dTransitionTime_Lin,dTransitionTime_Rot));

% Create new pose holding array
vPose_Cmd = zeros(numel(vTime_Cmd), 3+9);

%% Interpolate the linear command
vPose_Cmd(:,1) = interp1([0, vTime_Cmd(end)], [vPose_Current(1), stCommand.AxesValues(1)], vTime_Cmd, 'linear');
vPose_Cmd(:,2) = interp1([0, vTime_Cmd(end)], [vPose_Current(2), stCommand.AxesValues(2)], vTime_Cmd, 'linear');
vPose_Cmd(:,3) = interp1([0, vTime_Cmd(end)], [vPose_Current(3), stCommand.AxesValues(3)], vTime_Cmd, 'linear');

%% Interpolate the rotational command
% Temporary 
vPoseRot = [...
    ; interp1([0, vTime_Cmd(end)], [vPose_Current(4), stCommand.AxesValues(4)], vTime_Cmd, 'linear') ...
    ; interp1([0, vTime_Cmd(end)], [vPose_Current(5), stCommand.AxesValues(5)], vTime_Cmd, 'linear') ...
    ; interp1([0, vTime_Cmd(end)], [vPose_Current(6), stCommand.AxesValues(6)], vTime_Cmd, 'linear') ...
];
vPose_Cmd(:,(1:9) + 3) = rotm2row(eul2rotm(fliplr(transpose(rad2deg(vPoseRot))), 'ZYX'));


end


function [vTime_Cmd, vPose_Cmd] = in_interpLinear_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end

function [vTime_Cmd, vPose_Cmd] = in_interpArcCw_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end

function [vTime_Cmd, vPose_Cmd] = in_interpArcCw_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end

function [vTime_Cmd, vPose_Cmd] = in_interpArcCcw_Bezier(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end

function [vTime_Cmd, vPose_Cmd] = in_interpArcCcw_Straight(dTime_Current, vPose_Current, stCommand, dSamplingTime)

error('Not yet implemented');

end


%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
