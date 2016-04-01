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
%   RotationMatrix: The 3x3 rotation matrix as a product of rotations Rz, Ry,
%   and Rx (in that order)
%
%   See:
%       * https://en.wikipedia.org/wiki/Euler_angles#Tait.E2.80.93Bryan_angles
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-24
% Changelog:
%   2016-03-24:
%       * Update logic for radian checks to use a scaling factor rather than the
%       rad2deg function. This might not increase speed (though assume it will)
%       but will first and foremost change the codegen capabilities of this
%       function as it is no longer relying on rad2deg
%   2016-03-04:
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
RotationMatrix = rotz(C*dScaling)*roty(B*dScaling)*rotx(A*dScaling);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
