function Row = rotm2row(Matrix)%#codegen
% ROTM2ROW converts a 3d rotation matrix to a row
% 
%   ROW = ROTM2ROW(MATRIX) converts the 3x3 matrix into a 1x9 rotation vector
%   
%   
%   Inputs:
%   
%   MATRIX: A 3x3xN matrix of rotation matrices
% 
%   Outputs:
% 
%   ROW: Nx9 matrix of rotation matrix rows where the columns are of MATRIX are
%   horizontally concatenated
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-09
% Changelog:
%   2016-05-09
%       * Initial release



%% Transformation
% Number of matrices to convert
nMatrices = size(Matrix, 3);
% And reshape to match size Nx9
Row = reshape(permute(Matrix, [3, 2, 1]), nMatrices, 9);


end