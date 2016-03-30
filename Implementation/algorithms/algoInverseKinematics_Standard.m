function [Length, CableUnitVectors, PulleyAngles] = algoInverseKinematics_Standard(Pose, PulleyPositions, CableAttachments)%#codegen
% ALGOINVERSEKINEMATICS_STANDARD Determine cable lengths based on standard
% kinematics
%   
%   Inverse kinematics means to determine the values for the joint variables (in
%   this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because the
%   equation for the kinematic loop has to be solved, which is the sole purpose
%   of this method.
%   It can determine the cable lengths for any given robot configuration (note
%   that calculations will be done as if we were looking at a 3D/6DOF cable
%   robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, both the standard kinematic
%   loop can be used as well as the advanced pulley kinematics (considering
%   pulley radius and rotatability).
% 
%   LENGTH = ALGOINVERSEKINEMATICS_STANDARD(POSE, PULLEYPOSITIONS,
%   CABLEATTACHMENTS) performs standard inverse kinematics with the cables
%   running from a_i to b_i for the given pose
% 
%   [LENGTH, CABLEUNITVECTOR] = ALGOINVERSEKINEMATICS_STANDARD(...) also
%   provides the unit vectors for each cable which might come in handy at times
%   because it provides the direction of the force impinged by the cable on the
%   mobile platform.
% 
%   [LENGTH, CABLEUNITVECTOR, PULLEYANGLES] = ALGOINVERSEKINEMATICS_STANDARD(...)
%   additionally returns the angle of rotation that the cable local frame has
%   relative to the world frame's z_0
%   
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleys i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of pulleys in PULLEYPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using standard kinematics
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its corrected pulley point as 3xM matrix
%   
%   PULLEYANGLES: Vector of gamma angles of rotation of the cable plane relative
%   to the world frame, given as 1xM vector where the column is the respective
%   pulley
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-29
% Changelog:
%   2016-03-29
%       * Code cleanup
%       * Vectorize code to provide a slightly improved execution time (down by
%       0.001s)
%   2015-08-31
%       * Remove code for shape generation and put into a separate function
%       called algoCableShape_Standard
%   2015-08-19
%       * Add support for code generation
%   2015-06-24
%       * Add return value CABLESHAPE and remove CABLEVECTOR
%       * Add return value PULLEYANGLES
%   2015-04-22
%       * Initial release



%% Assertion for code generation
% Assert Pose
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



%% Initialize variables
% To unify variable names
aCableAttachments = CableAttachments;
aPulleyPositions = PulleyPositions;
nNumberOfCables = size(aPulleyPositions, 2);
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
aPlatformRotation = rotationRowToMatrix(Pose(4:12));
% Hold the local rotation angles of each cable's local frame relative to K_0
aPulleyAngles = zeros(1, nNumberOfCables);



%% Do the magic with vectorized code
% Get the matrix of all cable vectors
aCableVector = aPulleyPositions - (repmat(vPlatformPosition, 1, nNumberOfCables) + aPlatformRotation*aCableAttachments);

% Get the cable lengths (note, ```norm``` doesn't work here because that would
% take the norm of the matrix, however, we want the norm of each column thus
% we're using sqrt(sum(col.^2))
vCableLength = sqrt(sum(aCableVector.^2));

% Get the unit vectors of each cable (note this is the matrix of cable vectors
% divided per element by the corresponding length i.e., the first column of the
% divisor is only the first cable's length
aCableVectorUnit = aCableVector./repmat(vCableLength, 3, 1);

% Calculate the angle of rotation of the cable local frame K_c relative to K_0
% for all cables at once
aPulleyAngles(1,:) = atan2d(-aCableVector(2,:), -aCableVector(1,:));



%% Output parsing
% First output is the cable lengths
Length = vCableLength;

% Further outputs as requested
% Second output is the matrix of normalized cable vectors
if nargout > 1
    CableUnitVectors = aCableVectorUnit;
end

% Third output is the rotation angle of each cable plane
if nargout > 2
    PulleyAngles = aPulleyAngles;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
