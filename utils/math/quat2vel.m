function omega = quat2vel(q, q_dot)%#codegen
% QUAT2VEL Converts the quaternion velocity vector to angular velocity vector
% 
%   OMEGA = QUAT2VEL(Q, Qdot) calculates the angular velocity vector OMEGA from
%   the quaternion position and velocity vectors Q and Qdot, respectively.
%
%   Inputs:
% 
%   Q               1x4 vector of quaternion in vector notation with the real
%       entry at the first index.
%
%   Qdot            1x4 vector of quaternion velocity.
% 
%   Outputs:
% 
%   OMEGA           3x1 vector of angular velocities.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-09
% Changelog:
%   2016-12-09
%       * Propagate rename of function `ascolumn` to `ascol`
%   2016-05-10
%       * Add help doc
%   2016-04-08
%       * Initial release



%% Magic
omega = 2*quat2ratem(asrow(q))*ascol(q_dot);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
