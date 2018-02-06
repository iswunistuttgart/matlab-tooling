function l = limit(v, mi, ma)
% LIMIT the given value between minimum and maximum
%
%   LIMIT(V, MI, MA) limits the values in V such that they are at least MI large
%   but no larger than MA, either.
%
%   Inputs:
%
%   V                   MxN array or values to limit
%
%   MI                  Lower limit of each value.
%
%   MA                  Upper limit of each value.
%
%   Outputs:
%
%   L                   MxN array of limited values of V



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-06
% Changelog:
%   2018-02-06
%       * Initial release



%% Valdiate arguments
try
    % LIMIT(V, MI, MA)
    narginchk(3, 3);
    % LIMIT(V, MI, MA)
    % L = LIMIT(V, MI, MA)
    nargoutchk(0, 1);
catch me
    throwAsCaller(me);
end



%% Do your code magic here

% Limit v by the lower boundary, then by the upper boundary.
l = min(ma, max(v, mi));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
