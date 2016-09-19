function flag = isodd(number)
% ISODD checks the given number(s) for being odd
%
%   ISODD(NUMBER) returns true, if the number NUMBER is odd i.e., not dividable
%   by 2.
%
%   FLAG = ISODD(NUMBER) returns the flag.
%
%   Input:
%
%   NUMBER      Nx1 array to check for being odd.
%
%   Outputs:
%
%   FLAG        Logical flag whether NUMBER is odd (FLAG == 1) or even (FLAG ==
%       0).



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-19
% Changelog:
%   2016-09-19
%       * Initial release



%% Do your code magic here
flag = ~iseven(number);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
