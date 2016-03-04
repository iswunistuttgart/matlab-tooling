function RotationMatrix = rotationMatrixXYZ(A, B, C, InRadian)
%#codegen
% ROTATIONMATRIXXYZ - Returns an euler extrinsic rotation matrix
%
%   Rotation matrix returned is a three-dimensional matrix that performs
%   rotations about the global x-, y-, and then z-axis with angles of a, b, and
%   c, respectively.
%
%   [RotationMatrix] = rotationMatrixXYZ(A, B, C) returns the XYZ rotation
%   matrix with angles a, b, c about axes x, y, z. Values A, B, C are given in
%   degree.
%
%   [RotationMatrix] = rotationMatrixXYZ(A, B, C, true) returns the XYZ rotation
%   matrix with angles a, b, c about axes x, y, z. Values A, B, C are given in
%   radian
%
%   Inputs:
%
%   A: Rotation angle about global x-axis
%
%   B: Rotation angle about global y-axis
%
%   C: Rotation angle about global z-axis
%
%   InRadian: Boolean flag whether the values A, B, and C are given in radian
%   other than expected degree
%
%   Outputs:
%   
%   RotationMatrix: The 3x3 rotation matrix as a product of rotations Rx, Ry,
%   and Rz (in that order)
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-04
% Changelog:
%   2016-03-04:
%       * Initial release

if InRadian
    A = rad2deg(A);
    B = rad2deg(B);
    C = rad2deg(C);
end

RotationMatrix = rotz(C)*roty(B)*rotx(A);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
