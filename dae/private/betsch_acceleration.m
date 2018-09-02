function res = betsch_acceleration(odefun, tn, xn, vn, xne, vne, lle, lme, h, mass, conQ, conDQ, jconQ, varargin)
% BETSCH_ACCELERATION solves the non-linear ODE for the current acceleration
%
%   Inputs:
%
%   ODEFUN              ODE function callback.
%
%   TN                  Current time value.
%
%   XN                  Kx1 vector of the current positions.
%
%   VN                  Kx1 vector of the current velocities.
%
%   XNE                 Kx1 vector of the estimate of the next time step's
%                       velocities.
%
%   LL                  Gx1 vector of Lagrange multipliers for the current state
%                       to satisfy the geometric constraints.
%
%   LM                  Nx1 vector of Lagrange multipliers for the current state
%                       to satisfy the velocity constraints.
%
%   H                   Step size.
%
%   MASS                Structure containing information on the mass matrix.
%
%   CONSTRAINTSQ        Structure containing information on the geometric
%                       constraints on position level.
%
%   CONSTRAINTSDQ       Structure containing information on the velocity
%                       constraints.
%
%   JCONSTRAINTSQ       Structure containing information on the Jacobian of the
%                       geometric constraints on position level.
%
%   Outputs:
%
%   RES                 Residual of the estimate for an



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-01
% Changelog:
%   2018-09-01
%       * Initial release



%% Initialize variables

% Next time value
tne = tn + h;
% Half time value
tnh = tn + h/2;

% Next velocity
% vne = 2/h*( xne - xn ) - vn;

% Half time position
xnh = (xne - xne)./2;
% Half time velocity
vnh = (vne - vn)./2;
vnh = (xne - xn)./h;

% Current mass matrix
M = mass.Function(tn, xn, vn);

% Difference in the right-hand side
% f_d = odefun(tne, xne, vne) - odefun(tn, xn, vn);
f_d = odefun(tne, xne, vne);
% f_d = odefun(tnh, xnh, vnh);

% Geometric constraints of target state
hlc_e = conQ.Function(tne, xne);

% Difference in the holonomic constraints
% hlc_d = jconQ.Function(tne, xne) - jconQ.Function(tn, xn);
hlc_d = jconQ.Function(tne, xne);
% hlc_d = jconQ.Function(tnh, xnh);

% Difference in non-holonomic constraints
% nhlc_d = conDQ.Function(tne, xne) - conDQ.Function(tne, xn);
nhlc_d = conDQ.Function(tne, xne);
% nhlc_d = conDQ.Function(tnh, xnh);

% Build the full residual vector
res = [...
  ... vne - 2/h*(xne - xn) - vn ; ...
  2/h.*M*( xne - xn ) - 2.*M*vn - h*(f_d + transpose(hlc_d)*lle + transpose(nhlc_d)*lme ) ; ...
  hlc_e ; ...
];

% Append the kinematic constraints deviation if it exists (algorithm also works
% for just containing geometric constraints).
if ~isempty(nhlc_d)
  res = [res; nhlc_d*(qne - qn)];
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
