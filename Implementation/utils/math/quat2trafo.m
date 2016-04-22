function T = quat2trafo(q)%#codegen
% QUAT2TRAFO Gives the transformation matrix from Q to 
% 
%   T = QUAT2TRAFO(Q) determines the rotation matrix transformations from
%   quaternion to angular velocities of size 3x4xN for each quaternion
%   
%   Inputs:
%   
%   Q: Nx4 matrix of quaternions to translate into angular velocoties.
%
%   Outputs:
%
%   T: 3x4xN matrix of transformation matrix from quaternion to angular
%   velocoties for each quaternion provided
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-04
% Changelog:
%   2016-04-04
%       * Initial release



%% Assertion
% Input must be of type double or symbolic
assert(isa(q, 'double'), 'Input must be of type double');
% Input must be of size Nx4
assert(size(q, 2) == 4, 'Number of columns must be qual to 4');



%% Process inputs
% Get matrix of quaternion
aQuaternions = q;
% Number of quaternions
nQuaternions = size(aQuaternions, 1);
% Normalize quaternions i.e., each row of the matrix of quaternions
aQuaternions = matnormalrows(aQuaternions);



%% Magic, here we go
% Reshape the quaternions in the depth dimension
aQuaternions2 = reshape(aQuaternions.', [4, 1, nQuaternions]);

% Extract the parts [qw, qx, qy, qz] from q to make writing code easier
qw = aQuaternions2(1,1,:);
qx = aQuaternions2(2,1,:);
qy = aQuaternions2(3,1,:);
qz = aQuaternions2(4,1,:);

% Explicitly define concatenation dimension for codegen
tempT = cat(1, -qx, qw, -qz, qy,...
-qy, qz, qw, -qx,...
-qz, -qy, qz, qw );

% Reshape the matrix to its proper dimensions
aTrafos = reshape(tempT, [4, 3, nQuaternions]);
% Restore correct order of dimensions
aTrafos = 2.*permute(aTrafos, [2, 1, 3]);



%% Assign output quantities
% Only output is the matrix of transformation matrices
T = aTrafos;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
