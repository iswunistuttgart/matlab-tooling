function y = smoothtrans(x, in)
%% SMOOTHTRANS Evaluate a smooth transition function at value X
%
%   Y = SMOOTHTRANS(X) evaluates a smooth transition function from 0 to 1 along
%   the vector X.
%
%   Y = SMOOTHTRANS(X, I) uses interval I to perform smooth transition. Defaults
%   to [0;1].
%
%   Inputs:
%
%   X                   1xN vector at which to evaluate the smooth transition
%                       function.
%
%   I                   2xK vector of intervals on which to perform transition.
%
%   Outputs:
%
%   Y                   NxK vector of values of the smooth transition function.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-11-27
% Changelog:
%   2018-11-27
%       * Initial release



%% Validate arguments

try
  narginchk(1, Inf);
  nargoutchk(0, 1);
  
  % Default interval
  if nargin < 2 || isempty(in)
    in = [0; 1];
  end
  
  validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'nondecreasing', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'x');
  
  validateattributes(in, {'numeric'}, {'2d', 'nonempty', 'nrows', 2, 'nondecreasing', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'in');
  
catch me
  throwAsCaller(me);
end

  

%% Process
% p0 + ( pt - p0 ) .* ( 1 - 1 ./ ( exp( ( t - tt ) ./ w ) + 1 ) )
% Make sure X is a column vector
x = x(:);

% Adjust path coordinate to match original interval [0,1]
x_ = (x - in(1,:)) ./ ( in(2,:) - in(1,:) );

% Evaluate
y = h(x_) ./ ( h(x_) + h(1 - x_) );


end


function h_ = h(x)
%% H is the transition callback function



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-11-27
% Changelog:
%   2018-11-27
%       * Initial release



%% Calculate

h_ = x;
h_(x <= 0) = 0;
h_(0 < x & x < 1) = exp(-1 ./ x(0 < x & x < 1));
h_(1 <= x) = 1;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
