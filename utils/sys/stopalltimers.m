function [] = stopalltimers()
% STOPALLTIMERS stops all timers whether they are visible or not
%
%   STOPALLTIMERS stops all currently running timers regardless their
%   visibility. Displays a warning if a timer could not be stopped.
%
%   See also: timerfindall stop



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-02
% Changelog:
%   2016-09-02
%       * Initial release



%% Do your code magic here
% Get all timers
tiTimers = timerfindall;

% If we have timers
if ~isempty(tiTimers)
    % Loop over each timer
    for iTimer = 1:numel(tiTimers)
        % Stop the timer
        stop(tiTimers(iTimer))
        
        % Make sure the timer is stopped ...
        try
            % ... by asserting its 'Running' property is set to 'off'
            assert(strcmp('off', tiTimers(iTimer).Running));
        % Stopping failed, so display a warning
        catch me
            warning('PHILIPPTEMPEL:STOPALLTIMERS:failedStoppingTimer', 'Failed stopping timer %i', iTimer);
            
            continue;
        end

        % Delete timer object from memory
        delete(tiTimers(iTimer));
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
