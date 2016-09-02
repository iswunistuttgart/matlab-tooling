function [row, col] = closest(matrix, val)
% CLOSEST finds the row and column of the matrix element closest to a given
% value
%
%   [ROW, COL] = CLOSEST(MATRIX, VAL) finds the row and column index of a value
%   inside matrix MATRIX that is closest to value VAL.
%
%   Inputs:
%
%   MATRIX      Matrix or vector to extract value from.
%
%   VALUE       Value to find closes matrix element to.
%
%   Outputs:
%
%   ROW         Row in which the closest value was found.
%
%   COL         Column in which the closes value was found.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-02
% Changelog:
%   2016-09-02
%       * Initial release



%% Do your code magic here

[~, ii] = min(abs(matrix(:) - val));
[row, col] = ind2sub(size(matrix), ii);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
