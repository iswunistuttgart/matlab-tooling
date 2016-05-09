function Matrix = rotrow2m(Row)%#codegen
% ROTROW2M converts a 1d rotation matrix row vector to its matrix representation
% 
%   MATRIX = ROTROW2M(ROW) converts the Nx9 matrix ROW into its 3x3xN matrix
%   representation form where each consecutive three elements of ROW are placed
%   in each row the matrix
%   
%   
%   Inputs:
% 
%   ROW: The Nx9 row vector representing [R11 R12 R13 R21 R22 R23 R31 R32 R33]
%   per row
% 
%   Outputs:
%   
%   MATRIX: 3x3xN matrix of the rotation row where along the first dimension the
%   matrix looks like [R11, R12, R13; R21, R22, R23; R31, R32, R33]
% 



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-09
% Changelog:
%   2016-05-09
%       * Initial release



%% Transformation
% Number of Rows to convert
nRows = size(Row, 1);
% And reshape to match size Nx9
Matrix = permute(reshape(transpose(Row), 3, 3, nRows), [2 1 3]);




end