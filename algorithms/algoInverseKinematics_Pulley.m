function [Length, CableUnitVectors, PulleyAngles, CableShape, PulleyPositionCorrected] = algoInverseKinematics_Pulley(Pose, PulleyPositions, CableAttachments, PulleyRadius, PulleyOrientations)
%#codegen
% ALGOINVERSEKINEMATICS_PULLEY - Perform inverse kinematics for the given pose
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
%   LENGTH = ALGOINVERSEKINEMATICS_PULLEY(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to b_i
%   for the given pose
% 
%   [LENGTH, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_PULLEY(...) also provides
%   the the unit vectors for each cable which might come in handy at times
% 
%   [LENGTH, CABLEUNITVECTORS, PULLEYPOSITIONCORRECTED] =
%   ALGOINVERSEKINEMATICS_PULLEY(...) additionally returns the corrected pulley
%   positions.
% 
%   [LENGTH, CABLEUNITVECTORS, PULLEYPOSITIONCORRECTED, PULLEYANGLES] =
%   ALGOINVERSEKINEMATICS_PULLEY(...) returns the two angles gamma (in first
%   row) and beta (in second row) of the rotation of the pulley about its z-axis
%   and the wrap angle of the cable along the pulley
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
%   CABLESHAPE: Array of [2xKxM] points with the cable shape. First dimension is
%   the cable's local frame's x and z coordinate, second is the discretization
%   along the length of L with K-many steps, M is the number of cables
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-08-19
% Changelog:
%   2015-08-19
%       * Add support for code generation
%   2015-06-24:
%       * Fix incorrect help block
%       * Remove output value CABLEVECTOR
%       * Add output value CABLESHAPE
%   2015-06-18:
%       * Change doc code to align with 80 chars max line length
%       * Make code match PTT's coding convetions
%   2015-04-22:
%       * Initial release



%% Assertion for code generation
assert(isa(Pose, 'double') && size(Pose, 1) == 1 && size(Pose, 2) == 12);
assert(isa(PulleyPositions, 'double') && size(PulleyPositions, 1) <= 3 && size(PulleyPositions, 2) >= 1);
assert(isa(CableAttachments, 'double') && size(CableAttachments, 1) <= 3 && size(CableAttachments, 2) >= 1);
assert(isa(PulleyRadius, 'double') && size(PulleyRadius, 1) == 1 && size(PulleyRadius, 2) >= 1);
assert(isa(PulleyOrientations, 'double') && size(PulleyOrientations, 1) == 3 && size(PulleyOrientations, 2) >= 1);


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
vCableLength = zeros(1, nNumberOfCables);
% Holds offset to the cable lengths
vCableLengthOffset = zeros(1, nNumberOfCables);
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
aPlatformRotation = rotationRowToMatrix(Pose(4:12));
% Holds the rotation angle gamma and the wrapping angle beta
aPulleyAngles = zeros(2, nNumberOfCables);
% This will hold the return value of the cable shape
nDiscretizationPoints = 10e3;
aCableShape = zeros(2, nDiscretizationPoints, nNumberOfCables);



%% Do the magic
% Loop over every pulley and calculate the corrected pulley position i.e.,
% a_{i, corr}
for iUnit = 1:nNumberOfCables
    % Rotation matrix to rotate any vector given in pulley coordinate system
    % K_P into the global coordinate system K_O
    aRotation_kP2kO = rotz(aPulleyOrientations(3,iUnit))*roty(aPulleyOrientations(2,iUnit))*rotx(aPulleyOrientations(1,iUnit));

    % Vector from contact point of cable on pulley A to cable attachment point
    % on the platform B given in coordinates of system A
    v_A2B_in_kP = transpose(aRotation_kP2kO)*(vPlatformPosition + aPlatformRotation*aCableAttachments(:,iUnit) - aPulleyPositions(:,iUnit));

    % Determine the angle of rotation of the pulley to have the pulley's x-axis
    % point in the direction of the cable which points towards B
    dRotationAngleAbout_kAz_Degree = atan2d(v_A2B_in_kP(2), v_A2B_in_kP(1));
    aPulleyAngles(1,iUnit) = dRotationAngleAbout_kAz_Degree;

    % Rotation matrix from pulley coordinate system K_P to cable coordinate 
    % system K_C
    aRotation_kC2kP = rotz(dRotationAngleAbout_kAz_Degree);

    % Vector from point P (center of coordinate system K_P) to the cable
    % attachment point B given in the coordinate system of the pulley (easily
    % transferable from the same vector given in K_A by simply rotating it about
    % the local z-axis of K_A)
    v_A2B_in_kC = transpose(aRotation_kC2kP)*v_A2B_in_kP;

    % Vector from P to the pulley center given in the pulley coordinate system
    % K_P
    v_P2M_in_kC = vPulleyRadius(iUnit)*[1; 0; 0];

    % Closed vector loop to determine the vector from M to B in coordinate
    % system K_P: P2M + M2B = P2B. This basically also transforms our coordinate
    % system K_P to K_M
    v_M2B_in_kC = v_A2B_in_kC - v_P2M_in_kC;

    % Convert everything in to the coordinate system K_M of the
    % pulley's center
%     v_M2B_in_kM = v_M2B_in_kC;

    % Preliminarily determine the cable length (this helps us to determine the
    % angle beta_3 to later on determine the angle of the vector from M to C in
    % the coordinate system of M. It is quite simple to do so using Pythagoras:
    % l^2 + radius^2 = M2B^2
    dCableLength_C2B = sqrt(norm(v_M2B_in_kC)^2 - vPulleyRadius(iUnit)^2);

    % Determine the angle of rotation of that vector relative to the x-axis of
    % K_P. This is beta_2 in PTT's sketch
    dAngleBetween_M2B_and_xM_Degree = atan2d(v_M2B_in_kC(3), v_M2B_in_kC(1));

    % Now we can determine the angle between M2B and M2C using trigonometric
    % functions because cos(beta_3) = radius/M2B and as well sin(beta_3) = L/M2B
    % or tan(beta_3) = L/radius
    dAngleBetween_M2B_and_M2C_Degree = atand(dCableLength_C2B/vPulleyRadius(iUnit));

    % Angle between the x-axis of M and the vector from M to C given in
    % coordinate system K_M and in degree
    dAngleBetween_xM_and_M2C_Degree = dAngleBetween_M2B_and_M2C_Degree + dAngleBetween_M2B_and_xM_Degree;

    % Vector from pulley center M to adjusted cable release point C in nothing
    % but the x-axis rotated by the angle beta about the y-axis of K_M
    v_M2C_in_kC = transpose(roty(dAngleBetween_xM_and_M2C_Degree))*(vPulleyRadius(iUnit).*[1; 0; 0]);

    % Wrapping angle can be calculated in to ways, either by getting the angle
    % between the scaled negative x-axis (M to P) and the vector M to C, or by
    % getting the angle between the scaled positive x-axis and the vector M to C
    v_M2P_in_kM = vPulleyRadius(iUnit).*[-1; 0; 0];
    dAngleWrap_Degree = acosd(dot(v_M2P_in_kM, v_M2C_in_kC)/(norm(v_M2P_in_kM)*norm(v_M2C_in_kC)));
    aPulleyAngles(2,iUnit) = dAngleWrap_Degree;

    % Adjust the pulley position given the coordinates to point C
    aPulleyPositionsCorrected(:,iUnit) = aPulleyPositions(:,iUnit) + aRotation_kP2kO*(aRotation_kC2kP*(v_P2M_in_kC + v_M2C_in_kC));
    vCableLengthOffset(iUnit) = dAngleWrap_Degree*pi/180*vPulleyRadius(iUnit);
    
    % Finally, calculate the cable vector (from corrected pulley position to the
    % platform)
    aCableVector(:,iUnit) = aPulleyPositionsCorrected(:,iUnit) - ( vPlatformPosition + aPlatformRotation*aCableAttachments(:,iUnit) );
    % And its calculate the cable length
    vCableLength(iUnit) = norm(aCableVector(:,iUnit)) + vCableLengthOffset(iUnit);
    % Last but not least Calculate the direction of the unit vector of the
    % current cable
    aCableVectorUnit(:,iUnit) = aCableVector(:,iUnit)./vCableLength(iUnit);
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

% Fourth output is the cable shapes
if nargout >= 4
    %%% Perform the calculation of the cable shape only when necessary
    for iUnit = 1:nNumberOfCables
        % First, what's the ratio of cable on the pulley vs cable between pulley
        % and platform?
        dCableOnPulley = vCableLengthOffset(iUnit);
        dCableInWorkspace = norm(aCableVector(:,iUnit));
        dRatioPulleyToTotal = dCableOnPulley/vCableLength(iUnit);
        dRatioWorkspaceToTotal = dCableInWorkspace/vCableLength(iUnit);
        nDiscretizationPointsOnPulley = round(dRatioPulleyToTotal*nDiscretizationPoints);
        nDiscretizationPointsInWorkspace = round(dRatioWorkspaceToTotal*nDiscretizationPoints);

        % Create the linear spaces for the cable part on the pulley
        vLinspaceOfCableOnPulley = linspace(0, aPulleyAngles(2,iUnit)*pi/180, nDiscretizationPointsOnPulley);
        % and the part in the workspace
        vLinspaceOfCableInWorkspace = linspace(dCableOnPulley, dCableInWorkspace, nDiscretizationPointsInWorkspace + 1);

        % We need the position direction of the cable from the corrected pulley
        % point towards the 
        aRotation_kC2kP = rotz(aPulleyAngles(1,iUnit));
        aRotation_kP2kO = rotz(aPulleyOrientations(3,iUnit))*roty(aPulleyOrientations(2,iUnit))*rotx(aPulleyOrientations(1,iUnit));
        vAc2B_in_C = transpose(aRotation_kC2kP)*(transpose(aRotation_kP2kO)*(-aCableVector(:,iUnit)));
        vAc2B_in_C_normed = vAc2B_in_C./norm(vAc2B_in_C);

        % The shape of the cable on the pulley can be easily inferred from a
        % parametrization of a circle shifted along the x-axis by the radius of
        % the pulley
        aCableShape(:, 1:nDiscretizationPointsOnPulley, iUnit) = vPulleyRadius(iUnit).*[(1 - cos(vLinspaceOfCableOnPulley)); sin(vLinspaceOfCableOnPulley)];
        
        % The shape of the cable in the workspace is as easy as stretching the
        % normalized vector from A_c,i to B_i but offsetting it with the final
        % position on the pulley
        aCableShape(1, nDiscretizationPointsOnPulley:end, iUnit) = vPulleyRadius(iUnit).*(1-cosd(aPulleyAngles(2,iUnit))) + vAc2B_in_C_normed(1).*vLinspaceOfCableInWorkspace;
        aCableShape(2, nDiscretizationPointsOnPulley:end, iUnit) = vPulleyRadius(iUnit).*(sind(aPulleyAngles(2,iUnit))) +  vAc2B_in_C_normed(3).*vLinspaceOfCableInWorkspace;
    end
    
    CableShape = aCableShape;
end

% Fifth output is the corrected pulley angles
if nargout >= 5
    PulleyPositionCorrected = aPulleyPositionsCorrected;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
