function flag = issize(A, r, c)
% ISSIZE - Check whether the given matrix is of provided size/dimensions
% 
%   FLAG = ISSIZE(A, r, c) checks matrix A is of dimensions r x c
% 
%   Inputs:
% 
%   A: matrix to check for squareness
%   
%   r: rows matrix A has to have
%   
%   c: number of columns matrix A has to have
% 
%   Outputs:
% 
%   FLAG: evaluates to true if A is of size r x c, otherwise false
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release


% ------------- BEGIN CODE --------------


flag = ismatrix(A) && isequal(size(A, 1), r) && isequal(size(A, 2), c);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Cangelog" section of the header
