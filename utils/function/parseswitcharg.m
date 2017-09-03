function [res] = parseswitcharg(arg, add_on, add_off)%#codegen
% PARSESWITCHARG parses the toggle arg to a valid and unified char.
%
%   RES = PARSESWITCHARG(ARG) parses toggle argument ARG to match a unified
%   true/false value. The following mapping is used internally:
%       'on'        'on'
%       'yes'       'on'
%       'please'    'on'
%       'off'       'off'
%       'no'        'off'
%       'never'     'off'
%   If ARG cannot be parsed, it defaults to 'off'.
%
%   Inputs:
%
%   ARG     Argument as given to the function call.
%
%   Outputs:
%
%   RES     Resulting argument char representing a true value with 'on' and a
%           false value with 'off'.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-08-31
% Changelog:
%   2017-08-31
%       * Remove necessity for argument ARG to be non-empty
%   2016-09-18
%       * Add option to pass additional strings for 'on' or 'off' result
%   2016-09-07
%       * Initial release



%% Default arguments
if nargin < 2
    add_on = {};
end

if nargin < 3
    add_off = {};
end



%% Assertion
% Arg: char; non-empty
assert(ischar(arg), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:InvalidArgumentType', 'Argument [arg] must be char.');
% assert(~isempty(arg), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:EmptyArgument', 'Argument [arg] must not be empty.');
% Add_on: Cell of chars; nonempty
assert(iscell(add_on), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:InvalidArgumentType', 'Argument [add_on] must be cell.');
assert(all(cellfun(@(x) ischar(x), add_on)), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:InvalidArgumentType', 'Argument [add_on] must be cell array of chars.');
% Add_off: Cell of chars; nonempty
assert(iscell(add_off), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:InvalidArgumentType', 'Argument [add_offs] must be cell.');
assert(all(cellfun(@(x) ischar(x), add_off)), 'PHILIPPTEMPEL:MATLAB_TOOLING:PARSESWITCHARG:InvalidArgumentType', 'Argument [add_off] must be cell array of chars.');



%% Do your code magic here

ceChar_On = [{'on'}, {'yes'}, {'please'}, add_on{:}];
ceChar_Off = [{'off'}, {'no'}, {'never'}, add_off{:}];

switch lower(arg)
    case ceChar_On
        res = 'on';
    case ceChar_Off
        res = 'off';
    otherwise
        res = 'off';
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
