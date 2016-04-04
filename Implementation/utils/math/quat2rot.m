function R = quat2rot(q)%#codegen
% QUAT2ROT Gives rotation matrix R for quaternion Q
% 
%   R = QUAT2ROT(Q) determines the uniquely defined rotation matrix R for
%   quaternions Q
%   
%   Inputs:
%   
%   Q: Nx4 matrix of quaternions to translate into rotation matrices.
%
%   Outputs:
%
%   R: 3x3xN matrix of rotation matrices for each quaternion provided
%
%   See also: QUAT2ROTM
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-04-04
% Changelog:
%   2016-04-04
%       * Initial release



%% Assertion
% Input must be of type double or symbolic
assert(isa(q, 'double') || isa(q, 'sym'), 'Input must be of type double or symbolic');
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
tempR = cat(1, 1 - 2*(qy.^2 + qz.^2),   2*(qx.*qy - qw.*qz),   2*(qx.*qz + qw.*qy),...
2*(qx.*qy + qw.*qz), 1 - 2*(qx.^2 + qz.^2),   2*(qy.*qz - qw.*qx),...
2*(qx.*qz - qw.*qy),   2*(qy.*qz + qw.*qx), 1 - 2*(qx.^2 + qy.^2) );

% Reshape the matrix to its proper dimensions
aRots = reshape(tempR, [3, 3, nQuaternions]);
% Restore correct order of dimensions
aRots = permute(aRots, [2, 1, 3]);



%% Assign outputs
% Only output is the (matrix of) rotation matrix
R = aRots;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
