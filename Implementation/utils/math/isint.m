function flag = isint(A)
% ISINT True for arrays of integer type (not the machine integer type).
%
%   ISINT(A) returns true if A is an array of natural numbers.
%
%   Inputs:
%
%       A   Array to be checked for integer value.
%
%   Outputs:
%
%       FLAG    TRUE if all of array is integers (i.e., natural numbers), FALSE
%               otherwise.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-06-14
% Changelog:
%   2016-06-14
%       * Initial release



%% Magic, do your thing

flag = all(isnumeric(A(:))) && all(mod(A(:), 1.0) == 0);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
