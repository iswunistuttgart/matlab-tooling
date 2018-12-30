function y = richard(x, b, n, c)
%% RICHARD Generalized logistics curve or Richards' curve
%
%   Y = RICHARD(X) evaluates RICHARD's curve on X, with B = 100, C = 1, N = 1;
%
%   Y = RICHARD(X, B) uses growth rates B.
%
%   Y = RICHARD(X, B, N) wich N > 0 decides at which asymptote maximum growth
%   occurs.
%
%   Y = RICHARD(X, B, N, C) uses inverse scaling factor C to scale the output.
%
%   Inputs:
%
%   X                   Nx1 vector along which to evaluate Richard's curve.
%
%   B                   Kx1 vector of growth rates.
%
%   N                   Kx1 vector with positive values deciding at which
%                       asymptote maximum growth occurs.
%
%   C                   Inverse scaling factor.
%
%   Outputs:
%
%   Y                   NxK matrix of evaluated Richards' curve.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-16
% Changelog:
%   2018-12-16
%       * Initial release



%% Assert arguments
narginchk(1, 5);
nargoutchk(0, 1);

% RICHARD(X)
if nargin < 2 || 1 ~= exist('b', 'var') || isempty(b)
  b = 100;
else
  b = b(:).';
end

% RICHARD(X, B)
if nargin < 3 || 1 ~= exist('n', 'var') || isempty(n)
  n = ones(size(b));
else
  % Should be a column vector
  n = n(:).';
end

% RICHARD(X, B, N)
if nargin < 4 || 1 ~= exist('c', 'var') || isempty(c)
  c = ones(size(b));
else
  c = c(:).';
end

validateattributes(x, {'numeric'}, {'nonempty', 'increasing', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'X');

validateattributes(b, {'numeric'}, {'nonempty', 'positive', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'B');

validateattributes(n, {'numeric'}, {'nonempty', 'positive', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'N');

validateattributes(c, {'numeric'}, {'nonempty', 'positive', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'C');

% Ensure correect dimensions
x = x(:);



%% Do your code magic here

% Calculate value that depends on the initial values
q = ones(size(b));

% And Richard's curve
y = 1 ./ ( ( c + q .* exp(-b .* x) )  .^ ( 1 ./ n ) );


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
