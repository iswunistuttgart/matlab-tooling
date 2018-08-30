function res = bdf_acceleration(odefun, ordr, tn, tn1, ynp, yn1, mass, varargin)
% BDF_ACCELERATION implements the FSOLVE callback for BDF Euler
%
%   Inputs:
%
%   ODEFUN              ODE function callback.
%
%   ORDR                Order K of the BDF formulation.
%
%   TN                  Current time value.
%
%   TN1                 Time value at the to-be-estimated state.
%
%   YNP                 NxK vector of the previous states.
%
%   YN1                 Nx1 vector of the current next-state estimate.
%
%   MASS                Structure containing information on the mass matrix.
%
%   Outputs:
%
%   RES                 Residual of the estimate for y_n+1



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-29
% Changelog:
%   2018-08-29
%       * Remove currently unused argument `OPTIONS`
%   2018-08-19
%       * Rename from `odeXb_fsolve` to `odeXeb_fsolve`
%   2018-08-18
%       * Initial release



%% Initialize variables

% Order of BDF
nOrder = ordr;

% Mass information structure
stMass = mass;

% Calculate step size
dStepsize = tn1 - tn;

% To speed up evaluation, make Butcher tableau persistent
persistent aButcher
% Butcher tableau
if isempty(aButcher)
  aButcher = [ ...
      [      0,       0,      0,        0,       0,       -1] ; ...
      [      0,       0,      0,        0,     1/3,     -4/3] ; ...
      [      0,       0,      0,    -2/11,    9/11,   -18/11] ; ...
      [      0,       0,   3/25,   -16/25,   36/25,   -48/25] ; ...
      [ 60/137, -12/137, 75/137, -200/137, 300/137, -300/137] ; ...
      [ 10/147,  -24/49,  75/49, -400/147,  150/49,  -120/49] ; ...
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

% Determine value of mass matrix
switch stMass.Type
  case 0 % []
    M = 1;
  case 1 % M
    M = stMass.Value;
  case 2 % M(t)
    M = stMass.Function(tn);
  case {3, 4} % M(t, y)
    M = stMass.Function(tn, ynp);
end


% Calculate residual value
res = M*(yn1 + ynp*transpose(aButcher(nOrder,end-(nOrder-1):end))) - vStepsizeWeights(nOrder)*dStepsize*feval(odefun, tn1, yn1);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
