function varargout = ode4b(odefun, tspan, y0, options)
% ODE4B solve ODE with Newton-Euler BDF of second order
%
%   Inputs:
%
%   ODEFUN              Function handle to the ODE of the form @(t, y)
%
%   TSPAN               1x2 vector of [T0, TE] or a 1xN vector of time values at
%                       which to integrate the ODE.
%
%   Y0                  Kx1 vector of initial values
%
%   Outputs:
%
%   T                   Nx1 vector of time steps at which ODE was evaluated.
%
%   Y                   NxK state space vector of solution of ODEFUN.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-17
% Changelog:
%   2018-08-17
%       * Initial release



%% Wrap around ODEXB
try
    % Default options
    if nargin < 4
        options = {};
    end
    
    % Extend the options given with the maximum order for BDF
    options = odeset( ...
          options ...
        , 'MaxOrder', 4 ...
    );
    
    % Call our base function `odeXb` toprocess everything
    [varargout{1}, varargout{2}] = odeXb(odefun, tspan, y0, options);
catch me
    throwAsCaller(me);
end



end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
