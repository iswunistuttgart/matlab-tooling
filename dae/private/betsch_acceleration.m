function res = betsch_acceleration(h, tn, xc, vc, xn, lln, lmn, m, V, JxV, T, JxT, P, JvP, Gx, JxGx, JtGx, Gv)
% BETSCH_ACCELERATION solves the non-linear ODE for the current acceleration
%
%   We assume the following dimension numbers
%
%   K               Number of generalized positions and of generalized
%                   velocities.
%   MX              Number of constraints on the position level.
%   MV              Number of constraints on the velocity level.
%
%   We denote with pA/pB the partial derivative of A wrt B and with dA/dB the
%   total derivative of A wrt B.
%
%   Inputs:
%
%   H                   Step size.
%
%   TN                  1x1 current time value.
%
%   XC                  Kx1 vector of the current positions.
%
%   VC                  Kx1 vector of the current velocities.
%
%   XN                  Kx1 vector of the estimate of the next time step's
%                       velocities.
%
%   LLN                 MXx1 vector of Lagrange multipliers for the current state
%                       to satisfy the geometric constraints.
%
%   LMN                 MVx1 vector of Lagrange multipliers for the current state
%                       to satisfy the velocity constraints.
%
%   M                   KxK mass matrix callback function M = M(t, x, v).
%
%   V                   Holonomic potential function as V = V(t, x).
%
%   JXV                 Kx1 Jacobian of holonomic potential function V wrt
%                       generalized positions i.e., JXV = pV/px.
%
%   T                   Kinetic energies T = T(t, x, v);
%
%   JXT                 Kx1 Jacobian of kinetic energies T wrt generalized
%                       positions i.e., JXL = pL/pX.
%
%   P                   Dissipative potential function as P = P(t, x, v).
%
%   JVP                 Kx1 Jacobian of dissipative potential function wrt
%                       generalized velocities i.e., JVP = pP/pV.
%
%   JTT                 1x1 Jacobian of kinetic energies T wrt time i.e.,
%                       JTT = pT/pt.
%
%   JXJTT               Kx1 vector of the Jacobian of JTT wrt generalized
%                       positions i.e., JXJTT = pJTT/pX.
%
%   JVT                 Kx1 vector of the Jacobian of the kinetic energies wrt
%                       generalized velocities i.e., JVT = pT/pV.
%
%   JXJVT               KxK Jacobian matrix of JVT wrt generalized velocities
%                       i.e., JXJVT = pJVT/pX;
%
%   GX                  MXx1 vector of constraints on position level as
%                       GX = GX(t, x).
%
%   JXGX                MXxK Jacobian of positional constraints wrt generalized
%                       positions i.e., JXGX = pGX/pX.
%
%   JTGX                MXxK Jacobian of positional constraints wrt time i.e.,
%                       JTGX = pGX/pt.
%
%   GV                  MVxK Matrix of velocity constraints as GV = GV(t, x)
%                       such that GV*V == 0
%   
%
%   Outputs:
%
%   RES                 (K+MX+MV)x1 residual of the estimate for the given state
%                       of next positions.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-04
% Changelog:
%   2018-09-04
%       * Incorporate correct terms for the discrete derivative as based on
%       Gonzalez
%       * Add support for dissipative energies P = P(q, Dq) and kinetic energies
%       dependent on the generalized coordinates i.e., T = T(q, Dq, t).
%   2018-09-01
%       * Initial release



%% Initialize variables

% Half time value
th = tn + h/2;
% Next time value
tn = tn + h;

% Half time position
xh = (xn - xn)./2;

% Next velocity
vn = 2/h*( xn - xc ) - vc;
% Half time velocity
% vh = (vn - vc)./2;
% vh = (xn - xc)./h;

% Current mass matrix
M = m(tn, xc, vc);

% Discrete derivative of the potential function
dd_v = discrderiv(@(xh_) V(th, xh_), @(xh_) JxV(th, xh_), xc, xn);

% Discrete derivative of the dissipative function
dd_p = discrderiv(@(vh_) P(th, xh, vh_), @(vh_) JvP(th, xh, vh_), vc, vn);

% Discrete derivative of the change of kinetic energies
dd_t = discrderiv(@(vh_) T(th, xh, vh_), @(vh_) JxT(th, xh, vh_), vc, vn);

% Discrete derivative of the positional constraints function
dd_gx = discrderiv(@(xh_) Gx(th, xh_), @(xh_) JxGx(th, xh_), xc, xn);

% Explicit position constraints at the next state
gx_e = Gx(tn, xn);

% Implicit velocity constraints at the half state
gxv_h = JtGx(tn, xn);

% Explicit velocity constraints at the half state
gv_h = Gv(th, xh);

% Evaluated velocity constraints at next state
% @TODO Do we need the discrete derivative here of G wrt X? I would say so as
% the velocity constraints contain both the hidden velocity constraints as well
% as the explicit ones. And the hidden constraints are clearly including the
% Jacobian of GX.
gv_e = ( gv_h + dd_gx )*(xn - xc) + gxv_h;

% Build the full residual vector
res = vertcat( ...
  2/h.*M*( xn - xc ) - 2.*M*vc - h*( dd_v + dd_p + dd_t + transpose(dd_gx)*lln + transpose(gv_h)*lmn ) ...
  , gx_e ...
  , gv_e ...
);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
