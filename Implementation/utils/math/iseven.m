function flag = iseven(number)
% ISEVEN checks the given number(s) for being even
%
%   ISEVEN(NUMBER) returns true, if the number NUMBER are even i.e., dividable
%   by 2.
%
%   FLAG = ISEVEN(NUMBER) returns the flag.
%
%   Input:
%
%   NUMBER      Nx1 array to check for being even.
%
%   Outputs:
%
%   FLAG        Logical flag whether NUMBER is even (FLAG == 1) or odd (FLAG ==
%       0).



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-19
% Changelog:
%   2016-09-19
%       * Initial release



%% Do your code magic here
flag = mod(number, 2) == 0;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
