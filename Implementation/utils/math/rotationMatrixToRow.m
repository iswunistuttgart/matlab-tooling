function Row = rotationMatrixToRow(Matrix)%#codegen
% ROTATIONMATRIXTOROW converts a 3d rotation matrix to a row
% 
%   ROW = ROTATIONMATRIXTOROW(MATRIX) converts the 3x3 matrix into a 1x9
%   rotation vector
%   
%   
%   Inputs:
%   
%   MATRIX: The 3x3 rotation matrix in form of
%   [R11 R12 R13; ...
%    R21 R22 R23; ...
%    R31 R32 R33];
% 
%   Outputs:
% 
%   ROW: The 1x9 row vector representing the rows of MATRIX append to each other
%   like ROW = [R11 R12 R13 R21 R22 R23 R31 R32 R33]
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-01
% Changelog:
%   2016-05-01
%       * Update to using permute instead of transpose
%   2015-08-07
%       * Initial release



%% Transformation
Row = reshape(permute(Matrix, [2, 1]), 1, 9);


end