function dd = discrderiv(f, df, a, b)
% DISCRDERIV calculates the discrete derivative of a scalar function F
%
%   DD = DISCRDERIV(F, DF, A, B) calculates the discrete derivative of
%   vector-valued scalar function F = F(x) along the direction of A to B. DF is
%   the function derivative with respect its variable.
%
%   DD = DISCRDERIV(V, JV, A, B) calculates the discrete derivative of
%   vector-field V given as V = V(x) along the direction from A to B. JV is the
%   Jacobian of V for X.
%
%   In general we assume the following dimensional properties to hold true:
%
%   F: R^m -> R^k (k may be equal to 1)
%   X in R^m
%   A in R^m
%   B in R^m
%
%   The discrete derivative is implemented according to Gonzalez, O. J, Time
%   integration and discrete Hamiltonian systems, Nonlinear Sci (1996) 6: 449.
%   https://doi.org/10.1007/BF02440162.
%   It reads with our arguments
%
%                 / df                      \
%                 | --(z) * v + f(x) - f(y) |
%        d        \ dx                      /
%       -- f(z) + --------------------------- * v
%       dx                     2
%                          ||v||
%
%
%   Inputs:
%
%   F                   Function handle that returns a 1x1 scalar or Nx1
%                       vector-valued function.
%
%   DF                  Function handle returning the 1x1 scalar differential of
%                       F valuated at its given argument. For a function F given
%                       as F = F(X), DF represents DF = dF/dX evaluated at X.
%
%   JF                  Function handle returning the NxK Jacobian of Nx1
%                       vector-valued function F evaluated at its given
%                       argument. For the vector function F given as F = F(X),
%                       JF represents JF = pF/pX evaluated at X.
%
%   A                   Scalar or Nx1 vector that is the left side of the
%                       discrete derivative.
%
%   B                   Scalar or Nx1 vector that is the right side of the
%                       discrete derivative.
%
%   Outputs:
%
%   DD                  1x1 scalar or Nx1 vector valued evaluation of the
%                       discrete derivative of F along the direction of A to B.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-04
% Changelog:
%   2018-09-04
%       * Initial release



%% Dive right in

% The half way point
z = (a + b)./2;
% The difference
v = b - a;

% Refer to Gonzalez.1995: Gonzalez, O. J, Time integration and discrete
% Hamiltonian systems, Nonlinear Sci (1996) 6: 449.
% https://doi.org/10.1007/BF02440162
dd = feval(df, z) + ( feval(f, y) - feval(f, x) + transpose(feval(df, z))*v )*v./norm(v);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
