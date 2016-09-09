function [] = tsave(Filename, varargin)
% TSAVE 
%
%   Inputs:
%
%   FILENAME        Description of argument FILENAME



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Update script so that it will work with file extension given in the
%       file name
%   2016-09-01
%       * Initial release



%% Assert inputs
% Filename: Char. Non-empty
assert(isa(Filename, 'char'), 'PHILIPPTEMPEL:TSAVE:invalidTypeFilename', 'Filename must be char');
assert(~isempty(Filename), 'PHILIPPTEMPEL:TSAVE:emptyFilename', 'Filename cannot be empty');



%% Assign local variables
% Date format to append to filename
chDateFormat = 'yyyymmdd_HHMMSSFFF';
% % Get filename and adjust
chFilename = Filename;
% Did we create a backup?



%% Magic!
% Create the string of arguments
chArgs = '';
% If there are additional arguments to this function...
if ~isempty(varargin)
    % ... joint the arguments separated by "', '" and prepended by ", '" and
    % appended by "'"
    chArgs = sprintf(', ''%s''', strjoin(varargin, ''', '''));
end

% Get the file path, file name, and extension of the file to save
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(chFilename);

% Give the default '.mat' file extension to saving files
if isempty(chFile_Ext)
    chFile_Ext = '.mat';
end

% Append an underscore to the actual file name
if ~strcmp(chFile_Name(end), '_')
    chFile_Name = [chFile_Name , '_'];
end

% Just to avoid having to type this over and over again
chFile_Fullname = fullfile(chFile_Path, sprintf('%s%s%s', chFile_Name, datestr(now, chDateFormat), chFile_Ext));

% Create the command
chCommand = sprintf('save(''%s''%s);', chFile_Fullname, chArgs);

% Try to save the file
try
    % Evaluate the command in the caller's workspace
    evalin('caller', chCommand);
catch me
    throwAsCaller(me);
end



%% Nothing else to do


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
