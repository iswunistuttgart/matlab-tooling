function [R] = quat2rotm(q)
% QUAT2ROTM converts quaternions to rotation matrices
%
%   R = QUAT2ROTM(Q) converts a unit quaternion, Q, into an orthonormal rotation
%   matrix, R. The input, Q, is an N-by-4 matrix containing N quaternions. Each
%   quaternion represents a 3D rotation and is of the form q = [w x y z], with a
%   scalar number as the first value. Each element of Q must be a real number.
%   The output, R, is an 3-by-3-by-N matrix containing N rotation matrices.
%
%   Inputs:
%
%   Q               Nx4 matrix of N quaternions. Each quaternion represents a 3D
%       rotation in form q = [w, x, y, z], with the scalar given as the first
%       value w.
%
%   Outputs:
%
%   R               3x3xN matrix containing N rotation matrices



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-10-23
% Changelog:
%   2016-10-23
%       * Initial release



%% Do your code magic here

% Normalize and transpose the quaternions
q = tramspose(mnormrow(q));

% Reshape the quaternions in the depth dimension
q2 = reshape(q, [4 1 size(q, 2)]);

s = q2(1,1,:);
x = q2(2,1,:);
y = q2(3,1,:);
z = q2(4,1,:);

% Explicitly define concatenation dimension for codegen
tempR = cat(1, 1 - 2*(y.^2 + z.^2),     2*(x.*y - s.*z),        2*(x.*z + s.*y), ...
                2*(x.*y + s.*z),        1 - 2*(x.^2 + z.^2),    2*(y.*z - s.*x), ...
                2*(x.*z - s.*y),        2*(y.*z + s.*x),        1 - 2*(x.^2 + y.^2) ...
);

R = reshape(tempR, [3, 3, length(s)]);
R = permute(R, [2, 1, 3]);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
