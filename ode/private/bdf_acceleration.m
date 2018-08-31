function res = bdf_acceleration(odefun, ordr, yp, tn, yn, h, mass, varargin)
% BDF_ACCELERATION implements the FSOLVE callback for BDF Euler
%
%   Inputs:
%
%   ODEFUN              ODE function callback.
%
%   ORDR                Order K of the BDF formulation.
%
%   YP                  NxK vector of the previous states.
%
%   TN                  Time value at the to-be-estimated state.
%
%   YN                  Nx1 vector of the current next-state estimate.
%
%   H                   Step size.
%
%   MASS                Structure containing information on the mass matrix.
%
%   Outputs:
%
%   RES                 Residual of the estimate for y_n+1



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-30
% Changelog:
%   2018-08-30
%       * Fix incorrect Butcher tableau for BDF of order 5
%   2018-08-29
%       * Remove currently unused argument `OPTIONS`
%   2018-08-19
%       * Rename from `odeXb_fsolve` to `odeXeb_fsolve`
%   2018-08-18
%       * Initial release



%% Initialize variables

% To speed up evaluation, make Butcher tableau persistent
persistent aButcher
% Butcher tableau
if isempty(aButcher)
  aButcher = [ ...
      [      0,       0,       0,        0,       0,       -1] ; ...
      [      0,       0,       0,        0,     1/3,     -4/3] ; ...
      [      0,       0,       0,    -2/11,    9/11,   -18/11] ; ...
      [      0,       0,    3/25,   -16/25,   36/25,   -48/25] ; ...
      [      0, -12/137,  75/137, -200/137, 300/137, -300/137] ; ...
      [ 10/147, -72/147, 225/147, -400/147, 450/147, -360/147] ; ...
  ];
end

% To speed up process: also make stepsize weights persistent
persistent vStepsizeWeights
% Weights of step sizes
if isempty(vStepsizeWeights)
  vStepsizeWeights = [ ...
           1 ; ...
         2/3 ; ...
        6/11 ; ...
       12/25 ; ...
      60/137 ; ...
      60/147 ; ...
  ];
end


% Calculate residual value
res = mass(tn, yn)*(yn + yp*transpose(aButcher(ordr,end-(ordr-1):end))) - vStepsizeWeights(ordr)*h*feval(odefun, tn, yn);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
