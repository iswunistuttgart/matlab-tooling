function [] = tsave(Filename, varargin)
% TSAVE 
%
%   Inputs:
%
%   FILENAME        Description of argument FILENAME



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-01
% Changelog:
%   2016-09-01
%       * Initial release



%% Assert inputs
% Filename: Char. Non-empty
assert(isa(Filename, 'char'), 'PHILIPPTEMPEL:TSAVE:invalidTypeFilename', 'Filename must be char');
assert(~isempty(Filename), 'PHILIPPTEMPEL:TSAVE:emptyFilename', 'Filename cannot be empty');



%% Assign local variables
% Date format to append to filename
chDateFormat = 'yyyymmdd_HHMMSSFFF';
% Get filename and adjust
chFilename = Filename;
if ~strcmp(chFilename(end), '_')
    chFilename = [chFilename , '_'];
end
% Append timestamp to filename
chFilename = sprintf('%s%s', chFilename, datestr(datevec(now), chDateFormat));


%% Magic!
% Create the string of arguments
chArgs = '';
% If there are additional arguments to this function...
if ~isempty(varargin)
    % ... joint the arguments separated by "', '" and prepended by ", '" and
    % appended by "'"
    chArgs = sprintf(', ''%s''', strjoin(varargin, ''', '''));
end
% Create the command
chCommand = sprintf('save(''%s''%s);', chFilename, chArgs);

% Evaluate the command in the caller's workspace
evalin('caller', chCommand);



%% Nothing else to do


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
