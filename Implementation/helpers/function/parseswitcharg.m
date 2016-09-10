function [res] = parseswitcharg(arg)
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
% Date: 2016-09-07
% Changelog:
%   2016-09-07
%       * Initial release



%% Do your code magic here

switch lower(arg)
    case {'on', 'yes', 'please'}
        res = 'on';
    case {'off', 'no', 'never'}
        res = 'off';
    otherwise
        res = 'off';
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
