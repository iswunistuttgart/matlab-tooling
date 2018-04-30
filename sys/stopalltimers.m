function [] = stopalltimers()
% STOPALLTIMERS stops all timers whether they are visible or not
%
%   STOPALLTIMERS stops all currently running timers regardless their
%   visibility. Displays a warning if a timer could not be stopped.
%
%   See also: timerfindall stop



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-21
% Changelog:
%   2017-01-21
%       * Make use of arrayfun over simple loops
%   2016-09-02
%       * Initial release



%% Do your code magic here
% Get all timers
tiTimers = timerfindall;

% Filter running timers
tiTimers = tiTimers(cell2mat(arrayfun(@(ti) strcmp(ti.Running, 'on'), tiTimers, 'UniformOutput', false)));

% Loop over running fiters and stop each of these
arrayfun(@(ti) stop(ti), tiTimers, 'UniformOutput', false);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
