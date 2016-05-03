function saveWorkspace(varargin)
% SAVEWORKSPACE Save the whole workspace to a unique filename 
% 
%   SAVEWORKSPACE() saves the whole workspace to a filename based on the current
%   timestamp formatted as 'yyyymmdd_HHMMSSFFF' thus resulting in the filename
%   'yyyymmdd_HHMMSSFFF.mat'.
%
%   SAVEWORKSPACE(PREFIX) adds prefix 'PREFIX' to the file name.
%
%   SAVEWORKSPACE(PREFIX, SUFFIX) adds both prefix 'PREFIX' and suffix
%   'SUFFIX' to the file name.
%   
%   Inputs:
%   
%   PREFIX: Prefix to prepend to the file name. Can also be given with the
%   'Prefix' key.
%   
%   SUFFIX: Suffix to append to the file name before the extension. Can also be
%   given with the 'Suffix' key.
%
%   See also: save
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-03
% Changelog:
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
valFcn_Prefix = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'Prefix');
addOptional(ip, 'Prefix', 'ws_', valFcn_Prefix);

% Optional 2: Suffix to filename before extension
valFcn_Suffix = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'Suffix');
addOptional(ip, 'Suffix', '', valFcn_Suffix);

% Optional 2: Suffix to filename before extension
valFcn_DateFormat = @(x) validateattributes(x, {'cell'}, {'nonempty'}, mfilename, 'DateFormat');
addOptional(ip, 'DateFormat', 'yyyymmdd_HHMMSSFFF', valFcn_DateFormat);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, varargin{:});



%% Parse variables to local scope
% Prefix
chPrefix = char(ip.Results.Prefix);
% Suffix
chSuffix = char(ip.Results.Suffix);
% Date format
chDateFormat = char(ip.Results.DateFormat);



%% Do the magic
% In the base workspace we will be evaluating all the commands
evalin('base', ['save(''' , sprintf('%s%s%s.mat', chPrefix, datestr(datevec(now), chDateFormat), chSuffix) , ''');']);



%% Assign output quantities


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
