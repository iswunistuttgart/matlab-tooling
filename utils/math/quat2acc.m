function alpha = quat2acc(q, q_dot, q_ddot)%#codegen
% QUAT2ACC Get angular acceleration from quaternion position, velocity, and
% acceleration
% 
%   ALPHA = QUAT2ACC(Q, Qdot, Qddot) gets the angular acceleration ALPHA from
%   the quaternion position Q, quaternion velocity Qdot, and quaternion
%   acceleration Qddot.
%
%
%   Inputs:
% 
%   Q: 4x1 vector of quaternion in vector notation with the real entry at the
%   first index.
%
%   Qdot: 4x1 vector of quaternion velocity.
%
%   Qddot: 4x1 vector of quaternion acceleration.
% 
%   Outputs:
% 
%   ALPHA: 3x1 angular acceleration
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-10
% Changelog:
%   2016-05-10
%       * Add help doc
%   2016-04-08
%       * Initial release



%% Calculation

% alpha = 2*quat2ratem(asrow(q_dot))*ascolumn(q_dot) + 2*quat2ratem(asrow(q))*ascolumn(q_ddot);
alpha = 2*quat2ratem(asrow(q_dot))*ascolumn(q_ddot);

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
