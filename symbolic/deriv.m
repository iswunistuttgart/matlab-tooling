function fout = deriv(f, g)
% DERIV derives a symbolic expression with respect to another symbolic
% expression
%
%   F_G = DERIV(F, G) derives symbolic expressioN F with respect to G. For
%   example, if F is a function of G which in turn is a function of a free
%   coordinate T, then DERIV(F, G) will perform dF / dG
%
%   Inputs
%
%   F       Symbolic expression that shall be derived.
%
%   G       Symbolic expression that shall be derived after.
%
%   Outputs
%
%   F_G     Symbolic expression that is the derivative of F after G i.e.,
%       F_G = dF / dG



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-08-05
% Changelog:
%   2017-08-05
%       * Add support for arbitrarily sized input argument G
%   2016-09-15
%       * Add help
%       * Add block file information
%   2016-02-10
%       * Initial release



%% Magic
% Helper symbolic variable
x = sym('x', size(g));

% Substitute G in F by X i.e., F(G(...), ...) => F(X, ...)
f1 = subs(f, g, x);
% Derive new F after X i.e., dF/dX
f2 = jacobian(f1, x);

% And substitute X back to G i.e., F(X, ...) => F(G(...), ...)
fout = subs(f2, x, g);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
