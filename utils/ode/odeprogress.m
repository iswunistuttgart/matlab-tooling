function status = odeprogress(t, y, flag, varargin)
% ODEPROGRESS creates a progress bar window for use as simulation progress info
%
%   When the function ODEPROGRESS is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn', @odeprogress), the solver calls
%   ODEPROGRESS(T, Y, '') after every timestep.  The ODEPROGRESS displays a
%   progress bar window with a cancel button so that the current simulation
%   progress can be read.
%
%   Inputs:
%
%   T                   Description of argument T
%
%   Y                   Description of argument Y
%
%   FLAG                Description of argument FLAG
%
%   Outputs:
%
%   STATUS              Description of argument STATUS



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-09-17
% Changelog:
%   2017-09-17
%       * Initial release



%% Initialize function
persistent hpTarget

% Assume stop button wasn't pushed.
status = 0;
% Check Stop button every 1 sec.
dCallbackDelay = 1;

% support odeprogress(t, y) [v5 syntax]
if nargin < 3 || isempty(flag)
    flag = '';
end



%% Do your code magic here

switch ( flag )
    
    case ''
        if isempty(hpTarget)
            error(message('PHILIPPTEMPEL:MATLAB:ODEPROGRESS:NotCalledWithInit'));
        end
        
        dMaxTime = hpTarget.UserData.Time;
        
        dProgress = t(1)/dMaxTime;
        waitbar(dProgress, hpTarget, sprintf('Simulation time: %.4f/%.2f', t(1), dMaxTime));
        hpTarget.Name = sprintf('Progress: %.2f %%', dProgress*100);
    
    case 'init'
        hpTarget = waitbar(0, 'Initializing...', 'Name', 'Initializing', 'CreateCancelBtn', @in_cb_stopbutton);
        hpTarget.UserData.Time = max(t);
    
    case 'done'
        % Reset the persistent progress bar window
        hpWindow = hpTarget;
        hpTarget = [];
        
        delete(hpWindow);
        
    otherwise
        error(message('PHILIPPTEMPEL:MATLAB:ODEPROGRESS:UnrecognizedFlag', flag));
end
% END switch ( flag )


end


function in_cb_stopbutton(~, ~)

ud = get(gcbf, 'UserData');
ud.stop = 1;
set(gcbf, 'UserData', ud);

end 



%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
