function y = smoothtrans(x, in)
%% SMOOTHTRANS Evaluate a smooth transition function at value X
%
%   Y = SMOOTHTRANS(X) evaluates a smooth transition function from -1 to 1s
%   along the vector X.
%
%   Y = SMOOTHTRANS(X, I) uses interval I to perform smooth transition. Defaults
%   to [-1,1].
%
%   Inputs:
%
%   X                   Nx1 vector at which to evaluate the smooth transition
%                       function.
%
%   I                   2xK vector of intervals on which to perform transition.
%
%   Outputs:
%
%   Y                   NxK vector of values of the smooth transition function.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Update interval of method to be on [-1, 1] by default.
%   2018-12-16
%       * Ensure that intervals given as row vectors also work
%   2018-11-27
%       * Initial release



%% Validate arguments

try
  narginchk(1, Inf);
  nargoutchk(0, 1);
  
  % Default interval
  if nargin < 2 || isempty(in)
    in = [-1; 1];
  end
  
  % Make sure a vector interval is going to be a column vector
  if isvector(in) && isrow(in)
    in = in(:);
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
