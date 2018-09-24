function res = betsch_ic(odefun, t0, x0, v0, ll, lm, mass, conQ, conDQ, jconQ, varargin)
% BETSCH_IC solves the non-linear ODE for consistent initial conditions
%
%   Inputs:
%
%   ODEFUN              ODE function callback.
%
%   T0                  Initial time value.
%
%   X0                  Kx1 vector of the initial positions.
%
%   V0                  Kx1 vector of the initial velocities.
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
%   RES                 Residual of the estimate



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-01
% Changelog:
%   2018-09-01
%       * Initial release



%% Calculate residual

% Residual from implicit GGL formulation
res = [...
  mass.Function(t0, x0, v0)*zeros(numel(x0), 1) - feval(odefun, t0, x0, v0) - transpose(jconQ.Function(t0, x0))*ll - transpose(conDQ.Function(t0, x0))*lm ; ...
  conQ.Function(t0, x0) ; ...
  conDQ.Function(t0, x0)*v0 ; ...
];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
