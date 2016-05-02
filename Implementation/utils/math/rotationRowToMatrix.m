function Matrix = rotationRowToMatrix(Row)%#codegen
% ROTATIONROWTOMATRIX converts a 1d rotation matrix row vector to its matrix
% 
%   MATRIX = ROTATIONROWTOMATRIX(ROW) converts the 1x9 row vector into the
%   respective 3x3 rotation matrix
%   
%   
%   Inputs:
% 
%   ROW: The 1x9 row vector representing [R11 R12 R13 R21 R22 R23 R31 R32 R33]
% 
%   Outputs:
%   
%   MATRIX: The 3x3 rotation matrix in form of
%   [R11 R12 R13; ...
%    R21 R22 R23; ...
%    R31 R32 R33];
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
Matrix = permute(reshape(Row, 3, 3), [2, 1]);


end