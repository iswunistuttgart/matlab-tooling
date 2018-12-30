function l = loglim(d)
%% LOGLIM returns logarithmic limits
%
%   L = LOGLIM(D) returns logarithmic limits L for the values given in D. The
%   formula is simple:
%   L = [floor( ( log10(q) / 3 - 1 ) * 3), ceil( ( log10(q) / 3 + 1 ) * 3)]
%
%   Inputs:
%
%   D                   NxK array of values to obtain limits for.
%
%   Outputs:
%
%   L                   Nx2 array of lower and upper logarithmic limits.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Initial release



%% Do your code magic here

% Evaluate the floored and ceiled values of the 10-logarithm of all values given
f = -ceil( -log10(d) ./ 3 )*3;
c = floor( -log10(d) ./ 3 )*3;

% And build output
l = [min(f, [], 2), max(c, [], 2)];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
