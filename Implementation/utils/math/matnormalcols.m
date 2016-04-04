function Mn = matnormalcols(M)%#codegen
% MATNORMALCOLS Normalize a matrix per column
% 
%   MN = MATNORMALROWS(M) normalizes each column of matrix MAT by its norm.
%   
%   Inputs:
%   
%   M: Matrix of variable dimension to be normalized.
%
%   Outputs:
%
%   MN: Matrix with the each column's norm being one.
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-04
% Changelog:
%   2016-04-04
%       * Initial release



%% Assertion
assert(isa(M, 'double') || isa(M, 'sym'), 'Input must be of type double or symbolic'););



%% Magic, do your thing and create the output right away
Mn = transpose(matnormalrows(transpose(M)));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
