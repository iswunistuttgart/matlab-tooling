function [Length, CableUnitVectors, PulleyAngles, PulleyPositionCorrected] = algoInverseKinematics_PulleyClosedForm(Pose, PulleyPositions, CableAttachments, PulleyRadius, PulleyOrientations)%#codegen
% ALGOINVERSEKINEMATICS_PULLEYCLOSEDFORM Determine cable lengths based on pulley
% kinematics
%   
%   Inverse kinematics means to determine the values for the joint variables (in
%   this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because only
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration (note
%   that calculations will be done as if we were looking at a 3D/6DOF cable
%   robot following necessary conventions, so adjust your variables
%   accordingly).To determine the cable lengths, both the simple kinematic loop
%   can be used as well as the advanced pulley kinematics (considering pulley
%   radius and rotatability).
% 
%   LENGTH = ALGOINVERSEKINEMATICS_PULLEYCLOSEDFORM(POSE, PULLEYPOSITIONS,
%   CABLEATTACHMENTS, PYLLEYRADIUS, PULLEYORIENTATIONS) performs pulley-based
%   inverse kinematics with the cables running from a_i to b_i for the given pose.
% 
%   [LENGTH, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_PULLEYCLOSEDFORM(...)
%   also provides the unit vectors for each cable which might come in handy at
%   times.
% 
%   [LENGTH, CABLEUNITVECTORS, PULLEYANGLES] = 
%   ALGOINVERSEKINEMATICS_PULLEYCLOSEDFORM(...) returns the two angles gamma (in
%   first row) and beta (in second row) of the rotation of the pulley about its
%   z-axis and the wrap angle of the cable along the pulley.
% 
%   [LENGTH, CABLEUNITVECTORS, PULLEYANGLES, PULLEYPOSITIONCORRECTED] =
%   ALGOINVERSEKINEMATICS_PULLEYCLOSEDFORM(...) additionally returns the
%   corrected pulley positions.
%   
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has the
%   [x, y, z] position in the first three entries and then follwing are the
%   entries of the rotation matrix such that the vector POSE looks something
%   like
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value, respective
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The numbe
%   number of pulleys i.e., N, must match the number of cable attachment points
%   in CABLEATTACHMENTS (i.e., its column count) and the order must match the
%   real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the platform's
%   coordinate system. Each attachment point has its own column and the rows are
%   the x, y, and z-value, respectively, i.e., CABLEATTACHMENTS must be a matrix
%   of 3xM values. The number of cables i.e., N, must match the number of
%   pulleys in PULLEYPOSITIONS (i.e., its column count) and the order must
%   match the real linkage of cable attachment on the platform to pulley.
%
%   PULLEYRADIUS: 1xM matrix of pulley radius for each pulley.
%
%   PULLEYORIENTATIONS: 3xM matrix of orientations of the pulley wrt the
%   inertial reference frame. The transformation will be done using Tait-Bryan
%   XYZ angles in the ZYX convention of ABC (first A about X, then B about Y,
%   finally C about Z).
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths determined
%   using either simple, pulley, catenary, or catenary+pulley kinematics
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point to
%   its corrected pulley point as 3xM matrix
%   
%   PULLEYPOSITIONCORRECTED: Matrix of 3xM corrected pulley positions i.e., the
%   point where the cable leaves the pulley and goes to the platform
%   
%   PULLEYANGLES: Matrix of gamma and beta angles of rotation and wrapping angle
%   of pulley and cable on pulley, respectively, given as 2xM matrix where the
%   first row is the rotation about the z-axis of the pulley, and the second
%   row is the wrapping angle about the pulley.
%
%   SEE: EUL2ROTM
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-01
% Changelog:
%   2016-05-01
%       * Update to using EUL2ROTM(eul, 'ZYX') instead of custom-built rotation
%       matrix generation function
%       * Add check to cancel out numeric issues in determination of rotation
%       matrices such that R(abs(R) < 2*eps) = 0
%   2016-04-18
%       * Initial release



%% Assertion for code generation
% Assert pose
assert(isa(Pose, 'double'));
assert(numel(Pose) == 12);
assert(any(1 == size(Pose)));
% Assert PulleyPositions
assert(isa(PulleyPositions, 'double'));
assert(size(PulleyPositions, 1) == 3);
assert(size(PulleyPositions, 2) == size(CableAttachments, 2));
% Assert CableAttachments
assert(isa(CableAttachments, 'double'));
assert(size(CableAttachments, 1) == 3);
assert(size(CableAttachments, 2) == size(PulleyPositions, 2));
% Assert PulleyRadius
assert(isa(PulleyRadius, 'double'));
assert(isvector(PulleyRadius));
assert(numel(PulleyRadius) == size(PulleyPositions, 2));
% Assert PulleyOrientations
assert(isa(PulleyOrientations, 'double'));
assert(size(PulleyOrientations, 1) == 3);
assert(size(PulleyOrientations, 2) == size(PulleyPositions, 2));



%% Initialize variables
% To unify variable names
aCableAttachments = CableAttachments;
aPulleyPositions = PulleyPositions;
aPulleyPositionsCorrected = aPulleyPositions;
vPulleyRadius = PulleyRadius;
aPulleyOrientations = PulleyOrientations;
% Get the number of wires
nNumberOfCables = size(aPulleyPositions, 2);
% Holds the actual cable vector
aCableVector = zeros(3, nNumberOfCables);
% Holds the normalized cable vector
aCableVectorUnit = zeros(3, nNumberOfCables);
% Holds the cable lengths
vCableLength = zeros(nNumberOfCables, 1);
% Holds offset to the cable lengths
vCableLengthOffset = zeros(1, nNumberOfCables);
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
aPlatformRotation = rotrow2m(Pose(4:12));
% Holds the rotation angle gamma and the wrapping angle beta
aPulleyAngles = zeros(2, nNumberOfCables);



%% Do the magic
% Loop over every pulley and calculate the corrected pulley position i.e.,
% a_{i, corr}
for iUnit = 1:nNumberOfCables
    % Rotation matrix to rotate any vector given in pulley coordinate system
    % K_P into the global coordinate system K_O
    vEuler = fliplr(asrow(aPulleyOrientations(:,iUnit)))./180.*pi;
    aRotation_kW2kO = eul2rotm(vEuler, 'ZYX');
    aRotation_kW2kO(abs(aRotation_kW2kO) < 2*eps) = 0;

    % Vector from contact point of cable on pulley A to cable attachment point
    % on the platform B given in coordinates of system A
    v_W2B_in_kW = transpose(aRotation_kW2kO)*(vPlatformPosition + aPlatformRotation*aCableAttachments(:,iUnit) - aPulleyPositions(:,iUnit));

    % Determine the angle of rotation of the pulley to have the pulley's x-axis
    % point in the direction of the cable which points towards B
    aPulleyAngles(1,iUnit) = atan2d(v_W2B_in_kW(2), v_W2B_in_kW(1));

    % Rotation matrix from winch coordinate system K_W to roller coordinate 
    % system K_R
    aRotation_kR2kW = rotz(aPulleyAngles(1,iUnit));
    aRotation_kR2kW(abs(aRotation_kR2kW) < 2*eps) = 0;

    % Vector from point P (center of coordinate system K_R) to the cable
    % attachment point B given in the coordinate system of the pulley (easily
    % transferable from the same vector given in K_W by simply rotating it about
    % the local z-axis of K_W)
    v_W2B_in_kR = transpose(aRotation_kR2kW)*v_W2B_in_kW;

    % Vector from W to the pulley center given in the pulley coordinate system
    % K_P
    v_W2M_in_kR = vPulleyRadius(iUnit)*[1; 0; 0];

    % Closed vector loop to determine the vector from M to B in coordinate
    % system K_P: P2M + M2B = P2B. This basically also transforms our coordinate
    % system K_P to K_M
    v_M2B_in_kR = v_W2B_in_kR - v_W2M_in_kR;

    % Preliminarily determine the cable length (this helps us to determine the
    % angle beta_3 to later on determine the angle of the vector from M to C in
    % the coordinate system of M. It is quite simple to do so using Pythagoras:
    % l^2 + radius^2 = M2B^2
    dCableLength_C2B = sqrt(norm(v_M2B_in_kR)^2 - vPulleyRadius(iUnit)^2);
    dScalingTangentVector = -dCableLength_C2B;
    
    % Angle between the x-axis of K_M/K_R and the corrected cable attachment
    % point can be easily inferred from solving the algebraic equation given in
    % PTT's lab notebook
    dAngleBetween_xM_and_M2Ac_Degree = 180 + atan2d(dScalingTangentVector*v_M2B_in_kR(1) - vPulleyRadius(iUnit)*v_M2B_in_kR(3), -vPulleyRadius(iUnit)*v_M2B_in_kR(1) - dScalingTangentVector*v_M2B_in_kR(3));

    % Vector from pulley center M to adjusted cable release point Ac in nothing
    % but the x-axis rotated by the angle beta about the y-axis of K_M
    v_M2Ac_in_kR = transpose(roty(dAngleBetween_xM_and_M2Ac_Degree))*(vPulleyRadius(iUnit).*[1; 0; 0]);

    % Wrapping angle is nothing but the negativeof the angle between xM and M2Ac
    % (it has to be the negative because we are doing all above calculations in
    % 3D where a positive rotation about the y-axis 
    dAngleWrap_Degree = 180 - dAngleBetween_xM_and_M2Ac_Degree;
    aPulleyAngles(2,iUnit) = dAngleWrap_Degree;

    % Adjust the pulley position given the coordinates to point C
    aPulleyPositionsCorrected(:,iUnit) = aPulleyPositions(:,iUnit) + aRotation_kW2kO*(aRotation_kR2kW*(v_W2M_in_kR + v_M2Ac_in_kR));
    vCableLengthOffset(iUnit) = dAngleWrap_Degree*pi/180*vPulleyRadius(iUnit);
    
    % Finally, calculate the cable vector (from corrected pulley position to the
    % platform)
    aCableVector(:,iUnit) = aPulleyPositionsCorrected(:,iUnit) - ( vPlatformPosition + aPlatformRotation*aCableAttachments(:,iUnit) );
    % And its calculate the cable length
    vCableLength(iUnit) = norm(aCableVector(:,iUnit)) + vCableLengthOffset(iUnit);
    % Last but not least Calculate the direction of the unit vector of the
    % current cable
    aCableVectorUnit(:,iUnit) = aCableVector(:,iUnit)./norm(aCableVector(:,iUnit));
end



%% Output parsing
% First output is the cable lengths
Length = vCableLength;

%%% Further outputs as requested
% Second output is the matrix of normalized cable vectors
if nargout >= 2
    CableUnitVectors = aCableVectorUnit;
end

% Third output is the corrected pulley anchor points
if nargout >= 3
    PulleyAngles = aPulleyAngles;
end

% Fifth output is the corrected pulley angles
if nargout >= 4
    PulleyPositionCorrected = aPulleyPositionsCorrected;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
