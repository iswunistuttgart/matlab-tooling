function Mn = matnormalrows(M)%#codegen
% MATNORMALROWS Normalize a matrix per row
% 
%   MN = MATNORMALROWS(M) normalizes each row of matrix MAT by its norm.
%
%   
%   Inputs:
%   
%   M: Matrix of variable dimension to be normalized.
%
%   Outputs:
%
%   MN: Matrix with each row's norm being one.
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-04
% Changelog:
%   2016-04-04
%       * Initial release



%% Assertion
assert(isa(M, 'double'), 'Input must be of type double');



%% Magic, do your thing and create the output right away
Mn = bsxfun(@times, M, 1./sqrt(sum(M.^2,2)));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
