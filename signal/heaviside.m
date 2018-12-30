function y = heaviside(x, c)
%% HEAVISIDE Analytic heaviside function at X = 0
%
%   Y = HEAVISIDE(X) evaluates the Heaviside step function on X which is defined
%   such that HEAVISIDE(X) == 0 if X < 0 and HEAVISIDE(X) == 1 if X >= 0.
%
%   Y = HEAVISIDE(X, C) uses numerical scaling factor C to evaluate analytic
%   Heaviside function defined as 0.5*(1 + tanh(x*c)) which transitions more
%   smoothly around X == 0. The larger C, the steeper the transition.
%   When C == 0, then the standard Heaviside function is evaluated.
%
%   Inputs:
%
%   X                   Nx1 vector of values at which to evaluate Heaviside
%                       function
%
%   C                   1xK vector of scaling factors of the exponential
%                       argument.
%
%   Outputs:
%
%   Y                   NxK vector of Heaviside function evaluated at values of
%                       X.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-16
% Changelog:
%   2018-12-16
%       * Initial release



%% Assert arguments

narginchk(1, 2);
nargoutchk(0, 1);

if nargin < 2 || isempty(c)
  c = 0;
end

% Make sure vectors are of right dimensions
x = x(:);
c = c(:).';



%% Do your code magic here
% Analytical Heaviside
y = 0.5 .* ( 1 + tanh(x .* c) );

% And wherever C was zero, we will just do the default heaviside
y(x < 0,c == 0) = 0;
y(x >= 0,c == 0) = 1;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
