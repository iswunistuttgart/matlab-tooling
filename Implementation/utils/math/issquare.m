function flag = issquare(A)
% ISSQUARE - Check whether the given matrix is square
% 
%   FLAG = ISSQUARE(A) checks the matrix a for squareness i.e., checks that
%   the number of rows equals the number of columns
% 
%   Inputs:
% 
%   A: matrix to check for squareness
% 
%   Outputs:
% 
%   FLAG: vector of force distribution values as determined by the
%   algorithm
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release


%------------- BEGIN CODE --------------


flag = ismatrix(A) && isequal(size(A, 1), size(A, 2));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Cangelog" section of the header
