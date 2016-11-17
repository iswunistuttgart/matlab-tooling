function [name] = computername()
% COMPUTERNAME returns the name of the computer in the local network
%
%   NAME = COMPUTERNAME() determines the computers name depending on it being a
%   PC or UNIX system.
%
%   Outputs:
%
%   Name            Character array that is the computer name in the local
%       network.



%% File information
% Author: mathworks.com/matlabcentral/fileexchange/16450-get-computer-name-hostname/content/getComputerName.m
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-11-14
% Changelog:
%   2016-11-14
%       * Initial release



%% Code

% Call the system command `hostname` and check its result status
[status, name] = system('hostname');

% If the previous command call failed, we will need to infer the computer name
% from an environment variable
if status ~= 0
    % On windows
    if ispc
        name = getenv('COMPUTERNAME');
    % On anything else
    else      
        name = getenv('HOSTNAME');      
    end
end



%% Assign output quantities

% Strip any white space from name before returning
name = strtrim(name);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
