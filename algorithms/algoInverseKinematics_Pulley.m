function [length, varargout] = algoInverseKinematics_Pulley(Pose, WinchPositions, CableAttachments, WinchPulleyRadius, WinchOrientations)
% ALGOINVERSEKINEMATICS_PULLEY - Perform inverse kinematics for the given
%   pose of the virtual robot
%   Inverse kinematics means to determine the values for the joint
%   variables (in this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration
%   (note that calculations will be done as if we were looking at a 3D/6DOF
%   cable robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, both the simple kinematic
%   loop can be used as well as the advanced pulley kinematics (considering
%   pulley radius and rotatability).
% 
%   LENGTH = ALGOINVERSEKINEMATICS_PULLEY(POSE, WINCHPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
% 
%   [LENGTH, CABLEVECTORS] = ALGOINVERSEKINEMATICS_PULLEY(...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
% 
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_PULLEY(...)
%   also provides the unit vectors for each cable which might come in handy
%   at times
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   WINCHPOSITIONS: Matrix of winch positions w.r.t. the world frame. Each
%   winch has its own column and the rows are the x, y, and z-value,
%   respectively i.e., WINCHPOSITIONS must be a matrix of 3xN values. The
%   number of winches i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of winch to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xN values. The number of cables
%   i.e., N, must match the number of winches in WINCHPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to winch.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xN with the cable lengths
%   determined using either simple or advanced kinematics
%
%   CABLEVECTOR: Vectors of each cable from attachment point to corrected
%   winch point
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its corrected winch point
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release

%------------- BEGIN CODE --------------

%%% Initialize variables
% To unify variable names
mCableAttachments = CableAttachments;
mWinchPositions = WinchPositions;
vWinchPulleyRadius = WinchPulleyRadius;
mWinchOrientations = WinchOrientations;
% Holds the actual cable vector
mCableVector = zeros(3, size(mWinchPositions, 2));
% Holds the normalized cable vector
mCableVectorUnit = zeros(3, size(mWinchPositions, 2));
% Holds the cable lengths
vCableLength = zeros(1, size(mWinchPositions, 2));
% Holds offset to the cable lengths
vCableLengthOffset = zeros(1, size(mWinchPositions, 2));
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
mPlatformRotation = reshape(Pose(4:12), 3, 3);

% Loop over every winch and calculate the corrected winch position i.e.,
% a_{i, corr}
for iUnit = 1:size(mWinchPositions, 2)
    % Rotation matrix to rotate any vector given in winch coordinate
    % system K_A into the global coordinate system K_O
    mRotation_kA2kO = rotz(mWinchOrientations(3, iUnit))*roty(mWinchOrientations(2, iUnit))*rotx(mWinchOrientations(1, iUnit));

    % Vector from contact point of cable on pulley A to cable
    % attachment point on the platform B given in coordinates of system
    % A
    v_A2B_in_kA = transpose(mRotation_kA2kO)*(vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit) - mWinchPositions(:, iUnit));

    % Determine the angle of rotation of the pulley to have the
    % pulley's x-axis point in the direction of the cable which points
    % towards B
    dRotationAngleAbout_kAz_Degree = atan2d(v_A2B_in_kA(2), v_A2B_in_kA(1));

    % Rotation matrix from pulley coordinate system K_P to winch
    % coordinate system K_A
    mRotation_kP2kA = rotz(dRotationAngleAbout_kAz_Degree);

    % Vector from point P (center of coordinate system K_P) to the
    % cable attachment point B given in the coordinate system of the
    % pulley (easily transferable from the same vector given in K_A by
    % simply rotating it about the local z-axis of K_A)
    v_A2B_in_kP = transpose(mRotation_kP2kA)*v_A2B_in_kA;
    v_P2B_in_kP = v_A2B_in_kP;

    % Vector from P to the pulley center given in the pulley coordinate
    % system K_P
    v_P2M_in_kP = vWinchPulleyRadius(iUnit)*[1; 0; 0];

    % Closed vector loop to determine the vector from M to B in
    % coordinate system K_P: P2M + M2B = P2B. This basically also
    % transforms our coordinate system K_P to K_M
    v_M2B_in_kP = v_P2B_in_kP - v_P2M_in_kP;

    % Convert everything in to the coordinate system K_M of the
    % pulley's center
    v_M2B_in_kM = v_M2B_in_kP;

    % Preliminarily determine the cable length (this helps us to
    % determine the angle beta_3 to later on determine the angle of the
    % vector from M to C in the coordinate system of M. It is quite
    % simple to do so using Pythagoras: l^2 + radius^2 = M2B^2
    dCableLength_C2B = sqrt(norm(v_M2B_in_kM)^2 - vWinchPulleyRadius(iUnit)^2);

    % Determine the angle of rotation of that vector relative to the
    % x-axis of K_P. This is beta_2 in PTT's sketch
    dAngleBetween_M2B_and_xM_Degree = atan2d(v_M2B_in_kP(3), v_M2B_in_kP(1));

    % Now we can determine the angle between M2B and M2C using
    % trigonometric functions because cos(beta_3) = radius/M2B and as
    % well sin(beta_3) = L/M2B or tan(beta_3) = L/radius
    dAngleBetween_M2B_and_M2C_Degree = atand(dCableLength_C2B/vWinchPulleyRadius(iUnit));

    % Angle between the x-axis of M and the vector from M to C given in
    % coordinate system K_M and in degree
    dAngleBetween_xM_and_M2C_Degree = dAngleBetween_M2B_and_M2C_Degree + dAngleBetween_M2B_and_xM_Degree;

    % Vector from winch center M to adjusted cable release point C in
    % system K_M is nothing but the scaled x-axis rotated about the
    % y-axis with previsouly determined angle beta2
    mRotation_kC2kM = roty(dAngleBetween_xM_and_M2C_Degree);
    v_M2C_in_kM = transpose(mRotation_kC2kM)*(vWinchPulleyRadius(iUnit).*[1; 0; 0]);

    % Wrapping angle can be calculated in to ways, either by getting
    % the angle between the scaled negative x-axis (M to P) and the
    % vector M to C, or by getting the angle between the scaled
    % positive x-axis and the vector M to C
    v_M2P_in_kM = vWinchPulleyRadius(iUnit).*[-1; 0; 0];
    dAngleWrap_Degree = acosd(dot(v_M2P_in_kM, v_M2C_in_kM)/(norm(v_M2P_in_kM)*norm(v_M2C_in_kM)));

    % Adjust the winch position given the coordinates to point C
    mWinchPositions(:, iUnit) = mWinchPositions(:, iUnit) + mRotation_kA2kO*(mRotation_kP2kA*(v_P2M_in_kP + v_M2C_in_kM));
    vCableLengthOffset(iUnit) = degtorad(dAngleWrap_Degree)*vWinchPulleyRadius(iUnit);
    
    % ... calculate the cable vector
    mCableVector(:, iUnit) = mWinchPositions(:, iUnit) - ( vPlatformPosition + mPlatformRotation*mCableAttachments(:, iUnit) );
    % ... calculate the cable length
    vCableLength(iUnit) = norm(mCableVector(:, iUnit)) + vCableLengthOffset(iUnit);
    % ... calculate the direciton of the unit vector of the current cable
    mCableVectorUnit(:, iUnit) = mCableVector(:, iUnit)./vCableLength(iUnit);
end


%%% Output parsing
% First output is the cable lengths
length = vCableLength;

% Further outputs as requested
if nargout
    % Second output is the matrix of cable vectors from b_i to a_i
    if nargout > 1
        varargout{1} = mCableVector;
    end
    
    % Third output is the matrix of normalized cable vectors
    if nargout > 2
        varargout{2} = mCableVectorUnit;
    end
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
