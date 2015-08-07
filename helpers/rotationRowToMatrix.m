function Matrix = rotationRowToMatrix(Row)
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
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-08-07
% Changelog:
%   2015-08-07
%       * Initial release

Matrix = transpose(reshape(Row, 3, 3));

end