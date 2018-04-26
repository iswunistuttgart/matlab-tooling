function save_ws(varargin)
% SAVE_WS saves the whole workspace to a unique filename 
% 
%   SAVE_WS() saves the whole workspace to a filename based on the current
%   timestamp formatted as 'yyyymmdd_HHMMSSFFF' thus resulting in the filename
%   'yyyymmdd_HHMMSSFFF.mat'.
%
%   SAVE_WS(PREFIX) adds prefix 'PREFIX' to the file name.
%
%   SAVE_WS(PREFIX, SUFFIX) adds both prefix 'PREFIX' and suffix 'SUFFIX' to the
%   file name.
%
%   SAVE_WS('Name', 'Value', ...) allows setting optional inputs using
%   name/value pairs.
%   
%   Inputs:
%   
%   PREFIX          Prefix to prepend to the file name.
%   
%   SUFFIX          Suffix to append to the file name before the extension.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Prefix          Prefix to prepend to the file name.
%
%   Suffix          Suffix to append to the file name before the extension.
%
%   DateFormat      Formatting string for the date to be appended to the
%       filename. Defaults to 'yyyymmdd_HHMMSSFFF' but can be set to '' if no
%       date should be appended.
%
%   See also: SAVE EVALIN



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-10
% Changelog:
%   2016-12-10
%       * Fix incorrect type checking in input parser (from 'cell' to 'char')
%       * Rename to `save_ws`
%       * Add try/catch block around `evalin`
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-05-03
%       * Fix bug in input parser's ```parse```
%       * Fix bug resulting from different variable types (```char``` vs. ```cell```)
%   2016-04-01
%       * Add input parser
%       * Add help doc
%   2015-07-22
%       * Initial release



%% Define the input parser
ip = inputParser;

% Optional 1: Prefix to filename
valFcn_Prefix = @(x) validateattributes(x, {'char'}, {}, mfilename, 'Prefix');
defPrefix = 'ws_';
addOptional(ip, 'Prefix', defPrefix, valFcn_Prefix);

% Optional 2: Suffix to filename before extension
valFcn_Suffix = @(x) validateattributes(x, {'char'}, {}, mfilename, 'Suffix');
defSuffix = '';
addOptional(ip, 'Suffix', defSuffix, valFcn_Suffix);

% Optional 2: Suffix to filename before extension
valFcn_DateFormat = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'DateFormat');
defDateFormat = 'yyyymmdd_HHMMSSFFF';
addOptional(ip, 'DateFormat', defDateFormat, valFcn_DateFormat);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
end



%% Parse variables to local scope
% Prefix
chPrefix = char(ip.Results.Prefix);
if isempty(chPrefix)
    chPrefix = defPrefix;
end
% Suffix
chSuffix = char(ip.Results.Suffix);
if isempty(chSuffix)
    chSuffix = defSuffix;
end
% Date format
chDateFormat = char(ip.Results.DateFormat);



%% Do the magic
% In the base workspace we will be evaluating all the commands
try
    evalin('base', ['save(''' , sprintf('%s%s%s.mat', chPrefix, datestr(datevec(now), chDateFormat), chSuffix) , ''');']);
catch me
    throw(addCause(MException('PHILIPPTEMPEL:MATLABTOOLING:SAVEWS:ErrorSaving', 'There was an error saving your workspace.'), me));
end



%% Assign output quantities


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
