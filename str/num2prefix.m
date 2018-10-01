function [p, c] = num2prefix(n)
% NUM2PREFIX converts numbers to their SI unit prefix.
%
%   P = NUM2PREFIX(N) returns the SI-unit prefixes P for numbers N.
%
%   [P, C] = NUM2PREFIX(N) also returns the cropped numbers that can then be
%   used with the corresponding prefix.
%
%   Inputs:
%
%   N                   NxM array of numbers to get prefixes for.
%
%   Outputs:
%
%   P                   NxM cell array of prefixes for each number in N.
%
%   C                   NxM array of numbers adjusted to take into account the
%                       SI unit prefix.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-10-01
% Changelog:
%   2018-10-01
%       * Initial release



%% List of prefixes
persistent ceList
if isempty(ceList)
  ceList = {'y', 'z', 'a', 'f', 'p', 'n', 'mu', 'm', '', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'};
end



%% Do your code magic here
% Get the base-10 bases
b = fix(floor(log10(abs(n))) ./ 3);

% And now just shift these as CELIST contains the values
p = ceList(b + 8 + 1);

% Calculate the adjusted values
if nargout > 1
  c = n ./ ( 10 .^ ( b .* 3 ) );
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
