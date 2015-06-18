function flag = issize(A, r, c)
% ISSIZE - Check whether the given matrix is of provided size/dimensions
% 
%   FLAG = ISSIZE(A, r, c) checks matrix A is of dimensions r x c
% 
%   Inputs:
% 
%   A: matrix to check for squareness
%   
%   r: rows matrix A has to have. Can be empty to just check for the columns
%   couunt to match
%   
%   c: number of columns matrix A has to have. Can be empty to just check for
%   the rows count to match
% 
%   Outputs:
% 
%   FLAG: evaluates to true if A is of size r x c, otherwise false
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-06-18
% Changelog:
%   2015-06-18:
%       * Update to allow for empty arguments so that we can just check the
%       columns or rows count
%   2015-04-24:
%       * Update validation function to use ```isequaln``` rather than
%       ```isequal``` (slight improvement of readability and speed)
%   2015-04-22:
%       * Initial release


% ------------- BEGIN CODE --------------

if isempty(r)
    flag = ismatrix(A) && isequal(size(A, 2), c);
elseif isempty(c)
    flag = ismatrix(A) && isequal(size(A, 1), c);
else
    flag = ismatrix(A) && isequaln(size(A, 1), [r, c]);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Cangelog" section of the header
