function flag = isint(A)
% ISINT checks the given value to be of natural numbers
%
%   ISINT(A) returns true where A is a value of natural numbers.
%
%   Inputs:
%
%       A       Array to be checked for integer value.
%
%   Outputs:
%
%       FLAG    TRUE where A is int and FALSE otherwise.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-22
% Changelog:
%   2016-09-22
%       * Remove `all` from the checks so that it can be used to identify values
%       of an array that are int and ones that are not
%   2016-06-14
%       * Initial release



%% Magic, do your thing

flag = isnumeric(A(:)) & ( 0 == mod(A(:), 1.0) );


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
