function [StructureMatrix, NullSpace] = algoStructureMatrix_3R3T(CableAttachments, CableVectors, Rotation)%#codegen
% ALGOSTRUCTUREMATRIX_3R3T - Calculate the structure matrix for the given cable
%   attachment points and cable vectors of a 3R3T cable robot
% 
%   STRUCTUREMATRIX = ALGOSTRUCTUREMATRIX_3R3T(CABLEATTACHMENTS, CABLEVECTORS)
%   determines the structure matrix for the given cable attachment points
%   and the given cable vectors. Cable vectors can but must not be a matrix
%   of normalized vectors.
%
%   STRUCTUREMATRIX = ALGOSTRUCTUREMATRIX_3R3T(CABLEATTACHMENTS, CABLEVECTORS,
%   ROTATION) assumes the given rotation for the platform.
%
%   [STRUCTUREMATRIX, NULLSPACE] = ALGOSTRUCTUREMATRIX_3R3T(...) also returns
%   the nullspace of structure matrix STRUCTUREMATRIX.
%   
%   Inputs:
%   
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of winches in WINCHPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to winch.
%   
%   CABLEVECTORS: Matrix of cable direction vectors from CABLEATTACHMENTS
%   to the winch attachment point. Must not be a matrix of normalized
%   values, however, must be a 3xM matrix of coordinates [x, y, z]'
%
%   ROTATION: Current rotation of the platform. Can be a 1x3 vector representing
%   Tait-Bryan Euler angles ZYX (yaw = z, pitch = y, roll = x) rotation. May
%   also directly be a rotation matrix of size 3x3. If not provided,
%   unit-rotation will be assumed
% 
%   Outputs:
% 
%   STRUCTUREMATRIX: Structure matrix At for the given attachment points
%   given the cable vectors. At is of size 6xM
%
%   NULLSPACE: The corresponding nullspace to structure matrix At
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-05-01
% Changelog:
%   2016-05-02
%       * Add ability to let rotation be given as Tait-Bryan Euler Angles ZYX
%       * Update help with parameter Rotation
%   2016-03-30
%       * Add output parameter NULLSPACE
%   2016-03-29
%       * Code cleanup
%   2015-08-19
%       * Add support for code generation
%   2015-06-25
%       * Make this function only return the structure matrix for a 3R3T cable
%       robot
%   2015-06-13
%       * Add optional argument for the current rotation to method
%   2015-04-22
%       * Initial release



%% Default arguments
if nargin < 3
    Rotation = eye(3);
end



%% Assertion for code generation
% Assert CableAttachments: Double. 3 Rows. As many columns as CableVectors.
assert(isa(CableAttachments, 'double'));
assert(size(CableAttachments, 1) == 3);
assert(size(CableAttachments, 2) == size(CableVectors, 2));
% Assert CableVectors: Double. 3 Rows. As many columns as CableAttachments.
assert(isa(CableVectors, 'double'));
assert(size(CableVectors, 1) == 3);
assert(size(CableVectors, 2) == size(CableAttachments, 2));
% Assert Rotation: Double. Vector of 3, 4, or 12 elements or matrix of 9 elements.
assert(isa(Rotation, 'double'));
assert(isvector(Rotation) && any(numel(Rotation) == [3, 4, 12]) || ~isvector(Rotation) && ismatrix(Rotation) && issquare(Rotation, 3));



%% Parse Variables
% Get number of wires
nNumberOfWires = size(CableAttachments, 2);
% Create the structure matrix's matrix
aStructureMatrix = zeros(6, nNumberOfWires);
% Keeping variable names consistent
aCableVectors = CableVectors;
aCableAttachments = CableAttachments;
% Extract rotation given in Euler angles from Pose
if numel(Rotation) == 3
    aRotation = eul2rotm(fliplr(asrow(Rotation./180*pi)), 'ZYX');
% Extract rotation given as Quaternion from Posae
elseif numel(Rotation) == 4
    aRotation = quat2rotm(quatnormalize(asrow(Rotation)));
% Extract rotation given as row'ed Rotation matrix from Pose
elseif numel(Rotation) == 12
    aRotation = rotrow2m(Rotation);
else
    aRotation = Rotation;
end
% Nullspace is an Mx2 matrix;
NullSpace = zeros(nNumberOfWires, nNumberOfWires - 6);



%% Create the structure matrix
% Loop over the wires being placed into the columns of A'
for iUnit = 1:nNumberOfWires
    % Ensure the cable vector is normalized
    if norm(aCableVectors(:,iUnit)) ~= 1
        aCableVectors(:,iUnit) = aCableVectors(:,iUnit)./norm(aCableVectors(:,iUnit));
    end
    
    % Each column of A' is [u; cross((R*b), u)]';
    aStructureMatrix(1:3,iUnit) = aCableVectors(:,iUnit);
    aStructureMatrix(4:6,iUnit) = cross(aRotation*aCableAttachments(:,iUnit), aCableVectors(:,iUnit));
end



%% Assign output quantities
% First output: structure matrix; required
StructureMatrix = aStructureMatrix;

% Second output: nullspace of structure matrix; optional
if nargout > 1
    NullSpace = null(StructureMatrix);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
