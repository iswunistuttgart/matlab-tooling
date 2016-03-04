function [m] = nrows(A)
% NROWS(A) gets the number of rows of A
%   
%   Inputs:
%   
%   A: Matrix or vector to count the rows of
% 
%   Outputs:
% 
%   M: Number of rows of A
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-05-10
% Changelog:
%   2015-05-10: Update help documentation and add support for variables of type
%               2d
%   2015-04-27: Initial release

validateattributes(A, {'numeric'}, {'2d'}, mfilename, 'A');

m = size(A, 1);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
