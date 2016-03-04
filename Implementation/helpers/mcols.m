function [m] = mcols(A)
% MCOLS(A) gets the number of columns of A
%   
%   Inputs:
%   
%   A: Matrix or vector to count the columns of
% 
%   Outputs:
% 
%   M: Number of columns of A
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-05-10
% Changelog:
%   2015-05-10: Update help documentation and add support for variables of type
%               2d
%   2015-04-27: Initial release

validateattributes(A, {'numeric'}, {'2d'}, mfilename, 'A');

m = size(A, 2);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
