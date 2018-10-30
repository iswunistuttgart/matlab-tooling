function m = secs2hms(s)
% SECS2HMS Convert seconds to a human readable time format
%
%   SECS2HMS(S) converts seconds given in S into human readable HH:MM:SS
%   format.
%
%   Inputs:
%
%   S                   NxM array of numeric values assumed to be given in
%                       seconds requested to be converted to HH:MM:SS format.
%
%   Outputs:
%
%   M                   N*Mx8 character array of the given seconds converted to
%                       a HH:MM:SS format.
%
%   See also
%   DATESTR



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-10-30
% Changelog:
%   2018-10-30
%       * Initial release



%% Validate arguments
try
  validateattributes(s, {'numeric'}, {'nonempty', 'finite', 'nonnan', 'nonnegative', 'nonsparse'}, mfilename, 'S');
catch me
  me.throwAsCaller();
end



%% Do your code magic here

% Convert seconds to fractions of a day, then parse using `DATESTR`
m = datestr(s ./ 86400, 'HH:MM:SS');


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
