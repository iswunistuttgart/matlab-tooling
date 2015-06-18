function [length, varargout] = algoInverseKinematics_Simple(Pose, PulleyPositions, CableAttachments)
% ALGOINVERSEKINEMATICS_SIMPLE - Perform inverse kinematics for the given
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
%   LENGTH = ALGOINVERSEKINEMATICS_SIMPLE(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
% 
%   [LENGTH, CABLEVECTORS] = ALGOINVERSEKINEMATICS_SIMPLE(...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
% 
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_SIMPLE(...)
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
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleyes i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of pulleyes in PULLEYPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using either simple or advanced kinematics
%
%   CABLEVECTOR: Vectors of each cable from attachment point to corrected
%   pulley point given as 3xM matrix
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its corrected pulley point as 3xM matrix
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release



%% Initialize variables
% To unify variable names
aCableAttachments = CableAttachments;
aPulleyPositions = PulleyPositions;
nNumberOfWires = size(aPulleyPositions, 2);
% Holds the actual cable vector
aCableVector = zeros(3, nNumberOfWires);
% Holds the normalized cable vector
aCableVectorUnit = zeros(3, nNumberOfWires);
% Holds the cable lengths
vCableLength = zeros(1, nNumberOfWires);
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
aPlatformRotation = reshape(Pose(4:12), 3, 3).';



%% Do the magic
% Loop over every pulley and ...
for iUnit = 1:nNumberOfWires
    % ... calculate the cable vector
    aCableVector(:,iUnit) = aPulleyPositions(:,iUnit) - ( vPlatformPosition + aPlatformRotation*aCableAttachments(:,iUnit) );
    % ... calculate the cable length
    vCableLength(iUnit) = norm(aCableVector(:,iUnit));
    % ... calculate the direciton of the unit vector of the current cable
    aCableVectorUnit(:,iUnit) = aCableVector(:,iUnit)./vCableLength(iUnit);
end



%% Output parsing
% First output is the cable lengths
length = vCableLength;

% Further outputs as requested
% Second output is the matrix of cable vectors from b_i to a_i
if nargout > 1
    varargout{1} = aCableVector;
end

% Third output is the matrix of normalized cable vectors
if nargout > 2
    varargout{2} = aCableVectorUnit;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
