function RotationMatrix = rotationMatrixZYX(A, B, C, InRadian)
%#codegen
% ROTATIONMATRIXZYX - Returns an euler extrinsic rotation matrix
%
%   Rotation matrix returned is a three-dimensional matrix that performs
%   rotations about the global z-, y-, and then x-axis with angles of a, b, and
%   c, respectively.
%
%   [RotationMatrix] = rotationMatrixZYX(A, B, C) returns the ZYX rotation
%   matrix with angles a, b, c about axes z, y, x. Values A, B, C are given in
%   degree.
%
%   [RotationMatrix] = rotationMatrixZYX(A, B, C, true) returns the XYZ rotation
%   matrix with angles a, b, c about axes z, y, x. Values A, B, C are given in
%   radian
%
%   Inputs:
%
%   A: Rotation angle about global z-axis
%
%   B: Rotation angle about global y-axis
%
%   C: Rotation angle about global x-axis
%
%   InRadian: Boolean flag whether the values A, B, and C are given in radian
%   other than expected degree
%
%   Outputs:
%   
%   RotationMatrix: The 3x3 rotation matrix as a product of rotations Rx, Ry,
%   and Rz (in that order)
%
%   See:
%       * https://en.wikipedia.org/wiki/Euler_angles#Tait.E2.80.93Bryan_angles
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-24
% Changelog:
%   2016-03-24:
%       * Initial release



%------------- BEGIN OF CODE --------------
%% Set function default arguments
% Default argument
if nargin == 3
    InRadian = false;
end



%% Actual code
% Set default scaling to one i.e., values are given as is and thus in degree
dScaling = 1;

% If the values are said to be given in radian...
if InRadian
    % ... then the scaling parameter equals to 180/pi (degree to radian)
    dScaling = 180/pi;
end


%% Output assignment
% Rotation matrix
RotationMatrix = rotz(A*dScaling)*roty(B*dScaling)*rotx(C*dScaling);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
