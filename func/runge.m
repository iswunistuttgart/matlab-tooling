function y = runge(x, c)
%% RUNGE Calculates Runge's function 1 / (1 + x^2) over X
%
%   Y = RUNGE(X) evaluates Runge's function Y = 1 / (1 + X^2);
%
%   Y = RUNGE(X, C) uses C as the steepness of Runge's function.
%
%   Inputs:
%
%   X                   1xN array over which to evaluate X.
%
%   C                   1xK array of sharpnesses of Runge's function.
%
%   Outputs:
%
%   Y                   NxK array of Runge's function evaluated at X.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Initial release



%% Validate arguments

validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'nonsparse', 'finite'}, mfilename, 'x');

x = x(:);

if nargin < 2 || 1 ~= exist('c', 'var') || isempty(c)
  c = 1;
else
  c = c(:).';
end

validateattributes(c, {'numeric'}, {'nonempty', 'nonnan', 'nonzero', 'finite', 'nonsparse'}, mfilename, 'c');



%% Do your code magic here

% It's simply
y = 1 ./ ( 1 + c .* x .^ 2 );


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
