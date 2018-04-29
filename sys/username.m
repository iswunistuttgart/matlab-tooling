function [name] = username()
% USERNAME returns the current user's username
%
%   NAME = USERNAME() returns the username of the currently using user.
%
%   Outputs:
%
%   NAME        Name of the currently actively logged in user.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-11-14
% Changelog:
%   2016-11-14
%       * Initial release



%% Code

% On unix, we will get the 'USER' environment variable
if isunix()
    name = getenv('USER');
% Anywhere else we will get the 'username' environment variable
else
    name = getenv('username');
end



%% Assign output quantities

% Strip any white space from name before returning
name = strtrim(name);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header