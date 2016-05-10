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

warning('ROTATIONROWTOMATRIX function is obsolete. Use the ROTROW2M function instead');



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-10
% Changelog:
%   2016-05-10
%       * Add END OF CODE block
%   2016-05-09
%       * Deprecate function in favor of shorter method name `rotrow2m`
%   2016-05-01
%       * Update to using permute instead of transpose
%   2015-08-07
%       * Initial release



%% Transformation
Matrix = rotrow2m(Row);
% Matrix = permute(reshape(Row, 3, 3), [2, 1]);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
